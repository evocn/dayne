// Dayne
// Editor
// February 2024

#load "imgui-sdl-gl.jai";

Editor :: struct {
}

apply_inputs :: (using input: Input, editor : *Editor) {
}

update_and_draw_editor :: (game: *Game) {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse     = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard  = io.WantCaptureKeyboard;
    program_state.framerate                 = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor_functions();

        game_editor(game);

        ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}



// Individual Editor Features
////////////////////////////////////////////////////////////////////////////////

editor_functions :: () {
    ImGui.Begin("Editor");
    {
        ImGui.Checkbox("Debug Info", xx *program_state.show_debug_info);
    }
    ImGui.End();
}

game_editor :: (using game: *Game) {
    ImGui.Begin("Game");
    {
    }
    ImGui.End();
}
