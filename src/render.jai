// Dayne
// Render
// Alex Hartford
// February 2024

render :: (game_state: Game_State, menu: Menu) {
    // Render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, render_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if #complete program_state.current_scene == {
            case .GAME;
                draw_game_state(game_state);
                draw_user_interface(game_state);

            case .MENU;
                render_menu(menu);

            case .EDITOR;
                draw_game_state(game_state);
                draw_user_interface(game_state);
        }
    }

    render_framebuffer_to_screen();
}


draw_game_state :: (game_state: Game_State) {
    draw_sprite(
        render_context.spritesheet,
        index = 4,
        pixel = .{PIXEL_WIDTH - 64, 0},
        scale_factor = 4,
        horizontal_flip = true,
    );
}


draw_user_interface :: (game_state: Game_State) {
    draw_narrative(game_state.narrative);
}

draw_narrative :: (narrative: Narrative) {
    line := narrative.lines[narrative.index];

    text := line.text;
    color := line.speaker.color;

    draw_text(
        text,
        x = PIXEL_WIDTH  / 2,
        y = PIXEL_HEIGHT / 2,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .SMALL,
        color       = color,
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
