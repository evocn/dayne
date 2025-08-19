
// Basic (Entity)
////////////////////////////////////////////////////////////////////////////////

Basic :: struct {
    using #as entity : Entity;
    kind = .BASIC;

    // Properties
    using actor : Actor;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using basic: *Basic) {
    facing_left = false;
    velocity = .{};
}

update :: (using basic: *Basic, dt: float) {
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

draw :: (using basic: *Basic) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using basic: *Basic) {
    draw(collider, color=debug.unique_color);
}
