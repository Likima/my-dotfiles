#!/bin/bash

# Toggle AGS media popup

if ags list 2>/dev/null | grep -q "media-popup"; then
    # AGS media-popup instance is running, toggle window visibility
    ags toggle media-popup -i media-popup 2>/dev/null
else
    # Start AGS media popup
    cd ~/.config/ags
    ags run app.tsx 2>/dev/null &
fi
