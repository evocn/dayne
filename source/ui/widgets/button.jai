
// Button (Widget)
////////////////////////////////////////////////////////////////////////////////

Button_Visuals :: struct {
    colors : struct {
        box : struct {
            neutral : Color;
            hovered : Color;
            clicked : Color;
            disabled : Color; 
        }
        outline : struct {
            neutral : Color;
            hovered : Color;
            clicked : Color;
            disabled : Color;
        }
        text : struct {
            neutral : Color;
            hovered : Color;
            clicked : Color;
            disabled : Color;
        }
    }

    text : struct {
        font_kind : Font_Kind;
        alignment : Alignment;
    }
}

Button_Visuals_Default :: Button_Visuals.{
    colors = .{
        box = .{
            neutral = black,
            hovered = red,
            clicked = blue,
            disabled = gray,
        },
        outline = .{
            neutral = white,
            hovered = gray,
            clicked = blue,
            disabled = black,
        },
        text = .{
            neutral = white,
            hovered = black,
            clicked = white,
            disabled = black,
        }
    },

    text = .{
        font_kind = .MAIN,
        alignment = .CENTER,
    },
};

Button_Visuals_Transparent :: Button_Visuals.{
    colors = .{
        box = .{
            neutral = color_none,
            hovered = color_none,
            clicked = color_none,
            disabled = color_none,
        },
        outline = .{
            neutral = color_none,
            hovered = color_none,
            clicked = color_none,
            disabled = color_none,
        },
        text = .{
            neutral = white,
            hovered = blue,
            clicked = black,
            disabled = gray,
        }
    },

    text = .{
        font_kind = .MAIN,
        alignment = .CENTER,
    },
};

button :: (box: Box, text: string, disabled := false, visuals := Button_Visuals_Default) -> (clicked: bool, hovered: bool, draw_call: *Button_Draw_Call)
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

        draw_call.font_kind = visuals.text.font_kind;
        draw_call.text_alignment = visuals.text.alignment;

        // Color
        {
            if is_active(id) {
                draw_call.box_color     = visuals.colors.box.clicked;
                draw_call.outline_color = visuals.colors.outline.clicked;
                draw_call.text_color    = visuals.colors.text.clicked;
            }
            else if is_hot(id) {
                draw_call.box_color     = visuals.colors.box.hovered;
                draw_call.outline_color = visuals.colors.outline.hovered;
                draw_call.text_color    = visuals.colors.text.hovered;
            }
            else {
                draw_call.box_color     = visuals.colors.box.neutral;
                draw_call.outline_color = visuals.colors.outline.neutral;
                draw_call.text_color    = visuals.colors.text.neutral;
            }

            if disabled {
                draw_call.box_color     = visuals.colors.box.disabled;
                draw_call.outline_color = visuals.colors.outline.disabled;
                draw_call.text_color    = visuals.colors.text.disabled;
            }
        }

        array_add(*ui_context.draw_calls, cast(*Widget_Draw_Call, draw_call));
    }

    if clicked {
        play_sfx("click");
    }

    return clicked, within, draw_call;
}

Button_Draw_Call :: struct {
    using #as base: Widget_Draw_Call;
    kind = .BUTTON;

    box         : Box;
    text        : string;

    font_kind : Font_Kind;
    text_alignment : Alignment;

    using colors : struct {
        box_color       : Color;
        outline_color   : Color;
        text_color      : Color;
    }
}

button_draw :: (using draw_call: Button_Draw_Call) {
    margin :: 1;
    left   := box.x + margin;
    right  := box.x + box.width - margin;
    middle := box.x + box.width / 2;
    bottom := box.y + margin;

    draw(box, box_color, outline_color);

    x : int;
    if text_alignment == {
        case .LEFT;     x = left;
        case .CENTER;   x = middle;
        case .RIGHT;    x = right;
    }

    draw_text(
        get_widget_text(text),
        x = x,
        y = bottom,
        alignment   = text_alignment,
        font        = font_kind,
        color       = text_color,
    );
}
