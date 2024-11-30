// Dayne
// Render
// August 2024

render :: (game: Game, menu: Menu) {
    // render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, graphics_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_state.current_scene == {
            case .TITLE;
                draw_title_screen();
                draw_version_indicator();

            case .GAME;
                draw_game(game);
                draw_user_interface(game);

            case .MENU;
                draw_menu(menu);

            case .EDITOR;
                draw_game(game);
                // see editor.jai for more.
        }
    }

    render_framebuffer_to_screen();
}

draw_user_interface :: (game: Game) {
}

z_sort :: (entities: [..] *Entity) {
    comparison :: (a: *Entity, b: *Entity) -> int { 
        if a.z_index > b.z_index        return 1;
        else if a.z_index < b.z_index   return -1;
        else return b.id - a.id;
    }
    quick_sort(entities, comparison);
}

draw_overworld :: (using game: Game) {
    // Entities
    {
        z_sort(game.entities);

        for entity : game.entities {
            draw(entity);
        }
    }
}

draw_game :: (using game : Game) {
    draw_overworld(game);

    if game.spine.state == {
        case .OVERWORLD;

        case .SPEC;
            origin := Pair.{0, PIXEL_HEIGHT / 2};
            draw_stats(hero, origin);

        case .CHOOSE;
            origin := Pair.{0, PIXEL_HEIGHT - TILE_SIZE_IN_PIXELS};
            draw_fighter(hero, origin);

            origin = Pair.{PIXEL_WIDTH / 2, PIXEL_HEIGHT - TILE_SIZE_IN_PIXELS};
            draw_fighter(foe, origin);

        case .ROLL;
            if !result {
                print("What the hell? You're supposed to have rolled a result, man.\n");
            }

            origin := Pair.{PIXEL_WIDTH / 2, PIXEL_HEIGHT / 2};
            draw(result, origin);
            draw_number(sum(result), origin + .{0, TILE_SIZE_IN_PIXELS});

            /*
            origin := Pair.{PIXEL_WIDTH / 2, PIXEL_HEIGHT / 2};
            draw(pool, origin);
            */
    }

    // Debug Overlays
    draw_text(tprint("%", spine.state), 0, 0);

    if .DEBUG == program_state.mode {
        for entity : game.entities {
            draw_debug(entity);
        }
    }
}
