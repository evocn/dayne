// Dayne
// State
// February 2024

using program_state : struct {
    VERSION :: struct {
        major :: 0;
        minor :: 1;
    }

    mode : enum {
        NORMAL;
        DEBUG;
    }
    DEBUG_MEMORY :: true;

    ////////////////////////////////////////////////////////////////////////////

    running := true;
    current_scene : Scene = .TITLE;
    prior_scene : Scene;

    input : Input;

    game    : Game;
    editor  : Editor;

    graphics_context    : Graphics_Context;
    audio_context       : Audio_Context;

    ////////////////////////////////////////////////////////////////////////////

    using external_components : struct {
        window          : *SDL_Window;
        gl_context      : *SDL_GLContext;
        imgui_context   : *ImGui.ImGuiContext;

        imgui_capturing_mouse    := false;
        imgui_capturing_keyboard := false;
    }

    scratch_memory  : Flat_Pool;

    ////////////////////////////////////////////////////////////////////////////

    framerate : float;

    using simulation_state : struct {
        paused : bool;
        step : bool;
    }
}


// Scenes
////////////////////////////////////////////////////////////////////////////////

Scene :: enum {
    TITLE;
    MENU;
    EDITOR;
    GAME;
}

switch_scene :: (new_scene: Scene) {
    using program_state;

    prior_scene = current_scene;
    current_scene = new_scene;
}

return_to_prior_scene :: () {
    using program_state;

    current_scene, prior_scene = swap(current_scene, prior_scene);
}
