#!/bin/bash
# This script runs the PowerShell script at specified intervals

# Default interval if not set (in hours)
INTERVAL_HOURS=${INTERVAL_HOURS:-24}
INTERVAL_SECONDS=$((INTERVAL_HOURS * 3600))

echo "Starting Lidarr Album Monitor"
echo "Script will run every ${INTERVAL_HOURS} hour(s) (${INTERVAL_SECONDS} seconds)"

# Function to run the script and capture output
run_script() {
  echo "$(date): Running Update-LidarrAlbumMonitoring.ps1"
  # Execute the PowerShell script and direct all output to stdout/stderr
  pwsh -File /app/src/Update-LidarrAlbumMonitoring.ps1
  echo "$(date): Completed execution"
}

# Run the script immediately on startup
run_script

# Then run at the specified interval
while true; do
  echo "Waiting ${INTERVAL_HOURS} hour(s) before next execution..."
  sleep $INTERVAL_SECONDS
  run_script
done
