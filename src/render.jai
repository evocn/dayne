// Dayne
// Render
// Alex Hartford
// February 2024

render :: () {
    // Render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, render_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_state.current_scene == {
            case .DEMO;
                draw_demo_screen();

            case .GAME;
                draw_game_state();
                draw_user_interface();

            case .MENU;
                render_menu(main_menu);

            case .EDITOR;
        }
    }

    render_framebuffer_to_screen();
}

////////////////////////////////////////////////////////////////////////////////


draw_game_state :: () {
}


draw_user_interface :: () {
}


////////////////////////////////////////////////////////////////////////////////
// Below this is the specialized code for rendering various fixtures.
// It is all here to have centralized drawing code, separate from 
// implementation details.
////////////////////////////////////////////////////////////////////////////////

draw_demo_screen :: () {
    /*
    draw_sprite(
        render_context.haruhachi,
        index = 0,
        pixel = .{0, 0},
        scale_factor = 1,
    );
    */

    draw_sprite(
        render_context.spritesheet,
        index = 4,
        pixel = .{PIXEL_WIDTH - 64, 0},
        scale_factor = 4,
        horizontal_flip = true,
    );

    draw_sprite(
        render_context.spritesheet,
        index = 5,
        pixel = .{PIXEL_WIDTH - 80, 0},
        scale_factor = 1,
    );

    draw_sprite(
        render_context.spritesheet,
        index = 6,
        pixel = .{PIXEL_WIDTH - 96, 0},
        scale_factor = 1,
    );

    draw_sprite(
        render_context.spritesheet,
        index = 7,
        pixel = .{PIXEL_WIDTH - 112, 0},
        scale_factor = 1,
    );

    draw_text(
        "Dayne", 
        x = PIXEL_WIDTH  / 2, 
        y = PIXEL_HEIGHT * 3 / 4,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = green,
    );

    draw_text(
        "PROTOTYPING ENGINE",
        x = PIXEL_WIDTH  / 2,
        y = PIXEL_HEIGHT * 3 / 4 - 10,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .SMALL,
        color       = red,
    );

    draw_text(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,/\\!?@#$%^&*<>{}()[]",
        x = PIXEL_WIDTH / 2,
        y = PIXEL_HEIGHT * 3 / 4 - 20,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .SMALL,
        color       = yellow,
    );
}



////////////////////////////////////////////////////////////////////////////////
// Menu
////////////////////////////////////////////////////////////////////////////////

render_menu :: (using menu: Menu) {
    k := 10;

    for elements {
        draw_menu_element(it, PIXEL_HEIGHT - (it_index + 1) * k, color=it.usual_color);
    }

    // Draw selected element over it.
    if elements.count {
        hovering := *elements[element_index];
        draw_menu_element(hovering.*, PIXEL_HEIGHT - (element_index + 1) * k, color=hovering.*.hover_color);
    }
}

draw_menu_element :: (using element: *Menu_Element, height : int, color := white) {
    if kind == {
        case .GO;
            using cast(*Menu_Element_Go)element;
            draw_text(name, 1, height, color=color);

        case .CHECKBOX;
            using cast(*Menu_Element_Checkbox)element;
            str := "Off";
            if value.* then str = "On";
            draw_text(tprint("% - %", name, str), 1, height, color=color);

        case .SLIDER;
            using cast(*Menu_Element_Slider)element;
            draw_text(tprint("% - %", name, value), 1, height, color=color);
    }
}
