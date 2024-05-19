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
        models::{mancala_game::{MancalaGame, GameId, mancala_game}},
        models::{player::{GamePlayer}}
    };


    #[test]
    #[available_gas(3000000000000)]
    fn test_move() {
        // caller
        let player_one_address = starknet::contract_address_const::<0x0>();
        let player_two_address = starknet::contract_address_const::<0x456>();
        // models
        let mut models = array![mancala_game::TEST_CLASS_HASH];
        // deploy world with models
        let world = spawn_test_world(models);

        // deploy systems contract
        let contract_address = world.deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let actions_system = IActionsDispatcher { contract_address: contract_address };
        let game: MancalaGame = actions_system.create_game(player_one_address, player_two_address);
        let player_one: GamePlayer =  get!(world, (player_one_address, game.game_id), (GamePlayer));
        let player_two: GamePlayer =  get!(world, (player_one_address, game.game_id), (GamePlayer));

        assert(player_one.pit1 == 4, 'not init correctly');
        assert(player_one.pit2 == 4, 'not init correctly');
        assert(player_one.pit3 == 4, 'not init correctly');
        assert(player_one.pit4 == 4, 'not init correctly');
        assert(player_one.pit5 == 4, 'not init correctly');
        assert(player_one.pit6 == 4, 'not init correctly');
        assert(player_two.pit6 == 4, 'not init correctly');
        assert(player_two.pit6 == 4, 'not init correctly');
        assert(player_two.pit6 == 4, 'not init correctly');
        assert(player_two.pit6 == 4, 'not init correctly');
        assert(player_two.pit6 == 4, 'not init correctly');
        assert(player_two.pit6 == 4, 'not init correctly');

        let selected_pit: u8 = 1;
        actions_system.move(game.game_id, selected_pit);
        let game: MancalaGame = get!(world, game.game_id, (MancalaGame));
        let player_one: GamePlayer =  get!(world, (player_one_address, game.game_id), (GamePlayer));
        assert!(player_one.pit1 == 0, "pit not cleared");
        assert!(player_one.pit2 == 5, "pit does not have correct count");
    }
}
