// Dayne
// Main
// September 2024

main :: () {
    random_seed(cast,force(u64)current_time_monotonic().low);

    initialize_everything();

    gamepad: SDL_Joystick;
    mouse: Mouse;

    main_menu := menu_initialize();

    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *game.arena;
    initialize(*game,, allocator=a);

    // Play the starting music!
    {
        song := "secret";
        play_music(song);
    }

    dt, last_frame := 0.0;
    while program_state.running {
        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
            rainbow_color = update_rainbow_color(dt);

            #if DEVELOPER_TOOLS {
                update(*debugging_stuff);

                new_context := context;
                push_context new_context {
                    format_float := *context.print_style.default_format_float;
                    format_float.trailing_width = 2;
                    format_float.zero_removal   = .NO;

                    debug_print(tprint("dt: ~% ms (% fps)", 1000.0 * get_average(tracker), 1.0 / get_average(tracker)), pink);
                }
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        {
            /*
            Iprof.zone_begin(1);
            defer Iprof.zone_end();
            */

            gather_input(*input_one, *mouse, *gamepad);
            //gather_input(*input_two, *mouse, *gamepad);

            defer {
                post_frame_update(*input_one);
                //post_frame_update(*input_two);
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

                case .GAME;
                    if input_one.start.just_pressed {
                        switch_scene(.MENU);
                    }

                    apply_inputs(input_one, *game);

                case .EDITOR;
                    #if DEVELOPER_TOOLS {
                        apply_inputs(input_one, *editor);
                    }

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
            /*
            Iprof.zone_begin(2);
            defer Iprof.zone_end();
            */

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

            Sound_Player.update(dt);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Render
        {
            /*
            Iprof.zone_begin(3);
            defer Iprof.zone_end();
            */

            render(
                game,
                main_menu,
            );

            #if DEVELOPER_TOOLS {
                if program_state.current_scene == .EDITOR {
                    update_and_draw_editor(*game);
                    ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
                }
            }

            SDL_GL_SwapWindow(window);
            SDL_Delay(1);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {
            current_time := cast(float32)seconds_since_init();
            dt = current_time - last_frame;
            last_frame = current_time;

            #if DEVELOPER_TOOLS {
                add_sample(*tracker, dt);

                //Iprof.update(record_data = true);
            }

            reset_temporary_storage();
        }
    }

    /*
    #if DEVELOPER_TOOLS {
        Iprof.update(record_data = true);

        // Create profiling report
        report := Iprof.create_report();

        log("Profiling report incoming.");
        Iprof.log_text_report(report);

        /*
        {
            // Save csv report
            directory_now_exists := make_directory_if_it_does_not_exist(profiles_path, recursive = true);
            if !directory_now_exists then log_error("Unable to create directory at %", profiles_path);
            filename := tprint("%/profile_%.csv", profiles_path, timestamp());

            log("Saving the profiling report at %", filename);
            Iprof.save_csv_report(report, filename);
        }
        */
    }
    */

    cleanup_for_shutdown(*game, *main_menu);


    #if DEVELOPER_TOOLS then report_memory_leaks();

    // For postmortem console outputs
    #if DEVELOPER_TOOLS then while true { SDL_Delay(100000); }
}


// Imports /////////////////////////////////////////////////////////////////////
using Basic_Module :: #import "Basic"()(MEMORY_DEBUGGER=true);
#import "String";
#import "Math";
#import "Sort";
#import "Random";
#import "Hash_Table";
#import "Flat_Pool";

#import "System";
#import "File";
#import "File_Utilities";
#import "Text_File_Handler";

#import "SDL";
#import "GL";
#import "stb_image";
#import "freetype-2.12.1";
using Sound_Player :: #import "Sound_Player";

#if DEVELOPER_TOOLS {
#import "stb_image_write";
ImGui :: #import "ImGui";
}

// We'd like to put this under the DEVELOPER_TOOLS thing above, but...
// its module parameter adds to the context, which has to happen first...
// Whatever.
//Iprof :: #import "Iprof"(IMPORT_MODE = .CLIENT, MANUAL_MODE = true);

////////////////////////////////////////////////////////////////////////////////

// Core
#load "state.jai";
#load "initialize.jai";
#load "utils.jai";

#load "input.jai";
#load "render.jai";

// Subsystems
#load "game/game.jai";
#load "graphics/graphics.jai";
#load "audio.jai";
#load "animation/animation.jai";
#load "collision/collision.jai";
#load "ui/ui.jai";

#if DEVELOPER_TOOLS {
#load "tools/editor/editor.jai";
#load "tools/debug.jai";
#load "tools/tweaks.jai";
}

// Asset Paths
////////////////////////////////////////////////////////////////////////////////
sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/music";
sfx_path        :: "assets/sfx";
shaders_path    :: "assets/shaders";

#if DEVELOPER_TOOLS {
tweaks_path     :: "bin";
screenshots_path:: "screenshots";
profiles_path   :: "profiles";
}
