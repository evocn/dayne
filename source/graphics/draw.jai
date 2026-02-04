
// Graphics Drawing Functions
////////////////////////////////////////////////////////////////////////////////

// @TODO: Maybe work these out into like UI drawing, primitive drawing, etc. functions?

draw_game_over :: () {
    box := Box.{PIXEL_WIDTH / 2 - 60, PIXEL_HEIGHT / 2 - 20, 120, 40};
    draw(box, black);

    draw_text(
        "Game Over",
        PIXEL_WIDTH / 2, PIXEL_HEIGHT / 2,
        alignment = .CENTER,
        color = white,
    );
}

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
    position: Pair,
    frame := 0
)
{
    use_sprite_shader();

    x_offset_for_sprite := -6;
    y_offset_for_sprite := -10;

    draw_sprite_at(
        position + .{x_offset_for_sprite, y_offset_for_sprite},
        "cursor",
        frame = frame,
    );
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

////////////////////////////////////////////////////////////////////////////////

Pip_Visuals :: struct {
    SIZE :: 8;
    SEPARATION :: 4;
    PIPS_PER_GROUP :: 4;

    Direction :: enum {
        LEFT;
        RIGHT;
        UP;
        DOWN;
    }
    DIRECTION :: Direction.RIGHT;
}

draw_pip :: (x: int, y: int, size := Pip_Visuals.SIZE, color := yellow, outline_color := white)
{
    box := Box.{x, y, size, size};
    draw(box, color, outline_color);
}

draw_pips :: (
    x: int, y: int,
    count : int,
    filled := -1,
    pip_size := Pip_Visuals.SIZE,
    pip_separation := Pip_Visuals.SEPARATION,
    pips_per_group := Pip_Visuals.PIPS_PER_GROUP,
    direction := Pip_Visuals.DIRECTION,
    color := yellow,
    empty_color := gray,
    outline_color := white
)
{
    offset := pip_size + pip_separation;

    cursor := Pair.{x, y};
    origin := Pair.{x, y};
    next_in_this_group : Pair;
    next_group : Pair;

    if direction == {
        case .LEFT; {
            next_in_this_group = .{-offset, 0};
            next_group = .{0, -offset};
        }
        case .RIGHT; {
            next_in_this_group = .{offset, 0};
            next_group = .{0, -offset};
        }
        case .UP; {
            next_in_this_group = .{0, offset};
            next_group = .{offset, 0};
        }
        case .DOWN; {
            next_in_this_group = .{0, -offset};
            next_group = .{offset, 0};
        }
    }

    for 0..count-1 {
        {
            c := color;
            if it >= filled {
                c = empty_color;
            }

            draw_pip(cursor.x, cursor.y, pip_size, c, outline_color);
        }

        // @TODO: Apparently this is broken...
        {
            next_group_time := it != 0 && it % pips_per_group == 0;
            if next_group_time {
                group_index := it / pips_per_group;
                cursor = origin;
                cursor += (next_group * group_index);
            }
            else {
                cursor += next_in_this_group;
            }
        }
    }
}
