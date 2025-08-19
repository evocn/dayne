
// The core rendering loop
////////////////////////////////////////////////////////////////////////////////

render :: (game: Game, menu: Menu) {
    // render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, graphics_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);

        // Real drawing work
        {
            glClearColor(graphics_context.background_color.x, graphics_context.background_color.y, graphics_context.background_color.z, 1);
            glClear(GL_COLOR_BUFFER_BIT);

            if #complete program_state.current_scene == {
                case .TITLE;
                    draw_title_screen();
                    draw_version_indicator();
                    draw_build_type();

                case .GAME;
                    draw_game(game);
                    draw_user_interface(game);

                case .MENU;
                    draw_menu(menu);

                case .DEMO;
                    draw_demo();
            }
        }

        #if DEVELOPER_TOOLS {
            if program_state.show_debug_info {
                draw(debug_messages);

                draw(last_frame_report);
            }

            if want_screenshot {
                screenshot();
                want_screenshot = false;
            }
        }
    }

    render_framebuffer_to_screen();
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

        use_sprite_shader();
        for entity : game.entities {
            draw(entity);
        }
    }

    #if DEVELOPER_TOOLS {
        if program_state.show_debug_info {

            // This is dumb code, which works since most entities' "draw_debug()" just draws a dumb quad.
            // The more full-featured solution to this (and the use_sprite_shader() above) is to do actual batching of draw calls.
            // For now, we're cool.
            use_basic_shader();

            for entity : game.entities {
                draw_debug(entity);
            }
        }
    }
}

draw_user_interface :: (game: Game) {
    #if DEVELOPER_TOOLS {
        // For now, we'll just not draw these elements when we're editing.
        if program_state.editor.active {
            return;
        }
    }

    draw_mouse_cursor(input_one.mouse.position);

}
