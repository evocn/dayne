// Dayne
// Window
// Alex Hartford
// February 2024

PIXEL_WIDTH     :: 240;
PIXEL_HEIGHT    :: 160;

WINDOW_SCALE_FACTOR :: 8;

DEFAULT_WINDOW_WIDTH    :: PIXEL_WIDTH  * WINDOW_SCALE_FACTOR;
DEFAULT_WINDOW_HEIGHT   :: PIXEL_HEIGHT * WINDOW_SCALE_FACTOR;

GAME_ASPECT_RATIO : float : cast(float)PIXEL_WIDTH / PIXEL_HEIGHT;

Render_Context :: struct {
    window_width  : s32 = DEFAULT_WINDOW_WIDTH;
    window_height : s32 = DEFAULT_WINDOW_HEIGHT;

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

    SDL_GetWindowDisplayMode(window, *display_mode);
}

go_windowed :: () {
    display_mode : SDL_DisplayMode;
    SDL_GetDesktopDisplayMode(0, *display_mode);

    SDL_SetWindowResizable(window, SDL_TRUE);
    SDL_SetWindowBordered(window, SDL_TRUE);
    SDL_SetWindowSize(window,
        DEFAULT_WINDOW_WIDTH,
        DEFAULT_WINDOW_HEIGHT
    );
    SDL_SetWindowPosition(window, 
        display_mode.w / 2 - DEFAULT_WINDOW_WIDTH / 2,
        display_mode.h / 2 - DEFAULT_WINDOW_HEIGHT / 2
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
