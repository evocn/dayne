// Dayne
// Debug
// December 2024

Debug :: struct {
    messages : [..] string;

    collided_solids : [..] *Solid;
}

debug_print :: (s : string) {
    array_add(*program_state.game.debug.messages, s);
}

reset :: (using debug: *Debug) {
    array_reset(*messages);
}

draw :: (using debug: Debug) {
    k := 0;
    inc := 10;
    for s : messages {
        draw_text(
            s,
            1,
            PIXEL_HEIGHT - inc - (k * inc),
            font = .MAIN,
            color = debug_color,
        );

        k += 1;
    }
}
