
// Utilities
////////////////////////////////////////////////////////////////////////////////

// 0 -> <>s, 1 -> <>, 2 -> <>s
plural :: (n: int) -> bool {
    return n != 1;
}

// "FIGHTER", "fighter", etc. -> "Fighter"
normalize :: (raw : string) -> temp_allocated: string {
    assert(raw.count > 0);
    result := to_lower_copy(raw,, temp);
    result[0] = to_upper(result[0]);
    return result;
}

////////////////////////////////////////////////////////////////////////////////

debug_print :: inline (s : string, color := white) {
    #if DEVELOPER_TOOLS {
        array_add(*debug_messages.messages, .{s, color});
    }
}

////////////////////////////////////////////////////////////////////////////////

// Returns a temp-allocated string
// @NOTE(alex): this is necessary for use with dungeons and characters since we're using a bunch of string literals,
// So they have to be copied to be operated upon.
truncate_string :: inline (s: string, count: int) -> string {
    new_string := tprint("%", s);
    new_string.count = ifx count > s.count then s.count else count;

    return new_string;
}

////////////////////////////////////////////////////////////////////////////////

Pair :: struct {
    x: int;
    y: int;
}

to_pair :: (vec: Vector2) -> Pair {
    return .{xx vec.x, xx vec.y};
}
operator + :: (a: Pair, b: Pair) -> Pair { return .{a.x + b.x, a.y + b.y};  }
operator - :: (a: Pair, b: Pair) -> Pair { return .{a.x - b.x, a.y - b.y};  }
operator * :: (f: int, a: Pair)  -> Pair { return .{a.x * f,   a.y * f};    }
operator * :: (a: Pair, f: int)  -> Pair { return .{a.x * f,   a.y * f};    }
operator - :: (p: Pair) -> Pair { return .{-p.x, -p.x}; }

////////////////////////////////////////////////////////////////////////////////

Box :: struct {
    x, y : int;
    width, height : int;
}

collision :: (a: Box, b: Box) -> bool {
    return a.x < b.x + b.width && a.y < b.y + b.height
        && a.x + a.width > b.x && a.y + a.height > b.y;
}

point_within :: (p: Pair, c: Box) -> bool {
    return p.x >= c.x && p.x < c.x + c.width
        && p.y >= c.y && p.y < c.y + c.height;
}

draw :: (box: Box, color : Color,
    outline_color := color_none,
    screen_pixel_zoom := 1
) {
    use_basic_shader();

    bottom_left := world_space_to_screen_pixel(box.x, box.y);
    top_right := world_space_to_screen_pixel(box.x + box.width, box.y + box.height);

    // Some basic culling
    {
        box_is_entirely_off_screen := !on_screen(bottom_left) && !on_screen(top_right);
        if box_is_entirely_off_screen then return;
    }

    scale := screen_pixel_zoom;

    {
        doing_fill      := color != color_none;
        doing_outline   := outline_color != color_none;

        if !doing_fill && !doing_outline {
            log_error("What are we doing here? lol");
            return;
        }
        else if doing_fill && !doing_outline {
            draw_colored_quad(
                xx bottom_left.x, xx bottom_left.y,
                xx box.width * scale, xx box.height * scale,
                color=color
            );
        }
        else if doing_fill && doing_outline {
            draw_colored_quad(
                xx bottom_left.x, xx bottom_left.y,
                xx box.width * scale, xx box.height * scale,
                color=outline_color
            );

            draw_colored_quad(
                xx bottom_left.x + 1, xx bottom_left.y + 1,
                xx box.width * scale - 2, xx box.height * scale - 2,
                color=color
            );
        }
        else if !doing_fill && doing_outline {
            // @TODO.
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

get_random_direction_vector_on_unit_circle :: () -> Vector2 {
    angle := random_get_zero_to_one() * (2 * PI) - PI;
    
    result : Vector2;
    result.x = cos(angle);
    result.y = sin(angle);

    return result;
}

get_random_upward_direction_vectory_on_unit_circle :: () -> Vector2 {
    result : Vector2;
    while result.y <= 0 {
        result = get_random_direction_vector_on_unit_circle();
    }

    return result;
}

////////////////////////////////////////////////////////////////////////////////

// Rounds a float to the nearest int.
round :: (f: float) -> int {
    if f > 0 {
        if f - cast(int)f > 0.5 then return cast(int)f + 1;
        else return cast(int)f;
    }
    else {
        if f + cast(int)f < -0.5 then return cast(int)f - 1;
        else return cast(int)f;
    }
}

////////////////////////////////////////////////////////////////////////////////

coin_flip :: inline () -> bool {
    if random() > 0.5 then return true; else return false;
}

// [0, 1]
random :: inline () -> float {
    return random_get_zero_to_one();
}

// [0, max]
random :: inline (max: float) -> float {
    return random_get_zero_to_one() * max;
}

// [min, max]
random :: inline (min: float, max: float) -> float {
    return random_get_within_range(min, max);
}

// [0, max]
random :: inline (max: int) -> int {
    return cast(int, (random_get_zero_to_one() * (max + 0.999999)));
}

// [min, max]
random :: inline (min: int, max: int) -> int {
    return cast(int, (random_get_zero_to_one() * (max - min + 0.999999)) + min);
}

// Testing random integer ranges
/*
#run {
    values : [..] int;

    for 0..100000 array_add(*values, random(5));
    //for 0..100000 array_add(*values, random(3, 5));

    counts : [6] int;
    for values {
        counts[it] += 1;
    }

    print("%\n", counts);
}
*/

random_choice :: inline (choices: [] $T) -> T {
    max := choices.count-1;
    index := random(max);
    return choices[index];
}

random :: inline (min: Vector2, max: Vector2) -> Vector2 {
    return .{
        random(min.x, max.x),
        random(min.y, max.y),
    };
}

random_enum :: inline ($T: Type) -> T {
    values := enum_values_as_enum(T);
    return random_choice(values);
}

random_enum_as_s64 :: inline ($T: Type) -> s64 {
    values := enum_values_as_s64(T);
    return random_choice(values);
}

////////////////////////////////////////////////////////////////////////////////

time :: () -> Calendar_Time {
    apollo_time := current_time_consensus();
    t := to_calendar(apollo_time, Time_Zone.LOCAL);
    return t;
}

// A temp-allocated timestamp string, for saving files mostly.
timestamp :: () -> string {
    new_context := context;
    push_context new_context {
        format_int := *context.print_style.default_format_int;
        format_int.minimum_digits = 2;

        using t := time();
        timestamp := tprint("%-%-%_%-%-%", year, month_starting_at_0 + 1, day_of_month_starting_at_0 + 1, hour, minute, second);
        return timestamp;
    }
}

////////////////////////////////////////////////////////////////////////////////

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
    screen_box := Box.{
        x = 0,
        y = 0,
        width  = PIXEL_WIDTH,
        height = PIXEL_HEIGHT,
    };

    return point_within(screen_pixel, screen_box);
}
