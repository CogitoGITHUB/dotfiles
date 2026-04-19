let light_theme = {
    separator: dark_red
    leading_trailing_space_bg: { attr: n }
    header: dark_red
    empty: dark_red
    bool: dark_red
    int: dark_red
    filesize: dark_red
    duration: dark_red
    date: dark_red
    range: dark_red
    float: dark_red
    string: dark_red
    nothing: dark_red
    binary: dark_red
    cell-path: dark_red
    row_index: dark_red
    record: dark_red
    list: dark_red
    block: dark_red
    hints: dark_red
    search_result: { bg: "#3D0000" fg: "#8B0000" }
    shape_and: dark_red
    shape_binary: dark_red
    shape_block: dark_red
    shape_bool: dark_red
    shape_closure: dark_red
    shape_custom: dark_red
    shape_datetime: dark_red
    shape_directory: dark_red
    shape_external: dark_red
    shape_externalarg: dark_red
    shape_external_resolved: dark_red
    shape_filepath: dark_red
    shape_flag: dark_red
    shape_float: dark_red
    shape_garbage: { fg: dark_red bg: "#3D0000" attr: b }
    shape_glob_interpolation: dark_red
    shape_globpattern: dark_red
    shape_int: dark_red
    shape_internalcall: dark_red
    shape_keyword: dark_red
    shape_list: dark_red
    shape_literal: dark_red
    shape_match_pattern: dark_red
    shape_matching_brackets: { attr: u }
    shape_nothing: dark_red
    shape_operator: dark_red
    shape_or: dark_red
    shape_pipe: dark_red
    shape_range: dark_red
    shape_record: dark_red
    shape_redirection: dark_red
    shape_signature: dark_red
    shape_string: dark_red
    shape_string_interpolation: dark_red
    shape_table: dark_red
    shape_variable: dark_red
    shape_vardecl: dark_red
    shape_raw_string: dark_red
}

let light_theme = $light_theme

$env.config.color_config = $light_theme

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")