
// Tooltip (Widget)
////////////////////////////////////////////////////////////////////////////////

tooltip :: (box: Box, text: string, hover_element_label: string, text_alignment := Alignment.LEFT) -> (draw_call: *Text_Box_Draw_Call) {
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
        draw_call.text_alignment = text_alignment;

        {
            draw_call.background_color = Text_Box_Visuals.Colors.Neutral.BACKGROUND;
            draw_call.text_color = Text_Box_Visuals.Colors.Neutral.TEXT;
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
