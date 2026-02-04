[global]
    # Display settings
    monitor = 0
    follow = mouse
    
    # Geometry
    width = 350
    height = 150
    origin = top-right
    offset = 20x20
    
    # Progress bar
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    
    # Notification settings
    indicate_hidden = yes
    shrink = no
    transparency = 0
    separator_height = 3
    padding = 16
    horizontal_padding = 16
    text_icon_padding = 16
    frame_width = 2
    frame_color = "#7aa2f7"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    
    # Text settings
    font = JetBrainsMono Nerd Font 11
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    
    # Icons
    icon_position = left
    min_icon_size = 48
    max_icon_size = 64
    icon_path = /usr/share/icons/Papirus-Dark/48x48/apps/:/usr/share/icons/Papirus-Dark/48x48/status/:/usr/share/icons/Papirus-Dark/48x48/devices/
    
    # History
    sticky_history = yes
    history_length = 20
    
    # Misc
    dmenu = /usr/bin/rofi -dmenu -p dunst
    browser = /usr/bin/xdg-open
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 12
    ignore_dbusclose = false
    
    # Mouse actions
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#565f89"
    timeout = 5
    icon = dialog-information

[urgency_normal]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#7aa2f7"
    timeout = 10
    icon = dialog-information

[urgency_critical]
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#f7768e"
    timeout = 0
    icon = dialog-warning

# Spotify notifications - styled with green accent
[spotify]
    appname = Spotify
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#1db954"
    format = "<b>🎵 Now Playing</b>\n<b>%s</b>\n%b"
    timeout = 5
    icon_position = left
    min_icon_size = 64
    max_icon_size = 64
    script = ~/.config/dunst/scripts/spotify-notify.sh

# Discord notifications - show full message
[discord]
    appname = Discord
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#5865f2"
    format = "<b>%s</b>\n%b"
    timeout = 8
    icon_position = left
    min_icon_size = 48
    max_icon_size = 48
    script = ~/.config/dunst/scripts/discord-notify.sh

# Discord DMs - higher priority
[discord-dm]
    appname = Discord
    summary = "*Direct Message*"
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#eb459e"
    format = "<b>💬 %s</b>\n%b"
    timeout = 10
    urgency = normal

# Discord mentions
[discord-mention]
    appname = Discord
    body = "*@*"
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#faa61a"
    format = "<b>📢 %s</b>\n%b"
    timeout = 10
    urgency = normal

# Volume/brightness notifications
[volume]
    appname = "volume"
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#bb9af7"
    format = "<b>%s</b>\n%b"
    timeout = 2
    history_ignore = yes

[brightness]
    appname = "brightness"
    background = "#1a1b26"
    foreground = "#c0caf5"
    frame_color = "#e0af68"
    format = "<b>%s</b>\n%b"
    timeout = 2
    history_ignore = yes