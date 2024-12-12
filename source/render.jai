// Dayne
// Render
// August 2024

render :: (game: Game, menu: Menu) {
    // render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, graphics_context.fbo);
        glViewport(0, 0, xx PIXEL_WIDTH, xx PIXEL_HEIGHT);
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

draw_user_interface :: (using game: Game) {
    // Draw Boosts
    {
        max_boosts := BOOSTS;
        boosts := p1.boosts;

        i := 0;
        while i < max_boosts {
            if i < boosts {
                draw_sprite_on_screen(.{PIXEL_WIDTH / 2 + TILE_SIZE * i, PIXEL_HEIGHT - TILE_SIZE}, "ui", frame = 0);
            }
            else {
                draw_sprite_on_screen(.{PIXEL_WIDTH / 2 + TILE_SIZE * i, PIXEL_HEIGHT - TILE_SIZE}, "ui", frame = 1);
            }
            i += 1;
        }
    }
}

z_sort :: (entities: [..] *Entity) {
    comparison :: (a: *Entity, b: *Entity) -> int { 
        if a.z_index > b.z_index        return 1;
        else if a.z_index < b.z_index   return -1;
        else return b.id - a.id;
    }
    quick_sort(entities, comparison);
}

draw_game :: (using game : Game) {
    // Dungeon
    {
        draw(dungeon.rooms[dungeon.current]);
    }

    // Entities
    {
        z_sort(entities);

        for entity : entities {
            draw(entity);
        }
    }

    // Debug Overlays
    if .DEBUG == program_state.mode {
        draw_debug(dungeon.rooms[dungeon.current]);

        for entity : entities {
            draw_debug(entity);
        }

        draw(debug);
    }
}
