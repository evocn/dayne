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

draw_game :: (game : Game) {
    // Entities
    {
        z_sort(game.entities);

        for entity : game.entities {
            draw(entity);
        }
    }


    // Debug Overlays
    if .DEBUG == program_state.mode {
        for entity : game.entities {
            draw_debug(entity);
        }
    }
}
