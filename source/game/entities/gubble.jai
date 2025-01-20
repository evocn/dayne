// Dayne
// Gubble (Entity)
// January 2025

Gubble :: struct {
    using #as entity : Entity;
    kind = .GUBBLE;

    // Properties
    using actor : Actor;
    width  = 14;
    height = 14;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using gubble: *Gubble) {
    facing_left = false;
    velocity = .{};
}

update :: (using gubble: *Gubble, dt: float) {
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

gubble_variables : struct {
    speed := 50.0;
}

apply_inputs :: (using input: Input, gubble : *Gubble) {
    using gubble_variables;

    {
        // Update Velocity based on inputs
        if right.is_held && !left.is_held {
            gubble.velocity.x = speed;
        }
        else if left.is_held && !right.is_held {
            gubble.velocity.x = -speed;
        }
        else {
            gubble.velocity.x = 0;
        }
    }

    /*
    {
        jump :: (player: *Player) {
            player.velocity.y = JUMP_VELOCITY;
            player.grounded = false;

            player.coyote_time = 0.0;
        }

        // Apply Gravity
        if player.grounded {
            if button_was_just_pressed(input, .A) {
                jump(player);
            }
        }
        else {
            if player.velocity.y >= 0 && button_is_held(input, .A) {
                player.velocity.y -= HOLDING_GRAVITY;
            }
            else {
                player.velocity.y -= FALLING_GRAVITY;
            }

            if player.velocity.y <= -TERMINAL_GLIDING_VELOCITY && button_is_held(input, .A) {
                player.velocity.y = -TERMINAL_GLIDING_VELOCITY;
            }


            if player.coyote_time > 0.0 && button_was_just_pressed(input, .A) {
                jump(player);
            }
        }

        player.velocity.y = max(player.velocity.y, -TERMINAL_FALLING_VELOCITY);
    }
    */
}

////////////////////////////////////////////////////////////////////////////////

move_dumb :: (using gubble: *Gubble, new_x: int, new_y: int) {
    x = new_x;
    y = new_y;

    actor.x_remainder = 0;
    actor.y_remainder = 0;
}
