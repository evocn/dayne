
// Program State
////////////////////////////////////////////////////////////////////////////

using program_state : struct {
    DEVELOPER_TOOLS :: #run BUILD_TYPE == .DEBUG;

    ////////////////////////////////////////////////////////////////////////////

    running := true;
    current_scene : Scene = .TITLE;
    prior_scene : Scene;

    game : Game;

    using inputs : struct {
        input_one : Input;
        input_two : Input;
    }

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


// Scenes
////////////////////////////////////////////////////////////////////////////////

Scene :: enum {
    TITLE;
    GAME;
    MENU;

    DEMO;
}

switch_scene :: (new_scene: Scene) {
    using program_state;

    prior_scene = current_scene;
    current_scene = new_scene;
}

return_to_prior_scene :: () {
    using program_state;

    current_scene, prior_scene = prior_scene, current_scene;
}
