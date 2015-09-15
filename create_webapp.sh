#!/bin/bash
# Create a shortcut for a web app.
# Donie Leigh <donie.leigh@gmail.com>

APP_DIR="$HOME/bin"
APP_NAME=`zenity --entry \
    --title="Input App Name" \
    --text="Enter name of the app:" \
    --entry-text "sample"`
APP_URL=`zenity --entry \
    --title="Input App URL" \
    --text="Enter URL of the app:" \
    --entry-text "sample"`
APP_FILE="$APP_DIR/$APP_NAME"

die()
{
    echo "$@" >&2 && exit 1
}

! [[ "$APP_NAME" =~ ^[a-zA-Z0-9_]+$ ]] && die "Invalid app name, only letters, numbers and _ are allowed."
[ -e "$APP_DIR/$APP_NAME" ] && die "An app with the same name already exists."

SCRIPT=$(cat <<TEMPLATE
#!/bin/bash

source .app.lib
launch_web_app $APP_URL &
TEMPLATE
)

echo "$SCRIPT" > "$APP_FILE" && chmod 755 "$APP_FILE"
