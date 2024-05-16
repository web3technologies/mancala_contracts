use starknet::{ContractAddress};
use mancala::models::{game::{Game}};

// define the interface
#[dojo::interface]
trait IActions {
    fn create_game(player_1: ContractAddress, player_2: ContractAddress) -> Game;
    fn move(game_id: u32, selected_pit: u32) -> bool;
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address};
    use starknet::contract_address::ContractAddressZeroable;
    use mancala::models::{game::{Game, GameId}};
    use core::array::Array;

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn create_game(world: IWorldDispatcher, player_1: ContractAddress, player_2: ContractAddress) -> Game{

            let curr_world_id = world.uuid();
            let game_id: GameId = get!(world, curr_world_id, (GameId));
            let game: Game = Game {
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

        fn move(world: IWorldDispatcher, game_id: u32, selected_pit: u32) -> bool {
            let mut game: Game = get!(world, game_id, (Game));
            let player: ContractAddress = get_caller_address();
            let current_player: ContractAddress = game.current_player;
        
            if player != current_player {
                panic!("You are not the current player");
            }
        
            if selected_pit > 5 {
                panic!("Invalid pit, choose between 0 and 5");
            }
        
            // Get stones from the selected pit and validate it's not empty
            let mut stones = match selected_pit {
                0 => if current_player == game.player_one { game.p1_pit1 } else { game.p2_pit1 },
                1 => if current_player == game.player_one { game.p1_pit2 } else { game.p2_pit2 },
                2 => if current_player == game.player_one { game.p1_pit3 } else { game.p2_pit3 },
                3 => if current_player == game.player_one { game.p1_pit4 } else { game.p2_pit4 },
                4 => if current_player == game.player_one { game.p1_pit5 } else { game.p2_pit5 },
                5 => if current_player == game.player_one { game.p1_pit6 } else { game.p2_pit6 },
                _ => panic!("Invalid pit selected"),
            };
        
            if stones == 0 {
                panic!("Selected pit is empty. Choose another pit.");
            }
        
            // Clear the selected pit
            match selected_pit {
                0 => if current_player == game.player_one { game.p1_pit1 = 0 } else { game.p2_pit1 = 0 },
                1 => if current_player == game.player_one { game.p1_pit2 = 0 } else { game.p2_pit2 = 0 },
                2 => if current_player == game.player_one { game.p1_pit3 = 0 } else { game.p2_pit3 = 0 },
                3 => if current_player == game.player_one { game.p1_pit4 = 0 } else { game.p2_pit4 = 0 },
                4 => if current_player == game.player_one { game.p1_pit5 = 0 } else { game.p2_pit5 = 0 },
                5 => if current_player == game.player_one { game.p1_pit6 = 0 } else { game.p2_pit6 = 0 },
                _ => panic!("Invalid pit selected"),
            };
        
            // Distribute stones
            let mut current_pit = selected_pit;
            while stones > 0 {
                current_pit = (current_pit + 1) % 6; // wrap around to the first pit
                if current_pit == selected_pit {
                    continue; // skip the originally selected pit as it's been emptied
                }
                
                match current_pit {
                    0 => if current_player == game.player_one { game.p1_pit1 += 1 } else { game.p2_pit1 += 1 },
                    1 => if current_player == game.player_one { game.p1_pit2 += 1 } else { game.p2_pit2 += 1 },
                    2 => if current_player == game.player_one { game.p1_pit3 += 1 } else { game.p2_pit3 += 1 },
                    3 => if current_player == game.player_one { game.p1_pit4 += 1 } else { game.p2_pit4 += 1 },
                    4 => if current_player == game.player_one { game.p1_pit5 += 1 } else { game.p2_pit5 += 1 },
                    5 => if current_player == game.player_one { game.p1_pit6 += 1 } else { game.p2_pit6 += 1 },
                    _ => panic!("Invalid pit selected"),
                };
        
                stones -= 1;
            };
        
            // Update the game state
            set!(world, (game));
        
            // Switch players, or manage additional game logic here
            true
        }
        
    }
}
