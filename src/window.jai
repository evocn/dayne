// Dayne
// Window
// Alex Hartford
// February 2024

PIXEL_WIDTH     :: 240;
PIXEL_HEIGHT    :: 160;

DEFAULT_WINDOW_SCALE_FACTOR :: 6;
DEFAULT_WINDOW_WIDTH    :: PIXEL_WIDTH  * DEFAULT_WINDOW_SCALE_FACTOR;
DEFAULT_WINDOW_HEIGHT   :: PIXEL_HEIGHT * DEFAULT_WINDOW_SCALE_FACTOR;

GAME_ASPECT_RATIO : float : cast(float)PIXEL_WIDTH / PIXEL_HEIGHT;

Render_Context :: struct {
    window_width  : s32 = DEFAULT_WINDOW_WIDTH;
    window_height : s32 = DEFAULT_WINDOW_HEIGHT;
    window_scale_factor : s32 = DEFAULT_WINDOW_SCALE_FACTOR;

    viewport_width : s32 = cast(s32)(DEFAULT_WINDOW_HEIGHT * GAME_ASPECT_RATIO);
    viewport_height: s32 = DEFAULT_WINDOW_HEIGHT;

    fullscreen: bool;

    using opengl_context : OpenGL_Context;
}

////////////////////////////////////////////////////////////////////////////////

mouse_game_mode :: () {
    SDL_ShowCursor(0);
}

mouse_editor_mode :: () {
    SDL_ShowCursor(1);
}

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
