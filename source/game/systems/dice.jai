// Dayne
// Dice
// November 2024

Dice_Pool :: struct {
    dice : [..] Die;
}

Die :: struct {
    faces : [6] Face;
}

Face :: struct {
    number : int;
}

roll :: (using pool: Dice_Pool) -> [..] Face {
    result : [..] Face;
    for die : dice {
        array_add(*result, roll(die));
    }
    return result;
}

roll :: (using die: Die) -> Face {
    face := random_choice(faces);
    return face;
}

sum :: (using die: Die) -> int {
    result := 0;
    for face : faces {
        result += face.number;
    }
    return result;
}

sum :: (faces: [..] Face) -> int {
    result := 0;
    for face : faces {
        result += face.number;
    }
    return result;
}

draw :: (pool: Dice_Pool, screen_pixel : Pair) {
    k := 0;
    for die : pool.dice {
        draw(die, screen_pixel + .{0, k * TILE_SIZE_IN_PIXELS});
        k += 1;
    }
}

draw :: (using die: Die, screen_pixel : Pair, color := white) {
    k := 0;
    for face : faces {
        draw(face, screen_pixel + .{k * TILE_SIZE_IN_PIXELS, 0}, color);
        k += 1;
    }
}

draw :: (faces: [] Face, screen_pixel : Pair, color := white) {
    k := 0;
    for face : faces {
        draw(face, screen_pixel + .{k * TILE_SIZE_IN_PIXELS, 0}, color);
        k += 1;
    }
}

draw :: (using face: Face, screen_pixel: Pair, color := white) {
    index : int;
    if face.number == {
        case 0; index = 0;
        case 1; index = 1;
        case 2; index = 2;
        case 3; index = 3;
        case 4; index = 4;
        case 5; index = 5;
        case 6; index = 6;
    }

    draw_sprite_at(screen_pixel, "dice", index, color);
}

draw_number :: (number: int, screen_pixel: Pair) {
    text := tprint("%", number);

    draw_text(
        text,
        x = screen_pixel.x,
        y = screen_pixel.y,
        alignment   = Alignment.LEFT,
        progress    = -1,
        font        = .MAIN,
        color       = white,
    );
}
