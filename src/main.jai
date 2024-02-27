// Dayne
// Main
// Alex Hartford
// February 2024

VERSION :: 0;
DEBUG_MEMORY :: true;

window          : *SDL_Window;
gl_context      : *SDL_GLContext;
imgui_context   : *ImGui.ImGuiContext;

program_state   : Program_State;

audio_context   : Audio_Context;
render_context  : Render_Context;


// Loose Globals
scratch_memory  : Flat_Pool;

main_menu       : Menu;

////////////////////////////////////////////////////////////////////////////////

sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/audio/music";
sfx_path        :: "assets/audio/sfx";

shaders_path    :: "shaders";

boards_path     :: "boards";
tweaks_path     :: ".";

////////////////////////////////////////////////////////////////////////////////

main :: () {
    initialize_everything();

    gamepad: SDL_Joystick;

    main_menu = menu_initialize();

    play_music("bach");

    game : Game;
    _ := array_add(*game.players);


    game.entity = .{
        sprite = 1,
        color  = pink,

        position = .{0, 0},
    };







    dt, last_frame := 0.0;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        gather_input(*game.players[0].input, *gamepad);
        defer {
            post_frame_update(*game.players[0].input);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            // Dispatch based on program state
            if #complete program_state.current_scene == {
                case .GAME;
                    simulate(*game, dt);

                case .MENU;
                    simulate_menu(*main_menu, *game.players[0].input);

                case .EDITOR;
                    simulate_editor(*game.players[0].input);
            }
        }

        // Update stuff
        {
            rainbow_color = update_rainbow_color(dt);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Render
        render(
            game
        );

        if program_state.current_scene == .EDITOR {
            update_and_draw_editor(*game);
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {

            current_time := cast(float32)seconds_since_init();
            dt = current_time - last_frame;
            last_frame = current_time;

            reset_temporary_storage();
        }
    }

    cleanup_for_shutdown(*main_menu);

    #if DEBUG_MEMORY then report_memory_leaks();
}


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
#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype-2.12.1";
#import "miniaudio";


////////////////////////////////////////////////////////////////////////////////
// Loads
////////////////////////////////////////////////////////////////////////////////

// Core
#load "types.jai";
#load "window.jai";
#load "initialize.jai";

#load "input.jai";
#load "simulate.jai";
#load "render.jai";

#load "state.jai";

#load "game.jai";
#load "player.jai";
#load "entity.jai";

// Subsystems
#load "text.jai";
#load "audio.jai";
#load "menu.jai";
#load "editor.jai";
#load "imgui_init.jai";
#load "tweaks.jai";


// Rendering
#load "opengl_rendering.jai";
#load "opengl_shader.jai";
#load "opengl_texture.jai";
#load "sprite.jai";
#load "color.jai";
