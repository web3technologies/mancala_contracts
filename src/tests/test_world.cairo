#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use starknet::class_hash::Felt252TryIntoClassHash;
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    // import test utils
    
    use mancala::{
        // systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::{mancala_game::{MancalaGame, GameId, mancala_game}},
        models::{player::{GamePlayer}}
    };

    fn create_game() -> (GamePlayer, GamePlayer, IWorldDispatcher, IActionsDispatcher, MancalaGame, ContractAddress){
        let player_one_address = starknet::contract_address_const::<0x0>();
        let player_two_address = starknet::contract_address_const::<0x456>();
        // models
        let mut models = array![mancala_game::TEST_CLASS_HASH];
        // deploy world with models
        let world = spawn_test_world(models);

        // deploy systems contract
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address: contract_address };
        actions_system.create_initial_game_id();
        let game: MancalaGame = actions_system.create_game(player_one_address, player_two_address);
        let player_one: GamePlayer =  get!(world, (player_one_address, game.game_id), (GamePlayer));
        let player_two: GamePlayer =  get!(world, (player_two_address, game.game_id), (GamePlayer));

        (player_one, player_two, world, actions_system, game, contract_address)
    }

    #[test]
    #[available_gas(3000000000000)]
    fn test_create_game(){
        let (player_one, player_two, _, _, _, _) = create_game();
        assert(player_one.pit1 == 4, 'p1 pit 1 not init correctly');
        assert(player_one.pit2 == 4, 'p1 pit 2 not init correctly');
        assert(player_one.pit3 == 4, 'p1 pit 3 not init correctly');
        assert(player_one.pit4 == 4, 'p1 pit 4 not init correctly');
        assert(player_one.pit5 == 4, 'p1 pit 5 not init correctly');
        assert(player_one.pit6 == 4, 'p1 pit 6 not init correctly');
        assert(player_two.pit6 == 4, 'p2 pit 1 not init correctly');
        assert(player_two.pit6 == 4, 'p2 pit 2 not init correctly');
        assert(player_two.pit6 == 4, 'p2 pit 3 not init correctly');
        assert(player_two.pit6 == 4, 'p2 pit 4 not init correctly');
        assert(player_two.pit6 == 4, 'p2 pit 5 not init correctly');
        assert(player_two.pit6 == 4, 'p2 pit 6 not init correctly');
    }

    #[test]
    #[available_gas(3000000000000)]
    fn test_move_pit1() {
        let (player_one, player_two, world, actions_system, game, _) = create_game();
        let selected_pit: u8 = 1;
        actions_system.move(game.game_id, selected_pit);
        let game_after_move: MancalaGame = get!(world, game.game_id, (MancalaGame));
        let player_one: GamePlayer =  get!(world, (player_one.address, game.game_id), (GamePlayer));

        assert!(player_one.pit1 == 0, "pit1 not cleared");
        assert!(player_one.pit2 == 5, "pit2 does not have correct count");
        assert!(player_one.pit3 == 5, "pit3 does not have correct count");
        assert!(player_one.pit4 == 5, "pit4 does not have correct count");
        assert!(player_one.pit5 == 5, "pit5 does not have correct count");
        assert!(player_one.pit6 == 4, "pit5 does not have correct count");
        assert!(game_after_move.current_player == player_two.address, "current player did not switch");
        assert!(actions_system.is_game_finished(game.game_id) == false, "game should not be finished");
    }

    #[test]
    #[available_gas(3000000000000)]
    fn test_move_pit3() {
        // test that the seed should go in mancala and current player should remain the same
        let (player_one, _, world, actions_system, game, _) = create_game();
        let selected_pit: u8 = 3;
        actions_system.move(game.game_id, selected_pit);
        let game_after_move: MancalaGame = get!(world, game.game_id, (MancalaGame));
        let player_one: GamePlayer =  get!(world, (player_one.address, game.game_id), (GamePlayer));

        assert!(player_one.pit1 == 4, "pit1 not cleared");
        assert!(player_one.pit2 == 4, "pit2 does not have correct count");
        assert!(player_one.pit3 == 0, "pit3 does not have correct count");
        assert!(player_one.pit4 == 5, "pit4 does not have correct count");
        assert!(player_one.pit5 == 5, "pit5 does not have correct count");
        assert!(player_one.pit6 == 5, "pit5 does not have correct count");
        assert!(player_one.mancala == 1, "mancala should have 1 seed");
        assert!(game_after_move.current_player == player_one.address, "current player should remain the same");
        assert!(actions_system.is_game_finished(game.game_id) == false, "game should not be finished");
    }

    #[test]
    #[available_gas(3000000000000)]
    fn test_game_id_increments() {
        let (player_one, player_two, _, _, _, contract_address) = create_game();

        let actions_system = IActionsDispatcher { contract_address: contract_address };
        let game_two: MancalaGame = actions_system.create_game(player_one.address, player_two.address);
        assert!(game_two.game_id == 2, "incorrect id set");
        let game_three: MancalaGame = actions_system.create_game(player_one.address, player_two.address);
        assert!(game_three.game_id == 3, "incorrect id set");
    }
}
