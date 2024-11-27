// Dayne
// Main
// September 2024

main :: () {
    random_seed(xx current_time_monotonic());

    initialize_everything();

    gamepad: SDL_Joystick;

    main_menu := menu_initialize();

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *game.arena;
    initialize(*game,, allocator=a);

    song := "bach";
    play_music(song);

    dt, last_frame := 0.0;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
            rainbow_color = update_rainbow_color(dt);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        {
            gather_input(*input, *gamepad);

            defer {
                post_frame_update(*input);
            }

            // Dispatch Inputs based on program state
            if #complete program_state.current_scene == {
                case .TITLE;
                    if input.south.just_pressed {
                        switch_scene(.GAME);
                    }

                case .MENU;
                    apply_inputs(input, *main_menu);

                case .EDITOR;
                    apply_inputs(input, *editor);

                case .GAME;
                    if input.start.just_pressed {
                        switch_scene(.MENU);
                    }

                    apply_inputs(input, *game);
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            if #complete program_state.current_scene == {
                case .TITLE;
                case .MENU;
                case .EDITOR;
                case .GAME;
                    if simulation_state.paused {
                        if simulation_state.step {
                            simulation_state.step = false;
                            simulate(*game, dt);
                        }
                    }
                    else {
                        simulate(*game, dt);
                    }
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Render
        render(
            game,
            main_menu,
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
            Sound.update();

            current_time := cast(float32)seconds_since_init();
            dt = current_time - last_frame;
            last_frame = current_time;

            reset_temporary_storage();
        }
    }

    cleanup_for_shutdown(*game, *main_menu);

    #if DEBUG_MEMORY then report_memory_leaks();
}



// Imports /////////////////////////////////////////////////////////////////////
using Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
#import "String";
#import "Math";
#import "Sort";
#import "Random";
#import "Flat_Pool";
#import "Hash_Table";
#import "File";
#import "File_Utilities";
#import "System";
#import "Text_File_Handler";
#import "SDL";
#import "GL";
#import "stb_image";
#import "freetype-2.12.1";
ImGui :: #import "ImGui";
using Sound :: #import "Sound_Player";


////////////////////////////////////////////////////////////////////////////////

#load "initialize.jai";
#load "state.jai";
#load "render.jai";

// Core
#load "core/input.jai";
#load "core/menu.jai";
#load "core/tweaks.jai";
#load "core/utils.jai";

// Subsystems
#load "game/game.jai";
#load "graphics/graphics.jai";
#load "animation/animation.jai";
#load "audio.jai";
#load "editor/editor.jai";



// Asset Paths
////////////////////////////////////////////////////////////////////////////////
sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/music";
sfx_path        :: "assets/sfx";
shaders_path    :: "assets/shaders";

tweaks_path     :: "bin";
