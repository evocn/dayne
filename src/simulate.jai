// Dayne
// Simulate
// Alex Hartford
// February 2024

Game_State :: struct {
    score : int;
    players : [..] Player_Interface;
}

////////////////////////////////////////////////////////////////////////////////

simulate :: (game_state: Game_State, dt: float) {
    if game_state.players[0].input.start.just_pressed {
        switch_scene(.MENU);
    }

    if #complete game_state.players[0].state == {
        case .DEFAULT;            
            if game_state.players[0].input.up.just_pressed {
            }
    }
}

////////////////////////////////////////////////////////////////////////////////

simulate_menu :: (menu: *Menu, input: User_Input) {
    if input.start.just_pressed || input.east.just_pressed {
        return_to_prior_scene();
        play_sfx("click");
    }

    if input.up.just_pressed {
        menu.element_index -= 1;
        if menu.element_index < 0 {
            menu.element_index += 1;
        }
        play_sfx("click");
    }
    if input.down.just_pressed {
        menu.element_index += 1;
        if menu.element_index >= menu.elements.count {
            menu.element_index -= 1;
        }
        play_sfx("click");
    }
    if input.left.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index], left=true);
        play_sfx("click");
    }
    if input.right.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index]);
        play_sfx("click");
    }

    if input.south.just_pressed {
        toggle_menu_element(menu.elements[menu.element_index]);
    }
}

////////////////////////////////////////////////////////////////////////////////

simulate_editor :: (input: User_Input) {
}
