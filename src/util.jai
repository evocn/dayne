// Dayne
// Types to fill in gaps in the standard library
// Alex Hartford
// February 2024

Pair :: struct {
    x: int;
    y: int;
}

operator + :: (a : Pair, b : Pair) -> Pair {
    return .{a.x + b.x, a.y + b.y};
}

////////////////////////////////////////////////////////////////////////////////

// [0, 1]
rng :: inline () -> float {
    return random_get_zero_to_one();
}

// [0, max]
rng :: inline (max: float) -> float {
    return random_get_zero_to_one() * max;
}

// [min, max]
rng :: inline (min: float, max: float) -> float {
    return random_get_within_range(min, max);
}
