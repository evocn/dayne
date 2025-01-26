// Gubble
// God (Entity)
// January 2025

God :: struct {
    using #as entity : Entity;
    kind = .GOD;

    // Properties
    using solid : Solid;

    using animation : Sprite_Animation;

    hand_animation : Sprite_Animation;
    hand_collider  : Collider;

    // State
    facing_left : bool;
}

initialize :: (using god: *God) {
    facing_left = false;
}

update :: (using god: *God, dt: float) {

    // Visual
    {
        update(*animation, dt);
        update(*hand_animation, dt);
    }
}

draw :: (using god: *God) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );

    draw_sprite_relative_to_collider(
        hand_collider, hand_animation.sprite_name, hand_animation.frame, facing_left
    );
}

draw_debug :: (using god: *God) {
    draw(collider, color=debug.unique_color);
}
