// Dayne
// Build
// Alex Hartford

#import "ctags";


// This is data which should be visible to the build program and the target program.
shared_data :: #string DONE

build_settings : struct {
    configuration : enum {
        DEVELOP;
        RELEASE;
    }
}

program_title :: "Dayne";

DONE


build :: () {
    // Build program workspace
    {
        #run add_build_string(shared_data, w = -1);
        set_build_options_dc(.{do_output=false});
    }

    // Create target program workspace
    w := compiler_create_workspace("Final Program Workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    options := get_build_options(w);

    // Handle command-line arguments
    {
        for argument: options.compile_time_command_line {
            if argument == {
                case "release"; build_settings.configuration = .RELEASE;
            }
        }
    }

    // Set build options
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
            case .DEVELOP;  set_optimization(*options, .DEBUG);
            case .RELEASE;  set_optimization(*options, .VERY_OPTIMIZED);
        }

        set_build_options(options, w);
    }

    // Ctags module options
    ctags: CTags;
    defer reset(*ctags);
    ctags.output_filename = "tags";
    ctags.base_path = sprint("%", #filepath);
    defer free(ctags.base_path);

    // Start adding files to the target workspace
    {
        compiler_begin_intercept(w);

        // Files to compile
        {
            add_build_file(tprint("%/source/main.jai", #filepath), w);
        }

        // User Build Options
        {
            add_build_string(shared_data, w);

            build_configuration_string : string;
            build_configuration_string = tprint("BUILD_TYPE :: build_settings.configuration.%;", build_settings.configuration);
            add_build_string(build_configuration_string, w);
        }
    }

    while true {
        message := compiler_wait_for_message();
        if !message continue;

        if message.workspace == w {
            process_message(*ctags, message);
        }

        if message.kind == .COMPLETE break;
    }
    compiler_end_intercept(w);


    // Publishing work
    {
        log("\n\nCompilation ended on the target workspace. On to publishing work!");

        executable_path := sprint("%/%.exe", options.output_path, options.output_executable_name);
        defer free(executable_path);

        icon_path :: "assets/publishing/icon.png";

        create_and_apply_manifest_and_icon_files(executable_path, icon_path);
    }
}

#run build();

////////////////////////////////////////////////////////////////////////////////

create_and_apply_manifest_and_icon_files :: (executable_path : string, icon_path : string) {
    #if OS == .WINDOWS {
        #import "Ico_File";
        #import "Windows_Resources";

        ico_data := create_ico_file_from_bitmap_filename(icon_path);
        defer free(ico_data);

        ico_path := sprint("%.ico", path_strip_extension(icon_path));
        defer free(ico_path);
        // Save .ico back out for inspection
        {
            write_entire_file(ico_path, ico_data);
        }

        success := set_icon_by_data(executable_path, ico_data);
        print("Icon     added: %\n", success);

        manifest_options: Manifest_Options;
        success = add_manifest_to_executable(executable_path, manifest_options);

        print("Manifest added: %\n", success);
    }
}

#import "Compiler";
#import "Basic";
#import "File";
#import "String";
