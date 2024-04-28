// Dayne
// Program State
// Alex Hartford
// February 2024

// This file is poorly named. Its purpose is to govern overall program state -
// things which are essentially global facts about the program at a point in time.

Program_State :: struct {
    running := true;
    framerate : float;

    //

    Scene :: enum {
        TITLE;
        GAME;
        MENU;
        EDITOR;
    }
    current_scene : Scene = .TITLE;
    prior_scene : Scene;

    //

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;

    draw_demo : bool;
}

change_scene :: (new_scene: Program_State.Scene) {
    using program_state;

    prior_scene = current_scene;
    current_scene = new_scene;
}

return_to_prior_scene :: () {
    using program_state;

    current_scene, prior_scene = swap(current_scene, prior_scene);
}
