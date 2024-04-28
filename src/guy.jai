// Dayne
// Guy
// Alex Hartford
// March 2024

Guy :: struct {
    using #as entity: Entity;
    kind = .GUY;


    sprite  : int;
    color   : Color;

    flip    : bool;     @NoSerialize
}

initialize :: (guy: *Guy) {
    guy.flip = false;
}

update :: (guy: *Guy, dt: float) {
    guy.position.x += 1.0 * dt;
}

draw :: (guy: Guy) {
    pixel := world_space_to_screen_pixel(guy.position);

    draw_sprite(
        render_context.spritesheet,
        index = guy.sprite,
        pixel = pixel,
        scale_factor = 1,
        horizontal_flip = guy.flip,
        use_color_override = true,
        color_override = guy.color,
    );
}

