#!/usr/bin/env nu

def main [...args] {
    if ($args | is-not-empty) {
        print ($args | str join " ")
    } else {
        let msg = (input "Text: ")
        clear           # <— clears screen AFTER input
        print $msg
    }
}
