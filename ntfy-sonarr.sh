#!/bin/bash

NTFY_URL=""
NTFY_TOPIC=""
# Use ntfy_username and ntfy_password OR ntfy_token
NTFY_USERNAME=""
NTFY_PASSWORD=""
NTFY_TOKEN=""
# Leave empty if you do not want an icon.
NTFY_ICON="https://raw.githubusercontent.com/Sonarr/Sonarr/develop/Logo/48.png"

if [[ -n $NTFY_PASSWORD && -n $NTFY_TOKEN ]]; then
  echo "use NTFY_USERNAME and NTFY_PASSWORD or NTFY_TOKEN"
  exit 1
elif [ -n "$NTFY_PASSWORD" ]; then
  NTFY_BASE64=$( echo -n "$NTFY_USERNAME:$NTFY_PASSWORD" | base64 )
  NTFY_AUTH="Authorization: Basic $NTFY_BASE64"
elif [ -n "$NTFY_TOKEN" ]; then
  NTFY_AUTH="Authorization: Bearer $NTFY_TOKEN"
else
  NTFY_AUTH=""
fi

if [ "$SONARR_EVENTTYPE" == "Test" ]; then
  NTFY_TAG=information_source
  NTFY_TITLE="Testing"
elif [ "$SONARR_EVENTTYPE" == "Grab" ]; then
  NTFY_TAG=inbox_tray
  NTFY_TITLE="$SONARR_SERIES_TITLE - sonarr_episodefile_episodetitles (S$SONARR_RELEASE_SEASONNUMBER E$SONARR_RELEASE_EPISODENUMBERS)"
elif [ "$SONARR_EVENTTYPE" == "Download" ]; then
  NTFY_TAG=white_check_mark
  NTFY_TITLE="$SONARR_SERIES_TITLE - sonarr_episodefile_episodetitles (S$SONARR_EPISODEFILE_SEASONNUMBER E$SONARR_EPISODEFILE_EPISODENUMBERS)"
  NTFY_MESSAGE="[$SONARR_EPISODEFILE_QUALITY]"
elif [ "$SONARR_EVENTTYPE" == "HealthIssue" ]; then
  NTFY_TAG=warning
  NTFY_TITLE="[$SONARR_HEALTH_ISSUE_LEVEL]"
  NTFY_MESSAGE="$SONARR_HEALTH_ISSUE_MESSAGE"
else
  NTFY_TAG=information_source
  NTFY_TITLE="$SONARR_SERIES_TITLE - sonarr_episodefile_episodetitles (S$SONARR_EPISODEFILE_SEASONNUMBER E$SONARR_EPISODEFILE_EPISODENUMBERS)"
fi

if [ "$SONARR_EVENTTYPE" == "Download" ]; then
NTFY_POST_DATA()
{
  cat <<EOF
{
  "topic": "$NTFY_TOPIC",
  "tags": ["$NTFY_TAG"],
  "icon": "$NTFY_ICON",
  "title": "Sonarr: $SONARR_EVENTTYPE",
  "message": "$NTFY_TITLE $NTFY_MESSAGE",
  "actions": [
    {
      "action": "view",
      "label": "TVDB",
      "url": "https://www.thetvdb.com/?id=$SONARR_SERIES_TVDBID&tab=series",
      "clear": true
    }
  ]
}
EOF
}
else
NTFY_POST_DATA()
{
  cat <<EOF
{
  "topic": "$NTFY_TOPIC",
  "tags": ["$NTFY_TAG"],
  "icon": "$NTFY_ICON",
  "title": "Sonarr: $SONARR_EVENTTYPE",
  "message": "$NTFY_TITLE $NTFY_MESSAGE"
}
EOF
}
fi

curl -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -H "$NTFY_AUTH" -X POST --data "$(NTFY_POST_DATA)" "$NTFY_URL"
