// Dayne
// Artifact (Entity)
// February 2025

Artifact :: struct {
    using #as entity : Entity;
    kind = .ARTIFACT;

    z_index = -100;

    // Properties
    name: string;

    using collider : Collider;

    decision: Decision;

    using animation : Sprite_Animation;

    // State
    facing_left : bool;
}

initialize :: (using artifact: *Artifact) {
    facing_left = false;
}

update :: (using basic: *Artifact, dt: float) {
    // Visual
    {
        update(*animation, dt);
    }
}

draw :: (using artifact: *Artifact) {
    draw_sprite_relative_to_collider(
        collider, animation.sprite_name, animation.frame, facing_left
    );
}

draw_debug :: (using artifact: *Artifact) {
    draw(collider, color=debug.unique_color);
}
