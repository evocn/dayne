
// Initialize
////////////////////////////////////////////////////////////////////////////////

initialize_everything :: () {
    initialize_sdl();
    initialize_gl();

    initialize_window_context();
    initialize_graphics_context();
    initialize_audio_context();
    initialize_ui_context();

    #if DEVELOPER_TOOLS {
        initialize_imgui();
    }

    apply_default_settings :: () {
        window_context.fullscreen = false;
        set_screen_mode_according_to_fullscreen_variable();

        Sound_Player.mix_levels[Sound_Category.GENERAL_SFX] = 0.5;
        Sound_Player.mix_levels[Sound_Category.MUSIC]       = 0.5;
    }
    apply_default_settings();

    #if DEVELOPER_TOOLS {
        // Tweaks File
        tweaks_file_exists := load_tweaks_file_and_apply_results("all");
        if tweaks_file_exists then log("Applied tweaks file settings.\n");

        // stbi
        stbi_flip_vertically_on_write(xx true);
    }

    // Disable the debug console in Release builds.
    #if BUILD_TYPE == .RELEASE {
        #run {
            #if OS == .WINDOWS {
                WR :: #import "Windows_Resources";
                WR.disable_runtime_console();
            }
        }
    }
}


// Subsystem Initialization ////////////////////////////////////////////////////
initialize_sdl :: () {
    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK);

    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "opengl");

    window = SDL_CreateWindow(program_title,
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, window_context.window_width, window_context.window_height,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

    if !window {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        assert(false);
    }
    SDL_SetWindowResizable(window, xx false);

    // Settings
    {
        SDL_ShowCursor(0);
        SDL_SetRelativeMouseMode(SDL_FALSE);

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
    }

    /*
    // Log drivers that are available, in the order of priority SDL chooses them.
    // Useful for e.g. debugging which ones a particular build of SDL contains.
    for 0..SDL_GetNumRenderDrivers()-1 {
        info : SDL_RendererInfo;
        SDL_GetRenderDriverInfo(it, *info);
        log("%. %", it + 1, to_string(cast(*u8)info.name));
    }
    */
}


initialize_gl :: () {
    gl_context = SDL_GL_CreateContext(window);
    if !gl_context {
        print("Could not create OpenGL context: %\n", to_string(SDL_GetError()));
        assert(false);
    }
    gl_load(*gl, SDL_GL_GetProcAddress);

    // Settings
    {
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }
}

#if DEVELOPER_TOOLS {
initialize_imgui :: () {
    program_state.editor.imgui_state.imgui_context = ImGui.CreateContext();
    ImGui_ImplSdl_Init(window);

    io := ImGui.GetIO();
    io.IniFilename = "bin/imgui.ini";

    font_size := program_state.window_context.window_height / 60.0;
    log("%", font_size);
    io.Fonts.AddFontFromFileTTF(io.Fonts, "assets/fonts/Merriweather/Merriweather-VariableFont_opsz,wdth,wght.ttf", font_size, null, io.Fonts.GetGlyphRangesDefault(io.Fonts));

    // Settings
    {
        ImGui.StyleColorsClassic();
        //ImGui.StyleColorsLight();
    }
}
}


initialize_graphics_context :: () {
    using graphics_context;

    // Shaders
    basic_shader = make_shader("screen.vs", "basic.fs");
    sprite_shader= make_shader("screen.vs", "texture.fs");
    text_shader  = make_shader("text.vs", "text.fs");
    quad_shader  = make_shader("quad.vs", "quad.fs");

    // Primitives
    initialize_quad_rendering_objects(*quad);

    // Buffers
    initialize_framebuffer();

    // Initialize Fonts
    {
        initialize_freetype();

        initialize_font(*main_font,  "bm.ttf", 9);

        //initialize_font(*small_font, "gosub.otf", 6);
        //initialize_font(*small_font, "small_5x3.ttf", 7);
        initialize_font(*small_font, "bit5x3.ttf", 8);
        //initialize_font(*small_font, "pix3l5.ttf", 7);

        FT_Done_FreeType(ft);
    }

    // Initialize Sprites
    {
        TILE_SIZE_IN_PIXELS :: 16;

        // This array is of sprites who we know are not TILE_SIZE_IN_PIXELS x TILE_SIZE_IN_PIXELS.
        size_exceptions : Table(string, Pair);
        {
            table_add(*size_exceptions, "haruhachi", .{208, 256});
        }

        sprite_paths := file_list(sprites_path, recursive = true, follow_directory_symlinks = false,, allocator=temp);
        for path : sprite_paths {
            if path_extension(path) != "png" then continue;

            name := basename(path);

            width  := TILE_SIZE_IN_PIXELS;
            height := TILE_SIZE_IN_PIXELS;
            success, dimensions := table_find_new(*size_exceptions, name);
            if success {
                width  = dimensions.x;
                height = dimensions.y;
            }

            sprite := table_add(*graphics_context.sprites, copy_string(name), load_sheet(path, width, height));
            assert(sprite.loaded);
        }

        deinit(*size_exceptions);
    }
}


initialize_audio_context :: () {
    using audio_context;

    devices := get_devices();
    #if DEVELOPER_TOOLS {
        print("devices: %\n", devices);
    }

    success := sound_player_init(.{});
    assert(success);

    // SFX
    {
        sfx_paths := file_list(sfx_path, recursive = true, follow_directory_symlinks = false,, allocator=temp);
        for path : sfx_paths {
            name := basename(path);

            sfx := table_add(*audio_context.sfx, copy_string(name), load_audio_file(path));
            assert(sfx.loaded);
        }
    }

    // Music
    {
        music_paths := file_list(music_path, recursive = true, follow_directory_symlinks = false,, allocator=temp);
        for path : music_paths {
            name := basename(path);

            music := table_add(*audio_context.music, copy_string(name), load_audio_file(path));
            assert(music.loaded);
        }
    }
}

initialize_ui_context :: () {
    initialize(*ui_context);
}

//
// Shutdown ////////////////////////////////////////////////////////////////////
//

// Note that this function doesn't actually need to exist. The OS will always clean our stuff up.
// This is just here so we can clean house and see the real leaks if they happen when we are debugging memory.
cleanup_for_shutdown :: (game: *Game, menu: *Menu) {
    // Game Cleanup
    {
        finalize(game);
    }

    // UI Cleanup
    {
        finalize(*ui_context);
    }

    // Audio Cleanup
    {
        sound_player_shutdown();
    }

    // Graphics Cleanup
    {
        using graphics_context;

        deinit(*main_font.characters);
        deinit(*small_font.characters);
    }

    array_reset(*menu.elements);

    reset(*scratch_memory, overwrite_memory=true);

    #if DEVELOPER_TOOLS {
        ImGui_ImplSdl_Shutdown();
        ImGui.DestroyContext(program_state.editor.imgui_state.imgui_context);
    }

    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}
