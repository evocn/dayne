// Dayne
// Build
// Alex Hartford

#import "Basic";
#import "Compiler";
#import "File";

#import "ctags";

build :: () {
    w := compiler_create_workspace("Main Workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    options := get_build_options(w);

    // Check command-line arguments
    user_build_options : struct {
        build_type : enum {
            DEVELOP;
            RELEASE;
            SMALL;
        }
    }

    args := options.compile_time_command_line;
    {
        print("args is: %\n", args);
        for arg: args {
            if arg == {
                case "release"; user_build_options.build_type = .RELEASE;
                case "small";   user_build_options.build_type = .SMALL;
            }
        }
    }

    // Set build options
    {
        options.output_executable_name = "dayne";

        options.output_path = "bin";
        options.intermediate_path = "bin/.build";
        options.output_type = .EXECUTABLE;
        options.text_output_flags = 2;

        if user_build_options.build_type == {
            case .DEVELOP;  set_optimization(*options, .DEBUG);
            case .RELEASE;  set_optimization(*options, .VERY_OPTIMIZED);
            case .SMALL;    set_optimization(*options, .OPTIMIZED_VERY_SMALL);
        }

        set_build_options(options, w);
        set_build_options_dc(.{do_output=false});
    }

    // Ctags module options
    ctags: CTags;
    ctags.output_filename = "tags";
    ctags.base_path = tprint("%", #filepath);
    defer reset(*ctags);

    compiler_begin_intercept(w);

    // Files to compile
    {
        add_build_file(tprint("%/source/main.jai", #filepath), w);
    }

    // User Build Options
    {
        build_configuration_string : string;
        build_configuration_string = sprint("BUILD_TYPE :: build_type.%;", user_build_options.build_type);
        add_build_string(build_configuration_string, w);

        add_build_string(#string DONE
        build_type :: enum {
            DEVELOP;
            RELEASE;
            SMALL;
        }
        DONE
        , w);
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

    // Create a manifest and an icon file.
    #if OS == .WINDOWS {
        exe_name := sprint("%/%.exe", options.output_path, options.output_executable_name);
        defer free(exe_name);

        ico_data := create_ico_file_from_bitmap_filename("assets/publishing/icon.png");
        defer free(ico_data);

        set_icon_by_data(exe_name, ico_data);
        write_entire_file("assets/publishing/icon.ico", ico_data);

        print("Icon     added: %\n", set_icon_by_filename(exe_name, "assets/publishing/icon.ico"));

        manifest_options: Manifest_Options;
        print("Manifest added: %\n", add_manifest_to_executable(exe_name, manifest_options));

        #import "Ico_File";
        #import "Windows_Resources";
    }
}

#run build();
