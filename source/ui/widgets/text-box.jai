
// Text Box (Widget)
////////////////////////////////////////////////////////////////////////////////

Text_Box_Visuals :: struct {
    colors : struct {
        box : struct {
            neutral : Color;
            disabled : Color; 
        }
        outline : struct {
            neutral : Color;
            disabled : Color;
        }
        text : struct {
            neutral : Color;
            disabled : Color;
        }
    }

    text : struct {
        font_kind : Font_Kind;
        alignment : Alignment;
        margin : Pair;
        line_separation : int;
    }
}

Text_Box_Visuals_Default :: Text_Box_Visuals.{
    colors = .{
        box = .{
            neutral = black,
            disabled = gray,
        },
        outline = .{
            neutral = white,
            disabled = white,
        },
        text = .{
            neutral = white,
            disabled = black,
        }
    },

    text = .{
        font_kind = .MAIN,
        alignment = .LEFT,
        margin = .{ x = 4, y = 4, },
        line_separation = 0,
    },
};

Text_Box_Visuals_Transparent :: Text_Box_Visuals.{
    colors = .{
        box = .{
            neutral = color_none,
            disabled = color_none,
        },
        outline = .{
            neutral = color_none,
            disabled = color_none,
        },
        text = .{
            neutral = white,
            disabled = gray,
        }
    },

    text = .{
        font_kind = .MAIN,
        alignment = .LEFT,
        margin = .{ x = 4, y = 4, },
        line_separation = 0,
    },
};

text_box :: (box: Box, text: string, disabled := false, visuals := Text_Box_Visuals_Default) -> (draw_call: *Text_Box_Draw_Call) {
    id := get_widget_id(text);

    within := mouse_is_within(box);

    if !disabled {
        if is_hot(id) {
            if !within {
                unset_hot();
            }
        }

        if within {
            set_hot(.{id});
        }
    }

    if disabled && is_hot(id) then unset_hot();

    draw_call : *Text_Box_Draw_Call;
    {
        push_allocator(ui_context.allocator);
        draw_call = New(Text_Box_Draw_Call);

        draw_call.box   = box;
        draw_call.text  = text;

        draw_call.font_kind = visuals.text.font_kind;
        draw_call.alignment = visuals.text.alignment;
        draw_call.margin    = visuals.text.margin;
        draw_call.line_separation = visuals.text.line_separation;

        if disabled {
            draw_call.box_color     = visuals.colors.box.disabled;
            draw_call.outline_color = visuals.colors.outline.disabled;
            draw_call.text_color    = visuals.colors.text.disabled;
        }
        else {
            draw_call.box_color     = visuals.colors.box.neutral;
            draw_call.outline_color = visuals.colors.outline.neutral;
            draw_call.text_color    = visuals.colors.text.neutral;
        }

        array_add(*ui_context.draw_calls, cast(*Widget_Draw_Call, draw_call));
    }

    return draw_call;
}

Text_Box_Draw_Call :: struct {
    using #as base: Widget_Draw_Call;
    kind = .TEXT_BOX;

    box         : Box;
    text        : string;

    font_kind : Font_Kind;
    alignment : Alignment;
    margin : Pair;
    line_separation : int;

    using colors : struct {
        box_color       : Color;
        outline_color   : Color;
        text_color      : Color;
    }
}

text_box_draw :: (using draw_call: Text_Box_Draw_Call) {
    draw(box, box_color, outline_color);

    center := box.x + box.width / 2;
    left := box.x + margin.x;
    right := box.x + margin.x;
    top := box.y + box.height - 8 - line_separation - margin.y;

    {
        x : int;
        if alignment == {
            case .LEFT;     x = left;
            case .CENTER;   x = center;
            case .RIGHT;    x = right;
        }

        draw_text(
            text,
            x = x,
            y = top,
            alignment   = alignment,
            font        = font_kind,
            color       = text_color,
            separation  = line_separation,
        );
    }
}
