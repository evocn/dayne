// Dayne
// Entity
// September 2024

#load "entities/basic.jai";

Entity :: struct {
    Kind :: enum {
        BASIC;
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
    }
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .BASIC;            update(cast(*Basic)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw(cast(*Basic)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw_debug(cast(*Basic)entity);
    }
}

