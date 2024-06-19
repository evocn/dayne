// Dayne
// Sprite
// Alex Hartford
// February 2024

////////////////////////////////////////////////////////////////////////////////
// Plain Sprites
////////////////////////////////////////////////////////////////////////////////

Sprite :: struct {
    using texture : Texture = ---;
}

draw_sprite :: (
                name : string,
                x : int, y : int,
                scale_factor := 1,
                horizontal_flip := false,
                use_color_override := false, color_override := white
               )
{
    sprite, found := table_find(*render_context.sprites, name);
    if !found {
        log_error("Couldn't find sprite: %\n", name);
        return;
    }

    shader := use_sprite_shader();

    // Find the right uv coordinates for the texture.
    {
        spritesheet_offset := Vector2.{0, 0};
        set_vec2(shader, "spritesheet_offset", spritesheet_offset);
        relative_sheet_scale := Vector2.{1, 1};
        set_vec2(shader, "relative_sheet_scale", relative_sheet_scale);
    }

    // Scale / Translate for the screen
    {
        model := Matrix4_Identity;
            x_translation := x / cast(float)PIXEL_WIDTH;
            y_translation := y / cast(float)PIXEL_HEIGHT;
            translation_vector := Vector3.{x_translation, y_translation, 0};

            x_scale := scale_factor / (cast(float)PIXEL_WIDTH  / sprite.width);
            y_scale := scale_factor / (cast(float)PIXEL_HEIGHT / sprite.height);
            scale_vector := Vector3.{x_scale, y_scale, 1};

            translate(*model, translation_vector);
            scale(*model, scale_vector);
        set_mat4(shader, "model", model);
    }

    set_bool(shader, "horizontal_flip", horizontal_flip);

    // @TODO?
    set_vec4(shader, "color_override", color_override);
    set_bool(shader, "use_color_override", use_color_override);

    bind(sprite.texture, 0);
    draw_quad(render_context.quad);
}

////////////////////////////////////////////////////////////////////////////////

next_sprite_index := 0;

load_sprite :: (full_path : string) -> success: bool {
    short_name := path_strip_extension(path_filename(full_path));

    new := *render_context.sprite_storage[next_sprite_index];
    next_sprite_index += 1;

    success := make_sprite(new, full_path);
    if !success {
        print("Failed to load sprite %\n", full_path);
        return false;
    }

    added := table_add(*render_context.sprites, copy_string(short_name), new);
    if !added {
        print("Failed to add sprite % to the render context sprite table\n", full_path);
        return false;
    }

    return true;
}

make_sprite :: (sprite: *Sprite, full_path: string) -> success: bool {
    success : bool;
    sprite.texture, success = load_texture(full_path);
    return success;
}

////////////////////////////////////////////////////////////////////////////////
// Spritesheets
////////////////////////////////////////////////////////////////////////////////

Spritesheet :: struct {
    using #as sprite : Sprite;

    tile_width_in_pixels, tile_height_in_pixels : int;
    columns, rows : int;
}


draw_spritesheet :: (
                name : string,
                index : int,
                x : int, y : int,
                scale_factor := 1,
                horizontal_flip := false,
                use_color_override := false, color_override := white
               )
{
    spritesheet, found := table_find(*render_context.spritesheets, name);
    if !found {
        log_error("Couldn't find sprite: %\n", name);
        return;
    }

    shader := use_sprite_shader();

    assert(index >= 0 && index < (spritesheet.columns * spritesheet.rows));

    // Find the right uv coordinates for the texture.
    {
        col := index % spritesheet.columns;
        row := index / spritesheet.columns;

        spritesheet_offset := Vector2.{col / cast(float)spritesheet.columns, row / cast(float)spritesheet.rows};
        set_vec2(shader, "spritesheet_offset", spritesheet_offset);
        relative_sheet_scale := Vector2.{1.0 / spritesheet.columns, 1.0 / spritesheet.rows};
        set_vec2(shader, "relative_sheet_scale", relative_sheet_scale);
    }

    // Scale / Translate for the screen
    {
        model := Matrix4_Identity;
            x_translation := x / cast(float)PIXEL_WIDTH;
            y_translation := y / cast(float)PIXEL_HEIGHT;
            translation_vector := Vector3.{x_translation, y_translation, 0};

            x_scale := scale_factor / (cast(float)PIXEL_WIDTH  / spritesheet.tile_width_in_pixels);
            y_scale := scale_factor / (cast(float)PIXEL_HEIGHT / spritesheet.tile_height_in_pixels);
            scale_vector := Vector3.{x_scale, y_scale, 1};

            translate(*model, translation_vector);
            scale(*model, scale_vector);
        set_mat4(shader, "model", model);
    }

    set_bool(shader, "horizontal_flip", horizontal_flip);

    // @TODO?
    set_vec4(shader, "color_override", color_override);
    set_bool(shader, "use_color_override", use_color_override);

    bind(spritesheet.texture, 0);
    draw_quad(render_context.quad);
}

// Assumes that a sprite sheet is named in the following convention:
// <name>.<tile_size_in_pixels>.png
next_spritesheet_index := 0;
load_spritesheet :: (full_path : string) -> success: bool {
    short_name := split(path_strip_extension(path_strip_extension(path_filename(full_path))), ".")[0];
    tile_size_in_pixels := string_to_int(split(path_strip_extension(path_filename(full_path)), ".")[1]);

    new := *render_context.spritesheet_storage[next_spritesheet_index];
    next_spritesheet_index += 1;

    success := make_spritesheet(new, full_path, tile_size_in_pixels, tile_size_in_pixels);
    if !success {
        print("Failed to load spritesheet %\n", full_path);
        return false;
    }

    added := table_add(*render_context.spritesheets, copy_string(short_name), new);
    if !added {
        print("Failed to add spritesheet % to the render context spritesheet table\n", full_path);
        return false;
    }

    return true;
}

make_spritesheet :: (spritesheet : *Spritesheet, full_path : string, tile_width_in_pixels : int, tile_height_in_pixels : int) -> success: bool {
    success : bool;
    spritesheet.texture, success = load_texture(full_path);

    spritesheet.tile_width_in_pixels  = tile_width_in_pixels;
    spritesheet.tile_height_in_pixels = tile_height_in_pixels;
    spritesheet.columns = spritesheet.texture.width  / tile_width_in_pixels;
    spritesheet.rows    = spritesheet.texture.height / tile_height_in_pixels;

    return success;
}
