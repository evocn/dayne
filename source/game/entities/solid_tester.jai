
// Solid Tester (Entity)
////////////////////////////////////////////////////////////////////////////////

Solid_Tester :: struct {
    using #as entity : Entity;
    kind = .SOLID_TESTER;

    // Properties
    using solid : Solid;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using tester: *Solid_Tester) {
    facing_left = false;
    velocity = .{};
}

update :: (using tester: *Solid_Tester, dt: float) {
    // Move
    {
        amount_to_move := velocity * dt;

        move(*solid, amount_to_move.x, amount_to_move.y);
    }

    // Visual
    {
        if velocity.x > 0 && facing_left then facing_left = false;
        else if velocity.x < 0 && !facing_left then facing_left = true;

        update(*animation, dt);
    }
}

draw :: (using tester: *Solid_Tester) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using tester: *Solid_Tester) {
    draw(collider, color=debug.unique_color);
}

////////////////////////////////////////////////////////////////////////////////

apply_inputs :: (input: Input, tester: *Solid_Tester) {
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
