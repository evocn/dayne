// Dayne
// Game
// Alex Hartford
// February 2024

// This structure defines the game's current state.
Game :: struct {
    Player :: struct {
        state : enum {
            NO_INPUT;
            DEFAULT;
        }

        input : Input;

        gamepad: SDL_Joystick;
    }
    players : [..] Player;

    score : int;

    entities : [..] *Entity;
}

simulate_game :: (game: *Game, dt: float) {
    for entity : game.entities {
        determine_entity_kind_and_update(entity, dt);
    }
}
