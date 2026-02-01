
// UI
////////////////////////////////////////////////////////////////////////////////

#load "widget.jai";

UI_Context :: struct {
    using internals : struct {
        pool : Flat_Pool;
        allocator: Allocator;
    }

    input_state : UI_Input_State;

    hot     : Widget_Identifier = Null_Widget;
    active  : Widget_Identifier = Null_Widget;

    draw_calls: [..] *Widget_Draw_Call;
    id_stack: [..] int;
}

initialize :: (using ui_context: *UI_Context) {
    allocator.proc = flat_pool_allocator_proc;
    allocator.data = *pool;

    draw_calls.allocator = allocator;
}

finalize :: (using ui_context: *UI_Context) {
    array_reset(*draw_calls);
    reset(*pool, overwrite_memory=true);
}

new_frame :: (using ui_context: *UI_Context) {
    array_reset(*draw_calls);
    reset(*pool, overwrite_memory=true);
}

reset :: (using ui_context: *UI_Context) {
    hot = Null_Widget;
    active = Null_Widget;
    new_frame(ui_context);
}

apply_inputs :: (input: Input, ui: *UI_Context) {
    apply_inputs(input, *ui.input_state);

    {
        using ui_context;
        debug_print(tprint("ui | hot: %, active: %", hot, active));
    }
}

update :: (using ui : *UI_Context) {
    hovering := hot.widget != -1;
    clicking := active.widget != -1;

    // Mouse cursor visuals
    {
        if hovering {
            if clicking {
                input_state.mouse_frame = .GRAB;
            }
            else {
                input_state.mouse_frame = .HOVER;
            }
        }
        else {
            input_state.mouse_frame = .NEUTRAL;
        }
    }
}

draw :: (using ui : UI_Context) {
    for draw_calls widget_draw(it);

    // Draw input state
    {
        draw(input_state);
    }
}

////////////////////////////////////////////////////////////////////////////////

UI_Input_State :: struct {
    using input_state : struct {
        mouse : Input_Button;
        position : Pair;
        active : bool;
    }

    using visual_state : struct {
        Mouse_Visual_Frame :: enum {
            NEUTRAL;
            GRAB;
            HOVER;
            PEACE;
            LEFT;
            RIGHT;
        }
        mouse_frame : Mouse_Visual_Frame;
    }
}

apply_inputs :: (input: Input, using ui_input_state: *UI_Input_State) {
    // Mouse implementation
    {
        mouse = input.mouse.left;
        position = input.mouse.position;
        active = input.mouse.active;
    }
}

draw :: (using ui_input_state: UI_Input_State) {
    if !active then return;

    #if DEVELOPER_TOOLS {
        if editor.imgui_state.capturing_mouse {
        }
        else {
            draw_mouse_cursor(position, xx mouse_frame);
            debug_print(tprint("%", mouse_frame));
        }
    }
    else {
        draw_mouse_cursor(position, xx mouse_frame);
    }
}

mouse_is_within :: (box: Box) -> bool {
    return point_within(ui_context.input_state.position, box);
}

mouse_just_released :: () -> bool {
    return ui_context.input_state.mouse.just_released;
}

mouse_just_pressed :: () -> bool {
    return ui_context.input_state.mouse.just_pressed;
}

get_mouse_position :: () -> Pair {
    return ui_context.input_state.position;
}
