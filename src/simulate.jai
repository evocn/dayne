////////////////////////////////////////////////////////////////////////////////

simulate :: (game: Game, dt: float) {
    for player : game.players {
        input := player.input;
        state := player.state;

        if input.select.just_pressed {
            change_scene(.MENU);
        }

        if #complete state == {
            case .DEFAULT;            
                if input.up.just_pressed {
                }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

simulate_title :: (input: User_Input) {
    if input.south.just_pressed {
        change_scene(.GAME);
        play_sfx("sea");
    }

    if input.select.just_pressed {
        change_scene(.MENU);
        play_sfx("click");
    }
}

////////////////////////////////////////////////////////////////////////////////

simulate_menu :: (menu: *Menu, input: User_Input) {
    if input.select.just_pressed {
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
