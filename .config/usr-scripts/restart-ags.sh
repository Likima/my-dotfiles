#!/bin/bash

# Restart AGS media popup
ags quit -i media-popup 2>/dev/null
sleep 0.2
cd ~/.config/ags
ags run app.tsx 2>/dev/null &
