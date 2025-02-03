// Dayne
// Color
// August 2024

Color :: Vector4;
Hex_Color :: u32;

color_none :: Color.{};
black       :: #run color_from_hex(0x000000);
gray        :: #run color_from_hex(0x707070);
light_gray  :: #run color_from_hex(0xc8c8c8);
white       :: #run color_from_hex(0xffffff);

red         :: #run color_from_hex(0x991515);
dark_red    :: #run color_from_hex(0x4c0000);
light_red   :: #run color_from_hex(0xe03c32);
pink        :: #run color_from_hex(0xe03c32);

brown       :: #run color_from_hex(0x9f330f);
orange      :: #run color_from_hex(0xff6d0f);
yellow      :: #run color_from_hex(0xffa500);
light_yellow:: #run color_from_hex(0xe8ea4a);

beige       :: #run color_from_hex(0x8a6042);
light_beige :: #run color_from_hex(0xfeb854);

dark_green  :: #run color_from_hex(0x003d10);
green       :: #run color_from_hex(0x00953b);
light_green :: #run color_from_hex(0x67ab7a);
seafoam     :: #run color_from_hex(0x58f5b1);

dark_blue   :: #run color_from_hex(0x202040);
blue        :: #run color_from_hex(0x006ab4);
light_blue  :: #run color_from_hex(0x27badb);

purple      :: #run color_from_hex(0x4430ba);
light_purple:: #run color_from_hex(0x7e57c6);
magenta     :: #run color_from_hex(0xd376d6);




color_from_hex :: ($h: u32) -> Color {
    color : Color;
    color.x = ((h >> 16) & 0xff) / 255.0;
    color.y = ((h >> 8) & 0xff) / 255.0;
    color.z = ((h >> 0) & 0xff) / 255.0;
    color.w = 1.0;

    return color;
}


// Rainbow Color

rainbow_color : Color;

rainbow_color_time : float;
RAINBOW_OSCILLATION_SPEED :: 5.0;

update_rainbow_color :: (dt: float) -> Color {
    rainbow_color_time += dt * RAINBOW_OSCILLATION_SPEED;

    if rainbow_color_time >= 6.0 then rainbow_color_time = rainbow_color_time - 6.0;
    
    if rainbow_color_time > 5.0 then return yellow;
    else if rainbow_color_time > 4.0 then return pink;
    else if rainbow_color_time > 3.0 then return blue;
    else if rainbow_color_time > 2.0 then return green;
    else if rainbow_color_time > 1.0 then return red;
    return purple;
}

// Random Color
random_color :: () -> Color {
    return Color.{
        x = random_get_zero_to_one(),
        y = random_get_zero_to_one(),
        z = random_get_zero_to_one(),
        w = 1.0,
    };
}
