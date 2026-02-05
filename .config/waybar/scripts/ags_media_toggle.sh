#!/bin/bash

# Toggle AGS media popup

if ags list 2>/dev/null | grep -q "media-popup"; then
    # AGS is running, toggle the window
    ags toggle media-popup -i media-popup
else
    # Start AGS media popup
    cd ~/.config/ags
    ags run app.tsx &
    sleep 0.5
fi