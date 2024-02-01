// Dayne
// Render
// Alex Hartford
// February 2024

render :: (menu: Menu) {

    // Render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, render_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_state.current_scene == {
            case .GAME;
                draw_game_state();
                draw_user_interface();

            case .MENU;
                render_menu(menu);

            case .EDITOR;
        }
    }

    render_framebuffer_to_screen();
}


draw_game_state :: () {
    draw_spritesheet(
        render_context.spritesheet,
        index = 0,
        pixel = .{30, 30},
    );
}


draw_user_interface :: () {
    draw_text(
        "This is the user interface.", 
        x = PIXEL_WIDTH  / 2, 
        y = PIXEL_HEIGHT / 2,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = green,
    );
}


////////////////////////////////////////////////////////////////////////////////
// Below this is the specialized code for rendering various structures.
// It is all here to have centralized drawing code, separate from 
// implementation details.
////////////////////////////////////////////////////////////////////////////////

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
            using cast(*Go_Element)element;
            draw_text(name, 1, height, color=color);

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            str := "Off";
            if value.* then str = "On";
            draw_text(tprint("% - %", name, str), 1, height, color=color);

        case .SLIDER;
            using cast(*Slider_Element)element;
            draw_text(tprint("% - %", name, value), 1, height, color=color);
    }
}
