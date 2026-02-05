
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

textbox_texts :: string.[
    "Testing...",
    "The gentle and yielding is the disciple of life.",
    "What time is it?",
    "The quick brown fox jumps over the lazy dog.",
];
textbox_text_index : int;

simulate_demo :: (dt: float) {
    // Textbox
    {
        visuals := Text_Box_Visuals_Default;
        visuals.text.font_kind = .SMALL;

        margin :: 10;
        box := Box.{margin, margin, PIXEL_WIDTH - (margin * 2), 15};
        text_box(box, textbox_texts[textbox_text_index], visuals = visuals);
    }

    // UI
    {
        // Buttons
        {
            {
                margin :: 4;
                box := Box.{PIXEL_WIDTH - 40 - margin, PIXEL_HEIGHT / 2 - 12 / 2, 40, 12};
                if button(box, "Click!") {
                    play_sfx("click");
                }
            }

            visuals := Button_Visuals_Default;
            visuals.colors.box.neutral = color_none;
            visuals.colors.outline.neutral = color_none;

            margin_x :: 10;
            margin_y :: 26;
            box := Box.{PIXEL_WIDTH - 22 - margin_x, margin_y, 10, 10};
            if button(box, "<&1", visuals = visuals) {
                textbox_text_index -= 1;
                if textbox_text_index < 0 then textbox_text_index = textbox_texts.count-1;
            }
            box.x += 12;

            if button(box, ">&1", visuals = visuals) {
                textbox_text_index += 1;
                if textbox_text_index == textbox_texts.count then textbox_text_index = 0;
                log("%", textbox_text_index);
            }
            box.x += 12;
        }

        // Tooltips
        {
            box := Box.{0, 0, 40, 14};
            tooltip(box, "right", ">&1");

            tooltip(box, "left", "<&1");
        }
    }
}
