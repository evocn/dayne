
// Screenshot
////////////////////////////////////////////////////////////////////////////////

// Screenshots the currently bound framebuffer.
// Currently hardcoded to be simple RGB.
// @TODO: Allow you to pass a framebuffer so this doesn't assume any state?
screenshot :: () {
    channels    :: 3;
    width       :: PIXEL_WIDTH;
    height      :: PIXEL_HEIGHT;
    stride      :: channels * width;
    total_bytes :: stride * height;

    image := New([total_bytes] GLubyte);
    defer free(image);

    glReadPixels(
        0,
        0,
        width,
        height,
        GL_RGB,
        GL_UNSIGNED_BYTE,
        image.data
    );

    directory_now_exists := make_directory_if_it_does_not_exist(screenshots_path, recursive = true);
    if !directory_now_exists then log_error("Unable to create directory at %", screenshots_path);
    filename := tprint("%/screenshot_%.png", screenshots_path, timestamp());

    stbi_result := stbi_write_png(
        filename = temp_c_string(filename),
        w = xx width,
        h = xx height,
        comp = xx channels,
        data = image.data,
        stride_in_bytes = xx stride,
    );
    if !stbi_result then log_error("stbi_write_png failed");

    if directory_now_exists && stbi_result then print("Took a screenshot! Saved at %\n", filename);
}
