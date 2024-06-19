// Dayne
// Window
// Alex Hartford
// February 2024

////////////////////////////////////////////////////////////////////////////////
// Fullscreen / Resolution
////////////////////////////////////////////////////////////////////////////////

go_fullscreen :: () {
    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_FALSE);
    SDL_SetWindowBordered(window, SDL_FALSE);
    SDL_SetWindowPosition(window, 0, 0);
    SDL_SetWindowSize(window, display_mode.w, display_mode.h);

    render_context.window_width  = display_mode.w;
    render_context.window_height = display_mode.h;

    SDL_GetWindowDisplayMode(window, *display_mode);
}

go_windowed :: () {
    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_TRUE);
    SDL_SetWindowBordered(window, SDL_TRUE);

    render_context.window_width  = PIXEL_WIDTH  * render_context.window_scale_factor;
    render_context.window_height = PIXEL_HEIGHT * render_context.window_scale_factor;

    SDL_SetWindowSize(window,
        render_context.window_width,
        render_context.window_height,
    );
    SDL_SetWindowPosition(window, 
        display_mode.w / 2 - render_context.window_width  / 2,
        display_mode.h / 2 - render_context.window_height / 2
    );
    SDL_SetWindowResizable(window, SDL_FALSE);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

set_screen_mode_according_to_fullscreen_variable :: () {
    if render_context.fullscreen then
        go_fullscreen();
    else
        go_windowed();
}

////////////////////////////////////////////////////////////////////////////////

mouse_game_mode :: () {
    SDL_ShowCursor(0);
}

mouse_editor_mode :: () {
    SDL_ShowCursor(1);
}
