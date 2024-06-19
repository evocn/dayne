// Novel
// Text
// Alex Hartford
// May 2024

// This is a simple struct to read text in paragraphs from a markdown file.
// Currently tracks header stuff, but could also be extended easy to handle blocks / quotations.

Paragraph_Kind :: enum {
    BODY;
    HEADER_ONE;
    HEADER_TWO;

    //QUOTATION;
}

Paragraph :: struct {
    text: string;
    kind: Paragraph_Kind;
    //events: [..] Event;
}

Page :: struct {
    paragraphs: [..] Paragraph;
}

reset :: (page: *Page) {
    for paragraph: page.paragraphs {
        free(paragraph.text.data);
    }
    array_reset(*page.paragraphs);
}

////////////////////////////////////////////////////////////////////////////////

read_page :: (file_name: string, page: *Page) -> success: bool {
    raw_text, success := read_entire_file(tprint("%/%.md", text_path, file_name));
    normalize_line_endings(*raw_text);
    assert(success);

    // Out with the old.
    reset(page);

    // In with the new.
    {
        paragraphs := split(raw_text, "\n\n");

        for * paragraphs {
            new_paragraph := read_paragraph_from_raw_text(it.*);
            array_add(*page.paragraphs, new_paragraph);
        }
    }

    return true;
}

// Discerns what kind of paragraph this is and strips requisite identifiers.
// Note that this is quick and dirty, and will not work if you include multiple, etc...
read_paragraph_from_raw_text :: (raw: string) -> Paragraph {
    result : Paragraph;

    // Discern the kind
    text, occurences := replace(raw, "#", "");
    if      occurences == 1 then result.kind = .HEADER_ONE;
    else if occurences == 2 then result.kind = .HEADER_TWO;
    else if occurences  > 2 then assert(false, "The paragraph we're reading here is malformatted. Here it is: \n%\n", text);

    // Quotations
    // etc.

    // Cleanup
    {
        // Do markdown formatting, squishing lines together.
        // For now, we're gonna not do this, since we want to be able to fix up formatting in the text editor.
        //text = replace(text, old="\n", new=" ");

        text = trim(text);
    }

    result.text = text;

    return result;
}
