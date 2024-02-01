// Dayne
// Simulate
// Alex Hartford
// February 2024

simulate :: (player_interface: Player_Interface, input: User_Input, menu: *Menu, dt: float) {
    // Nonsense
    rainbow_color = update_rainbow_color(dt);

    // Core Simulation Logic
    if #complete program_state.current_scene == {
        case .GAME;
            resolve_game_inputs(player_interface, input, dt);

        case .MENU;
            resolve_menu_inputs(menu, input);

        case .EDITOR;
            resolve_editor_inputs(input);
    }
}

resolve_game_inputs :: (player_interface: Player_Interface, input: User_Input, dt: float) {
    if input.start.just_pressed {
        switch_scene(.MENU);
    }

    resolve_player_interface_inputs(player_interface, input, dt);
}
