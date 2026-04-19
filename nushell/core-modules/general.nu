# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false

    ls: {
        use_ls_colors: false
        clickable_links: true
    }

    rm: {
        always_trash: true
    }

    table: {
        mode: rounded
        index_mode: auto
        show_empty: true
        padding: { left: 0, right: 0 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: true
        footer_inheritance: true
    }

    error_style: "fancy"

    display_errors: {
        exit_code: true
        termination_signal: true
    }

    datetime_format: {
        table: '%m/%d/%y %I:%M:%S%p'
    }

    explore: {
        status_bar_background: { fg: "#8B0000", bg: "#3D0000" }
        command_bar_text: { fg: "#8B0000" }
        highlight: { fg: "#8B0000", bg: "#3D0000" }
        status: {
            error: { fg: "#8B0000", bg: "#3D0000" }
            warn: { fg: "#8B0000", bg: "#3D0000" }
            info: { fg: "#8B0000", bg: "#3D0000" }
        }
        selected_cell: { bg: "#3D0000" }
    }

    history: {
        max_size: 100_000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: false
    }

    cursor_shape: {
        emacs: line
        vi_insert: block
        vi_normal: underscore
    }

    footer_mode: 25
    float_precision: 2
    buffer_editor: null
    use_ansi_coloring: true
    bracketed_paste: true
    edit_mode: emacs

    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: true
        osc133: true
        osc633: true
        reset_application_mode: true
    }

    render_right_prompt_on_last_line: false
    use_kitty_protocol: false
    highlight_resolved_externals: false
    recursion_limit: 50

    hooks: {
        pre_prompt: [{ null }]
        pre_execution: [{ null }]
        env_change: {
            PWD: [{|before, after| null }]
        }
        display_output: "if (term size).columns >= 100 { table -e } else { table }"
        command_not_found: { null }
    }

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: columnar
                columns: 4
                col_width: 20
                col_padding: 2
            }
            style: {
                text: dark_red
                selected_text: { fg: dark_red, bg: "#3D0000" }
                description_text: dark_red
                match_text: { attr: u }
                selected_match_text: { fg: dark_red, bg: "#3D0000" }
            }
        }
        {
            name: ide_completion_menu
            only_buffer_difference: false
            marker: "| "
            type: {
                layout: ide
                min_completion_width: 0
                max_completion_width: 50
                max_completion_height: 10
                padding: 0
                border: true
                cursor_offset: 0
                description_mode: "prefer_right"
                min_description_width: 0
                max_description_width: 50
                max_description_height: 10
                description_offset: 1
                correct_cursor_pos: false
            }
            style: {
                text: dark_red
                selected_text: { fg: dark_red, bg: "#3D0000" }
                description_text: dark_red
                match_text: { attr: u }
                selected_match_text: { fg: dark_red, bg: "#3D0000" }
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: dark_red
                selected_text: { fg: dark_red, bg: "#3D0000" }
                description_text: dark_red
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_width: 20
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: dark_red
                selected_text: { fg: dark_red, bg: "#3D0000" }
                description_text: dark_red
            }
        }
    ]
color_config: {
        separator: "#8B0000"
        leading_trailing_space_bg: { attr: n }
        header: "#8B0000"
        empty: "#8B0000"
        bool: "#8B0000"
        int: "#8B0000"
        filesize: "#8B0000"
        duration: "#8B0000"
        date: "#8B0000"
        range: "#8B0000"
        float: "#8B0000"
        string: "#8B0000"
        nothing: "#8B0000"
        binary: "#8B0000"
        cell-path: "#8B0000"
        row_index: "#8B0000"
        record: "#8B0000"
        list: "#8B0000"
        block: "#8B0000"
        hints: "#8B0000"
        search_result: { bg: "#3D0000" fg: "#8B0000" }
        shape_and: "#8B0000"
        shape_binary: "#8B0000"
        shape_block: "#8B0000"
        shape_bool: "#8B0000"
        shape_closure: "#8B0000"
        shape_custom: "#8B0000"
        shape_datetime: "#8B0000"
        shape_directory: "#8B0000"
        shape_external: "#8B0000"
        shape_externalarg: "#8B0000"
        shape_external_resolved: "#8B0000"
        shape_filepath: "#8B0000"
        shape_flag: "#8B0000"
        shape_float: "#8B0000"
        shape_garbage: { fg: "#8B0000" bg: "#3D0000" attr: b }
        shape_glob_interpolation: "#8B0000"
        shape_globpattern: "#8B0000"
        shape_int: "#8B0000"
        shape_internalcall: "#8B0000"
        shape_keyword: "#8B0000"
        shape_list: "#8B0000"
        shape_literal: "#8B0000"
        shape_match_pattern: "#8B0000"
        shape_matching_brackets: { attr: u }
        shape_nothing: "#8B0000"
        shape_operator: "#8B0000"
        shape_or: "#8B0000"
        shape_pipe: "#8B0000"
        shape_range: "#8B0000"
        shape_record: "#8B0000"
        shape_redirection: "#8B0000"
        shape_signature: "#8B0000"
        shape_string: "#8B0000"
        shape_string_interpolation: "#8B0000"
        shape_table: "#8B0000"
        shape_variable: "#8B0000"
        shape_vardecl: "#8B0000"
        shape_raw_string: "#8B0000"
    }
}