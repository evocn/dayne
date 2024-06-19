// Dayne
// Game
// Alex Hartford
// February 2024

// This structure defines the game's current state.
Game :: struct {
    Player :: struct {
        state : enum {
            DEFAULT;
            NO_INPUT;
        }

        input : Input;

        gamepad: SDL_Joystick;
    }
    player : Player;

    entities : [..] *Entity;

    //
    //

    spine : Spine;

    page : Page;
}

simulate_game :: (game: *Game, dt: float) {
    for entity : game.entities {
        determine_entity_kind_and_update(entity, dt);
    }
}
