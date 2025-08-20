
// Main
////////////////////////////////////////////////////////////////////////////////

main :: () {
    random_seed(cast,force(u64)current_time_monotonic().low);

    initialize_everything();

    gamepad: SDL_Joystick;

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

    dt, frame_start, frame_end : float;
    while program_state.running {
        zone_begin(.FRAME);

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Startup
        {
            frame_start = cast(float32)seconds_since_init();

            rainbow_color = update_rainbow_color(dt);

            #if DEVELOPER_TOOLS {
                update(*debug_messages);

                add_sample(*tracker, dt);
            }
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Input
        {
            zone(.INPUT);

            gather_input(*input_one, *gamepad);
            //gather_input(*input_two, *gamepad);

            defer {
                post_frame_update(*input_one);
                //post_frame_update(*input_two);
            }


            #if DEVELOPER_TOOLS {
                if editor.active {
                    apply_inputs(input_one, *editor);
                }
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

                case .DEMO;
                    if input_one.a.just_pressed || input_one.b.just_pressed {
                        return_to_prior_scene();
                    }
            }

            {
                debug_print(tprint("Scene: %", program_state.current_scene));

                debug_print(
                    tprint("P: %x%, W: %x%, V: %x%",
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
            zone(.GAME);

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

                case .DEMO;
            }

            Sound_Player.update(dt);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Graphics
        {
            zone(.DRAW);

            render(
                game,
                main_menu,
            );

            #if DEVELOPER_TOOLS {
                if editor.active {
                    update_and_draw_editor(*game);
                    ImGui_ImplSdl_RenderDrawLists(ImGui.GetDrawData());
                }
            }

            SDL_GL_SwapWindow(window);
        }

        ////////////////////////////////////////////////////////////////////////////////
        // Frame Cleanup
        {
            zone(.IDLE);

            reset_temporary_storage();

            // Frame timing
            {
                frame_end = cast(float32)seconds_since_init();
                dt = frame_end - frame_start;

                // Fixed Framerate
                {
                    if dt < LOCKED_DT {
                        idle_time := LOCKED_DT - dt;
                        dt = LOCKED_DT;
                        SDL_Delay(xx (1000 * idle_time)); // function takes time in ms.
                    }
                }
            }
        }

        zone_end(.FRAME);

        last_frame_report = profiler_flush(dt);
    }

    cleanup_for_shutdown(*game, *main_menu);

    // Uncomment this for memory debugging
    /*
    #if DEVELOPER_TOOLS {
        report_memory_leaks();
        defer while true { SDL_Delay(100000); }
    }
    */
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
ImGui :: #import "ImGui";
#import "stb_image_write"; // For Screenshots
}

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
#load "audio/audio.jai";
#load "animation/animation.jai";
#load "collision/collision.jai";
#load "menu/menu.jai";

// Tools
#load "tools/profiler.jai";
#if DEVELOPER_TOOLS {
#load "tools/editor/editor.jai";
#load "tools/debug.jai";
#load "tools/tweaks.jai";
#load "tools/screenshot.jai";
}

// Asset Paths
////////////////////////////////////////////////////////////////////////////////
sprites_path    :: "assets/sprites";
fonts_path      :: "assets/fonts";
music_path      :: "assets/music";
sfx_path        :: "assets/sfx";
shaders_path    :: "assets/shaders";

profiles_path   :: "bin/profiles";
#if DEVELOPER_TOOLS {
tweaks_path     :: "bin";
screenshots_path:: "bin/screenshots";
}
