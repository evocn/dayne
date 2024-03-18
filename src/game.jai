// Dayne
// Game
// Alex Hartford
// February 2024

Game :: struct {
    players : [..] Player;

    Player :: struct {
        state : enum {
            NO_INPUT;
            DEFAULT;
        }

        input : Input;

        gamepad: SDL_Joystick;
    }

    score : int;

    entities : [..] *Entity;
}

simulate_game :: (game: *Game, dt: float) {
    for entity : game.entities {
        determine_entity_kind_and_update(entity, dt);
    }
}
