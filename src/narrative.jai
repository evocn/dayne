// Dayne
// Narrative
// Alex Hartford
// February 2024

Narrative :: struct {
    lines: [..] Line;
    index: int;

    Line :: struct {
        text: string;

        speaker: Speaker;
    }

    Speaker :: struct {
        kind : enum {
            NARRATOR;
            CHARACTER;
            OTHER;
        }

        name: string;

        color : Color = white;

        //portrait: int;
    }
}

next :: (using narrative: *Narrative) {
    index += 1;
    if index > lines.count {
        index = 0;
    }
}

Narrator :: Narrative.Speaker.{kind = .NARRATOR, name = "", color = white};
Yoren :: Narrative.Speaker.{kind = .CHARACTER, name = "Yoren", color = purple};
Rogue :: Narrative.Speaker.{kind = .CHARACTER, name = "The Rogue", color = red};
Blue_Knight :: Narrative.Speaker.{kind = .CHARACTER, name = "The Blue Knight", color = blue};
Sasha :: Narrative.Speaker.{kind = .CHARACTER, name = "Sasha", color = green};

////////////////////////////////////////////////////////////////////////////////

the_main_narrative :: () -> Narrative {
    narrative : Narrative;

    array_add(*narrative.lines, Narrative.Line.{ text = "You are Yoren, The Forgotten King.", } );

    array_add(*narrative.lines,
        .{
            text = 
                "They fear you, but wonder at you all the same.",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "Once, long ago, you were the furtive prince, whose repose lasted for a year and more.",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "In another year, you were the slayer of beasts, the rancor of Ebon.",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "And there is, of course, the faded memory of treachery. Of exile.",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "You wonder at which tales these grey men have heard -",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "These three who would take your life for the pieces of silver you bear.",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "But your answer comes like a pick through ice, from a voice thick with age.",
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "We have known no king on the Road of Tor-bjorn.",
            speaker = Rogue,
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "Only desolation.",
            speaker = Rogue,
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "Your reputation will not stow these swords. It is blood they seek."
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "soundlessly, the chipped sword slips from its scabbard."
        }
    );

    array_add(*narrative.lines,
        .{
            text = 
                "You tremble. You fight."
        }
    );

    return narrative;
}
