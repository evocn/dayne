// Dayne
// Test (Entity)
// November 2024

Test :: struct {
    using entity : Entity;
    kind = .TEST;

    // Properties
    using actor : Actor;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using test: *Test) {
    facing_left = false;
    velocity = .{};
}

update :: (using test: *Test, dt: float) {
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

draw :: (using test: *Test) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using test: *Test) {
    draw(collider, color=debug.unique_color);
}
