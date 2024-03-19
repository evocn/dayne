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
random :: inline () -> float {
    return random_get_zero_to_one();
}

// [0, max]
random :: inline (max: float) -> float {
    return random_get_zero_to_one() * max;
}

// [min, max]
random :: inline (min: float, max: float) -> float {
    return random_get_within_range(min, max);
}

random_choice :: inline (choices: [] $T) -> T {
    min := 0.0;
    max := cast(float)(choices.count);
    index := cast(int)random_get_within_range(min, max);
    return choices[index];
}

////////////////////////////////////////////////////////////////////////////////

// Rounds a float to the nearest int.
round :: (f: float) -> int {
    return cast(int)(f + 0.5);
}

