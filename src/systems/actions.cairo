use starknet::{ContractAddress};
use mancala::models::{mancala_game::{MancalaGame}};

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(player_1: ContractAddress, player_2: ContractAddress) -> MancalaGame;
    fn move(game_id: u128, selected_pit: u32) -> bool;
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use starknet::contract_address::ContractAddressZeroable;
    use mancala::models::{mancala_game::{MancalaGame, MancalaGameTrait, GameId}};
    use core::array::Array;

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn create_game(world: IWorldDispatcher, player_1: ContractAddress, player_2: ContractAddress) -> MancalaGame{
            
            // is caller owner of januarys nft

            
            
            let player: felt252 = get_caller_address().into();
            let player_1_str: felt252 = player_1.into();
            let player_2_str: felt252 = player_2.into();
            println!("Caller: {}", player);
            println!("Player1: {}", player_1_str);
            println!("Player2: {}", player_2_str);


            let curr_world_id = world.uuid();
            let game_id: GameId = get!(world, curr_world_id, (GameId));
            let game: MancalaGame = MancalaGame {
                game_id: game_id.game_id,
                player_one: player_1,
                player_two: player_2,
                winner: ContractAddressZeroable::zero(),
                current_player: player_1,
                score: 0,
                is_finished: false,
                p1_pit1: 4,
                p1_pit2: 4,
                p1_pit3: 4,
                p1_pit4: 4,
                p1_pit5: 4,
                p1_pit6: 4,
                p2_pit1: 4,
                p2_pit2: 4,
                p2_pit3: 4,
                p2_pit4: 4,
                p2_pit5: 4,
                p2_pit6: 4,
                p1_store: 0,
                p2_store: 0
            };
            set!(world,(game));
            set!(world, (GameId{world_id: curr_world_id, game_id: game_id.game_id + 1}));
            game
        }

        fn move(world: IWorldDispatcher, game_id: u128, selected_pit: u32) -> bool {
            let mut game: MancalaGame = get!(world, game_id, (MancalaGame));
            let player: ContractAddress = get_caller_address();
            let current_player: ContractAddress = game.current_player;
        
            let current_player_str: felt252 = player.into();
            
            println!("current player addres {}", current_player_str);

            if player != current_player {
                panic!("You are not the current player");
            }
        
            if selected_pit < 1 || selected_pit > 6 {
                panic!("Invalid pit, choose between 0 and 5");
            }
        
            // Get stones from the selected pit and validate it's not empty
            let mut stones = game.get_stones(selected_pit);
            if stones == 0 {
                panic!("Selected pit is empty. Choose another pit.");
            }
            // Clear the selected pit
            game.clear_pit(selected_pit);
            // Distribute stones
            game.distribute_stones(ref stones, selected_pit);
        
            // Update the game state
            set!(world, (game));
        
            // Switch players, or manage additional game logic here
            true
        }
        
    }
}
