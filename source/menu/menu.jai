
// Menu (simple, for the pause screen, mostly)
////////////////////////////////////////////////////////////////////////////////

apply_inputs :: (using input: Input, menu: *Menu) {
    if start.just_pressed || b.just_pressed {
        return_to_prior_mode();
        play_sfx("click");
    }

    if up.just_pressed {
        menu.element_index -= 1;
        if menu.element_index < 0 {
            menu.element_index += 1;
        }
        play_sfx("click");
    }
    if down.just_pressed {
        menu.element_index += 1;
        if menu.element_index >= menu.elements.count {
            menu.element_index -= 1;
        }
        play_sfx("click");
    }
    if left.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index], left=true);
        play_sfx("click");
    }
    if right.just_pressed {
        nudge_menu_element(menu.elements[menu.element_index]);
        play_sfx("click");
    }

    if a.just_pressed {
        toggle_menu_element(menu.elements[menu.element_index]);
    }
}

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
        screen_mode.value = *window_context.fullscreen;
        array_add(*elements, cast(*Menu_Element)screen_mode);

        sfx := New(Menu_Element_Slider,, a);
        sfx.name = "Sfx";
        sfx.value = *Sound_Player.mix_levels[Sound_Category.GENERAL_SFX];
        sfx.callback = null;
        array_add(*elements, cast(*Menu_Element)sfx);

        music := New(Menu_Element_Slider,, a);
        music.name = "Music";
        music.value = *Sound_Player.mix_levels[Sound_Category.MUSIC];
        music.callback = null;
        array_add(*elements, cast(*Menu_Element)music);

        quit := New(Menu_Element_Go,, a);
        quit.name = "Quit";
        quit.callback = quit_game;
        array_add(*elements, cast(*Menu_Element)quit);
    }

    return new_menu;
}



Menu :: struct {
    name : string;

    elements : [..] *Menu_Element;
    element_index : int;
}

// Elements below

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

    value : *float;
    callback : #type ();

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


// Functions

toggle_menu_element :: (using element: *Menu_Element) {
    if kind == {
        case .GO;
            using cast(*Menu_Element_Go)element;
            if callback then callback();
            play_sfx("click");

        case .CHECKBOX;
            using cast(*Menu_Element_Checkbox)element;
            value.* = !(value.*);
            if callback then callback();
            play_sfx("click");

        case .SLIDER;
            // Don't do anything.
    }

    #if DEVELOPER_TOOLS {
        save_tweaks_file("all");
    }
}


nudge_menu_element :: (using element: *Menu_Element, left := false) {
    if kind == {
        case .GO; ; // Nothing
        case .CHECKBOX;
            using cast(*Menu_Element_Checkbox)element;
            value.* = !(value.*);
            if callback then callback();
            play_sfx("click");

        case .SLIDER;
            using cast(*Menu_Element_Slider)element;
            if left {
                value.* = clamp(value.* - increment, min, max);
                if callback then callback();
            }
            else {
                value.* = clamp(value.* + increment, min, max);
                if callback then callback();
            }

            play_sfx("click");
    }

    #if DEVELOPER_TOOLS {
        save_tweaks_file("all");
    }
}


// Callbacks for Menu Elements
resume_game :: () {
    return_to_prior_mode();
}

quit_game :: () {
    program_state.running = false;
}

go_to_settings :: () {
    switch_mode(.MENU);
}

////////////////////////////////////////////////////////////////////////////////

draw_menu :: (using menu: Menu) {
    use_text_shader();

    k := 10;
    total_height := k * elements.count + 2;

    for elements {
        draw_menu_element(it, total_height - (it_index + 1) * k, color=it.usual_color);
    }

    // Draw selected element over it.
    if elements.count {
        hovering := *elements[element_index];
        draw_menu_element(hovering.*, total_height - (element_index + 1) * k + 1, color=hovering.*.hover_color);
    }
}

draw_menu_element :: (using element: *Menu_Element, height : int, color := white) {
    if kind == {
        case .GO;
            using cast(*Menu_Element_Go)element;
            draw_text(name, 1, height, color=color);

        case .CHECKBOX;
            using cast(*Menu_Element_Checkbox)element;
            str := "Off";
            if value.* then str = "On";
            draw_text(tprint("% - %", name, str), 1, height, color=color);

        case .SLIDER;
            using cast(*Menu_Element_Slider)element;
            draw_text(tprint("% - %", name, value.*), 1, height, color=color);
    }
}
