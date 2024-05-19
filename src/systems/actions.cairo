use starknet::{ContractAddress};
use mancala::models::{mancala_game::{MancalaGame}};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use mancala::models::player::{GamePlayer, GamePlayerTrait};

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(player_1: ContractAddress, player_2: ContractAddress) -> MancalaGame;
    fn move(game_id: u128, selected_pit: u8);
    fn get_score(game_id: u128) -> (u8, u8);
    fn is_game_finished(game_id: u128) -> bool;
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
            let mancala_game: MancalaGame = MancalaGameTrait::new(game_id.game_id, player_1, player_2);
            set!(world, (p_one, p_two, mancala_game));
            set!(world, (GameId{world_id: curr_world_id, game_id: game_id.game_id + 1}));
            mancala_game
        }

        fn move(world: IWorldDispatcher, game_id: u128, selected_pit: u8) {
            // world.foo();
            let mut mancala_game: MancalaGame = get!(world, game_id, (MancalaGame));
            let player: ContractAddress = get_caller_address();
            
            mancala_game.validate_move(player, selected_pit);
            let (mut current_player, mut oponent) = mancala_game.get_players(world);
            // Get stones from the selected pit and validate it's not empty
            let mut stones = mancala_game.get_stones(current_player, selected_pit);
            if stones == 0 {
                panic!("Selected pit is empty. Choose another pit.");
            }
            mancala_game.clear_pit(ref current_player, selected_pit);
            mancala_game.distribute_stones(ref current_player, ref oponent, ref stones, selected_pit);

            set!(world, (mancala_game, current_player, oponent));
        }

        fn get_score(world: IWorldDispatcher, game_id: u128) -> (u8, u8){
            let mut mancala_game: MancalaGame = get!(world, game_id, (MancalaGame));
            let player_one: GamePlayer = get!(world, (mancala_game.player_one, mancala_game.game_id), (GamePlayer));
            let player_two: GamePlayer = get!(world, (mancala_game.player_two, mancala_game.game_id), (GamePlayer));
            mancala_game.get_score(player_one, player_two)
        }

        fn is_game_finished(world: IWorldDispatcher, game_id: u128) -> bool{
            let mut mancala_game: MancalaGame = get!(world, game_id, (MancalaGame));
            let player_one: GamePlayer = get!(world, (mancala_game.player_one, mancala_game.game_id), (GamePlayer));
            let player_two: GamePlayer = get!(world, (mancala_game.player_two, mancala_game.game_id), (GamePlayer));
            mancala_game.is_game_finished(player_one, player_two)
        }
        
    }
}
