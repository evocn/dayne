// Dayne
// Initialize
// Alex Hartford
// February 2024

initialize_everything :: () {
    set_working_directory_to_base_folder();

    initialize_sdl();
    initialize_gl();
    initialize_imgui();

    initialize_rendering_structures();

    initialize_images();

    initialize_fonts();

    initialize_audio();

    apply_default_settings();
    tweaks_file_exists := load_tweaks_file_and_apply_results("all");
    if tweaks_file_exists then log("Applied tweaks file settings.\n");
}

////////////////////////////////////////////////////////////////////////////////
// Subsystem Initialization ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

initialize_sdl :: () {
    SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK);

    window = SDL_CreateWindow("Dayne",
        SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, window_width, window_height,
        SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

    if !window {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        assert(false);
    }
    SDL_SetWindowResizable(window, xx false);

    // Settings
    {
        SDL_ShowCursor(0);
        SDL_SetRelativeMouseMode(SDL_TRUE);

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

    io := ImGui.GetIO();
    io.Fonts.AddFontFromFileTTF(io.Fonts, "assets/fonts/verdanab.ttf", window_height / 50.0, null, io.Fonts.GetGlyphRangesDefault(io.Fonts));

    // Settings
    {
        ImGui.StyleColorsClassic();
        //ImGui.StyleColorsLight();
    }
}


initialize_audio :: () {
    result := ma_engine_init(null, *audio_context.engine);
    if result != .MA_SUCCESS {
        log_error("Unable to initialize the miniaudio engine!\n");
        assert(false);
    }

    {
        // Sound Groups
        result = ma_sound_group_init(*audio_context.engine, 0, null, *audio_context.music_group);
        if result != .MA_SUCCESS {
            log_error("Unable to initialize one or more sound groups.\n");
            assert(false);
        }

        result = ma_sound_group_init(*audio_context.engine, 0, null, *audio_context.sfx_group);
        if result != .MA_SUCCESS {
            log_error("Unable to initialize one or more sound groups.\n");
            assert(false);
        }
    }

    {
        // SFX
        sfx_paths := File_Utilities.file_list(sfx_path, recursive = true, follow_symlinks = false);
        for sfx_paths {
            load_sfx(it);
            free(it.data);
        }

        array_reset(*sfx_paths);
    }

    {
        // Music
        music_paths := File_Utilities.file_list(music_path, recursive = true, follow_symlinks = false);
        for music_paths {
            load_music(it);
            free(it.data);
        }

        array_reset(*music_paths);
    }
}

initialize_fonts :: () {
    initialize_freetype();

    initialize_font(*render_context.main_font,  "bm.ttf", 9);
    initialize_font(*render_context.small_font, "gosub.otf", 7);

    FT_Done_FreeType(ft);
}

initialize_rendering_structures :: () {
    using render_context;

    // Shaders
    basic_shader = make_shader("screen.vs", "basic.fs");
    shader       = make_shader("screen.vs", "texture.fs");
    text_shader  = make_shader("text.vs", "text.fs");
    quad_shader  = make_shader("quad.vs", "quad.fs");
    sprite_shader= make_shader("sprite.vs", "texture.fs");

    // Primitives
    initialize_quad_rendering_objects(*quad);

    // Buffers
    initialize_framebuffer();
}

initialize_images :: () {
    success : bool;

    // Spritesheets
    full_path := tprint("%/sheet.png", assets_path);
    success = make_spritesheet(*render_context.spritesheet, full_path, 16);
    assert(success);
}

//
// Various Configuration Functions /////////////////////////////////////////////
//

set_working_directory_to_base_folder :: () {
	executable_path := path_strip_filename(System.get_path_of_running_executable());
	set_working_directory(tprint("%/../", executable_path));
}

deactivate_mouse :: () {
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

activate_mouse :: () {
    SDL_ShowCursor(1);
    SDL_SetRelativeMouseMode(SDL_FALSE);
    SDL_WarpMouseInWindow(window, window_width / 2, window_height / 2);
}

//
// Shutdown ////////////////////////////////////////////////////////////////////
//

// Note that this function doesn't actually need to exist. The OS will always clean our stuff up.
// This is just here so we can clean house and see the real leaks if they happen when we are debugging memory.
cleanup_for_shutdown :: (menu: *Menu) {
    array_reset(*menu.elements);

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

    array_reset(*menu.elements);
    deinit(*render_context.main_font.characters);
    deinit(*render_context.small_font.characters);
    reset(*scratch_memory, overwrite_memory=true);

    ImGui_ImplSdl_Shutdown();
    ImGui.DestroyContext(imgui_context);
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

