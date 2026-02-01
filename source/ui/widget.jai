
// Widget
////////////////////////////////////////////////////////////////////////////////

#load "widgets/button.jai";
#load "widgets/text-box.jai";
#load "widgets/tooltip.jai";

////////////////////////////////////////////////////////////////////////////////

Widget_Id :: #type,distinct s64;

get_widget_id :: (text: string) -> Widget_Id {
    hash := get_hash(text);

    if ui_context.id_stack.count != 0 {
        top_of_id_stack := peek(ui_context.id_stack);
        hash = hash ^ get_hash(top_of_id_stack);
    }

    return cast(Widget_Id, hash);
}

////////////////////////////////////////////////////////////////////////////////

Widget_Identifier :: struct {
    widget : Widget_Id;
}

Null_Widget :: Widget_Identifier.{widget = -1};

operator == :: (a: Widget_Identifier, b: Widget_Identifier) -> bool {
    return a.widget == b.widget;
}

////////////////////////////////////////////////////////////////////////////////

is_hot :: (id: Widget_Id) -> bool {
    return id == ui_context.hot.widget;
}

is_active :: (id: Widget_Id) -> bool {
    return id == ui_context.active.widget;
}

set_hot :: (identifier: Widget_Identifier) {
    if ui_context.active != Null_Widget && ui_context.active != identifier then return;
    ui_context.hot = identifier;
}

set_active :: (identifier: Widget_Identifier) {
    ui_context.active = identifier;
}


unset_hot :: () {
    ui_context.hot = Null_Widget;
}

unset_active :: () {
    ui_context.active = Null_Widget;
}

////////////////////////////////////////////////////////////////////////////////

Widget_Draw_Call :: struct {
    Kind :: enum {
        BUTTON;
        TEXT_BOX;
        TOOLTIP;
    }
    kind : Kind;
    
    // @TODO(alex):
    // I'm not sure how else you are supposed to handle polymorphic structs in these dynamic scenarios...
    // I just haven't used polymorphism that much, so I'm pretty sure this is trivial, but I just don't have the info yet.
    // For now, we'll just do the hack.
    polymorph_data : *void;
}

widget_draw :: (draw_call: *Widget_Draw_Call) {
    if #complete draw_call.kind == {
        case .BUTTON;       button_draw(cast(*Button_Draw_Call, draw_call));
        case .TEXT_BOX;     text_box_draw(cast(*Text_Box_Draw_Call, draw_call));
        case .TOOLTIP;      text_box_draw(cast(*Text_Box_Draw_Call, draw_call));
    }
}

////////////////////////////////////////////////////////////////////////////////

push_id :: (id: int) {
    array_add(*ui_context.id_stack, id);
}

pop_id :: () {
    assert(ui_context.id_stack.count != 0, "Unmatched push_id and pop_id calls.");

    id := pop(*ui_context.id_stack);
}
