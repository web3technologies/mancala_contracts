use starknet::{ContractAddress};
use mancala::models::{mancala_game::{MancalaGame}};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use mancala::models::player::{GamePlayer, GamePlayerTrait};

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(player_1: ContractAddress, player_2: ContractAddress) -> MancalaGame;
    fn move(game_id: u128, selected_pit: u8) -> bool;
}

// dojo decorator
#[dojo::contract]
mod actions {

    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use starknet::contract_address::ContractAddressZeroable;
    use mancala::models::{mancala_game::{MancalaGame, MancalaGameTrait, GameId}};
    use mancala::models::{player::{GamePlayer, GamePlayerTrait}};
    use core::array::Array;

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {

        fn create_game(world: IWorldDispatcher, player_1: ContractAddress, player_2: ContractAddress) -> MancalaGame{
            let curr_world_id = world.uuid();
            let game_id: GameId = get!(world, curr_world_id, (GameId));
            let p_one = GamePlayerTrait::new(game_id.game_id, player_1);
            let p_two = GamePlayerTrait::new(game_id.game_id, player_2);

            println!("what about here: {}", p_one.pit1);

            let mancala_game: MancalaGame = MancalaGameTrait::new(game_id.game_id, player_1, player_2);
            println!("wait a minute");
            set!(world, (p_one, p_two, mancala_game));

            set!(world, (GameId{world_id: curr_world_id, game_id: game_id.game_id + 1}));
            
            let test_player: GamePlayer = get!(world, (player_1, game_id.game_id), (GamePlayer));
            println!("test player here: {}", test_player.pit1);
            println!("game_id: {}", test_player.game_id);
            mancala_game
        }

        fn move(world: IWorldDispatcher, game_id: u128, selected_pit: u8) -> bool {
            // world.foo();
            let mut mancala_game: MancalaGame = get!(world, game_id, (MancalaGame));
            let player: ContractAddress = get_caller_address();
            
            mancala_game.validate_move(player, selected_pit);
            let (mut current_player, mut other_player) = mancala_game.get_players(world);
            // Get stones from the selected pit and validate it's not empty
            let mut stones = mancala_game.get_stones(current_player, selected_pit);
            if stones == 0 {
                panic!("Selected pit is empty. Choose another pit.");
            }
            mancala_game.clear_pit(ref current_player, selected_pit);
            mancala_game.distribute_stones(ref current_player, ref stones, selected_pit);
            // todo implement
            mancala_game.capture();
            // todo implement
            mancala_game.switch_player();

            let is_game_finished:bool = mancala_game.is_game_finished();

            set!(world, (mancala_game, current_player, other_player));
            is_game_finished
        }
        
    }
}
