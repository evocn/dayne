// Dayne
// Debug
// December 2024

Debug :: struct {
    messages : [..] string;

    collided_solids : [..] *Solid;

    profiling : Profiling_Stuff;
}

debug_print :: (s : string) {
    array_add(*program_state.debug.messages, s);
}

frame_reset :: (using debug: *Debug) {
    array_reset(*messages);
    table_reset(*profiling.ranges);
}

draw :: (using debug: Debug) {
    k := 0;
    inc := 10;
    for s : messages {
        draw_text(
            s,
            1,
            PIXEL_HEIGHT - inc - (k * inc),
            font = .MAIN,
            color = debug_color,
        );

        k += 1;
    }
}

//
// Profiling
//

// Dec. 2024:
// This stuff was just here to learn about how I'd do profiling.
// I think I'll just use Iprof now, since I understand the general idea.
// Pretty fun little adventure here!

#if CPU == .X64 {
    #import "Machine_X64";  // For rdtsc, etc.
} else {
    // Poor-man’s replacements for rdtsc.
    rdtsc :: () -> u64 #expand {
        #if OS == .WINDOWS {
            Windows :: #import "Windows";
            pc: s64;
            Windows.QueryPerformanceCounter(*pc);
            return cast,no_check(u64) pc;
        } else {
            POSIX ::#import "POSIX";
            ts: POSIX.timespec;
            POSIX.clock_gettime(.MONOTONIC_RAW, *ts);
            return cast,no_check(u64) ts.tv_nsec;
        }
    }
}

Profiling_Stuff :: struct {
    ranges : Table(string, Profiling_Range);
}

Profiling_Range :: struct {
    start: Apollo_Time;
    end  : Apollo_Time;
}

profiling_start_range :: (name: string) {
    table_add(*debug.profiling.ranges, name, .{start = current_time_monotonic()});
}

profiling_end_range :: (name: string) {
    p := table_find_pointer(*debug.profiling.ranges, name);
    if p == null {
        log_error("Couldn't find a matching range for %\n", name);
        return;
    }

    p.end = current_time_monotonic();
}

debug_print_report :: (using p : Profiling_Stuff) {
    format_float := *context.print_style.default_format_float;  // Get a pointer to this so we can play with it.

    for range, name : ranges {
        debug_print(tprint("%: %", name, to_float64_seconds(range.end - range.start) * 1000));
    }
}

print_report :: (using p : Profiling_Stuff) {
    print("Frame %\n", current_frame);
    for range, name : ranges {
        print("%: % ms\n", name, to_float64_seconds(range.end - range.start) * 1000);
    }
}
