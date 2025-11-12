#!/usr/bin/env nu

let wallpaper_dir = $"($env.HOME)/.config/mpvpaper"
let youtube_links = [
    "https://www.youtube.com/live/jfKfPfyJRdk?si=HyGJH0l9M7WhXwta"
]

# Ensure wallpaper dir exists
mkdir $wallpaper_dir | ignore

# Safely gather local files
let local_files = (
    try {
        ls $"($wallpaper_dir)/**" | where type == "file" | get name
    } catch {
        []
    }
)

let all_choices = ($local_files | append $youtube_links)
let choice = ($all_choices | fzf --prompt "🎥 Pick your wallpaper: ")

if ($choice | is-empty) { exit 0 }

^pkill swww-daemon | ignore
^pkill mpvpaper | ignore

let is_youtube = ($choice | str contains "http")
let video_url = if $is_youtube {
    ^yt-dlp -g $choice | str trim
} else {
    $choice
}

^mpvpaper -o "--loop --hwdec=no" eDP-1 $video_url &
