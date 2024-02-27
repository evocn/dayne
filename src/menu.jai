// Dayne
// Menu
// Alex Hartford
// February 2024

menu_initialize :: () -> Menu {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *scratch_memory;

    new_menu: Menu;

    {
        using new_menu;
        elements.allocator = a;
        name = "Pause";

        resume := New(Menu_Element_Go,, a);
        resume.name = "Resume";
        resume.callback = resume_game;
        array_add(*elements, cast(*Menu_Element)resume);

        screen_mode := New(Menu_Element_Checkbox,, a);
        screen_mode.name = "Fullscreen";
        screen_mode.callback = set_screen_mode_according_to_fullscreen_variable;
        screen_mode.value = *render_context.fullscreen;
        array_add(*elements, cast(*Menu_Element)screen_mode);

        sfx := New(Menu_Element_Slider,, a);
        sfx.name = "Sounds";
        sfx.value = get_sfx_volume();
        sfx.callback = set_sfx_volume;
        array_add(*elements, cast(*Menu_Element)sfx);

        music := New(Menu_Element_Slider,, a);
        music.name = "Music";
        music.value = get_music_volume();
        music.callback = set_music_volume;
        array_add(*elements, cast(*Menu_Element)music);

        quit := New(Menu_Element_Go,, a);
        quit.name = "Quit";
        quit.callback = quit_game;
        array_add(*elements, cast(*Menu_Element)quit);
    }

    return new_menu;
}

////////////////////////////////////////////////////////////////////////////////
// Elements
////////////////////////////////////////////////////////////////////////////////

Menu_Element_Go :: struct {
    using #as menu_element: Menu_Element;
    kind = .GO;

    callback : #type ();
}

Menu_Element_Checkbox :: struct {
    using #as menu_element: Menu_Element;
    kind = .CHECKBOX;

    value : *bool;

    callback : #type ();
}

Menu_Element_Slider :: struct {
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

////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////

// This could return false if we want there to be menu options that bonk on failure.
// Not sure what that would be useful for, just figured I'd mention it in case it became useful.
toggle_menu_element :: (using element: *Menu_Element) {
    if kind == {
        case .GO;
            using cast(*Menu_Element_Go)element;
            callback();
            play_sfx("click");

        case .CHECKBOX;
            using cast(*Menu_Element_Checkbox)element;
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
            using cast(*Menu_Element_Checkbox)element;
            value.* = !(value.*);
            callback();
            play_sfx("click");

        case .SLIDER;
            using cast(*Menu_Element_Slider)element;
            if left {
                value = clamp(value - increment, min, max);
                callback(value);
            }
            else {
                value = clamp(value + increment, min, max);
                callback(value);
            }

            play_sfx("click");
    }

    save_tweaks_file("all");
}

////////////////////////////////////////////////////////////////////////////////
// Callbacks for Menu Elements
////////////////////////////////////////////////////////////////////////////////
resume_game :: () {
    return_to_prior_scene();
}

quit_game :: () {
    program_state.running = false;
}

go_to_settings :: () {
    switch_scene(.MENU);
}
