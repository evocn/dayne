// Dayne
// State
// February 2024

using program_state : struct {
    RELEASE_BUILD :: #run BUILD_TYPE == .RELEASE;

    VERSION :: struct {
        major :: 0;
        minor :: 1;
    }

    show_debug_info : bool = false;

    ////////////////////////////////////////////////////////////////////////////

    running := true;
    current_scene : Scene = .TITLE;
    prior_scene : Scene;

    game    : Game;
    editor  : Editor;

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
        imgui_context   : *ImGui.ImGuiContext;

        imgui_capturing_mouse    := false;
        imgui_capturing_keyboard := false;
    }

    scratch_memory  : Flat_Pool;

    ////////////////////////////////////////////////////////////////////////////

    framerate : float;

    using simulation_state : struct {
        frozen  : bool;
        step    : bool;
    }

    want_screenshot : bool;
}


// Scenes
////////////////////////////////////////////////////////////////////////////////

Scene :: enum {
    TITLE;
    GAME;
    MENU;

    EDITOR;
    DEMO;
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
