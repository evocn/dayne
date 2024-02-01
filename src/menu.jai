// Dayne
// Menu
// Alex Hartford
// July 2023

menu_initialize :: () -> Menu {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *scratch_memory;

    new_menu: Menu;

    {
        using new_menu;
        elements.allocator = a;
        name = "Pause";

        resume := New(Go_Element,, a);
        resume.name = "Resume";
        resume.callback = resume_game;
        array_add(*elements, cast(*Menu_Element)resume);

        screen_mode := New(Checkbox_Element,, a);
        screen_mode.name = "Fullscreen";
        screen_mode.callback = set_screen_mode_according_to_fullscreen_variable;
        screen_mode.value = *fullscreen;
        array_add(*elements, cast(*Menu_Element)screen_mode);

        sfx := New(Slider_Element,, a);
        sfx.name = "Sounds";
        sfx.value = ma_sound_group_get_volume(*audio_context.sfx_group);
        sfx.callback = set_sfx_volume;
        array_add(*elements, cast(*Menu_Element)sfx);

        music := New(Slider_Element,, a);
        music.name = "Music";
        music.value = ma_sound_group_get_volume(*audio_context.music_group);
        music.callback = set_music_volume;
        array_add(*elements, cast(*Menu_Element)music);

        quit := New(Go_Element,, a);
        quit.name = "Quit";
        quit.callback = quit_game;
        array_add(*elements, cast(*Menu_Element)quit);
    }

    return new_menu;
}

////////////////////////////////////////////////////////////////////////////////

Go_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .GO;

    callback : #type ();
}

Checkbox_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .CHECKBOX;

    value : *bool;

    callback : #type ();
}

Slider_Element :: struct {
    using #as menu_element: Menu_Element;
    kind = .SLIDER;

    value : float;
    callback : (float) -> ();

    increment : float = 0.25;
    min : float = 0.0;
    max : float = 1.0;
}

Menu_Element :: struct {
    kind : enum #complete {
        GO;
        CHECKBOX;
        SLIDER;
    }

    name : string;
    usual_color: Color = gray;
    hover_color: Color = white;
}

Menu :: struct {
    name : string;

    elements : [..] *Menu_Element;
    element_index : int;
}

resolve_menu_inputs :: (menu: *Menu, input: User_Input) {
    if input.start.just_pressed || input.east.just_pressed {
        return_to_prior_scene();
        play_sfx("click");
    }

    if input.up.just_pressed {
        menu.element_index -= 1;
        if menu.element_index < 0 {
            menu.element_index += 1;
        }
        play_sfx("click");
    }
    if input.down.just_pressed {
        menu.element_index += 1;
        if menu.element_index >= menu.elements.count {
            menu.element_index -= 1;
        }
        play_sfx("click");
    }
    if input.left.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index], left=true);
        play_sfx("click");
    }
    if input.right.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index]);
        play_sfx("click");
    }

    if input.south.just_pressed {
        toggle_menu_element(menu.elements[menu.element_index]);
    }
}

// This could return false if we want there to be menu options that bonk on failure.
// Not sure what that would be useful for, just figured I'd mention it in case it became useful.
toggle_menu_element :: (using element: *Menu_Element) {
    if kind == {
        case .GO;
            using cast(*Go_Element)element;
            callback();
            play_sfx("click");

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            value.* = !(value.*);
            callback();
            play_sfx("click");

        case .SLIDER;
            // Don't do anything.
    }

    save_tweaks_file("all");
}


nudge_menu_element :: (using element: *Menu_Element, left := false) {
    if kind == {
        case .GO;
            // Don't do anything.

        case .CHECKBOX;
            using cast(*Checkbox_Element)element;
            value.* = !(value.*);
            callback();
            play_sfx("choose");

        case .SLIDER;
            using cast(*Slider_Element)element;
            if left {
                value = clamp(value - increment, min, max);
                callback(value);
            }
            else {
                value = clamp(value + increment, min, max);
                callback(value);
            }
    }

    save_tweaks_file("all");
}

//
// Callbacks for Menu Elements /////////////////////////////////////////////////
//
resume_game :: () {
    return_to_prior_scene();
}

quit_game :: () {
    running = false;
}

go_to_settings :: () {
    switch_scene(.MENU);
}

// Fullscreen stuff

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
    SDL_SetWindowSize(window, WINDOW_WIDTH, WINDOW_HEIGHT);
    SDL_SetWindowPosition(window, display_mode.w / 2 - WINDOW_WIDTH / 2, display_mode.h / 2 - WINDOW_HEIGHT / 2);
    SDL_SetWindowResizable(window, SDL_FALSE);

    SDL_GetWindowDisplayMode(window, *display_mode);
}

set_screen_mode_according_to_fullscreen_variable :: () {
    if fullscreen then go_fullscreen();
    else go_windowed();
}
