
// Button (Widget)
////////////////////////////////////////////////////////////////////////////////

Button_Visuals :: struct {
    COLORS :: struct {
        BOX :: struct {
            NEUTRAL     :: black;
            HOVERED     :: red;
            CLICKED     :: blue;
            DISABLED    :: gray;
        }
        OUTLINE :: struct {
            NEUTRAL     :: white;
            HOVERED     :: gray;
            CLICKED     :: blue;
            DISABLED    :: black;
        }
    }
}

button :: (box: Box, text: string, disabled := false) -> (clicked: bool, hovered: bool, draw_call: *Button_Draw_Call)
{
    id := get_widget_id(text);

    within := mouse_is_within(box);
    clicked : bool;

    // Logic
    if !disabled {
        if is_active(id) {
            if mouse_just_released() {
                if is_hot(id) {
                    clicked = true;
                }
                unset_active();
            }
        }

        if is_hot(id) {
            if mouse_just_pressed() {
                set_active(.{id});
            }
            if !within {
                unset_hot();
            }
        }

        if within {
            set_hot(.{id});
        }
    }

    if disabled && is_hot(id) then unset_hot();

    draw_call : *Button_Draw_Call;
    {
        push_allocator(ui_context.allocator);
        draw_call = New(Button_Draw_Call);

        draw_call.box   = box;
        draw_call.text  = text;

        {
            if is_active(id) {
                draw_call.box_color     = Button_Visuals.COLORS.BOX.CLICKED;
                draw_call.outline_color = Button_Visuals.COLORS.OUTLINE.CLICKED;
            }
            else if is_hot(id) {
                draw_call.box_color     = Button_Visuals.COLORS.BOX.HOVERED;
                draw_call.outline_color = Button_Visuals.COLORS.OUTLINE.HOVERED;
            }
            else {
                draw_call.box_color     = Button_Visuals.COLORS.BOX.NEUTRAL;
                draw_call.outline_color = Button_Visuals.COLORS.OUTLINE.NEUTRAL;
            }

            if disabled {
                draw_call.box_color     = Button_Visuals.COLORS.BOX.DISABLED;
                draw_call.outline_color = Button_Visuals.COLORS.OUTLINE.DISABLED;
            }
        }

        array_add(*ui_context.draw_calls, cast(*Widget_Draw_Call, draw_call));
    }

    return clicked, within, draw_call;
}

Button_Draw_Call :: struct {
    using #as base: Widget_Draw_Call;
    kind = .BUTTON;

    box         : Box;
    text        : string;

    using colors : struct {
        box_color   : Color;
        outline_color : Color;
    }
}

button_draw :: (using draw_call: Button_Draw_Call) {
    draw(box, box_color, outline_color);

    middle := box.x + box.width / 2;
    bottom := box.y + 2;

    draw_text(
        text,
        x = middle,
        y = bottom,
        alignment   = Alignment.CENTER,
        font        = .MAIN,
        color       = white,
    );
}
