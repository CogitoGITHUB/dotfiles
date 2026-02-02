{ config, pkgs, lib, ... }:
# let
#   logDir = "$HOME/.local/share/logs/cleanup";
#   log = service: ''
#     LOG_FILE="${logDir}/${service}.log"
#     mkdir -p "${logDir}"
#     exec >> "$LOG_FILE" 2>&1
#     echo "--- $(date) ---"
#   '';
# in
# {
#   # ===========================================================================
#   # HOME DIRECTORY CLEANUP
#   # ===========================================================================
#   systemd.user.services.home-cleanup = {
#     Unit = {
#       Description = "Home directory cleanup";
#       After = [ "graphical-session.target" ];
#     };
#     Service = {
#       Type = "oneshot";
#       ExecStart = toString (pkgs.writeShellScript "home-cleanup" ''
#         ${log "home-cleanup"}
#
#         find "$HOME/tmp" -type f -mtime +7 -delete 2>/dev/null || true
#         find "$HOME/.local/tmp" -type f -mtime +7 -delete 2>/dev/null || true
#
#         find "$HOME/.local/share/qutebrowser/webengine" -name "*.tmp" -mtime +3 -delete 2>/dev/null || true
#
#         find "$HOME/.cache/thumbnails" -type f -atime +30 -delete 2>/dev/null || true
#
#         find "$HOME/.cache/mpv" -type f -mtime +7 -delete 2>/dev/null || true
#
#         if command -v atuin >/dev/null 2>&1; then
#           atuin history prune --max-age 365 2>/dev/null || true
#         fi
#
#         for db in \
#           "$HOME"/.mozilla/firefox/*/places.sqlite \
#           "$HOME/.config/qutebrowser/history.sqlite"; do
#           [ -f "$db" ] && sqlite3 "$db" "VACUUM;" 2>/dev/null || true
#         done
#
#         find "$HOME/.local/share/logs" -type f -mtime +30 -delete 2>/dev/null || true
#
#         echo "Home cleanup completed"
#       '');
#     };
#   };
#
#   systemd.user.timers.home-cleanup = {
#     Unit.Description = "Home cleanup timer";
#     Timer = {
#       OnCalendar = "daily";
#       Persistent = true;
#       RandomizedDelaySec = 3600;
#     };
#     Install.WantedBy = [ "timers.target" ];
#   };
#
#   # ===========================================================================
#   # NIX STORE CLEANUP
#   # ===========================================================================
#   systemd.user.services.nix-cleanup = {
#     Unit.Description = "Nix store garbage collection and optimisation";
#     Service = {
#       Type = "oneshot";
#       ExecStart = toString (pkgs.writeShellScript "nix-cleanup" ''
#         ${log "nix-cleanup"}
#
#         echo "Collecting garbage older than 14 days..."
#         doas nix-collect-garbage --delete-older-than 14d
#
#         echo "Optimising store..."
#         doas nix store optimise
#
#         echo "Nix cleanup completed"
#       '');
#     };
#   };
#
#   systemd.user.timers.nix-cleanup = {
#     Unit.Description = "Nix store cleanup timer";
#     Timer = {
#       OnCalendar = "weekly";
#       Persistent = true;
#     };
#     Install.WantedBy = [ "timers.target" ];
#   };
#
#   # ===========================================================================
#   # DOWNLOADS ORGANISATION
#   # ===========================================================================
#   systemd.user.services.organize-downloads = {
#     Unit.Description = "Organise Downloads folder by file type";
#     Service = {
#       Type = "oneshot";
#       ExecStart = toString (pkgs.writeShellScript "organize-downloads" ''
#         ${log "organize-downloads"}
#
#         DOWNLOADS="$HOME/Downloads"
#
#         for dir in Archives Documents Images Audio Video Executables Other; do
#           mkdir -p "$DOWNLOADS/$dir"
#         done
#
#         # -print0 / -d '\0' — the empty string is escaped as ''' in Nix strings
#         find "$DOWNLOADS" -maxdepth 1 -type f -mtime +1 -print0 | while IFS= -r -d ''''' file; do
#           name=$(basename "$file")
#           ext="${name##*.}"
#
#           if [ "$ext" = "$name" ]; then
#             mv "$file" "$DOWNLOADS/Other/" 2>/dev/null || true
#             continue
#           fi
#
#           ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
#
#           case "$ext_lower" in
#             zip|tar|gz|bz2|xz|rar|7z|tgz)
#               mv "$file" "$DOWNLOADS/Archives/"     ;;
#             pdf|doc|docx|txt|rtf|odt|md|epub)
#               mv "$file" "$DOWNLOADS/Documents/"   ;;
#             jpg|jpeg|png|gif|bmp|svg|webp|raw|cr2)
#               mv "$file" "$DOWNLOADS/Images/"      ;;
#             mp3|wav|flac|aac|ogg|m4a|wma)
#               mv "$file" "$DOWNLOADS/Audio/"       ;;
#             mp4|avi|mkv|mov|wmv|flv|webm|m4v)
#               mv "$file" "$DOWNLOADS/Video/"       ;;
#             deb|rpm|dmg|pkg|exe|msi|appimage)
#               mv "$file" "$DOWNLOADS/Executables/" ;;
#             *)
#               mv "$file" "$DOWNLOADS/Other/"       ;;
#           esac 2>/dev/null || true
#         done
#
#         echo "Downloads organised"
#       '');
#     };
#   };
#
#   systemd.user.timers.organize-downloads = {
#     Unit.Description = "Organise Downloads timer";
#     Timer = {
#       OnCalendar = "daily";
#       Persistent = true;
#     };
#     Install.WantedBy = [ "timers.target" ];
#   };
#
#   # ===========================================================================
#   # DOTFILES & EDITOR DEBRIS CLEANUP
#   # ===========================================================================
#   systemd.user.services.dotfiles-cleanup = {
#     Unit.Description = "Clean up old dotfile backups and editor swap files";
#     Service = {
#       Type = "oneshot";
#       ExecStart = toString (pkgs.writeShellScript "dotfiles-cleanup" ''
#         ${log "dotfiles-cleanup"}
#
#         find "$HOME" -maxdepth 2 -name "*.bak" -mtime +30 -delete 2>/dev/null || true
#         find "$HOME/.config" -maxdepth 2 -name "*.old" -mtime +30 -delete 2>/dev/null || true
#
#         find "$HOME" -name ".*.swp" -delete 2>/dev/null || true
#         find "$HOME" -name ".*.swo" -delete 2>/dev/null || true
#         find "$HOME" -name "*~"    -mtime +7 -delete 2>/dev/null || true
#
#         echo "Dotfiles cleanup completed"
#       '');
#     };
#   };
#
#   systemd.user.timers.dotfiles-cleanup = {
#     Unit.Description = "Dotfiles cleanup timer";
#     Timer = {
#       OnCalendar = "weekly";
#       Persistent = true;
#     };
#     Install.WantedBy = [ "timers.target" ];
#   };
#
#   # ===========================================================================
#   # HELPER SCRIPTS
#   # ===========================================================================
#   home.packages = with pkgs; [
#     (writeShellScriptBin "cleanup-now" ''
#       echo "Running all cleanup tasks..."
#       systemctl --user start home-cleanup.service
#       systemctl --user start nix-cleanup.service
#       systemctl --user start organize-downloads.service
#       systemctl --user start dotfiles-cleanup.service
#       echo "Done. Logs in ~/.local/share/logs/cleanup/"
#     '')
#
#     (writeShellScriptBin "cleanup-status" ''
#       for timer in home-cleanup nix-cleanup organize-downloads dotfiles-cleanup; do
#         echo "=== $timer ==="
#         systemctl --user list-timers "$timer.timer" --no-header --no-pager 2>/dev/null \
#           || echo "  Not enabled"
#         echo ""
#       done
#     '')
#
#     (writeShellScriptBin "cleanup-enable" ''
#       for timer in home-cleanup nix-cleanup organize-downloads dotfiles-cleanup; do
#         systemctl --user enable "$timer.timer"
#       done
#       echo "All cleanup timers enabled."
#     '')
#
#     (writeShellScriptBin "cleanup-disable" ''
#       for timer in home-cleanup nix-cleanup organize-downloads dotfiles-cleanup; do
#         systemctl --user disable "$timer.timer"
#       done
#       echo "All cleanup timers disabled."
#     '')
#   ];
#
#   # ===========================================================================
#   # SHELL ALIASES
#   # ===========================================================================
#   home.shellAliases = {
#     clean         = "cleanup-now";
#     clean-status  = "cleanup-status";
#     clean-enable  = "cleanup-enable";
#     clean-disable = "cleanup-disable";
#
#     nix-clean     = "nix-collect-garbage -d";
#     nix-optimise  = "nix store optimise";
#     nix-repair    = "nix-store --verify --check-contents --repair";
#
#     clean-cache   = "find ~/.cache -mindepth 1 -delete 2>/dev/null; echo done";
#     clean-tmp     = "rm -rf ~/tmp/* ~/.local/tmp/* 2>/dev/null; echo done";
#     clean-swp     = "find ~ -name '*.swp' -delete 2>/dev/null; echo done";
#
#     big-files     = "du -ah ~ | sort -rh | head -20";
#     big-dirs      = "du -sh ~/*/ 2>/dev/null | sort -rh | head -10";
#     nix-size      = "nix path-info -Sh /run/current-system";
#   };
}
