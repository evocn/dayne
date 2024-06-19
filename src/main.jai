// Dayne
// Main
// Alex Hartford
// February 2024

DEBUG_MEMORY :: true;

program_state   : Program_State;

audio_context   :  Audio_Context;
render_context  : Render_Context;

scratch_memory  : Flat_Pool;

main_menu       : Menu;

////////////////////////////////////////////////////////////////////////////////

sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/audio/music";
sfx_path        :: "assets/audio/sfx";

shaders_path    :: "shaders";

data_path       :: "data";
tweaks_path     :: "bin";

////////////////////////////////////////////////////////////////////////////////

main :: () {
    initialize_everything();

    main_menu = menu_initialize();

    play_music("bach");

    game : Game;

    // Make the Game.
    {
        array_add(*game.players, .{});

        {
            entity_allocator: Allocator;
            entity_allocator.proc = flat_pool_allocator_proc;
            entity_allocator.data = *game.entity_pool;

            success := load_entities(*game.entities, "entities.txt",, entity_allocator);
            assert(success, "Failed to load entities from a file.\n");
        }

        /*
        game.the_animator = make_animator(
            key_frames = ...[
                .{
                    time  = 0.0,
                    value = 5,
                },
                .{
                    time  = 0.5,
                    value = 10,
                }
            ],
        );
        */
    }



    dt, last_frame := 0.0;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        for * player : game.players {
            gather_input(*player.input, *player.gamepad);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            // Dispatch based on program state
            if #complete program_state.current_scene == {
                case .TITLE;
                    apply_input_to_title(game.players[0].input);

                case .GAME;
                    apply_player_inputs_to_game(*game);
                    simulate_game(*game, dt);

                case .MENU;
                    apply_input_to_menu(*main_menu, game.players[0].input);

                case .EDITOR;
                    apply_input_to_editor(game.players[0].input);
            }
        }

        // Frame Update
        {
            rainbow = update_rainbow_color(dt);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Render
        render(game);

        if program_state.current_scene == .EDITOR {
            update_and_draw_editor(*game);
            ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
        }

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {
            for * player : game.players {
                post_frame_update(*player.input);
            }

            reset_temporary_storage();

            current_time := cast(float32)seconds_since_init();
            dt = current_time - last_frame;
            last_frame = current_time;
        }
    }

    // Memory Debugging code
    cleanup_for_shutdown(*game);
    #if DEBUG_MEMORY then report_memory_leaks();
}

////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////

using Basic :: #import "Basic"()(MEMORY_DEBUGGER=DEBUG_MEMORY);
#import "Flat_Pool";
#import "String";
#import "Math";
#import "File";
#import "Random";
#import "Hash_Table";
#import "Text_File_Handler";
File_Utilities :: #import "File_Utilities"; // For file_list()
System         :: #import "System";         // For get_path_of_running_executable()
Reflection :: #import "Reflection";


#import "SDL";
#import "GL";
ImGui :: #import "ImGui";
#import "stb_image";
#import "freetype-2.12.1";
#import "miniaudio";

// Core
#load "util.jai";
#load "initialize.jai";
#load "window.jai";
#load "state.jai";

#load "input.jai";
#load "interface.jai";
#load "game.jai";
#load "render.jai";

// Subsystems
#load "text.jai";
#load "audio.jai";
#load "menu.jai";
#load "editor.jai";
#load "tweaks.jai";


#load "entity.jai";
#load "entity_serialization.jai";
#load "guy.jai";
#load "particle_system.jai";

#load "animator.jai";

// Rendering
#load "opengl_rendering.jai";
#load "opengl_shader.jai";
#load "opengl_texture.jai";

#load "sprite.jai";
#load "color.jai";

// Physics
#load "physics.jai";
#load "physics_collider.jai";
#load "physics_solid.jai";
#load "physics_actor.jai";
