// Dayne
// Game
// Alex Hartford
// February 2024

Game :: struct {
    players : [..] Player_Interface;

    score : int;

    MAX_ENTITIES :: 1000;
    entities : [MAX_ENTITIES] *Entity;
}

