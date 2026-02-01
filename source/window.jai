
// Window
////////////////////////////////////////////////////////////////////////////////

using window_constants : struct {
    TILE_SIZE_IN_PIXELS :: 16;

    PIXEL_WIDTH     :: 256;
    PIXEL_HEIGHT    :: 244;

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

initialize_window_context :: () {
    determine_max_scale_factor_based_on_resolution :: () -> int {
        display_mode : SDL_DisplayMode;
        SDL_GetDesktopDisplayMode(0, *display_mode);

        width_max   := cast(float)display_mode.w / PIXEL_WIDTH;
        height_max  := cast(float)display_mode.h / PIXEL_HEIGHT;
        max_scale_factor := cast(int)(min(width_max, height_max));

        return max_scale_factor;
    }

    // Find the ideal scale_factor based on the size of the desktop
    {
        window_context.max_scale_factor = determine_max_scale_factor_based_on_resolution();
        window_context.scale_factor = window_context.max_scale_factor;
    }

    resize_window(xx (PIXEL_WIDTH * window_context.scale_factor), xx (PIXEL_HEIGHT * window_context.scale_factor));
}

go_fullscreen :: () {
    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_FALSE);
    SDL_SetWindowBordered(window, SDL_FALSE);
    SDL_SetWindowPosition(window, 0, 0);
    SDL_SetWindowSize(window, display_mode.w, display_mode.h);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

go_windowed :: () {
    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    get_scaled_window_dimensions :: () -> s32, s32 {
        return cast(s32)window_context.scale_factor * PIXEL_WIDTH, cast(s32)window_context.scale_factor * PIXEL_HEIGHT;
    }
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
    if window_context.fullscreen then
        go_fullscreen();
    else
        go_windowed();
}

resize_window :: (width: s32, height: s32) {
    window_context.window_width  = width;
    window_context.window_height = height;

    window_aspect_ratio := cast(float)width / cast(float)height;

    if GAME_ASPECT_RATIO > window_aspect_ratio {
        window_context.viewport_width = window_context.window_width;
        window_context.viewport_height  = cast(s32)(window_context.viewport_width / GAME_ASPECT_RATIO);
    }
    else {
        window_context.viewport_height = window_context.window_height;
        window_context.viewport_width  = cast(s32)(window_context.viewport_height * GAME_ASPECT_RATIO);
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
    SDL_WarpMouseInWindow(window, window_context.window_width / 2, window_context.window_height / 2);
}

////////////////////////////////////////////////////////////////////////////////

debug_print :: (window_context: Window_Context)
{
    debug_print(
        tprint("P: %x%, W: %x%, V: %x%",
            PIXEL_WIDTH, PIXEL_HEIGHT,
            window_context.window_width, window_context.window_height,
            window_context.viewport_width, window_context.viewport_height
        ),
        color = teal
    );

    if window_context.fullscreen {
        debug_print("Fullscreen", color = teal);
    }
    else {
        debug_print(
            tprint("Pixel Scale: %", window_context.scale_factor),
            color = teal
        );
    }
}
