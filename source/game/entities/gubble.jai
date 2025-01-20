// Dayne
// Gubble (Entity)
// January 2025

Gubble :: struct {
    using #as entity : Entity;
    kind = .GUBBLE;

    // Properties
    using actor : Actor;
    width  = 12;
    height = 12;

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
        if velocity.x < 0 then facing_left = true; else facing_left = false;

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
