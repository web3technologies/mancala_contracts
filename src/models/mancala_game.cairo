use core::traits::Into;
use starknet::ContractAddress;
use starknet::contract_address::ContractAddressZeroable;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use mancala::models::player::{GamePlayer, GamePlayerTrait};


#[derive(Model, Copy, Drop, Serde)]
struct GameId {
    #[key]
    world_id: u32,
    game_id: u128
}

#[derive(Model, Copy, Drop, Serde)]
struct MancalaGame {
    #[key]
    game_id: u128,
    player_one: ContractAddress,
    player_two: ContractAddress,
    current_player: ContractAddress,
    winner: ContractAddress,
    score: u8,
    is_finished: bool,
}


trait MancalaGameTrait{
    fn get_stones(self: MancalaGame, player:GamePlayer, selected_pit: u8) -> u8;
    fn clear_pit(ref self: MancalaGame, ref player: GamePlayer, selected_pit: u8);
    fn distribute_stones(ref self: MancalaGame, ref current_player: GamePlayer, ref opponent: GamePlayer, ref stones: u8, selected_pit: u8);
    fn validate_move(self:MancalaGame, player: ContractAddress,  selected_pit: u8);
    // todo implement logic
    fn handle_player_switch(ref self: MancalaGame, stones: u8, current_pit: u8, opponent: GamePlayer);
    // todo implement logic
    fn capture(self: MancalaGame);
    fn new(game_id: u128, player_one: ContractAddress, player_two: ContractAddress) -> MancalaGame;
    fn is_game_finished(self: MancalaGame) -> bool;
    fn get_players(self: MancalaGame, world: IWorldDispatcher) -> (GamePlayer, GamePlayer);
}


impl MancalaImpl of MancalaGameTrait{

    fn new(game_id: u128, player_one: ContractAddress, player_two: ContractAddress) -> MancalaGame{
        let mancala_game: MancalaGame = MancalaGame {
            game_id: game_id,
            player_one: player_one,
            player_two: player_two,
            winner: ContractAddressZeroable::zero(),
            current_player: player_one,
            score: 0,
            is_finished: false,
        };
        mancala_game
    }

    fn get_players(self: MancalaGame, world: IWorldDispatcher)-> (GamePlayer, GamePlayer){
        let player_one: GamePlayer = get!(world, (self.player_one, self.game_id), (GamePlayer));
        let player_two: GamePlayer = get!(world, (self.player_two, self.game_id), (GamePlayer));
        // the first player in the tupple is the current player
        if (self.current_player == player_one.address){
            (player_one, player_two)
        } else{
            (player_two, player_one)
        }
    }


    fn validate_move(self: MancalaGame, player: ContractAddress, selected_pit: u8){
        if player != self.current_player {
            panic!("You are not the current player");
        }
        if selected_pit < 1 || selected_pit > 6 {
            panic!("Invalid pit, choose between 0 and 5");
        }
    }

    fn get_stones(self: MancalaGame, player: GamePlayer, selected_pit: u8) -> u8{
        
        let mut stones: u8 = match selected_pit {
            0 => panic!("Invalid pit selected"),
            1 => player.pit1,
            2 => player.pit2,
            3 => player.pit3,
            4 => player.pit4,
            5 => player.pit5,
            6 => player.pit6,
            _ => panic!("Invalid pit selected"),
        };
        stones
    }

    fn clear_pit(ref self: MancalaGame, ref player: GamePlayer, selected_pit: u8){
        match selected_pit {
            0 => panic!("Invalid pit selected"),
            1 => {player.pit1 = 0;},
            2 => {player.pit2 = 0;},
            3 => {player.pit3 = 0;},
            4 => {player.pit4 = 0;},
            5 => {player.pit5 = 0;},
            6 => {player.pit6 = 0;},
            _ => panic!("Invalid pit selected"),
        };
    }

    fn distribute_stones(ref self: MancalaGame, ref current_player: GamePlayer, ref opponent: GamePlayer, ref stones: u8, selected_pit: u8){
        // go to next pit
        let mut current_pit = selected_pit + 1;
        while stones > 0 {
            match current_pit {
                0 => panic!("Invalid pit selected"), 
                1 => {current_player.pit1 += 1;},
                2 => {current_player.pit2 += 1;},
                3 => {current_player.pit3 += 1;},
                4 => {current_player.pit4 += 1;},
                5 => {current_player.pit5 += 1;},
                6 => {current_player.pit6 += 1;},
                7 => {current_player.mancala += 1;},
                8 => {opponent.pit1 += 1;},
                9 => {opponent.pit2 += 1;},
                10 => {opponent.pit3 += 1;},
                11 => {opponent.pit4 += 1;},
                12 => {opponent.pit5 += 1;},
                13 => {opponent.pit6 += 1},
                _ => {current_pit = 1}
            };
            self.handle_player_switch(stones, current_pit, opponent);
            stones -= 1;
            current_pit += 1;
        };
        self.capture();
    }

    fn handle_player_switch(ref self: MancalaGame, stones: u8, current_pit: u8, opponent: GamePlayer){
        if stones == 1_u8 {
            if current_pit != 7 {
                self.current_player = opponent.address;
            } 
        };
    }

    fn capture(self: MancalaGame){}

    fn is_game_finished(self: MancalaGame)-> bool{
        // self.player1.is_finished() & self.player2.is_finished()
        true
    }
}