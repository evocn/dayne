// Dayne
// Monk (Entity)
// February 2025

Hero :: struct {
    using #as entity : Entity;
    kind = .HERO;

    // Properties
    using actor : Actor;

    using animator : Animator;

    using constants : struct {
        SPEED :: 15;
    }

    // State
    facing_left : bool;
    velocity    : Vector2;
}

initialize :: (using hero: *Hero) {
    facing_left = false;
    velocity = .{};
}

update :: (using hero: *Hero, dt: float) {
    // Move
    {
        amount_to_move := velocity * dt;

        move_x(*actor, amount_to_move.x, null);
        move_y(*actor, amount_to_move.y, null);
    }

    // Visual
    {
        if velocity.x < 0 && !facing_left then facing_left = true;
        else if velocity.x > 0 && facing_left then facing_left = false;

        update(*animator, dt);
    }
}

draw :: (using hero: *Hero) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using hero: *Hero) {
    draw(collider, color=debug.unique_color);
}

////////////////////////////////////////////////////////////////////////////////

apply_inputs :: (input: Input, hero: *Hero) {
    apply_inputs_to_gameplay(input, hero);

    apply_inputs_to_visuals(input, hero);
}

apply_inputs_to_gameplay :: (input: Input, hero: *Hero) {
    direction : Vector2;

    if input.left.is_held  then direction.x -= 1;
    if input.right.is_held then direction.x += 1;

    if input.a.is_held {
        hero.velocity = .{};
    }
    else {
        hero.velocity = hero.SPEED * direction;
    }
}

apply_inputs_to_visuals :: (input: Input, hero: *Hero) {
    if input.left.is_held || input.right.is_held {
        change(*hero.animator, "walk");
    }
    else {
        change(*hero.animator, "idle");
    }

    if input.a.is_held {
        change(*hero.animator, "point");
    }
}
