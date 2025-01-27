// Gubble
// Level Generator
// January 2025

make_bubble :: () -> *Bubble {
    using bubble : *Bubble = xx new_entity(.BUBBLE);
    width   = 16;
    height  = 16;

    initialize(*animation, "Bubble");
    initialize(*pop_animation, "Pop");

    return bubble;
}

make_platform :: () -> *Platform {
    using platform : *Platform = xx new_entity(.PLATFORM);
    width   = 16;
    height  = 16;

    initialize(*animation, "test-platform");

    return platform;
}

make_one_way_platform :: () -> *Platform {
    using platform : *Platform = xx new_entity(.PLATFORM);
    width   = 16;
    height  = 16;

    solid.one_way = true;

    initialize(*animation, "one-way-platform");

    return platform;
}

make_annie :: (the_variety : Annie.Variety) -> *Annie {
    using annie : *Annie = xx new_entity(.ANNIE);
    width   = 8;
    height  = 8;

    variety = the_variety;
    if variety == {
        case .ORANGE;   initialize(*animation, "Orange");
        case .RED;      initialize(*animation, "Red");
        case .BLUE;     initialize(*animation, "Blue");
        case .GREEN;    initialize(*animation, "Green");
    }

    return annie;
}


////////////////////////////////////////////////////////////////////////////////

floors :: 2;
tiles_wide :: 12;
tiles_high :: 8;

template_position_to_entity_position :: (index: int, floor: int) -> int, int {
    x, y: int;
    col := index / tiles_wide;
    row := index % tiles_wide;

    x = (TILE_SIZE_IN_PIXELS * row);
    y = (floor * TILE_SIZE_IN_PIXELS * tiles_high) + (TILE_SIZE_IN_PIXELS * col);

    return x, y;
}

generate_level :: (entities: *[..] *Entity, simulation: *Simulation) {
    for floor : 0..floors {
        template_raw := random_choice(templates);

        template := replace(template_raw, "\n", "");

        for < char, index : template {
            if char == #char "B" {
                bubble := make_bubble();
                bubble.x, bubble.y = template_position_to_entity_position(index, floor);
                array_add(entities, xx bubble);
            }

            if char == #char "P" {
                platform := make_platform();
                platform.x, platform.y = template_position_to_entity_position(index, floor);

                array_add(entities, xx platform);
                array_add(*simulation.solids, *platform.solid);
            }

            if char == #char "T" {
                platform := make_one_way_platform();
                platform.x, platform.y = template_position_to_entity_position(index, floor);

                array_add(entities, xx platform);
                array_add(*simulation.solids, *platform.solid);
            }
        }

        add_annie :: (floor: int, entities: *[..] *Entity, simulation: *Simulation) {
            varieties := Annie.Variety.[.ORANGE, .RED, .BLUE, .GREEN];

            annie := make_annie(random_choice(varieties));
            annie.x = xx random(0, xx (PIXEL_WIDTH - annie.width));
            annie.y = floor * TILE_SIZE_IN_PIXELS * tiles_high;

            array_add(entities, annie);
            array_add(*simulation.actors, *annie.actor);
        }

        // Populate
        if floor >= 5 {
            add_annie(floor, entities, simulation);
        }
        if floor >= 20 {
            add_annie(floor, entities, simulation);
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
    t5,
    t6,
    t7,
    t8,
    t9,
    t10,
    t11,
    t12,
    t13,
];

// Templates
t0 :: #string DONE
------------
------------
----------B-
-B----------
------------
------------
----------B-
-B----------
DONE

t1 :: #string DONE
B----------B
------------
------------
-----BB-----
------------
B----------B
BBBBBBBBBBBB
------------
DONE

t2 :: #string DONE
------------
------------
----------B-
------------
------B-----
------------
--B---------
------------
DONE

t3 :: #string DONE
------------
------------
-B----------
------------
-----B------
------------
---------B--
------------
DONE

t4 :: #string DONE
-----BB-----
---B----B---
------------
------B-----
-----B------
-B--------B-
------------
-----BB-----
DONE

t5 :: #string DONE
-----BB-----
------------
------------
------------
B--B----B--B
------------
------------
-----BB-----
DONE

t6 :: #string DONE
-B--------B-
------------
------------
-----B------
------B-----
------------
------------
-B--------B-
DONE

t7 :: #string DONE
-BB---------
------------
------------
---------BB-
-BB---------
------------
------------
---------BB-
DONE

t8 :: #string DONE
---B-----B--
------------
--B---------
-----------B
------B-----
------------
------------
---B----B---
DONE

t9 :: #string DONE
------------
--------B---
--B--------B
------------
-----B------
------------
------------
B-------B---
DONE

t10 :: #string DONE
------------
---B--------
------------
------B-----
------------
---------B--
------------
---------B--
DONE

t11 :: #string DONE
---------B--
B-----------
------B-----
-----------B
--B---------
------------
------------
---B--------
DONE

t12 :: #string DONE
------------
----------B-
--B---------
------------
------B-----
------------
----------B-
B-----------
DONE

t13 :: #string DONE
-B--------B-
------------
------------
-----------B
B-----------
------------
------------
-B--------B-
DONE
