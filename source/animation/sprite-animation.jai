// Dayne
// Sprite Animation
// September 2024

Sprite_Animation :: struct {
    sprite_name : string;
    frame_count : int;

    speed : float = 1.0;

    // State
    frame   : int;
    t       : float;
}

initialize :: (animation: *Sprite_Animation, sprite_name: string, speed := 1.0) {
    sprite := table_find_pointer(*graphics_context.sprites, sprite_name);
    if !sprite {
        log_error("Couldn't load spritesheet % when loading animation.\n", sprite_name);
        return;
    }

    {
        animation.frame_count = sprite.columns * sprite.rows;
        animation.sprite_name = sprite_name;
        animation.speed = speed;
    }
}

reset :: (using animation : *Sprite_Animation) {
    frame = 0;
    t = 0;
}

update :: (using animation : *Sprite_Animation, dt: float) -> finished : bool {
    t += dt;
    BASE_SPEED_CONSTANT :: 0.2;
    change_time := BASE_SPEED_CONSTANT / speed;
    if t < change_time then return false;
    else {
        t = fmod_cycling(t, change_time);
        frame = (frame + 1) % frame_count;
        return 0 == frame;
    }
}
