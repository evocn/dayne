// Dayne
// Interface
// Alex Hartford
// March 2024

// This file includes functions which define how the Input gathered elsewhere
// should be applied to program systems.

////////////////////////////////////////////////////////////////////////////////
// Main Game Inputs

apply_player_inputs_to_game :: (game: *Game) {
    if game.player.input.select.just_pressed {
        change_scene(.MENU);
    }

    apply_inputs_from_player_to_game(game.player, game);
}

apply_inputs_from_player_to_game :: (player: Game.Player, game: *Game) {
    input := player.input;
    state := player.state;

    if #complete state == {
        case .NO_INPUT; {
        }

        case .DEFAULT; {
            if input.south.just_pressed {
                spine_next(*game.spine);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Miscellaneous Program States

apply_input_to_title :: (input: Input) {
    if input.south.just_pressed {
        change_scene(.GAME);
    }

    if input.select.just_pressed {
        change_scene(.MENU);
    }
}


apply_input_to_end :: (input: Input) {
    if input.south.just_pressed {
        program_state.running = false;
    }

    if input.north.just_pressed {
        // Reset game state to the beginning. Do it all over again.
    }
}


apply_input_to_menu :: (menu: *Menu, input: Input) {
    if input.select.just_pressed {
        return_to_prior_scene();
    }

    if input.up.just_pressed {
        menu.element_index -= 1;
        if menu.element_index < 0 {
            menu.element_index += 1;
        }
    }
    if input.down.just_pressed {
        menu.element_index += 1;
        if menu.element_index >= menu.elements.count {
            menu.element_index -= 1;
        }
    }
    if input.left.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index], left=true);
    }
    if input.right.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index]);
    }

    if input.south.just_pressed {
        toggle_menu_element(menu.elements[menu.element_index]);
    }
}

apply_input_to_editor :: (input: Input) {
}

