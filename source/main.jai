// Dayne
// Main
// September 2024

main :: () {
    random_seed(cast,force(u64)current_time_monotonic().low);

    initialize_everything();

    gamepad: SDL_Joystick;

    main_menu := menu_initialize();

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *game.arena;
    initialize(*game,, allocator=a);

    // Music
    {
        song := "26";
        play_music(song);
    }

    dt, last_frame := 0.0;
    tracker : Fps_Tracker;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
            rainbow_color = update_rainbow_color(dt);

            update(*debugging_stuff);

            new_context := context;
            push_context new_context {
                format_float := *context.print_style.default_format_float;
                format_float.trailing_width = 2;
                format_float.zero_removal   = .NO;

                debug_print(tprint("dt: ~% ms (% fps)", 1000.0 * get_average(tracker), 1.0 / get_average(tracker)), pink);
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        {
            gather_input(*input_one, *gamepad);

            defer {
                post_frame_update(*input_one);
            }

            // Dispatch Inputs based on program state
            if #complete program_state.current_scene == {
                case .TITLE;
                    if input_one.start.just_pressed {
                        switch_scene(.MENU);
                    }

                    if input_one.a.just_pressed {
                        switch_scene(.GAME);
                    }

                case .MENU;
                    apply_inputs(input_one, *main_menu);

                case .EDITOR;
                    apply_inputs(input_one, *editor);

                case .GAME;
                    if input_one.start.just_pressed {
                        switch_scene(.MENU);
                    }

                    apply_inputs(input_one, *game);

                case .DEMO;
                    if input_one.a.just_pressed || input_one.b.just_pressed {
                        return_to_prior_scene();
                    }
            }

            {
                debug_print(tprint("Scene: %", program_state.current_scene));

                debug_print(
                    tprint("Pixels: %x%, Window: %x%, Viewport: %x%", 
                        PIXEL_WIDTH, PIXEL_HEIGHT,
                        graphics_context.window_width, graphics_context.window_height,
                        graphics_context.viewport_width, graphics_context.viewport_height
                    ),
                    color = teal
                );

                if graphics_context.fullscreen {
                    debug_print("Fullscreen", color = teal);
                }
                else {
                    debug_print(
                        tprint("Pixel Scale: %", graphics_context.scale_factor),
                        color = teal
                    );
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Simulate
        {
            if #complete program_state.current_scene == {
                case .TITLE;

                case .GAME;
                    if simulation_state.frozen {
                        debug_print("Frozen", red);

                        if simulation_state.step {
                            simulation_state.step = false;
                            simulate(*game, dt);
                        }
                    }
                    else {
                        simulate(*game, dt);
                    }

                case .MENU;
                case .EDITOR;

                case .DEMO;
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Render
        render(
            game,
            main_menu,
        );

        #if !RELEASE_BUILD {
            if program_state.current_scene == .EDITOR {
                update_and_draw_editor(*game);
                ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
            }
        }

        SDL_GL_SwapWindow(window);
        SDL_Delay(1);

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {
            Sound_Player.update();

            // Let it ride!
            {
                current_time := cast(float32)seconds_since_init();
                dt = current_time - last_frame;
                last_frame = current_time;
            }

            /*
            // Fixed Timestep
            {
                current_time := cast(float32)seconds_since_init();
                dt = current_time - last_frame;

                if dt < fixed_timestep {
                    SDL_Delay(xx (1000 * (fixed_timestep - dt)));
                    dt = fixed_timestep;
                }
                else {
                    print("Missed the timestep by % s.\n", dt - fixed_timestep);
                }

                last_frame = current_time;
            }
            */

            add_sample(*tracker, dt);

            reset_temporary_storage();
        }
    }

    cleanup_for_shutdown(*game, *main_menu);

    #if !RELEASE_BUILD then report_memory_leaks();
}


// Imports /////////////////////////////////////////////////////////////////////
using Basic_Module :: #import "Basic"()(MEMORY_DEBUGGER=true);
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
#import "stb_image_write";
#import "freetype-2.12.1";
ImGui :: #import "ImGui";
using Sound_Player :: #import "Sound_Player";


////////////////////////////////////////////////////////////////////////////////

#load "initialize.jai";
#load "state.jai";
#load "render.jai";
#load "debug.jai";

// Core
#load "core/input.jai";
#load "core/tweaks.jai";
#load "core/utils.jai";

// Subsystems
#load "game/game.jai";
#load "graphics/graphics.jai";
#load "animation/animation.jai";
#load "audio.jai";
#load "editor/editor.jai";

#load "ui/menu.jai";

// Asset Paths
////////////////////////////////////////////////////////////////////////////////
sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/music";
sfx_path        :: "assets/sfx";
shaders_path    :: "assets/shaders";

tweaks_path     :: "bin";
screenshots_path:: "screenshots";
