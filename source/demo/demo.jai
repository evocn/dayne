
// Demo
////////////////////////////////////////////////////////////////////////////////

draw_demo :: () {
    {
        use_sprite_shader();
        draw_sprite_at(.{0, 0}, "haruhachi");
    }

    {
        use_text_shader();
        draw_text(
            "the quick brown fox",
            x = 1,
            y = PIXEL_HEIGHT - 7,
            alignment   = Alignment.LEFT,
            font        = .SMALL,
            color       = red,
        );

        draw_text(
            "jumps over the lazy dog.",
            x = 1,
            y = PIXEL_HEIGHT - 14,
            alignment   = Alignment.LEFT,
            font        = .SMALL,
            color       = seafoam,
        );

        draw_text(
            "the quick brown fox",
            x = PIXEL_WIDTH - 1,
            y = PIXEL_HEIGHT - 20,
            alignment   = Alignment.RIGHT,
            font        = .MAIN,
            color       = blue,
        );

        draw_text(
            "jumps over the lazy dog.",
            x = PIXEL_WIDTH - 1,
            y = PIXEL_HEIGHT - 28,
            alignment   = Alignment.RIGHT,
            font        = .MAIN,
            color       = yellow,
        );

        draw_text(
            "Yeah!",
            x = 120,
            y = 170,
            alignment   = Alignment.RIGHT,
            font        = .SMALL,
            color       = rainbow_color,
        );
    }

    draw_clock_readout();
}

simulate_demo :: (dt: float) {
    {
        margin :: 4;
        box := Box.{PIXEL_WIDTH - 40 - margin, margin, 40, 20};
        if button(box, "Click!") {
            play_sfx("click");
        }
    }
}
