// Dayne
// Entity
// September 2024

#load "entities/basic.jai";
#load "entities/gubble.jai";

Entity :: struct {
    Kind :: enum {
        BASIC;
        GUBBLE;
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
        case .GUBBLE;           new_entity = xx New(Gubble);
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
        case .GUBBLE;           initialize(cast(*Gubble)entity);
    }
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .BASIC;            update(cast(*Basic)entity, dt);
        case .GUBBLE;           update(cast(*Gubble)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw(cast(*Basic)entity);
        case .GUBBLE;           draw(cast(*Gubble)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw_debug(cast(*Basic)entity);
        case .GUBBLE;           draw_debug(cast(*Gubble)entity);
    }
}

