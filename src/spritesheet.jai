// Dayne
// Spritesheet
// Alex Hartford
// February 2024

// @TODO: Simplify this code.
// My thoughts for now:
// * Set a framebuffer to the size you desire.
// * Have all the APIs work in terms of Pixels.
// * Have this code draw in terms of pixels. E.g. no scaling, pixel translation, etc.
// * Have the sprites automagically scale to one pixel. Don't fiddle with it.
// * Maybe allow 2x, 3x scaling, etc.
// * Build everything around the resolution of the game board. Not just text, but everything!
// * ALSO: True letterboxing for fullscreen! Check Bird for how I did this...

draw_spritesheet :: (using sheet : Spritesheet,
                     index: int,
                     pixel : Pair,
                     horizontal_flip := false,
                     use_color_override := false, color_override := white
                    )
{
    shader := use_tile_shader();
    bind(sheet.texture, 0);

    assert(index >= 0 && index < columns * rows);

    col := index % columns;
    row := index / columns;

    spritesheet_offset := Vector2.{col / cast(float)columns, row / cast(float)rows};
    set_vec2(shader, "spritesheet_offset", spritesheet_offset);

    relative_sheet_scale := Vector2.{1.0 / columns, 1.0 / rows};
    set_vec2(shader, "relative_sheet_scale", relative_sheet_scale);

    model := Matrix4_Identity;
    x_translation := pixel.x / cast(float)PIXEL_WIDTH;
    y_translation := pixel.y / cast(float)PIXEL_HEIGHT;
    translation_vector := Vector3.{x_translation, y_translation, 0};

    x_scale := 1.0 / 25;
    y_scale := 1.0 / 18.75;
    scale_vector := Vector3.{x_scale, y_scale, 1};

    translate(*model, translation_vector);
    scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color_override", color_override);
    set_bool(shader, "horizontal_flip", horizontal_flip);
    set_bool(shader, "use_color_override", use_color_override);

    draw_quad(render_context.quad);
}

////////////////////////////////////////////////////////////////////////////////

Spritesheet :: struct {
    texture : Texture = ---;
    columns, rows : int;
}

make_spritesheet :: (using spritesheet : *Spritesheet, full_path : string, tile_size_in_pixels : int) -> success: bool {
    texture =, success := load_texture(full_path);
    columns = texture.width  / tile_size_in_pixels;
    rows    = texture.height / tile_size_in_pixels;

    return success;
}
