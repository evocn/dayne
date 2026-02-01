
// Program State
////////////////////////////////////////////////////////////////////////////

using program_state : struct {
    DEVELOPER_TOOLS :: #run BUILD_TYPE == .DEBUG;

    ////////////////////////////////////////////////////////////////////////////

    running := true;
    current_mode : Mode = .TITLE;
    prior_mode : Mode;

    game : Game;

    using inputs : struct {
        input_one : Input;
        input_two : Input;
    }

    window_context  : Window_Context;
    graphics_context: Graphics_Context;
    audio_context   : Audio_Context;

    ////////////////////////////////////////////////////////////////////////////

    using external_components : struct {
        window          : *SDL_Window;
        gl_context      : *SDL_GLContext;
    }

    scratch_memory  : Flat_Pool;

    ////////////////////////////////////////////////////////////////////////////

    using framerate : struct {
        LOCKED_FPS :: 60;
        LOCKED_DT  :: 1.0 / LOCKED_FPS;
    }

    using simulation_state : struct {
        frozen  : bool;
        step    : bool;
    }

    ////////////////////////////////////////////////////////////////////////////

    #if DEVELOPER_TOOLS {
        show_debug_info : bool = false;

        editor : Editor;

        tracker : Fps_Tracker;
        want_screenshot : bool;
    }
}


// Modes
////////////////////////////////////////////////////////////////////////////////

Mode :: enum {
    TITLE;
    GAME;
    MENU;

    DEMO;
}

switch_mode :: (new_mode: Mode) {
    using program_state;

    prior_mode = current_mode;
    current_mode = new_mode;
}

return_to_prior_mode :: () {
    using program_state;

    current_mode, prior_mode = prior_mode, current_mode;
}
