// Dayne
// Editor
// February 2024

#load "imgui-sdl-gl.jai";

Editor :: struct {
}

apply_input :: (using editor : *Editor, input: Input) {
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
        ImGui.RadioButton("Normal", xx *program_state.mode, 0);
        ImGui.SameLine();
        ImGui.RadioButton("Debug",  xx *program_state.mode, 1);
    }
    ImGui.End();
}

game_editor :: (using game: *Game) {
    ImGui.Begin("Game");
    {
    }
    ImGui.End();
}
