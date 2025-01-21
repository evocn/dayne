// Dayne
// Bubble (Entity)
// January 2025

Bubble :: struct {
    using #as entity : Entity;
    kind = .BUBBLE;

    // Properties
    using actor : Actor;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using bubble: *Bubble) {
    facing_left = false;
    velocity = .{};
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

        update(*animation, dt);
    }
}

draw :: (using bubble: *Bubble) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using bubble: *Bubble) {
    draw(collider, color=debug.unique_color);
}
