// Dayne
// Bubble (Entity)
// January 2025

Bubble :: struct {
    using #as entity : Entity;
    kind = .BUBBLE;

    // Properties
    using actor : Actor;

    using animation : Sprite_Animation;
    pop_animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;

    popped : bool;
}

initialize :: (using bubble: *Bubble) {
    facing_left = false;
    velocity = .{};
    popped = false;
}

update :: (using bubble: *Bubble, dt: float) {
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

        if popped {
            done := update(*pop_animation, dt);
            if done then should_die = true;
        }
        else {
            update(*animation, dt);
        }
    }
}

draw :: (using bubble: *Bubble) {
    if popped {
        draw_sprite_relative_to_collider(
            collider, pop_animation.sprite_name, pop_animation.frame, facing_left
        );
    }
    else {
        draw_sprite_relative_to_collider(
            collider, animation.sprite_name, animation.frame, facing_left
        );
    }
}

draw_debug :: (using bubble: *Bubble) {
    if popped then return;

    draw(collider, color=debug.unique_color);
}
