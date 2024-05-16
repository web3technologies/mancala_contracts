#[cfg(test)]
mod tests {
    use starknet::class_hash::Felt252TryIntoClassHash;
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    // import test utils


    use mancala::{
        // systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
        models::{game::{Game, GameId, game}}
    };

    #[test]
    #[available_gas(300000000000)]
    fn test_move() {
        // caller
        let player_one = starknet::contract_address_const::<0x0>();
        let player_two = starknet::contract_address_const::<0x1>();
        // models
        let mut models = array![game::TEST_CLASS_HASH];
        // deploy world with models
        let world = spawn_test_world(models);


        // deploy systems contract
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address: contract_address };
        
        let game: Game = actions_system.create_game(player_one, player_two);
        assert(game.p1_pit1 == 4, 'not init correctly');
        assert(game.p1_pit2 == 4, 'not init correctly');
        assert(game.p1_pit3 == 4, 'not init correctly');
        assert(game.p1_pit4 == 4, 'not init correctly');
        assert(game.p1_pit5 == 4, 'not init correctly');
        assert(game.p1_pit6 == 4, 'not init correctly');
        assert(game.p2_pit1 == 4, 'not init correctly');
        assert(game.p2_pit2 == 4, 'not init correctly');
        assert(game.p2_pit3 == 4, 'not init correctly');
        assert(game.p2_pit4 == 4, 'not init correctly');
        assert(game.p2_pit5 == 4, 'not init correctly');
        assert(game.p2_pit6 == 4, 'not init correctly');

        // let selected_pit: u32 = 1;
        // actions_system.move(game.game_id, selected_pit);
        // let game: Game = get!(world, game.game_id, (Game));
        // assert(game.p1_pit1 == 3, 'not correct');
    }
}
