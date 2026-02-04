#!/bin/bash
# This script is called by dunst when a Discord notification arrives
# It ensures the message body is properly displayed

# The notification details are passed as environment variables by dunst
# DUNST_APP_NAME, DUNST_SUMMARY, DUNST_BODY, DUNST_ICON_PATH, DUNST_URGENCY

# Log for debugging (optional)
# echo "Discord notification: $DUNST_SUMMARY - $DUNST_BODY" >> /tmp/discord-notify.log

# Play notification sound (optional)
# paplay /usr/share/sounds/freedesktop/stereo/message.oga &

exit 0