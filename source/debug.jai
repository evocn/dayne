// Dayne
// Debug
// December 2024

Debug :: struct {
    messages : [..] string;
}

debug_print :: (s : string) {
    array_add(*program_state.game.debug.messages, s);
}

reset :: (using debug: *Debug) {
    array_reset(*messages);
}

draw :: (using debug: Debug) {
    k := 0;
    for s : messages {
        draw_text(
            s,
            1,
            PIXEL_HEIGHT - 10 - k,
            font = .SMALL,
            color = white,
        );

        k += 8;
    }
}
