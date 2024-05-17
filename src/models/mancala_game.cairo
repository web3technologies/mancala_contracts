use starknet::ContractAddress;

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


trait MancalaGameTrait{
    fn get_stones(self: MancalaGame, selected_pit: u32) -> u8;
    fn clear_pit(ref self: MancalaGame, selected_pit: u32);
    fn distribute_stones(ref self: MancalaGame, ref stones: u8, selected_pit: u32);
    fn validate_move(self:MancalaGame, player: ContractAddress,  selected_pit: u32);
    // todo implement logic
    fn switch_player(self: MancalaGame);
    // todo implement logic
    fn capture(self: MancalaGame);
}


impl MancalaImpl of MancalaGameTrait{

    fn validate_move(self: MancalaGame, player: ContractAddress, selected_pit: u32){
        if player != self.current_player {
            panic!("You are not the current player");
        }
        if selected_pit < 1 || selected_pit > 6 {
            panic!("Invalid pit, choose between 0 and 5");
        }
    }

    fn get_stones(self: MancalaGame, selected_pit: u32) -> u8{
        let mut stones: u8 = match selected_pit {
            0 => panic!("Invalid pit selected"),
            1 => if self.current_player == self.player_one { self.p1_pit1 } else { self.p2_pit1 },
            2 => if self.current_player == self.player_one { self.p1_pit2 } else { self.p2_pit2 },
            3 => if self.current_player == self.player_one { self.p1_pit3 } else { self.p2_pit3 },
            4 => if self.current_player == self.player_one { self.p1_pit4 } else { self.p2_pit4 },
            5 => if self.current_player == self.player_one { self.p1_pit5 } else { self.p2_pit5 },
            6 => if self.current_player == self.player_one { self.p1_pit6 } else { self.p2_pit6 },
            _ => panic!("Invalid pit selected"),
        };
        stones
    }

    fn clear_pit(ref self: MancalaGame, selected_pit: u32){
        match selected_pit {
            0 => panic!("Invalid pit selected"),
            1 => if self.current_player == self.player_one { self.p1_pit1 = 0 } else { self.p2_pit1 = 0 },
            2 => if self.current_player == self.player_one { self.p1_pit2 = 0 } else { self.p2_pit2 = 0 },
            3 => if self.current_player == self.player_one { self.p1_pit3 = 0 } else { self.p2_pit3 = 0 },
            4 => if self.current_player == self.player_one { self.p1_pit4 = 0 } else { self.p2_pit4 = 0 },
            5 => if self.current_player == self.player_one { self.p1_pit5 = 0 } else { self.p2_pit5 = 0 },
            6 => if self.current_player == self.player_one { self.p1_pit6 = 0 } else { self.p2_pit6 = 0 },
            _ => panic!("Invalid pit selected"),
        };
    }

    fn distribute_stones(ref self: MancalaGame, ref stones: u8, selected_pit: u32){
        let mut current_pit = selected_pit;
        while stones > 0 {
            current_pit = (current_pit + 1) % 6; // wrap around to the first pit
            if current_pit == selected_pit {
                continue; // skip the originally selected pit as it's been emptied
            }
            match current_pit {
                0 => panic!("Invalid pit selected"), 
                1 => if self.current_player == self.player_one { self.p1_pit1 += 1 } else { self.p2_pit1 += 1 },
                2 => if self.current_player == self.player_one { self.p1_pit2 += 1 } else { self.p2_pit2 += 1 },
                3 => if self.current_player == self.player_one { self.p1_pit3 += 1 } else { self.p2_pit3 += 1 },
                4 => if self.current_player == self.player_one { self.p1_pit4 += 1 } else { self.p2_pit4 += 1 },
                5 => if self.current_player == self.player_one { self.p1_pit5 += 1 } else { self.p2_pit5 += 1 },
                6 => if self.current_player == self.player_one { self.p1_pit6 += 1 } else { self.p2_pit6 += 1 },
                _ => panic!("Invalid pit selected"),
            };
    
            stones -= 1;
        };
    }

    fn switch_player(self: MancalaGame){}
    fn capture(self: MancalaGame){}
}