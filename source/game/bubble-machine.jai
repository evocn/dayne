// Gubble
// Bubble Machine
// January 2025

blow :: () -> *Bubble {
    using bubble : *Bubble = xx new_entity(.BUBBLE);
    width   = 16;
    height  = 16;

    initialize(*animation, "Bubble");

    return bubble;
}

blow_bubbles :: (entities: *[..] *Entity) {
    count :: 100;

    for i : 0..count {
        bubble := blow();
        bubble.x = xx random(0, 240);
        bubble.y = xx random(0, 1000);

        array_add(entities, xx bubble);
    }
}

floors :: 30;
tiles_wide :: 16;
tiles_high :: 8;

generate_level :: (entities: *[..] *Entity) {
    for floor : 0..floors {
        template_raw := random_choice(templates);

        template := replace(template_raw, "\n", "");

        for char, index : template {
            col := index / tiles_wide;
            row := index % tiles_wide;

            if char == #char "B" {
                bubble := blow();
                bubble.x = TILE_SIZE_IN_PIXELS * (row);
                bubble.y = TILE_SIZE_IN_PIXELS * (col) + floor * TILE_SIZE_IN_PIXELS * tiles_high;
                array_add(entities, xx bubble);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////

templates :: string.[
    t0,
    t1,
    t2,
    t3,
    t4,
];

// Templates
t0 :: #string DONE
0000000000B000B0
0B000B0000000000
0000000000B000B0
0B000B0000000000
0000000000B000B0
0B000B0000000000
0000000000B000B0
0B000B0000000000
DONE

t1 :: #string DONE
BBBBBBBBBBBBBBBB
0000000000000000
0000000000000000
BBBBBBBBBBBBBBBB
0000000000000000
0000000000000000
BBBBBBBBBBBBBBBB
0000000000000000
DONE

t2 :: #string DONE
0000000000000000
0000000000BBB000
0000000000000000
0000000BBB000000
0000000000000000
0000BBB000000000
0000000000000000
0BBB000000000000
DONE

t3 :: #string DONE
B000000000000000
00B0000000000000
0000B00000000000
000000B000000000
00000000B0000000
0000000000B00000
000000000000B000
00000000000000B0
DONE

t4 :: #string DONE
00000BB00BB00000
00BB00000000BB00
0000000000000000
B000000BB000000B
0000000000000000
0BB0000000000BB0
0000BB0000BB0000
0000000BB0000000
DONE
