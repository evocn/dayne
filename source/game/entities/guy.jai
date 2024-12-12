// Dayne
// Guy
// December 2024

using bird_constants : struct {
    using movement : struct {
        // Horizontal
        MINIMUM_WALK_SPEED   :: 10.0;
        MAXIMUM_WALK_SPEED   :: 60.0;
        WALK_ACCELERATION    :: 2.0;
        RELEASE_DECELERATION :: 8.0;

        // Vertical
        JUMP_VELOCITY   :: 100.0;
        BOOST_VELOCITY  :: 80.0;

        FALLING_GRAVITY :: 2.0;
        TERMINAL_FALLING_VELOCITY :: 100.0;
        GLIDING_GRAVITY :: 0.5;
        TERMINAL_GLIDING_VELOCITY :: 10.0;

        COYOTE_TIME_MARGIN :: 0.1;
    }

    BOOSTS :: 2;
}

Guy :: struct {
    using #as entity : Entity;
    kind = .GUY;

    // Properties
    using actor : Actor;

    animation : *Sprite_Animation;
    animations : struct {
        idle    : Sprite_Animation;
        walk    : Sprite_Animation;
        jump    : Sprite_Animation;
        glide   : Sprite_Animation;
        fall    : Sprite_Animation;
    }

    // State
    velocity    : Vector2;

    grounded    : bool;
    gliding     : bool;

    coyote_time : float;

    boosts      : int;

    facing_left : bool;
}

initialize :: (using guy: *Guy) {
}

apply_input :: (using guy: *Guy, input: Input) {
    apply_input_to_velocity(guy, input);
    apply_input_to_appearance(guy, input);
}

apply_input_to_velocity :: (using guy: *Guy, input: Input) {
    {
        left  := input.left.is_held;
        right := input.right.is_held;

        // Update Velocity based on inputs
        if right && !left {
            velocity.x = max(velocity.x, MINIMUM_WALK_SPEED);
            velocity.x += WALK_ACCELERATION;
            velocity.x = min(velocity.x, MAXIMUM_WALK_SPEED);
        }
        else if left && !right {
            velocity.x = min(velocity.x, -1 * MINIMUM_WALK_SPEED);
            velocity.x += -1 * WALK_ACCELERATION;
            velocity.x = max(velocity.x, -1 * MAXIMUM_WALK_SPEED);
        }
        else {
            if velocity.x < 0 {
                velocity.x += RELEASE_DECELERATION;
                velocity.x = min(0.0, velocity.x);
            }
            else if velocity.x > 0 {
                velocity.x -= RELEASE_DECELERATION;
                velocity.x = max(0.0, velocity.x);
            }
        }
    }

    {
        jump :: (using guy: *Guy) {
            velocity.y = JUMP_VELOCITY;
            grounded = false;

            coyote_time = 0.0;
        }

        boost :: (using guy: *Guy) {
            if boosts == 0 then return;

            velocity.y = BOOST_VELOCITY;

            boosts -= 1;
        }

        // Apply Gravity
        if grounded {
            if input.a.just_pressed then jump(guy);
        }
        else {
            if velocity.y < 0 && input.a.is_held then gliding = true;
            else gliding = false;

            if input.a.just_pressed && coyote_time > 0.0 {
                jump(guy);
            }

            if input.b.just_pressed {
                boost(guy);
            }
        }
    }
}

apply_input_to_appearance :: (using guy: *Guy, input: Input) {
    // Orientation
    left  := input.left.is_held;
    right := input.right.is_held;
    if left  then facing_left = true;
    if right then facing_left = false;

    {
        using animations;

        if grounded {
            if (left | right) && !(left && right) {
                animation = *walk;
            }
            else {
                animation = *idle;
            }
        }
        else {
            if velocity.y > 0 {
                animation = *jump;
            }
            else if velocity.y < -TERMINAL_GLIDING_VELOCITY {
                animation = *fall;
            }
            else {
                animation = *glide;
            }
        }
    }
}


update :: (using guy: *Guy, dt: float) {
    // Tick state
    {
        coyote_time = max(0.0, coyote_time - dt);

        // Determine new grounded state.
        {
            if velocity.y <= 0.0 {
                grounded = check_if_grounded(actor);

                if grounded {
                    velocity.y = 0.0;
                    coyote_time = COYOTE_TIME_MARGIN;
                    boosts = BOOSTS;
                }
            }

            if velocity.y > 0.0 {
                hitting_head_now := check_if_hitting_head(actor);
                if hitting_head_now {
                    velocity.y = 0.0;
                }
            }
        }

        // Gravity.
        {
            if gliding {
                velocity.y = max(velocity.y - GLIDING_GRAVITY, -TERMINAL_GLIDING_VELOCITY);
            }
            else {
                velocity.y = max(velocity.y - FALLING_GRAVITY, -TERMINAL_FALLING_VELOCITY);
            }
        }
    }

    // Move
    {
        debug_print(tprint("p: %", position));
        debug_print(tprint("v: %", velocity));
        debug_print(tprint("glide: %", gliding));
        debug_print(tprint("ground: %", grounded));

        amount_to_move := velocity * dt;

        /*
        profile_timer :
        */
        move_x(*actor, amount_to_move.x, null);
        move_y(*actor, amount_to_move.y, null);

        debug_print(tprint("p: %", position));
    }

    update_visuals(guy, dt);
}

update_visuals :: (using guy: *Guy, dt: float) {
    update(animation, dt);
}


////////////////////////////////////////////////////////////////////////////////

draw :: (using guy: *Guy) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using guy: *Guy) {
    draw(collider, color=debug.unique_color);
}
