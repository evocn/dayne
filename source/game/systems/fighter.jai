// Dayne
// Fighter
// November 2024

Fighter :: struct {
    name : string;

    using stats : struct {
        strength : Die;
    }

    bonus : [..] Die;
}

draw_fighter :: (using fighter: Fighter, origin : Pair) {
    draw_text(fighter.name, origin.x, origin.y);
    draw_stats(fighter, origin - .{0, 2 * TILE_SIZE_IN_PIXELS});
}

draw_stats :: (using fighter: Fighter, origin : Pair) {
    k := 0;
    draw_stat("strength", fighter.strength, origin + .{0, 2 * k * TILE_SIZE_IN_PIXELS}, red);
    k -= 1;
}

draw_stat :: (name: string, die: Die, origin: Pair, color := white) {
    draw(die, origin, color);
    draw_text("strength", origin.x, origin.y + TILE_SIZE_IN_PIXELS);
}
