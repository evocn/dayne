// Dayne
// Profiler
// February 2025

// This is a dead-simple profiler for top-level zones.
// It helps us identify which parts of the program we're spending time in.
// It has three features:
// - A macro for defining zones.
// - A function to report values for the frame (in ms and % of total).
// - A function to draw the given report to the screen.

Zone :: struct {
    start: s64;
    ticks: s64;

    Kind :: enum {
        FRAME; // Reserved for the overall frame zone.

        INPUT;
        GAME;
        DRAW;
        IDLE;
    }
}
ZONE_COUNT :: #run enum_highest_value(Zone.Kind) + 1;

zones : [ZONE_COUNT] Zone;

// Put this at the start of a scope you want to profile.
zone :: (kind : Zone.Kind) #expand {
    zone_begin(kind);
    `defer zone_end(kind);
}

zone_begin :: inline (kind : Zone.Kind) #expand {
    zone := *zones[xx kind];

    ticks := cast,no_check(s64) rdtsc();
    zone.start = ticks;
}

zone_end :: inline (kind : Zone.Kind) {
    zone := *zones[xx kind];

    ticks := cast,no_check(s64) rdtsc();

    zone.ticks = ticks - zone.start;
}

////////////////////////////////////////////////////////////////////////////////

// Call this at the end of every frame to reset stuff and see what the frame looked like.
profiler_flush :: (dt: float) -> Report {
    report : Report;

    // This is some unit conversion.
    // We want to get a value which converts ticks to time.
    // Our best approximation of rdtsc to wall clock time is simply to take the overall frame ticks vs overall frame time.
    // Once you know that, you can use the ratio to convert each zone's ticks into each zone's time.

    frame_ticks := zones[xx Zone.Kind.FRAME].ticks;

    ticks_over_time := cast(float64) frame_ticks / dt;
    time_over_ticks := 1.0 / ticks_over_time;

    names := enum_names(Zone.Kind);
    for zone, index : zones {
        report[index].name = names[index];
        report[index].ms = zone.ticks * time_over_ticks * 1000.0;
        report[index].percent = cast(float64)zone.ticks / frame_ticks;
    }

    return report;
}

Report :: [ZONE_COUNT] Report_Section;

Report_Section :: struct {
    name    : string;
    ms      : float64;
    percent : float64;
}

last_frame_report : Report;

////////////////////////////////////////////////////////////////////////////////

draw :: (report: Report) {
    zone_colors : [ZONE_COUNT] Color;
    zone_colors[xx Zone.Kind.FRAME] = white;
    zone_colors[xx Zone.Kind.INPUT] = yellow;
    zone_colors[xx Zone.Kind.GAME]  = blue;
    zone_colors[xx Zone.Kind.DRAW]  = seafoam;
    zone_colors[xx Zone.Kind.IDLE]  = red;

    // Draw bars
    {
        use_basic_shader();

        x := 0;
        for section, index : report {
            if index == xx Zone.Kind.FRAME then continue;

            width := cast(int)(section.percent * PIXEL_WIDTH);

            draw_colored_quad(
                x = x,
                y = 0,
                width = width,
                height = 16,
                color = zone_colors[index]
            );

            x += width;
        }
    }

    // Draw Legend
    {
        use_text_shader();

        x := 0;
        for section, index : report {
            draw_text(
                tprint("% %", cast(Zone.Kind)index, formatFloat(section.ms, width = 2, trailing_width = 2)),
                x = x,
                y = 16,
                font = .SMALL,
                color = zone_colors[index]
            );

            x += 50;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Timestamp code

#if CPU == .X64 {
    #import "Machine_X64";  // For rdtsc, etc.
} else {
    // Poor-man’s replacements for rdtsc.
    // @TODO: We should probably call something like ARM64 CNTPCTSS_EL0 instead, but the compiler does not support that right now.
    //  -rluba, 2024-04-22
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
