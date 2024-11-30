// Dayne
// Game
// November 2024

#load "spine.jai";

#load "entity.jai";
#load "entities/test.jai";

#load "systems/dice.jai";
#load "systems/fighter.jai";

#load "physics/physics.jai";

Game :: struct {
    using constants : struct {
    }

    using data : struct {
        foes : [..] Fighter;
    }

    using internals : struct {
        arena : Flat_Pool;
    }

    using state : struct {
        spine : Spine;

        simulation: Simulation;

        entities: [..] *Entity;

        hero: Fighter;
        foe : Fighter;

        using transient : struct {
            pool: Dice_Pool;
            result : [..] Face;
        }
    }

    camera : struct {
        position : Pair;
        zoom : int;
    }
}

apply_inputs :: (using input: Input, game: *Game) {
    if game.spine.state == {
        case .OVERWORLD;
            if input.east.just_pressed {
                game.spine.state = .CHOOSE;
                game.foe = random_choice(game.foes);
            }

            if input.north.just_pressed {
                game.spine.state = .SPEC;
            }

        case .SPEC;
            if input.south.just_pressed {
                game.spine.state = .OVERWORLD;
            }

        case .CHOOSE;
            if input.south.just_pressed {
                game.spine.state = .OVERWORLD;
            }

            if input.east.just_pressed {
                game.result = roll(game.pool);
            }

        case .ROLL;
            if input.east.just_pressed {
                game.spine.state = .OVERWORLD;
                array_reset(*game.result);
            }
    }
}

initialize :: (using game: *Game) {
    // Initialization
    {
        camera.position = .{};
        camera.zoom = 1;
    }

    // System State
    {
        {
            {
                using fool : Fighter;
                name = "Fool";

                {
                    using strength;
                    faces[0] = .{0};
                    faces[1] = .{0};
                    faces[2] = .{0};
                    faces[3] = .{1};
                    faces[4] = .{1};
                    faces[5] = .{2};
                }

                array_add(*foes, fool);
            }

            {
                using monk : Fighter;
                name = "Monk";

                {
                    using strength;
                    faces[0] = .{1};
                    faces[1] = .{1};
                    faces[2] = .{1};
                    faces[3] = .{2};
                    faces[4] = .{2};
                    faces[5] = .{2};
                }

                array_add(*foes, monk);
            }
        }

        {
            using hero;
            name = "Hero";

            {
                using strength;
                faces[0] = .{1};
                faces[1] = .{1};
                faces[2] = .{1};
                faces[3] = .{2};
                faces[4] = .{2};
                faces[5] = .{3};
            }
        }
    }

    // Create Entities
    {
        test : *Test = xx new_entity(.TEST);
        {
            using test;
            width  = 16;
            height = 16;

            initialize(*animation, "Frog-Idle");
        }
        array_add(*entities, xx test);
    }
}

simulate :: (using game: *Game, dt: float) {
    for entity : entities {
        update(entity, dt);
    }
}
