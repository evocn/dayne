
// Editor
////////////////////////////////////////////////////////////////////////////////

Editor :: struct {
    active : bool;

    imgui_state : struct {
        imgui_context : *ImGui.ImGuiContext;
        capturing_mouse    := false;
        capturing_keyboard := false;
    }
}

apply_inputs :: (using input: Input, editor : *Editor) {
}

update_and_draw_editor :: (game: *Game) {
    using program_state.editor;

    io := ImGui.GetIO();
    imgui_state.capturing_mouse     = io.WantCaptureMouse;
    imgui_state.capturing_keyboard  = io.WantCaptureKeyboard;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor_functions();

        game_editor(game);

        ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}

activate :: (using editor: *Editor) {
    active = true;
    SDL_ShowCursor(1);
}

deactivate :: (using editor: *Editor) {
    active = false;
    SDL_ShowCursor(0);
}

// Individual Editor Features
////////////////////////////////////////////////////////////////////////////////

editor_functions :: () {
    ImGui.Begin("Functions");
    {
        ImGui.Text("Modes:");
        if ImGui.RadioButton("Title (F1)", program_state.current_mode == .TITLE) {
            switch_mode(.TITLE);
        }
        if ImGui.RadioButton("Game (F2)", program_state.current_mode == .GAME) {
            switch_mode(.GAME);
        }
        if ImGui.RadioButton("Menu (F3)", program_state.current_mode == .MENU) {
            switch_mode(.MENU);
        }
        if ImGui.RadioButton("Demo (F4)", program_state.current_mode == .DEMO) {
            switch_mode(.DEMO);
        }

        ImGui.Checkbox("Debug Info (F8)", xx *program_state.show_debug_info);

        ImGui.NewLine();
        ImGui.Text("Simulation state:");
        ImGui.Text("Freeze (F9)");
        ImGui.Text("Step (F10)");

        ImGui.NewLine();
        if ImGui.Button("Screenshot (F11)") {
            program_state.want_screenshot = true;
        }
        if ImGui.Button("Close Editor (F7)") {
            deactivate(*program_state.editor);
        }
    }
    ImGui.End();
}

game_editor :: (using game: *Game) {
    ImGui.Begin("Game");
    {
        ImGui.Text("Entities: %", entities.count);
    }
    ImGui.End();
}


#load "imgui_sdl_gl.jai";
