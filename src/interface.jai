// Dayne
// Interface
// Alex Hartford
// March 2024

// This file includes functions which define how the Input gathered elsewhere
// should be applied to different program systems.
// For instance, what should inputs do to the title screen? To the Game? Menus?
// That's here for now. Maybe later it will go somewhere nicer.

////////////////////////////////////////////////////////////////////////////////
// Main Game Inputs

apply_player_inputs_to_game :: (game: *Game) {
    for player : game.players {
        if player.input.select.just_pressed {
            change_scene(.MENU);
        }

        apply_inputs_from_player_to_game(player, game);
    }
}

apply_inputs_from_player_to_game :: (player: Game.Player, game: *Game) {
    input := player.input;
    state := player.state;

    if #complete state == {
        case .NO_INPUT; {           
        }

        case .DEFAULT; {           
            if input.up.just_pressed {
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Miscellaneous Program States

apply_input_to_title :: (input: Input) {
    if input.south.just_pressed {
        change_scene(.GAME);
        play_sfx("sea");
    }

    if input.select.just_pressed {
        change_scene(.MENU);
        play_sfx("click");
    }
}


apply_input_to_menu :: (menu: *Menu, input: Input) {
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


apply_input_to_editor :: (input: Input) {
}
