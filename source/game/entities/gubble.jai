// Gubble
// Gubble (Entity)
// January 2025

gubble_variables : struct {
    run_speed   := 50.0;
    jump_thrust := 100.0;
    gravity     := -200.0;
    terminal    := -50.0;
}

Gubble :: struct {
    using #as entity : Entity;
    kind = .GUBBLE;

    // Properties
    using actor : Actor;
    width  = 14;
    height = 14;

    using animation : Sprite_Animation;

    // State
    velocity    : Vector2;
    grounded    : bool;

    facing_left : bool;
}

initialize :: (using gubble: *Gubble) {
    facing_left = false;
    velocity = .{};
}

update :: (using gubble: *Gubble, dt: float) {
    {
        using gubble_variables;
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
        if velocity.y <= 0.0 {
            grounded_now := check_if_grounded(actor);

            if grounded_now {
                velocity.y = 0.0;
            }

            grounded = grounded_now;
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
}

////////////////////////////////////////////////////////////////////////////////

move_dumb :: (using gubble: *Gubble, new_x: int, new_y: int) {
    x = new_x;
    y = new_y;

    actor.x_remainder = 0;
    actor.y_remainder = 0;
}
