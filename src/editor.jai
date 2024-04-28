// Dayne
// Editor
// Alex Hartford
// February 2024

#load "editor_imgui_init.jai";

editor_state : struct {
    entity_index : int = -1;
}

update_and_draw_editor :: (game: *Game) {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse     = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard  = io.WantCaptureKeyboard;
    program_state.framerate                 = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor(game);

        entities_editor(game);

        ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}

////////////////////////////////////////////////////////////////////////////////
// Individual Editors
////////////////////////////////////////////////////////////////////////////////

entities_editor :: (game: *Game) {
    ImGui.Begin("Entities");
    {
        if ImGui.Button("Load") {
            success := load_entities(*game.entities, "entities.txt");
            assert(success, "Failed to load entities from a file.\n");
        }
        ImGui.SameLine();
        if ImGui.Button("Save") {
            success := save_entities(game.entities, "entities.txt");
            assert(success, "Failed to save entities to a file.\n");
        }

        ImGui.BeginListBox("### Entities");
        {
            for entity, index : game.entities {
                if ImGui.Button(temp_c_string(tprint("%", entity.name))) {
                    editor_state.entity_index = index;
                }
            }
        }
        ImGui.EndListBox();

        ImGui.Text("Make");
        if ImGui.Button("Guy") then array_add(*game.entities, make_entity(.GUY));
        if ImGui.Button("PS") then array_add(*game.entities, make_entity(.PARTICLE_SYSTEM));

        if editor_state.entity_index != -1 {
            entity := game.entities[editor_state.entity_index];

            determine_entity_kind_and_inspect(entity);
        }
    }
    ImGui.End();
}

editor :: (game: *Game) {
    ImGui.Begin("Editor");
    {
        ImGui.Text("% FPS", program_state.framerate);

        ImGui.Checkbox("Draw Demo", *program_state.draw_demo);

        ImGui.SliderInt("Score", xx *game.score, 0, 99);
    }
    ImGui.End();
}

////////////////////////////////////////////////////////////////////////////////
// Inspector Functions
////////////////////////////////////////////////////////////////////////////////


determine_entity_kind_and_inspect :: (entity: *Entity) {
    ImGui.Begin("Entity");

    if #complete entity.kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!");
        case .GUY;              inspect(temp_c_string(entity.name), cast(*Guy)entity, type_info(Guy));
        case .PARTICLE_SYSTEM;  inspect(temp_c_string(entity.name), cast(*Particle_System)entity, type_info(Particle_System));
    }
    ImGui.End();
}


inspect :: (name: *u8, data: *void, info: *Type_Info) {
    default_size: ImGui.ImVec2;

    using Type_Info_Tag;
    if #complete info.type == {
        case INTEGER;
            info_int := cast(*Type_Info_Integer) info;
            ImGui.InputInt(name, data); // @@ Add support for unsigned, and larger int types.
        case FLOAT;
            if info.runtime_size == {
                case 4;
                    //ImGui.DragFloat(name, data, display_format="%.3f");
                    ImGui.InputFloat(name, data, 0.01, 1.0);
                case 8;
                    x : float = xx <<cast(*float64) data;
                    if ImGui.InputFloat(name, *x, 0.01, 1.0) { <<cast(*float64) data = x; };
            }
        case BOOL;
            //ImGui.Checkbox(name, data);
            index : s32 = xx <<cast(*bool)data;
            if ImGui.Combo(name, *index, "false\0true\0\0") { <<cast(*bool)data = xx index; };
        case STRING;
            s := << cast(*string) data;  // For now we assume non-relative strings only.
            if s.count ImGui.InputText(name, s.data, xx s.count, ImGui.InputTextFlags.ReadOnly);    // @@ We could allow editing of strings too.
            else ImGui.InputText(name, "(null)", 6, ImGui.InputTextFlags.ReadOnly);

        case POINTER;
            // @@ Open in new window?
            ImGui.Text("pointer");
        case PROCEDURE;
            ImGui.Text("procedure");
        case VOID;
            ImGui.Text("void");
        case CODE;
            ImGui.Text("Code");
        case STRUCT;
            info_struct := cast(*Type_Info_Struct) info;
            if ImGui.TreeNode(name, "%: %", to_string(name), info_struct.name) {
                for member: info_struct.members {
                    inspect(temp_c_string(member.name), data + member.offset_in_bytes, member.type);
                }
                ImGui.TreePop();
            }
        case ARRAY;
            info_array := cast(*Type_Info_Array) info;
            array_count, array_data := Reflection.get_array_count_and_data(data, info_array);
            array_name := to_string(name);
            element_size := info_array.element_type.runtime_size;
            if ImGui.TreeNode(name, "% (count = %)", array_name, array_count) {
                for 0..array_count-1 {
                    item_name := temp_c_string(tprint("%[%]", array_name, it));
                    inspect(item_name, array_data + it * element_size, info_array.element_type);
                }
                ImGui.TreePop();
            }
        case ANY;
            // @@ Display type and inspect value.
            ImGui.Text("Any!");
        case ENUM;
            info_enum := cast(*Type_Info_Enum) info;

            if info_enum.enum_type_flags & .FLAGS {
                // @@ How to handle flags?
            }
            else {
                value := Reflection.get_enum_value(data, info_enum);
                value_name := "";
                for info_enum.names {
                    if value == info_enum.values[it_index]  value_name = it;
                }

                if ImGui.BeginCombo(name, temp_c_string(value_name)) {
                    for info_enum.names {
                        is_selected := value == info_enum.values[it_index];
                        if ImGui.Selectable(temp_c_string(it), is_selected, size=*default_size) {
                            Reflection.set_enum_value(data, info_enum, info_enum.values[it_index]);
                        }
                        if is_selected ImGui.SetItemDefaultFocus();
                    }

                    ImGui.EndCombo();
                }
            }


        case POLYMORPHIC_VARIABLE;
            // @@ ??
        case TYPE;
            // @@
        case OVERLOAD_SET;
            // @@
        case VARIANT;
        // @Incomplete: Can do something better here.
            tiv := cast(*Type_Info_Variant) info;
            inspect(name, data, tiv.variant_of);
    }

}
