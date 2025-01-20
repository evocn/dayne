// Dayne
// Window
// August 2024

using window_constants : struct {
    PIXEL_WIDTH     :: 256;
    PIXEL_HEIGHT    :: 224;

    TILE_SIZE_IN_PIXELS :: 16;

    GAME_ASPECT_RATIO :: cast(float)PIXEL_WIDTH / cast(float)PIXEL_HEIGHT;
}

Window_Context :: struct {
    window_width    : s32;
    window_height   : s32;

    viewport_width  : s32;
    viewport_height : s32;

    fullscreen      : bool;
    max_scale_factor: int;
    scale_factor    : int = 1;
}

////////////////////////////////////////////////////////////////////////////////
// Fullscreen / Resolution

determine_max_scale_factor_based_on_resolution :: () -> int {
    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    width_max   := cast(float)display_mode.w / PIXEL_WIDTH;
    height_max  := cast(float)display_mode.h / PIXEL_HEIGHT;
    max_scale_factor := cast(int)(min(width_max, height_max));

    return max_scale_factor;
}

initialize_window_resolution :: () {
    using graphics_context;

    // Find the ideal scale_factor based on the size of the desktop
    {
        max_scale_factor = determine_max_scale_factor_based_on_resolution();
        scale_factor = max_scale_factor;
    }

    resize_window(xx (PIXEL_WIDTH * scale_factor), xx (PIXEL_HEIGHT * scale_factor));
}

go_fullscreen :: () {
    using graphics_context;

    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_FALSE);
    SDL_SetWindowBordered(window, SDL_FALSE);
    SDL_SetWindowPosition(window, 0, 0);
    SDL_SetWindowSize(window, display_mode.w, display_mode.h);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

get_scaled_window_dimensions :: () -> s32, s32 {
    using graphics_context;
    return cast(s32)scale_factor * PIXEL_WIDTH, cast(s32)scale_factor * PIXEL_HEIGHT;
}

go_windowed :: () {
    using graphics_context;

    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    scaled_width, scaled_height := get_scaled_window_dimensions();

    SDL_SetWindowResizable(window, SDL_TRUE);
    SDL_SetWindowBordered(window, SDL_TRUE);
    SDL_SetWindowSize(window,
        scaled_width,
        scaled_height
    );
    SDL_SetWindowPosition(window, 
        display_mode.w / 2 - scaled_width / 2,
        display_mode.h / 2 - scaled_height / 2
    );
    SDL_SetWindowResizable(window, SDL_FALSE);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

set_screen_mode_according_to_fullscreen_variable :: () {
    if graphics_context.fullscreen then
        go_fullscreen();
    else
        go_windowed();
}

resize_window :: (width: s32, height: s32) {
    graphics_context.window_width  = width;
    graphics_context.window_height = height;

    window_aspect_ratio := cast(float)width / cast(float)height;

    if GAME_ASPECT_RATIO > window_aspect_ratio {
        graphics_context.viewport_width = graphics_context.window_width;
        graphics_context.viewport_height  = cast(s32)(graphics_context.viewport_width / GAME_ASPECT_RATIO);
    }
    else {
        graphics_context.viewport_height = graphics_context.window_height;
        graphics_context.viewport_width  = cast(s32)(graphics_context.viewport_height * GAME_ASPECT_RATIO);
    }
}

////////////////////////////////////////////////////////////////////////////////

deactivate_mouse :: () {
    SDL_ShowCursor(0);
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

activate_mouse :: () {
    SDL_ShowCursor(1);
    SDL_SetRelativeMouseMode(SDL_FALSE);
    SDL_WarpMouseInWindow(window, graphics_context.window_width / 2, graphics_context.window_height / 2);
}
