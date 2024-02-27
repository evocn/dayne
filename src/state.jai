// Dayne
// State
// Alex Hartford
// February 2024

Program_State :: struct {
    running := true;

    current_scene : Scene = .DEMO;
    prior_scene : Scene;

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;
    framerate : float;
}

////////////////////////////////////////////////////////////////////////////////
// Scene
////////////////////////////////////////////////////////////////////////////////

Scene :: enum {
    DEMO;
    GAME;
    MENU;
    EDITOR;
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
