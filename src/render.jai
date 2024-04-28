// Dayne
// Render
// Alex Hartford
// February 2024

render :: (game: Game) {
    // Render everything in this block to the framebuffer.
    {
        glBindFramebuffer(GL_FRAMEBUFFER, render_context.fbo);
        glViewport(0, 0, PIXEL_WIDTH, PIXEL_HEIGHT);
        glClearColor(black.x, black.y, black.z, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        if program_state.draw_demo {
            draw_demo_screen();
            //draw_credits_screen();
        }

        draw_particle_system(the_particle_system);

        draw_pixel(.{50, get_value(the_animator)}, color = rainbow);

        if #complete program_state.current_scene == {
            case .TITLE;
                draw_title_screen();

            case .GAME;
                draw_game_state(game);
                draw_user_interface(game);

            case .EDITOR;
                draw_game_state(game);

                draw_editor_features();

            case .MENU;
                draw_menu(main_menu);
                draw_controls_display();
        }
    }

    render_framebuffer_to_screen();
}

////////////////////////////////////////////////////////////////////////////////


draw_game_state :: (game: Game) {
    for entity: game.entities {
        if !entity then continue;

        draw_entity(entity.*);
    }
}

draw_mouse_cursor :: (position : Pair, color : Color) {
    draw_pixel(position, color);
    draw_pixel(position + .{0, -1}, color);
    draw_pixel(position + .{0, -2}, color);
    draw_pixel(position + .{1, 0}, color);
    draw_pixel(position + .{2, 0}, color);
}

draw_user_interface :: (game: Game) {
    // Mouse Position
    {
        mouse_color := white;
        if      game.players[0].input.left_mouse.is_down  then mouse_color = yellow;
        else if game.players[0].input.right_mouse.is_down then mouse_color = pink;

        draw_mouse_cursor(
            game.players[0].input.mouse_position,
            mouse_color,
        );
    }

    // HUD
    {
        draw_text(
            tprint("SCORE: %", game.score),
            x = 2,
            y = PIXEL_HEIGHT - 10,
            alignment   = Alignment.LEFT,
            progress    = -1,
            font        = .SMALL,
            color       = white,
        );
    }
}

////////////////////////////////////////////////////////////////////////////////

draw_editor_features :: () {
}

////////////////////////////////////////////////////////////////////////////////
// Below this is the specialized code for rendering various fixtures.
// It is all here to have centralized drawing code, separate from 
// implementation details.
////////////////////////////////////////////////////////////////////////////////

draw_entity :: (entity: Entity) {
    pixel := world_space_to_screen_pixel(entity.position);

    draw_sprite(
        render_context.spritesheet,
        index = entity.sprite,
        pixel = pixel,
        scale_factor = 1,
        horizontal_flip = entity.flip,
        use_color_override = true,
        color_override = entity.color,
    );
}

world_space_to_screen_pixel :: (world_space: Vector2) -> pixel: Pair {
    pixel: Pair;

    pixel.x = cast(int)world_space.x;
    pixel.y = cast(int)world_space.y;

    // @NOTE: Camera Transform Here

    return pixel;
}

////////////////////////////////////////////////////////////////////////////////

draw_title_screen :: () {
    draw_text(
        "Dayne",
        x = PIXEL_WIDTH  * 1 / 2,
        y = PIXEL_HEIGHT * 3 / 4,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = red,
    );

    draw_text(
        "A GAME BY ALEX HARTFORD",
        x = PIXEL_WIDTH  * 1 / 2,
        y = PIXEL_HEIGHT * 3 / 4 - 12,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .SMALL,
        color       = yellow,
    );

    draw_controls_display();

    draw_text(
        "PRESS ESC FOR SETTINGS",
        x = 2,
        y = 2,
        alignment   = Alignment.LEFT,
        progress    = -1,
        font        = .SMALL,
        color       = gray,
    );

    draw_text(
        "PRESS J TO BEGIN",
        x = PIXEL_WIDTH - 2,
        y = 2,
        alignment   = Alignment.RIGHT,
        progress    = -1,
        font        = .SMALL,
        color       = rainbow,
    );
}

draw_demo_screen :: () {
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

    draw_pixel(.{10, 50}, color=rainbow);
    draw_pixel(.{15, 50}, color=pink);
    draw_pixel(.{20, 50}, color=red);
    draw_pixel(.{25, 50}, color=yellow);
    draw_pixel(.{30, 50}, color=green);
    draw_pixel(.{35, 50}, color=blue);
    draw_pixel(.{40, 50}, color=purple);
    draw_pixel(.{45, 50}, color=white);
    draw_pixel(.{50, 50}, color=gray);

    draw_line(.{0, 55}, .{PIXEL_WIDTH, 55}, color=rainbow);
    draw_line(.{0, 60}, .{PIXEL_WIDTH, 60}, color=pink);
    draw_line(.{0, 65}, .{PIXEL_WIDTH, 65}, color=red);
    draw_line(.{0, 70}, .{PIXEL_WIDTH, 70}, color=yellow);
    draw_line(.{0, 75}, .{PIXEL_WIDTH, 75}, color=green);
    draw_line(.{0, 80}, .{PIXEL_WIDTH, 80}, color=blue);
    draw_line(.{0, 85}, .{PIXEL_WIDTH, 85}, color=purple);
    draw_line(.{0, 90}, .{PIXEL_WIDTH, 90}, color=white);
    draw_line(.{0, 95}, .{PIXEL_WIDTH, 95}, color=gray);
}

draw_controls_display :: () {
    draw_text(
        "Controls:",
        x = PIXEL_WIDTH  * 1 / 2,
        y = PIXEL_HEIGHT * 1 / 2,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = white,
    );

    controls_sprite_pixel := Pair.{
        PIXEL_WIDTH / 2 - render_context.controls.tile_width_in_pixels / 2,
        PIXEL_HEIGHT * 1 / 3 - render_context.controls.tile_height_in_pixels / 2,
    };

    draw_sprite(
        render_context.controls,
        index = 0,
        pixel = controls_sprite_pixel,

        scale_factor = 1,
        horizontal_flip = false,
        use_color_override = true,
        color_override = gray,
    );
}



////////////////////////////////////////////////////////////////////////////////

draw_particle_system :: (particle_system: Particle_System) {
    for particle: particle_system.particles {
        draw_particle(particle);
    }
}

draw_particle :: (particle: Particle) {
    pixel := world_space_to_screen_pixel(particle.position);
    
    draw_pixel(pixel, particle.color);
}


////////////////////////////////////////////////////////////////////////////////
// Menu
////////////////////////////////////////////////////////////////////////////////

draw_menu :: (using menu: Menu) {
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
