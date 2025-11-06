# Define a white-background theme (black text everywhere)
let light_theme = {
    separator: black
    leading_trailing_space_bg: { attr: n }
    header: black
    empty: black

    bool: black
    int: black
    filesize: black
    duration: black
    date: black
    range: black
    float: black
    string: black
    nothing: black
    binary: black
    cell-path: black
    row_index: black
    record: black
    list: black
    block: black
    hints: black
    search_result: { bg: "#DDDDDD" fg: "#000000" }

    shape_and: black
    shape_binary: black
    shape_block: black
    shape_bool: black
    shape_closure: black
    shape_custom: black
    shape_datetime: black
    shape_directory: black
    shape_external: black
    shape_externalarg: black
    shape_external_resolved: black
    shape_filepath: black
    shape_flag: black
    shape_float: black
    shape_garbage: { fg: black bg: "#FF0000" attr: b }
    shape_glob_interpolation: black
    shape_globpattern: black
    shape_int: black
    shape_internalcall: black
    shape_keyword: black
    shape_list: black
    shape_literal: black
    shape_match_pattern: black
    shape_matching_brackets: { attr: u }
    shape_nothing: black
    shape_operator: black
    shape_or: black
    shape_pipe: black
    shape_range: black
    shape_record: black
    shape_redirection: black
    shape_signature: black
    shape_string: black
    shape_string_interpolation: black
    shape_table: black
    shape_variable: black
    shape_vardecl: black
    shape_raw_string: black
}

let color_config = $light_theme

# Ensure autoload directory exists and Starship prompt works
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

