// Dayne
// Main
// Alex Hartford
// February 2024

DEBUG_MEMORY :: true;

program_state   : Program_State;

audio_context   : Audio_Context;
render_context  : Render_Context;

scratch_memory  : Flat_Pool;
entity_pool     : Flat_Pool; // @TODO: Put this in a better location!

main_menu       : Menu;

//the_animator : Animator;

PIXEL_WIDTH     :: 2400;
PIXEL_HEIGHT    :: 1600;

DEFAULT_WINDOW_SCALE_FACTOR :: 1;
DEFAULT_WINDOW_WIDTH    :: PIXEL_WIDTH  * DEFAULT_WINDOW_SCALE_FACTOR;
DEFAULT_WINDOW_HEIGHT   :: PIXEL_HEIGHT * DEFAULT_WINDOW_SCALE_FACTOR;

GAME_ASPECT_RATIO : float : cast(float)PIXEL_WIDTH / PIXEL_HEIGHT;

Render_Context :: struct {
    window_width  : s32 = DEFAULT_WINDOW_WIDTH;
    window_height : s32 = DEFAULT_WINDOW_HEIGHT;
    window_scale_factor : s32 = DEFAULT_WINDOW_SCALE_FACTOR;

    viewport_width : s32 = cast(s32)(DEFAULT_WINDOW_HEIGHT * GAME_ASPECT_RATIO);
    viewport_height: s32 = DEFAULT_WINDOW_HEIGHT;

    fullscreen: bool;

    using opengl_context : OpenGL_Context;
}

////////////////////////////////////////////////////////////////////////////////

text_path       :: "text";

sprites_path    :: "assets/art/sprites";
spritesheets_path :: "assets/art/spritesheets";

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

    play_music("cavetine");

    game : Game;
    array_add(*game.spine.vignettes, 
        .{
            song = "concerto",
        }
    );
    array_add(*game.spine.vignettes, 
        .{
            song = "fugue",
        }
    );
    array_add(*game.spine.vignettes, 
        .{
            song = "cavetine",
        }
    );
    array_add(*game.spine.vignettes, 
        .{
            song = "rhapsody",
        }
    );

    {
        success := load_entities(*game.entities, "entities.txt");
        assert(success, "Failed to load entities from a file.\n");
    }

    /*
    the_animator = make_animator(
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

    {
        page_name := "0";
        success := read_page(page_name, *game.page);
        assert(success, "Failed to read the page %.\n", page_name);


    }


    dt, last_frame := 0.0;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        gather_input(*game.player.input, *game.player.gamepad);

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            // Dispatch based on program state
            if #complete program_state.current_scene == {
                case .TITLE;
                    apply_input_to_title(game.player.input);

                case .GAME;
                    apply_player_inputs_to_game(*game);
                    simulate_game(*game, dt);

                case .MENU;
                    apply_input_to_menu(*main_menu, game.player.input);

                case .EDITOR;
                    apply_input_to_editor(game.player.input);

                case .END;
                    apply_input_to_end(game.player.input);
            }
        }

        // Frame Update
        {
            //update(*the_animator, dt);

            rainbow = update_rainbow_color(dt);
            flashing_red = update_flashing_red_color(dt);
        }

        if !program_state.running {
            print("%\n", program_state.current_scene);
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
            post_frame_update(*game.player.input);

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
#load "draw_text.jai";
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

// Game Code
#load "vignette.jai";
#load "text.jai";
