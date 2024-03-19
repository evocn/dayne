// Dayne
// Editor
// Alex Hartford
// February 2024

#load "imgui_init.jai";

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

        if ImGui.Button("Load") {
            success := load_entities(*game.entities, "entities.txt");
            assert(success, "Failed to load entities from a file.\n");
        }
        ImGui.SameLine();
        if ImGui.Button("Save") {
            success := save_entities(game.entities, "entities.txt");
            assert(success, "Failed to save entities to a file.\n");
        }

        ImGui.Checkbox("Draw Demo", *program_state.draw_demo);

        ImGui.SliderInt("Score", xx *game.score, 0, 99);
    }
    ImGui.End();
}
