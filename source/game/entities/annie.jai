// Gubble
// Annie (Entity)
// January 2025

annie_variables : struct {
    move_speed   := 30.0;
}

Annie :: struct {
    using #as entity : Entity;
    kind = .ANNIE;

    // Properties
    using actor : Actor;

    using animation : Sprite_Animation;

    Variety :: enum {
        ORANGE;
        RED;
        BLUE;
        GREEN;
    }
    variety : Variety;

    // State
    velocity    : Vector2;

    facing_left : bool;
}

initialize :: (using annie: *Annie) {
}

update :: (using annie: *Annie, dt: float) {
    // Get Behavior
    if velocity == .{} {
        using annie_variables;

        if variety == {
            case .ORANGE;
                velocity = .{move_speed, 0};

            case .RED;
                velocity = .{0, -move_speed};

            case .BLUE;
                velocity = .{-move_speed, -move_speed};

            case .GREEN;
                velocity = .{move_speed * 2, 0};

        }
    }

    // Move
    {
        amount_to_move := velocity * dt;

        x_collision := move_x(*actor, amount_to_move.x, null);
        y_collision := move_y(*actor, amount_to_move.y, null);

        if x_collision {
            velocity.x = -velocity.x;
        }
        if y_collision {
            velocity.y = -velocity.y;
        }
    }

    // Visual
    {
        if velocity.x > 0 &&  facing_left then facing_left = false;
        if velocity.x < 0 && !facing_left then facing_left = true;

        update(*animation, dt);
    }

    // End-of-Update checks
    {
    }
}

draw :: (using annie: *Annie) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using annie: *Annie) {
    draw(collider, color=debug.unique_color);
}
