// Dayne
// Build
// Alex Hartford

// This file contains a metaprogram whose objective is to build the target program contained in source/.


// Shared between the build program and the target program.
shared_data :: #string DONE

build_settings : struct {
    configuration : enum {
        DEBUG;
        RELEASE;
    }
}

program_title :: "Dayne";

program_version :: struct {
    major :: 0;
    minor :: 1;
    patch :: 0;
}

DONE
#run add_build_string(shared_data, w = -1);

////////////////////////////////////////////////////////////////////////////////

// For some reason, #filepath has a trailing "/". I do this to work around it.
root := #filepath;
#run root.count -= 1;

build :: () {
    // Create target program workspace
    w := compiler_create_workspace("Final Program");
    if !w {
        log_error("Workspace creation failed.");
        return;
    }
    options := get_build_options(w);


    // Handle command-line arguments / plugins
    arguments := options.compile_time_command_line;
    {
        for argument: arguments {
            if argument == {
                case "release"; {
                    build_settings.configuration = .RELEASE;
                }
            }
        }
    }


    // Build options for the Target Workspace
    {
        options.output_executable_name = program_title;

        options.output_path = "bin";
        options.intermediate_path = "bin/.build";
        options.output_type = .EXECUTABLE;

        // Configure Compiler output printing
        options.text_output_flags = 0;
        //options.text_output_flags |= .OUTPUT_LINK_LINE;
        options.text_output_flags |= .OUTPUT_TIMING_INFO;

        if build_settings.configuration == {
            case .DEBUG;    set_optimization(*options, .DEBUG);
            case .RELEASE;  set_optimization(*options, .VERY_OPTIMIZED);
        }

        set_build_options(options, w);
    }


    // Init plugins
    {
        success, plugins_to_create := parse_plugin_arguments(arguments);

        init_plugins(plugins_to_create, *plugins, w);
    }

    {
        // Interception begins
        intercept_flags: Intercept_Flags;
        for plugins if it.before_intercept it.before_intercept(it, *intercept_flags);

        compiler_begin_intercept(w, intercept_flags);

        // Add files to the Target Workspace
        {
            for plugins if it.add_source it.add_source(it);

            // Files to compile
            {
                add_build_file(tprint("%/source/main.jai", root), w);
            }

            {
                // Add shared data to the target program.
                add_build_string(shared_data, w);

                // Also tell the target program what kind of build this is.
                build_configuration_string : string;
                build_configuration_string = tprint("BUILD_TYPE :: build_settings.configuration.%;", build_settings.configuration);
                add_build_string(build_configuration_string, w);
            }
        }

        message_loop(w);

        compiler_end_intercept(w);

        for plugins if it.finish it.finish(it);
        for plugins if it.shutdown it.shutdown(it);
    }

    // Publishing work
    {
        log("Compilation ended on the target workspace. On to publishing work!");

        executable_path := sprint("%/%.exe", options.output_path, options.output_executable_name);
        defer free(executable_path);

        icon_path :: "publishing/icon.png";

        #if OS == .WINDOWS {
            log("\n---\n");
            create_and_apply_manifest_and_icon_files(executable_path, icon_path);
        }

        if build_settings.configuration == .RELEASE {
            log("\n---\n");
            package_name := tprint("%-%.%.%", program_title, program_version.major, program_version.minor, program_version.patch);
            package(package_name);
        }
    }

    // Build Program (this one) settings.
    {
        // No executable!
        set_build_options_dc(.{
            do_output = false,
            write_added_strings = false
        });
    }
}

#run,stallable build(); // If plugins have assertions, they may stall.

////////////////////////////////////////////////////////////////////////////////

message_loop :: (w: Workspace) {

    // Ctags module setup
    ctags: CTags;
    defer reset(*ctags);
    ctags.output_filename = "tags";
    ctags.base_path = sprint("%", root);
    defer free(ctags.base_path);

    while true {
        message := compiler_wait_for_message();
        if !message continue;

        if message.workspace == w {
            process_message(*ctags, message);

            for plugin : plugins if plugin.message plugin.message(plugin, message);
        }

        if message.kind == .COMPLETE return;
    }
}

////////////////////////////////////////////////////////////////////////////////

#if OS == .WINDOWS {
create_and_apply_manifest_and_icon_files :: (executable_path : string, icon_path : string) {
    #import "Ico_File";
    #import "Windows_Resources";

    log("Creating an icon and manifest file for Windows from the icon at %.", icon_path);

    ico_data := create_ico_file_from_bitmap_filename(icon_path);
    defer free(ico_data);

    ico_path := sprint("%.ico", path_strip_extension(icon_path));
    defer free(ico_path);
    // Save .ico back out for inspection
    {
        write_entire_file(ico_path, ico_data);
    }

    success := set_icon_by_data(executable_path, ico_data);
    log("Icon     added: %\n", success);

    manifest_options: Manifest_Options;
    success = add_manifest_to_executable(executable_path, manifest_options);

    log("Manifest added: %\n", success);
}
}

packages_path :: "bin/packages";

package :: (package_name: string) {
    #import "File_Utilities";

    package_path := tprint("%/%/%", root, packages_path, package_name);

    log("Building a package for % at %.", package_name, package_path);

    // Delete existing package (if one exists)
    preexisting_package := file_exists(package_path);
    if preexisting_package {
        directory_deleted := delete_directory(package_path);
        assert(directory_deleted, "Unable to delete the directory %", package_path);
    }

    // Create a directory for the package
    directory_now_exists := make_directory_if_it_does_not_exist(package_path, recursive=true);
    assert(directory_now_exists, "Unable to create the directory %", package_path);

    // @TODO: If things get too big here, then I'd switch to this abstraction:
    /*
    copy_to_package :: (relative_path: string) -> bool {
    }
    */

    // Executables and DLLs
    {
        binaries_path :: "bin";
        package_binaries_path := tprint("%/%", package_path, binaries_path);

        // Create a directory for the binaries
        directory_now_exists := make_directory_if_it_does_not_exist(package_binaries_path, recursive=true);
        assert(directory_now_exists, "Unable to create the directory %", package_binaries_path);

        binaries_to_copy := string.[
            "Dayne.exe",
            "SDL2.dll",
        ];

        for binaries_to_copy {
            source := tprint("%/%/%", root, binaries_path, it);
            destination := tprint("%/%/%", package_path, binaries_path, it);

            log("  % -> %", source, destination);

            success := copy_file(source, destination);
            assert(success, "Unable to copy % to %", source, destination);
        }
    }

    // Assets
    {
        assets_path :: "assets";

        {
            source := tprint("%/%", root, assets_path);
            destination := tprint("%/%", package_path, assets_path);

            log("  % -> %", source, destination);

            // ... The File_Utilities copy_directory function doesn't report failure...
            // @TODO: Hand-roll our own thing here?
            /*
            success := copy_directory(source, destination);
            assert(success, "Unable to copy % to %", source, destination);
            */

            copy_directory(source, destination);
        }
    }

    log("Package successfully created at %.", package_path);
}

////////////////////////////////////////////////////////////////////////////////

// Standard Library
#import "Basic";
#import "Compiler";
#import "String";
#import "File";

// Local Project Modules
#import "ctags";

// Plugins
#import "Metaprogram_Plugins";
#import "Iprof";

plugins: [..] *Metaprogram_Plugin;
