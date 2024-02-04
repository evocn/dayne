// Dayne
// Editor
// Alex Hartford
// February 2024

update_and_draw_editor :: () {
    io := ImGui.GetIO();
    program_state.imgui_capturing_mouse     = io.WantCaptureMouse;
    program_state.imgui_capturing_keyboard  = io.WantCaptureKeyboard;
    program_state.framerate                 = io.Framerate;

    ImGui_ImplSdl_NewFrame(window);
    ImGui.NewFrame();
    {
        editor();

        ImGui.ShowDemoWindow();
    }
    ImGui.Render();
}

////////////////////////////////////////////////////////////////////////////////
// Individual Editors
////////////////////////////////////////////////////////////////////////////////

editor :: () {
    ImGui.Begin("Editor");
    {

    }
    ImGui.End();
}
