use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct GameId {
    #[key]
    world_id: u32,
    game_id: u128
}

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    game_id: u128,
    player_one: ContractAddress,
    player_two: ContractAddress,
    current_player: ContractAddress,
    winner: ContractAddress,
    score: u8,
    is_finished: bool,
    p1_pit1: u8,
    p1_pit2: u8,
    p1_pit3: u8,
    p1_pit4: u8,
    p1_pit5: u8,
    p1_pit6: u8,
    p2_pit1: u8,
    p2_pit2: u8,
    p2_pit3: u8,
    p2_pit4: u8,
    p2_pit5: u8,
    p2_pit6: u8,
    p1_store: u256,
    p2_store: u256
}

