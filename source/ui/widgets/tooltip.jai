
// Tooltip (Widget)
////////////////////////////////////////////////////////////////////////////////

Tooltip_Visuals_Default :: Text_Box_Visuals.{
    colors = .{
        box = .{
            neutral = black,
            disabled = gray,
        },
        outline = .{
            neutral = color_none,
            disabled = color_none,
        },
        text = .{
            neutral = white,
            disabled = black,
        }
    },

    text = .{
        font_kind = .MAIN,
        alignment = .CENTER,
        margin = .{ x = 2, y = 2, },
        line_separation = 0,
    },
};

tooltip :: (box: Box, text: string, hover_element_label: string, visuals := Tooltip_Visuals_Default) -> (draw_call: *Text_Box_Draw_Call) {
    id := get_widget_id(text);

    // We only display this element if the specified hover element is hot.
    visible : bool;
    {
        hover_id := get_widget_id(hover_element_label);
        if is_hot(hover_id) {
            visible = true;
        }
    }

    moved_box := box;
    {
        mouse_position := get_mouse_position();

        // We have to put the box where the mouse is, but also keep it from going off the screen as best we can.
        // Initial strategy: Just find the quadrant of the screen we're in, and choose a direction based on that.
        quadrant := get_screen_quadrant(mouse_position);
        if quadrant == {
            case .UPPER_RIGHT; {
                moved_box.x = mouse_position.x;
                moved_box.y = mouse_position.y - moved_box.height;
            }
            case .UPPER_LEFT; {
                moved_box.x = mouse_position.x - moved_box.width;
                moved_box.y = mouse_position.y - moved_box.height;
            }
            case .LOWER_LEFT; {
                moved_box.x = mouse_position.x;
                moved_box.y = mouse_position.y;
            }
            case .LOWER_RIGHT; {
                moved_box.x = mouse_position.x - moved_box.width;
                moved_box.y = mouse_position.y;
            }
        }
    }

    draw_call : *Text_Box_Draw_Call;
    if visible {
        push_allocator(ui_context.allocator);
        draw_call = New(Text_Box_Draw_Call);

        draw_call.box   = moved_box;
        draw_call.text  = text;

        draw_call.font_kind = visuals.text.font_kind;
        draw_call.alignment = visuals.text.alignment;
        draw_call.margin    = visuals.text.margin;
        draw_call.line_separation = visuals.text.line_separation;

        {
            draw_call.box_color = visuals.colors.box.neutral;
            draw_call.outline_color = visuals.colors.outline.neutral;
            draw_call.text_color = visuals.colors.text.neutral;
        }

        array_add(*ui_context.draw_calls, cast(*Widget_Draw_Call, draw_call));
    }

    return draw_call;
}

////////////////////////////////////////////////////////////////////////////////

Quadrant :: enum {
    UPPER_RIGHT;
    UPPER_LEFT;
    LOWER_LEFT;
    LOWER_RIGHT;
}

get_screen_quadrant :: (using position: Pair) -> Quadrant {
    middle_x :: PIXEL_WIDTH / 2;
    middle_y :: PIXEL_HEIGHT / 2;

    result : Quadrant;
    if x > middle_x { // right
        if y > middle_y { // upper
            result = .UPPER_RIGHT;
        }
        else { // lower
            result = .LOWER_RIGHT;
        }
    }
    else { // left
        if y > middle_y { // upper
            result = .UPPER_LEFT;
        }
        else { // lower
            result = .LOWER_LEFT;
        }
    }

    return result;
}
