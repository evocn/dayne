// Dayne
// Editor
// Alex Hartford
// February 2024

update_and_draw_editor :: (game: *Game) {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse     = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard  = io.WantCaptureKeyboard;
    program_state.framerate                 = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor(game);

        ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}

////////////////////////////////////////////////////////////////////////////////
// Individual Editors
////////////////////////////////////////////////////////////////////////////////

editor :: (game: *Game) {
    ImGui.Begin("Editor");
    {
        ImGui.Text("% FPS", program_state.framerate);

        ImGui.Checkbox("Draw Demo", *program_state.draw_demo);

        ImGui.SliderInt("Score", xx *game.score, 0, 99);
    }
    ImGui.End();
}
