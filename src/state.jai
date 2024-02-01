// Dayne
// State
// Alex Hartford
// February 2024

Program_State :: struct {
    current_scene : Scene = .GAME;
    prior_scene : Scene;

    imgui_capturing_mouse    := false;
    imgui_capturing_keyboard := false;
    framerate : float;
}

////////////////////////////////////////////////////////////////////////////////
// Scene
////////////////////////////////////////////////////////////////////////////////

Scene :: enum {
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




////////////////////////////////////////////////////////////////////////////////
// Player Interface State
////////////////////////////////////////////////////////////////////////////////

Player_Interface_State :: enum {
    DEFAULT;
}

Player_Interface :: struct {
    state : Player_Interface_State;
}

resolve_player_interface_inputs :: (player_interface: Player_Interface, input: User_Input, dt: float) {
    if #complete player_interface.state == {
        case .DEFAULT;            
            if input.up.just_pressed {
            }
    }
}
