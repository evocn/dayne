// Dayne
// Types to fill in gaps in the standard library
// Alex Hartford
// February 2024

Pair :: struct {
    x: int;
    y: int;
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

////////////////////////////////////////////////////////////////////////////////

// Rounds a float to the nearest int.
round :: (f: float) -> int {
    return cast(int)(f + 0.5);
}

