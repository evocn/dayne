// Dayne
// Game
// Alex Hartford
// February 2024

// The State of the Game.

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

    entities    : [..] *Entity;
    entity_pool : Flat_Pool;


    // Experimentation
    //the_animator : Animator;
}

simulate_game :: (using game: *Game, dt: float) {
    for entity : entities {
        determine_entity_kind_and_update(entity, dt);
    }

    //update(*the_animator, dt);
}
