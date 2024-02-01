// Dayne
// Main
// Alex Hartford
// February 2024

////////////////////////////////////////////////////////////////////////////////

DEBUG_MEMORY :: true;

//WINDOW_WIDTH  :: 3840;
//WINDOW_HEIGHT :: 2160;
WINDOW_WIDTH  :: 2400;
WINDOW_HEIGHT :: 1600;

PIXEL_WIDTH :: 400;
PIXEL_HEIGHT :: 300;

////////////////////////////////////////////////////////////////////////////////

main :: () {
    initialize_everything();

    input: User_Input;
    gamepad: SDL_Joystick;
    player_interface: Player_Interface;

    menu := menu_initialize();

    play_music("bach");









    dt, last_frame := 0.0;
    while running {
        {
            // Frame Startup
        }

        handle_input(*input, *gamepad);
        defer post_frame_update(*input);

        simulate(
            player_interface, input, 
            *menu,
            dt
        );

        render(menu);

        if program_state.current_scene == .EDITOR {
            update_and_draw_editor();
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);

        {
            // Frame Cleanup

            current_time := cast(float32)seconds_since_init();
            dt = current_time - last_frame;
            last_frame = current_time;

            reset_temporary_storage();
        }
    }

    cleanup_for_shutdown(*menu);

    #if DEBUG_MEMORY then report_memory_leaks();
}


////////////////////////////////////////////////////////////////////////////////
// Global Variables
////////////////////////////////////////////////////////////////////////////////

// Loose Globals
window_width  : s32 = WINDOW_WIDTH;
window_height : s32 = WINDOW_HEIGHT;

fullscreen: bool;
running := true;


// Global Systems
scratch_memory  : Flat_Pool;

window          : *SDL_Window;
gl_context      : *SDL_GLContext;
imgui_context   : *ImGui.ImGuiContext;

program_state   : Program_State;

audio_context   : Audio_Context;
render_context  : Render_Context;

////////////////////////////////////////////////////////////////////////////////
// File Paths
////////////////////////////////////////////////////////////////////////////////

assets_path     :: "assets";
fonts_path      :: "assets/fonts";
music_path      :: "assets/audio/music";
ambience_path   :: "assets/audio/ambiences";
sfx_path        :: "assets/audio/sfx";

boards_path     :: "boards";
tweaks_path     :: ".";


////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

// Standard Library files
using Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
#import "Flat_Pool";
#import "String";
#import "Math";
#import "Hash_Table";
#import "File";
#import "Text_File_Handler";
File_Utilities :: #import "File_Utilities"; // For file_list()
System         :: #import "System";         // For get_path_of_running_executable()


// Third Party Dependencies
#import "stb_image";
#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "freetype-2.12.1";
#import "miniaudio";

////////////////////////////////////////////////////////////////////////////////
// Loads
////////////////////////////////////////////////////////////////////////////////

// Core
#load "types.jai";
#load "state.jai";
#load "initialize.jai";
#load "input.jai";
#load "simulate.jai";
#load "render.jai";


// Subsystems
#load "text.jai";
#load "audio.jai";
#load "menu.jai";
#load "editor.jai";
#load "imgui_init.jai";
#load "tweaks.jai";


// Rendering
#load "opengl_rendering.jai";
#load "shader.jai";
#load "texture.jai";
#load "sprite.jai";
#load "spritesheet.jai";
#load "color.jai";
