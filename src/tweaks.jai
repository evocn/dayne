// Dayne
// Tweaks
// Alex Hartford
// February 2024

tweaks_apply_defaults :: () {
    render_context.fullscreen = false;

    set_screen_mode_according_to_fullscreen_variable();

    DEFAULT_SFX_VOLUME :: 0.5;
    DEFAULT_MUSIC_VOLUME :: 0.5;

    set_sfx_volume(DEFAULT_SFX_VOLUME);
    set_music_volume(DEFAULT_MUSIC_VOLUME);
}

////////////////////////////////////////////////////////////////////////////////

tweaks_save_to_file :: (file_name : string) {
    builder : String_Builder;
    defer free_buffers(*builder);

    // Write to the buffer
    {
        append(*builder, "# Tweaks file\n\n");

        print_to_builder(*builder, "fullscreen %\n", render_context.fullscreen);

        print_to_builder(*builder, "sfx %\n", get_sfx_volume());
        print_to_builder(*builder, "music %\n", get_music_volume());
    }

    full_path := tprint("%/%.tweaks", tweaks_path, file_name);
    write_entire_file(full_path, *builder);
}

tweaks_load_from_file_and_apply :: (file_name : string) -> file_exists: bool {
    handler : Text_File_Handler;
    defer deinit(*handler);
    handler.do_version_number = false;

    full_path := tprint("%/%.tweaks", tweaks_path, file_name);
    start_file(*handler, file_name, full_path);
    if handler.failed return false;

    {
        line, found := consume_next_line(*handler);

        while found {
            successfully_split, left, right := split_from_left(line, #char " ");
            if !successfully_split {
                log_error("Problem parsing the tweaks file!\n");
                return false;
            }

            successfully_parsed : bool;
            if left == {
                case "fullscreen";
                    render_context.fullscreen, successfully_parsed = parse_bool(*right);
                    set_screen_mode_according_to_fullscreen_variable();

                case "sfx";
                    sfx_volume :, successfully_parsed = parse_float(*right);
                    set_sfx_volume(sfx_volume);

                case "music";
                    music_volume:, successfully_parsed = parse_float(*right);
                    set_music_volume(music_volume);
            }
            if !successfully_parsed {
                log_error("Problem parsing the tweaks file!\n");
                return false;
            }

            line, found = consume_next_line(*handler);
        }
    }

    return true;
}
