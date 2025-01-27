// Gubble
// Platform (Entity)
// January 2025

Platform :: struct {
    using #as entity : Entity;
    kind = .PLATFORM;

    // Properties
    using solid : Solid;

    using animation : Sprite_Animation;

    // State
    velocity    : Vector2;
    movement_t  : float;
    movement_speed := 10.0;
}

initialize :: (using platform: *Platform) {
    velocity = .{};
    one_way = true;
}

update :: (using platform: *Platform, dt: float) {
    // Update Velocity
    {
        /*
        // Sine pattern
        movement_t += dt;
        velocity.x = movement_speed * cos(movement_t);
        */
    }

    // Move
    {
        amount_to_move := velocity * dt;

        move(*solid, amount_to_move.x, amount_to_move.y);
    }

    // Visual
    {
        update(*animation, dt);
    }
}

draw :: (using platform: *Platform) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame
    );
}

draw_debug :: (using platform: *Platform) {
    draw(collider, color=debug.unique_color);
}

////////////////////////////////////////////////////////////////////////////////
