#!/run/current-system/profile/bin/bash
export PATH="$HOME/.config/guix/current/bin:$PATH"
script -q -c "guix system reconfigure $HOME/.config/guix/config.scm --max-jobs=1" /dev/null
