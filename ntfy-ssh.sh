#!/bin/bash

# NTFY_URL=""
NTFY_TOPIC="server"
# Use ntfy_username and ntfy_password OR ntfy_token
# NTFY_USERNAME=""
# NTFY_PASSWORD=""
# NTFY_TOKEN=""
# Leave empty if you do not want an icon.
NTFY_ICON=""

if [[ -n $NTFY_PASSWORD && -n $NTFY_TOKEN ]]; then
  echo "use NTFY_USERNAME and NTFY_PASSWORD or NTFY_TOKEN"
  exit 1
elif [ -n "$NTFY_PASSWORD" ]; then
  NTFY_BASE64=$(echo -n "$NTFY_USERNAME:$NTFY_PASSWORD" | base64)
  NTFY_AUTH="Authorization: Basic $NTFY_BASE64"
elif [ -n "$NTFY_TOKEN" ]; then
  NTFY_AUTH="Authorization: Bearer $NTFY_TOKEN"
else
  NTFY_AUTH=""
fi

if [ "${PAM_TYPE}" = "open_session" ]; then
  NTFY_TAG=warning
  NTFY_PRIORITY=5
  NTFY_TITLE="SSH login"
  NTFY_MESSAGE="${PAM_USER} from ${PAM_RHOST}"
fi

NTFY_POST_DATA() {
  cat <<EOF
{
  "topic": "$NTFY_TOPIC",
  "tags": ["$NTFY_TAG"],
  "priority": $NTFY_PRIORITY,
  "icon": "$NTFY_ICON",
  "title": "$NTFY_TITLE",
  "message": "$NTFY_MESSAGE"
}
EOF
}

curl -H "Accept: application/json" \
  -H "Content-Type:application/json" \
  -H "$NTFY_AUTH" -X POST --data "$(NTFY_POST_DATA)" "$NTFY_URL"
