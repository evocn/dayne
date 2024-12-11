// Dayne
// Platform
// December 2024

Platform :: struct {
    using #as entity : Entity;
    kind = .PLATFORM;

    using solid : Solid;
}

initialize :: (using platform: *Platform) {
}

apply_input :: (using platform: *Platform, input: Input) {
}

update :: (using platform: *Platform, dt: float) {
}

////////////////////////////////////////////////////////////////////////////////

draw :: (using platform: *Platform) {
    draw(collider, color=white);
}

draw_debug :: (using platform: *Platform) {
    draw(collider, color=debug.unique_color);
}
