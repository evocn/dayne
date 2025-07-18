// Dayne
// Graphics Drawing Functions
// November 2024

world_space_to_screen_pixel :: (x: int, y: int) -> pixel: Pair {
    pixel: Pair;

    pixel.x = x;
    pixel.y = y;

    // Camera Transform
    {
        pixel -= game.camera.position;
        pixel = game.camera.zoom * pixel;
    }

    return pixel;
}

screen_pixel_zoom :: () -> zoom: int {
    return game.camera.zoom;
}

on_screen :: inline (screen_pixel: Pair) -> bool {
    x := screen_pixel.x >= 0 && screen_pixel.x < PIXEL_WIDTH;
    y := screen_pixel.y >= 0 && screen_pixel.y < PIXEL_HEIGHT;

    return x && y;
}

////////////////////////////////////////////////////////////////////////////////

// @TODO: Maybe work these out into like UI drawing, primitive drawing, etc. functions?

draw_title_screen :: () {
    {
        use_text_shader();
        draw_text(
            program_title,
            x = PIXEL_WIDTH / 2,
            y = 80,
            alignment   = Alignment.CENTER,
            progress    = -1,
            font        = .MAIN,
            color       = white,
        );

        draw_text(
            "You reap what you sow.",
            x = PIXEL_WIDTH / 2,
            y = 60,
            alignment   = Alignment.CENTER,
            progress    = -1,
            font        = .SMALL,
            color       = white,
        );
    }
}

draw_version_indicator :: () {
    use_text_shader();

    draw_text(
        tprint("version %.%.%", program_version.major, program_version.minor, program_version.patch),
        x = 1,
        y = 1,
        alignment = Alignment.LEFT,
        progress = -1,
        font = .SMALL,
        color = white,
    );
}

draw_build_type :: () {
    use_text_shader();

    draw_text(
        tprint("%", BUILD_TYPE),
        x = 1,
        y = 8,
        alignment = Alignment.LEFT,
        progress = -1,
        font = .SMALL,
        color = gray,
    );
}

////////////////////////////////////////////////////////////////////////////////

draw_demo :: () {
    {
        use_sprite_shader();
        draw_sprite_at(.{0, 0}, "haruhachi");
    }

    {
        use_text_shader();
        draw_text(
            "the quick brown fox",
            x = 1,
            y = PIXEL_HEIGHT - 7,
            alignment   = Alignment.LEFT,
            font        = .SMALL,
            color       = red,
        );

        draw_text(
            "jumps over the lazy dog.",
            x = 1,
            y = PIXEL_HEIGHT - 14,
            alignment   = Alignment.LEFT,
            font        = .SMALL,
            color       = seafoam,
        );

        draw_text(
            "the quick brown fox",
            x = PIXEL_WIDTH - 1,
            y = PIXEL_HEIGHT - 20,
            alignment   = Alignment.RIGHT,
            font        = .MAIN,
            color       = blue,
        );

        draw_text(
            "jumps over the lazy dog.",
            x = PIXEL_WIDTH - 1,
            y = PIXEL_HEIGHT - 28,
            alignment   = Alignment.RIGHT,
            font        = .MAIN,
            color       = yellow,
        );
    }

    draw_clock_readout();
}

////////////////////////////////////////////////////////////////////////////////

draw_menu :: (using menu: Menu) {
    use_text_shader();

    k := 10;
    total_height := k * elements.count + 2;

    for elements {
        draw_menu_element(it, total_height - (it_index + 1) * k, color=it.usual_color);
    }

    // Draw selected element over it.
    if elements.count {
        hovering := *elements[element_index];
        draw_menu_element(hovering.*, total_height - (element_index + 1) * k + 1, color=hovering.*.hover_color);
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
            draw_text(tprint("% - %", name, value.*), 1, height, color=color);
    }
}

// Clock
draw_clock_readout :: () {
    using t := time();

    clock_readout : string;
    {
        am_pm_string : string;
        if hour < 12 {
            am_pm_string = "am";
        }
        else {
            am_pm_string = "pm";
        }

        hour_in_twelve_hour_time := hour;
        if hour > 12 {
            hour_in_twelve_hour_time -= 12;
        }
        else if hour == 0 {
            hour_in_twelve_hour_time = 12;
        }

        new_context := context;
        format_int := *new_context.print_style.default_format_int;
        format_int.minimum_digits = 2;

        push_context new_context {
            clock_readout = tprint("%:% %", hour_in_twelve_hour_time, minute, am_pm_string);
        }
    }

    color : Color;
    {
        if hour < 3 {
            color = pink;
        }
        else if hour < 6 {
            color = purple;
        }
        else if hour < 9 {
            color = yellow;
        }
        else if hour < 12 {
            color = green;
        }
        else if hour < 15 {
            color = teal;
        }
        else if hour < 18 {
            color = blue;
        }
        else if hour < 21 {
            color = red;
        }
        else if hour < 24 {
            color = gray;
        }
        else {
            "What the fuck?";
        }
    }

    draw_colored_quad(
        x = 0,
        y = 0,
        width  = 34,
        height = 7,
        color  = black,
    );

    {
        use_text_shader();
        draw_text(
            clock_readout, 
            x = 1,
            y = 1,
            alignment   = Alignment.LEFT,
            progress    = -1,
            font        = .SMALL,
            color       = color,
        );
    }
}

draw_mouse_cursor :: (
    position: Pair
)
{
    use_sprite_shader();
    draw_sprite_at(position - .{0, 16}, "cursor", frame = 0);
}

////////////////////////////////////////////////////////////////////////////////

draw_sprite_relative_to_collider :: (
    using collider: Collider,
    name: string,
    frame := 0,
    facing_left := false
)
{
    sprite := table_find_pointer(*graphics_context.sprites, name);
    if !sprite {
        log_error("Couldn't load spritesheet % for drawing.\n", name);
        return;
    }

    screen_pixel := world_space_to_screen_pixel(xx x, xx y);

    bottom_left_corner_of_sprite :=
          screen_pixel    // Bottom left corner of collider
        + .{width / 2, 0} // Gets us the center bottom of collider
        - .{sprite.tile_width_in_pixels / 2, 0} // Bottom left corner!
    ;

    scale := screen_pixel_zoom();

    draw_sprite(
        sprite,
        frame = frame,
        pixel = bottom_left_corner_of_sprite,

        scale_factor = scale,

        horizontal_flip = facing_left,

        use_color_override = false,
    );
}

draw_sprite_at :: (
    pixel : Pair,
    name: string,
    frame := 0,
    facing_left := false
)
{
    sprite := table_find_pointer(*graphics_context.sprites, name);
    if !sprite {
        log_error("Couldn't load spritesheet % for drawing.\n", name);
        return;
    }

    scale := screen_pixel_zoom();

    draw_sprite(
        sprite,
        frame = frame,
        pixel = pixel,

        scale_factor = scale,

        horizontal_flip = facing_left,

        use_color_override = false,
    );
}
