// Dayne
// Guy
// Alex Hartford
// March 2024

Guy :: struct {
    using #as entity: Entity;
    kind = .GUY;


    spritesheet_index : int;
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

    draw_spritesheet(
        "main",
        index = guy.spritesheet_index,
        x = pixel.x,
        y = pixel.y,

        scale_factor = 1,
        horizontal_flip = guy.flip,
        use_color_override = true,
        color_override = guy.color,
    );
}

