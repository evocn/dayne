
// Text Box (Widget)
////////////////////////////////////////////////////////////////////////////////

Text_Box_Visuals :: struct {
    Colors :: struct {
        Neutral     :: struct {
            BACKGROUND  :: black;
            TEXT        :: white;
        }
        Disabled    :: struct {
            BACKGROUND  :: gray;
            TEXT        :: white;
        }
    }

    Formatting :: struct {
        Margin :: struct {
            X :: 4;
            Y :: 4;
        }

        LINE_SEPARATION :: 0;
    }
}

text_box :: (box: Box, text: string, disabled := false, text_alignment := Alignment.LEFT) -> (draw_call: *Text_Box_Draw_Call) {
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
        draw_call.text_alignment = text_alignment;

        if disabled {
            draw_call.background_color = Text_Box_Visuals.Colors.Disabled.BACKGROUND;
            draw_call.text_color = Text_Box_Visuals.Colors.Disabled.TEXT;
        }
        else {
            draw_call.background_color = Text_Box_Visuals.Colors.Neutral.BACKGROUND;
            draw_call.text_color = Text_Box_Visuals.Colors.Neutral.TEXT;
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
    text_alignment : Alignment;

    using colors : struct {
        background_color    : Color;
        text_color          : Color;
    }
}

text_box_draw :: (using draw_call: Text_Box_Draw_Call) {
    draw(box, background_color);

    center := box.x + box.width / 2;
    left := box.x + Text_Box_Visuals.Formatting.Margin.X;
    right := box.x + box.width - Text_Box_Visuals.Formatting.Margin.X;
    top := box.y + box.height - 8 - Text_Box_Visuals.Formatting.LINE_SEPARATION - Text_Box_Visuals.Formatting.Margin.Y;

    {
        x : int;
        if text_alignment == {
            case .LEFT;     x = left;
            case .CENTER;   x = center;
            case .RIGHT;    x = right;
        }

        draw_text(
            text,
            x = x,
            y = top,
            alignment   = text_alignment,
            font        = .MAIN,
            color       = text_color,
            separation  = Text_Box_Visuals.Formatting.LINE_SEPARATION,
        );
    }
}
