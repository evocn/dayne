// Dayne
// Initialize
// Alex Hartford
// February 2024

window          : *SDL_Window;
gl_context      : *SDL_GLContext;
imgui_context   : *ImGui.ImGuiContext;


initialize_everything :: () {
    set_working_directory_to_base_folder :: () {
        executable_path := path_strip_filename(System.get_path_of_running_executable());
        set_working_directory(tprint("%/../", executable_path));
    }
    set_working_directory_to_base_folder();


    initialize_sdl();
    initialize_gl();
    initialize_imgui();


    initialize_render_context();

    initialize_audio_context();


    // Tweaks File
    tweaks_apply_defaults();
    tweaks_file_exists := tweaks_load_from_file_and_apply("all");
    if tweaks_file_exists then log("Applied tweaks file settings.\n");
}

////////////////////////////////////////////////////////////////////////////////
// Subsystem Initialization
////////////////////////////////////////////////////////////////////////////////

initialize_sdl :: () {
    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK);

    window = SDL_CreateWindow("Dayne",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 
        render_context.window_width, render_context.window_height,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN
    );

    if !window {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        assert(false);
    }
    SDL_SetWindowResizable(window, xx false);

    // Settings
    {
        SDL_ShowCursor(0);

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);
    }
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


initialize_imgui :: () {
    imgui_context = ImGui.CreateContext();
    ImGui_ImplSdl_Init(window);

    // Settings
    {
        io := ImGui.GetIO();
        io.Fonts.AddFontFromFileTTF(io.Fonts, "assets/fonts/cascadia.ttf", render_context.window_height / 30.0, null, io.Fonts.GetGlyphRangesDefault(io.Fonts));

        // Default location
        io.IniFilename = "bin/imgui.ini";

        ImGui.StyleColorsClassic();
        //ImGui.StyleColorsLight();
    }
}


initialize_render_context :: () {
    using render_context;

    // Shaders
    basic_shader = make_shader("screen.vs", "basic.fs");
    sprite_shader= make_shader("screen.vs", "texture.fs");
    text_shader  = make_shader("text.vs", "text.fs");
    quad_shader  = make_shader("quad.vs", "quad.fs");

    // Primitives
    initialize_quad_rendering_objects(*quad);

    // Buffers
    initialize_framebuffer();

    initialize_fonts :: () {
        initialize_freetype();

        // High-res fonts
        initialize_font(*render_context.main_font,  "verdanab.ttf", xx (render_context.window_height / 16));
        initialize_font(*render_context.big_font,   "verdanab.ttf", xx (render_context.window_height / 10));
        initialize_font(*render_context.small_font, "verdana.ttf",  xx (render_context.window_height / 24));

        // Pixel fonts
        /*
        initialize_font(*render_context.main_font,  "bm.ttf", 9);
        initialize_font(*render_context.big_font,   "bm.ttf", 18);
        initialize_font(*render_context.small_font, "3x5.ttf", 8);
        */

        FT_Done_FreeType(ft);
    }
    initialize_fonts();


    // Sprites
    {
        paths := File_Utilities.file_list(sprites_path, recursive = true, follow_symlinks = false);
        for path : paths {
            success := load_sprite(path);
            assert(success);

            free(path.data);
        }

        array_reset(*paths);
    }

    // Spritesheets
    {
        paths := File_Utilities.file_list(spritesheets_path, recursive = true, follow_symlinks = false);
        for path : paths {
            success := load_spritesheet(path);
            assert(success);

            free(path.data);
        }

        array_reset(*paths);
    }
}


initialize_audio_context :: () {
    using audio_context;

    result := ma_engine_init(null, *engine);
    if result != .MA_SUCCESS {
        log_error("Unable to initialize the miniaudio engine!\n");
        assert(false);
    }

    // Sound Groups
    {
        result = ma_sound_group_init(*engine, 0, null, *music_group);
        if result != .MA_SUCCESS {
            log_error("Unable to initialize one or more sound groups.\n");
            assert(false);
        }

        result = ma_sound_group_init(*engine, 0, null, *sfx_group);
        if result != .MA_SUCCESS {
            log_error("Unable to initialize one or more sound groups.\n");
            assert(false);
        }
    }

    // SFX
    {
        paths := File_Utilities.file_list(sfx_path, recursive = true, follow_symlinks = false);
        for path : paths {
            load_sfx(path);
            free(path.data);
        }

        array_reset(*paths);
    }

    // Music
    {
        paths := File_Utilities.file_list(music_path, recursive = true, follow_symlinks = false);
        for path : paths {
            load_music(path);
            free(path.data);
        }

        array_reset(*paths);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Shutdown
////////////////////////////////////////////////////////////////////////////////

// Note that this function doesn't actually need to exist. The OS will always clean our stuff up.
// This is just here so we can clean house and see the real leaks if they happen when we are debugging memory.
cleanup_for_shutdown :: (game: *Game) {
    // Cleanup Game Struct
    {
    }

    // Audio Cleanup
    {
        using audio_context;

        for sfx {
            free(it_index.data);
            ma_sound_uninit(it);
        }
        deinit(*sfx);

        for music {
            free(it_index.data);
            ma_sound_uninit(it);
        }
        deinit(*music);

        ma_engine_uninit(*engine);
    }

    array_reset(*main_menu.elements);
    deinit(*render_context.main_font.characters);
    deinit(*render_context.small_font.characters);
    reset(*scratch_memory, overwrite_memory=true);

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

