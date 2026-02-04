
// Menu (Using the UI system)
////////////////////////////////////////////////////////////////////////////////

menu_ui :: () {
    visuals := Button_Visuals_Transparent;
    visuals.text.alignment = .RIGHT;

    separation :: 0;
    margin_x :: 0;
    margin_y :: 1;
    width :: 100;
    height :: 10;
    box := Box.{PIXEL_WIDTH - width - margin_x, margin_y, width, height};

    // Elements
    {
        // Quit
        {
            if button(box, "Quit", visuals = visuals) {
                #if DEVELOPER_TOOLS {
                    save_tweaks_file("all");
                }
                quit_game();
            }
            box.y += height + separation;
        }

        // Music
        {
            button_text := tprint("Music: %", Sound_Player.mix_levels[Sound_Category.MUSIC]);
            if button(box, button_text, visuals = visuals) {
                Sound_Player.mix_levels[Sound_Category.MUSIC] += 0.25;
                if Sound_Player.mix_levels[Sound_Category.MUSIC] > 1.0 {
                    Sound_Player.mix_levels[Sound_Category.MUSIC] = 0.0;
                }
            }
            box.y += height + separation;
        }

        // Sfx
        {
            button_text := tprint("Sfx: %", Sound_Player.mix_levels[Sound_Category.GENERAL_SFX]);
            if button(box, button_text, visuals = visuals) {
                Sound_Player.mix_levels[Sound_Category.GENERAL_SFX] += 0.25;
                if Sound_Player.mix_levels[Sound_Category.GENERAL_SFX] > 1.0 {
                    Sound_Player.mix_levels[Sound_Category.GENERAL_SFX] = 0.0;
                }
            }
            box.y += height + separation;
        }

        // Windowing
        {
            button_text := tprint("%", ifx window_context.fullscreen then "Fullscreen" else "Windowed");
            if button(box, button_text, visuals = visuals) {
                window_context.fullscreen = !window_context.fullscreen;
                set_screen_mode_according_to_fullscreen_variable();
            }
            box.y += height + separation;
        }

        // Resume
        {
            if button(box, "Resume", visuals = visuals) {
                resume_game();
            }
            box.y += height + separation;
        }
    }
}
