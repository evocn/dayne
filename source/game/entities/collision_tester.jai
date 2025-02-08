// Dayne
// Collision Tester (Entity)
// February 2025

Collision_Tester :: struct {
    using #as entity : Entity;
    kind = .COLLISION_TESTER;

    // Properties
    using actor : Actor;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using tester: *Collision_Tester) {
    facing_left = false;
    velocity = .{};
}

update :: (using tester: *Collision_Tester, dt: float) {
    // Move
    {
        amount_to_move := velocity * dt;

        move_x(*actor, amount_to_move.x, null);
        move_y(*actor, amount_to_move.y, null);
    }

    // Visual
    {
        if velocity.x > 0 && facing_left then facing_left = false;
        else if velocity.x < 0 && !facing_left then facing_left = true;

        update(*animation, dt);
    }
}

draw :: (using tester: *Collision_Tester) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using tester: *Collision_Tester) {
    draw(collider, color=debug.unique_color);
}

////////////////////////////////////////////////////////////////////////////////

apply_inputs :: (input: Input, tester: *Collision_Tester) {
    SPEED :: 100;

    new_velocity : Vector2;
    if input.right.is_held {
        new_velocity.x += SPEED;
    }
    if input.left.is_held {
        new_velocity.x -= SPEED;
    }
    if input.up.is_held {
        new_velocity.y += SPEED;
    }
    if input.down.is_held {
        new_velocity.y -= SPEED;
    }

    tester.velocity = new_velocity;
}

