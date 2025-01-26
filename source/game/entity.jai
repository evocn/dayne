// Dayne
// Entity
// September 2024

#load "entities/basic.jai";
#load "entities/gubble.jai";
#load "entities/platform.jai";
#load "entities/bubble.jai";
#load "entities/annie.jai";
#load "entities/god.jai";

Entity :: struct {
    Kind :: enum {
        BASIC;
        GUBBLE;
        PLATFORM;
        BUBBLE;
        ANNIE;
        GOD;
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
        case .PLATFORM;         new_entity = xx New(Platform);
        case .BUBBLE;           new_entity = xx New(Bubble);
        case .ANNIE;            new_entity = xx New(Annie);
        case .GOD;              new_entity = xx New(God);
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
        case .PLATFORM;         initialize(cast(*Platform)entity);
        case .BUBBLE;           initialize(cast(*Bubble)entity);
        case .ANNIE;            initialize(cast(*Annie)entity);
        case .GOD;              initialize(cast(*God)entity);
    }
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .BASIC;            update(cast(*Basic)entity, dt);
        case .GUBBLE;           update(cast(*Gubble)entity, dt);
        case .PLATFORM;         update(cast(*Platform)entity, dt);
        case .BUBBLE;           update(cast(*Bubble)entity, dt);
        case .ANNIE;            update(cast(*Annie)entity, dt);
        case .GOD;              update(cast(*God)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw(cast(*Basic)entity);
        case .GUBBLE;           draw(cast(*Gubble)entity);
        case .PLATFORM;         draw(cast(*Platform)entity);
        case .BUBBLE;           draw(cast(*Bubble)entity);
        case .ANNIE;            draw(cast(*Annie)entity);
        case .GOD;              draw(cast(*God)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw_debug(cast(*Basic)entity);
        case .GUBBLE;           draw_debug(cast(*Gubble)entity);
        case .PLATFORM;         draw_debug(cast(*Platform)entity);
        case .BUBBLE;           draw_debug(cast(*Bubble)entity);
        case .ANNIE;            draw_debug(cast(*Annie)entity);
        case .GOD;              draw_debug(cast(*God)entity);
    }
}

