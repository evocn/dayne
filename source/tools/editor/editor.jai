// Dayne
// Editor
// February 2024

Editor :: struct {
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

        //ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}



// Individual Editor Features
////////////////////////////////////////////////////////////////////////////////

editor_functions :: () {
    ImGui.Begin("Editor");
    {
        ImGui.Checkbox("Debug Info (F8)", xx *program_state.show_debug_info);
    }
    ImGui.End();
}

game_editor :: (using game: *Game) {
    ImGui.Begin("Game");
    {
    }
    ImGui.End();
}


#load "imgui-sdl-gl.jai";
