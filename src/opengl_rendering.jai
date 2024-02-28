// Dayne
// OpenGL Rendering primitives and functions
// Alex Hartford
// February 2024

OpenGL_Context :: struct {
    using shaders : struct {
        basic_shader    : Shader;
        sprite_shader   : Shader;
        text_shader     : Shader;
        quad_shader     : Shader;
    }

    // Primitives for drawing things
        quad : Quad;

        spritesheet : Sprite;
        haruhachi : Sprite;
        controls : Sprite;

        fbo : GLuint;
        render_texture : GLuint;

    // Fonts
        main_font  : Font;
        small_font : Font;
}

////////////////////////////////////////////////////////////////////////////////
// Immediate Mode Drawing Functions
////////////////////////////////////////////////////////////////////////////////

draw_pixel :: (screen_pixel: Pair, color := white) {
    Pixel :: struct {
        position: Vector2;
        vao, vbo: GLuint;
    }

    pixel: Pixel;

    // Get pixel ready for drawing with OpenGL
    {
        pixel.position.x = cast(float)screen_pixel.x / PIXEL_WIDTH;
        pixel.position.y = cast(float)screen_pixel.y / PIXEL_HEIGHT;

        glGenVertexArrays(1, *pixel.vao);
        glGenBuffers(1, *pixel.vbo);

        glBindVertexArray(pixel.vao);
        defer glBindVertexArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, pixel.vbo);
        defer glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBufferData(GL_ARRAY_BUFFER, 2 * size_of(float), *pixel.position, GL_STATIC_DRAW);

        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, cast(*void)0);
        glEnableVertexAttribArray(0);
    }

    // Draw the thing!
    {
        shader := use_basic_shader();
        set_vec4(shader, "color", color);

        model := Matrix4_Identity;
        set_mat4(shader, "model", model);

        glBindVertexArray(pixel.vao);
        glBindBuffer(GL_ARRAY_BUFFER, pixel.vbo);

        glDrawArrays(GL_POINTS, 0, 1);
    }

    // Free vao/vbo for other things!
    {
        glDeleteVertexArrays(1, *pixel.vao);
        glDeleteBuffers(1, *pixel.vbo);
    }
}


////////////////////////////////////////////////////////////////////////////////
// Line
////////////////////////////////////////////////////////////////////////////////

draw_line :: (a: Pair, b: Pair, color := white) {
    Line :: struct {
        points: [2] Vector2;
        vao, vbo: GLuint;
    }

    line: Line;

    // Get line ready for drawing with OpenGL
    {
        line.points[0].x = cast(float)a.x / PIXEL_WIDTH;
        line.points[0].y = cast(float)a.y / PIXEL_HEIGHT;

        line.points[1].x = cast(float)b.x / PIXEL_WIDTH;
        line.points[1].y = cast(float)b.y / PIXEL_HEIGHT;

        glGenVertexArrays(1, *line.vao);
        glGenBuffers(1, *line.vbo);

        glBindVertexArray(line.vao);
        defer glBindVertexArray(0);

        glBindBuffer(GL_ARRAY_BUFFER, line.vbo);
        defer glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBufferData(GL_ARRAY_BUFFER, line.points.count * 2 * size_of(float), *line.points[0], GL_STATIC_DRAW);

        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, cast(*void)0);
        glEnableVertexAttribArray(0);
    }

    // Draw the thing!
    {
        shader := use_basic_shader();
        set_vec4(shader, "color", color);

        model := Matrix4_Identity;
        set_mat4(shader, "model", model);

        glBindVertexArray(line.vao);
        glBindBuffer(GL_ARRAY_BUFFER, line.vbo);

        glDrawArrays(GL_LINES, 0, 2);
    }

    // Free vao/vbo for other things!
    {
        glDeleteVertexArrays(1, *line.vao);
        glDeleteBuffers(1, *line.vbo);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Quads and Rectangles
////////////////////////////////////////////////////////////////////////////////

blit_quad :: () {
    // @TODO!
}

Quad :: struct {
    points := float.[0, 0, 0,
                     0, 1, 0,
                     1, 1, 0,
                     1, 0, 0];
    indices:= u32.[0, 1, 2,
                   0, 2, 3];
    vao, vbo, ibo : GLuint;
}

initialize_quad_rendering_objects :: (using quad : *Quad) {
	glGenVertexArrays(1, *vao);
	glGenBuffers(1, *vbo);
	glGenBuffers(1, *ibo);

	glBindVertexArray(vao);
	defer glBindVertexArray(0);

	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	defer glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBufferData(GL_ARRAY_BUFFER, size_of(float) * points.count, points.data, GL_STATIC_DRAW);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
	defer glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, size_of(u32) * indices.count, indices.data, GL_STATIC_DRAW);

	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * size_of(float), cast(*void)0);
	glEnableVertexAttribArray(0);
}

draw_quad :: (using quad: Quad) {
	glBindVertexArray(vao);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

	glDrawElements(GL_TRIANGLES, cast(u32)indices.count, GL_UNSIGNED_INT, null);
}

draw_colored_rectangle :: (x: int, y: int, width: int, height: int, color := white) {
    shader := use_basic_shader();

    model := Matrix4_Identity;
    translation_vector := Vector3.{cast(float)x / PIXEL_WIDTH, cast(float)y / PIXEL_HEIGHT, 0.0};
    scale_vector := Vector3.{cast(float)width / PIXEL_WIDTH, cast(float)height / PIXEL_HEIGHT, 1.0};

    translate(*model, translation_vector);
    scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    set_vec4(shader, "color", color);

    draw_quad(render_context.quad);
}

////////////////////////////////////////////////////////////////////////////////
// Framebuffer
////////////////////////////////////////////////////////////////////////////////

initialize_framebuffer :: () {
    glGenFramebuffers(1, *render_context.fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, render_context.fbo);

    glGenTextures(1, *render_context.render_texture);
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, render_context.render_texture);
    // Give an empty image to OpenGL
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGBA, PIXEL_WIDTH, PIXEL_HEIGHT, 0,GL_RGBA, GL_UNSIGNED_BYTE, cast(*void)0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);

    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, render_context.render_texture, 0);

    // Set the list of draw buffers.
    draw_buffers := GLenum.[GL_COLOR_ATTACHMENT0];
    glDrawBuffers(1, draw_buffers.data);

    result := glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if result != GL_FRAMEBUFFER_COMPLETE {
        log_error("Framebuffer problems. Result code: %\n", result);
        assert(false);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

draw_screen_quad :: (shader: Shader) {
    viewport_portion_of_the_screen_in_x := cast(float)render_context.viewport_height / render_context.window_height;
    viewport_portion_of_the_screen_in_y := cast(float)render_context.viewport_width / render_context.window_width;

    model := Matrix4_Identity;
        // Scale
        default_scale_x :: 2;
        default_scale_y :: 2;

        scale_x : float = default_scale_x * viewport_portion_of_the_screen_in_x;
        scale_y : float = default_scale_y * viewport_portion_of_the_screen_in_y;
        scale_vector := Vector3.{scale_y, scale_x, 1};

        // Translate
        default_translate_x :: -1;
        default_translate_y :: -1;

        translate_x : float = default_translate_x * viewport_portion_of_the_screen_in_y;
        translate_y : float = xx default_translate_y;
        translation_vector := Vector3.{translate_x, translate_y, 1};

        translate(*model, translation_vector);
        scale(*model, scale_vector);
    set_mat4(shader, "model", model);

    draw_quad(render_context.quad);
}

// Renders the framebuffer as a texture on a screen-space quad.
render_framebuffer_to_screen :: () {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, xx render_context.window_width, xx render_context.window_height);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    shader := render_context.quad_shader;
    use_shader(shader);
    defer disable_shaders();

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, render_context.render_texture);

    draw_screen_quad(shader);
}


////////////////////////////////////////////////////////////////////////////////
// Utilities
////////////////////////////////////////////////////////////////////////////////

print_gl_errors :: (str := "-") {
    if dont_check_for_gl_errors_anymore then return;

    current_error : GLenum;
    current_error = glGetError();
    while current_error != GL_NO_ERROR {
        dont_check_for_gl_errors_anymore = true;

        log_error("OpenGL Error(%) = %\n", str, current_error);

        current_error = glGetError();
    }
}
dont_check_for_gl_errors_anymore : bool;
