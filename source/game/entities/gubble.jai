// Gubble
// Gubble (Entity)
// January 2025

gubble_variables : struct {
    run_speed   := 100.0;
    jump_thrust := 300.0;
    slap_thrust := 300.0;

    gravity     := -700.0;
    terminal    := -1000.0;

    hold_gravity    := -500.0;
    hold_terminal   := -800.0;

    slap_cooldown   := 0.5;

    // Powerups
    boost_thrust:= 300.0;
}

Gubble :: struct {
    using #as entity : Entity;
    kind = .GUBBLE;

    // Properties
    using actor : Actor;
    width  = 16;
    height = 16;

    using animation : Sprite_Animation;

    // State
    velocity    : Vector2;
    grounded    : bool;
    holding     : bool;

    facing_left : bool;

    cooldown : float;

    victims : [..] *Entity;
}

initialize :: (using gubble: *Gubble) {
    facing_left = false;
    velocity = .{};
}

update :: (using gubble: *Gubble, dt: float) {
    // Cooldowns
    {
        cooldown = max(cooldown - dt, 0);
    }

    // Gravity
    {
        gravity : float;
        terminal: float;
        {
            if holding {
                gravity = gubble_variables.hold_gravity;
                terminal = gubble_variables.hold_terminal;
            }
            else {
                gravity = gubble_variables.gravity;
                terminal = gubble_variables.terminal;
            }
        }

        velocity.y += gravity * dt;
        velocity.y = max(velocity.y, terminal);
    }

    // Move
    {
        amount_to_move := velocity * dt;

        move_x(*actor, amount_to_move.x, null);
        move_y(*actor, amount_to_move.y, null);
    }

    // Visual
    {
        if velocity.x > 0 &&  facing_left then facing_left = false;
        if velocity.x < 0 && !facing_left then facing_left = true;

        update(*animation, dt);
    }

    // End-of-Update checks
    {
        // Determine new grounded state.
        if velocity.y < 0.0 {
            grounded_now := check_if_grounded(actor);
            if grounded_now {
                velocity.y = 0.0;
            }

            grounded = grounded_now;
        }

        if velocity.y > 0.0 {
            hitting_head_now := check_if_hitting_head(actor);
            if hitting_head_now {
                velocity.y = 0.0;
            }
        }
    }
}

draw :: (using gubble: *Gubble) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using gubble: *Gubble) {
    draw(collider, color=debug.unique_color);
}

////////////////////////////////////////////////////////////////////////////////

apply_inputs :: (using input: Input, gubble : *Gubble) {
    using gubble_variables;

    {
        // Update Velocity based on inputs
        if right.is_held && !left.is_held {
            gubble.velocity.x = run_speed;
        }
        else if left.is_held && !right.is_held {
            gubble.velocity.x = -run_speed;
        }
        else {
            gubble.velocity.x = 0;
        }
    }

    {
        jump :: (using gubble: *Gubble) {
            using gubble_variables;

            velocity.y = jump_thrust;
            grounded = false;
        }

        if gubble.grounded {
            if input.a.just_pressed {
                jump(gubble);
            }
        }
    }

    {
        slap :: (using gubble: *Gubble) {
            using gubble_variables;

            velocity.y = slap_thrust;
            cooldown = slap_cooldown;
        }

        if input.a.just_pressed && gubble.cooldown == 0.0 {
            if gubble.victims {
                for victim : gubble.victims {
                    victim.should_die = true;
                }
                slap(gubble);
            }
        }
    }

    // Float
    {
        if input.a.is_held {
            gubble.holding = true;
        }
        else {
            gubble.holding = false;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

move_dumb :: (using gubble: *Gubble, new_x: int, new_y: int) {
    x = new_x;
    y = new_y;

    actor.x_remainder = 0;
    actor.y_remainder = 0;
}

camera_follow_gubble :: (using gubble: Gubble, old_camera : Pair) -> Pair {
    camera : Pair;
    camera.x = 0;

    MAX_SCREEN_BENEATH_GUBBLE :: PIXEL_HEIGHT / 2;

    if old_camera.y + MAX_SCREEN_BENEATH_GUBBLE > gubble.y {
        camera.y = old_camera.y;
    }
    else {
        camera.y = gubble.y - PIXEL_HEIGHT + MAX_SCREEN_BENEATH_GUBBLE;
    }

    return camera;
}
