// Dayne
// Entity
// September 2024

#load "entities/basic.jai";
#load "entities/collision_tester.jai";
#load "entities/solid_tester.jai";

Entity :: struct {
    Kind :: enum {
        BASIC;
        COLLISION_TESTER;
        SOLID_TESTER;
    }
    kind : Kind;

    z_index     : int;

    id          : int;
    should_die  : bool;

    debug: struct {
        unique_color: Color;
    }
}

next_id := 0;
new_entity :: (kind : Entity.Kind) -> *Entity {
    new_entity : *Entity;

    if #complete kind == {
        case .BASIC;            new_entity = xx New(Basic);
        case .COLLISION_TESTER; new_entity = xx New(Collision_Tester);
        case .SOLID_TESTER;     new_entity = xx New(Solid_Tester);
    }

    initialize(new_entity);

    new_entity.id = next_id;
    next_id += 1;

    return new_entity;
}


initialize :: (entity: *Entity) {
    entity.debug.unique_color = random_color();

    if #complete entity.kind == {
        case .BASIC;            initialize(cast(*Basic)entity);
        case .COLLISION_TESTER; initialize(cast(*Collision_Tester)entity);
        case .SOLID_TESTER;     initialize(cast(*Solid_Tester)entity);
    }
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .BASIC;            update(cast(*Basic)entity, dt);
        case .COLLISION_TESTER; update(cast(*Collision_Tester)entity, dt);
        case .SOLID_TESTER;     update(cast(*Solid_Tester)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw(cast(*Basic)entity);
        case .COLLISION_TESTER; draw(cast(*Collision_Tester)entity);
        case .SOLID_TESTER;     draw(cast(*Solid_Tester)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw_debug(cast(*Basic)entity);
        case .COLLISION_TESTER; draw_debug(cast(*Collision_Tester)entity);
        case .SOLID_TESTER;     draw_debug(cast(*Solid_Tester)entity);
    }
}

