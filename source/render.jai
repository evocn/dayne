
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

            if #complete program_state.current_mode == {
                case .TITLE;
                    draw_title_screen();
                    draw_version_indicator();
                    draw_build_type();

                case .GAME;
                    draw_game(game);

                case .MENU;
                    draw_menu(menu);

                case .DEMO;
                    draw_demo();
            }

            draw(*ui_context);
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
