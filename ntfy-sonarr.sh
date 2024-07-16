#!/bin/bash

# NTFY_URL=""
# NTFY_TOPIC=""
# # Use ntfy_username and ntfy_password OR ntfy_token
# NTFY_USERNAME=""
# NTFY_PASSWORD=""
# NTFY_TOKEN=""
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

if [ "$sonarr_eventtype" == "Test" ]; then
  NTFY_TAG=information_source
  NTFY_TITLE="Testing"
elif [ "$sonarr_eventtype" == "Grab" ]; then
  NTFY_TAG=inbox_tray
  NTFY_TITLE="$sonarr_series_title - $sonarr_episodefile_episodetitles (S$sonarr_release_seasonnumber E$sonarr_release_episodenumbers)"
elif [ "$sonarr_eventtype" == "Download" ]; then
  NTFY_TAG=white_check_mark
  NTFY_TITLE="$sonarr_series_title - $sonarr_episodefile_episodetitles (S$sonarr_episodefile_seasonnumber E$sonarr_episodefile_episodenumbers)"
  NTFY_MESSAGE="[$sonarr_episodefile_quality]"
elif [ "$sonarr_eventtype" == "HealthIssue" ]; then
  NTFY_TAG=warning
  NTFY_TITLE="[$sonarr_health_issue_level]"
  NTFY_MESSAGE="$sonarr_health_issue_message"
else
  NTFY_TAG=information_source
  NTFY_TITLE="$sonarr_series_title - $sonarr_episodefile_episodetitles (S$sonarr_episodefile_seasonnumber E$sonarr_episodefile_episodenumbers)"
fi

if [ "$sonarr_eventtype" == "Download" ]; then
NTFY_POST_DATA()
{
  cat <<EOF
{
  "topic": "$NTFY_TOPIC",
  "tags": ["$NTFY_TAG"],
  "icon": "$NTFY_ICON",
  "title": "Sonarr: $sonarr_eventtype",
  "message": "$NTFY_TITLE $NTFY_MESSAGE",
  "actions": [
    {
      "action": "view",
      "label": "TVDB",
      "url": "https://www.thetvdb.com/?id=$sonarr_series_tvdbid&tab=series",
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
  "title": "Sonarr: $sonarr_eventtype",
  "message": "$NTFY_TITLE $NTFY_MESSAGE"
}
EOF
}
fi

curl -H "Accept: application/json" \
     -H "Content-Type:application/json" \
     -H "$NTFY_AUTH" -X POST --data "$(NTFY_POST_DATA)" "$NTFY_URL"
