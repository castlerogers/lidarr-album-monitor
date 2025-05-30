# Lidarr Album Monitoring

This project provides tools to automatically set monitoring for Lidarr albums released in the last 60 days (configurable).

## Background

This script was created as a workaround for a known issue in Lidarr where the "monitor new albums" feature is not working correctly ([Lidarr issue #3778](https://github.com/Lidarr/Lidarr/issues/3778)). When you have "download monitored albums" selected and "monitor" set to "new albums", Lidarr will add new albums to the artist's page, but it fails to actually monitor them. As a result, new releases are not being automatically downloaded when they become available.

This script addresses this bug by periodically checking for albums released within a configurable time period and ensuring they're properly set to monitored, allowing Lidarr to download them as intended.

## Usage

### Docker Run

```bash
docker run -e LIDARR_BASE_URL="https://your-lidarr-instance" \
           -e LIDARR_API_KEY="your-api-key" \
           -e DAYS_TO_LOOK_BACK="60" \
           -e INTERVAL_HOURS="24" \
           lidarr-album-monitor
```

### Docker Compose


```yaml
services:
  lidarr-album-monitor:
    image: ghcr.io/castlerogers/lidarr-album-monitor:latest
    container_name: lidarr-album-monitor
    environment:
      - LIDARR_BASE_URL=https://lidarr.example.com  # Your Lidarr base URL (don't include "/api/v1")
      - LIDARR_API_KEY=your-api-key                 # Your Lidarr API key
      - DAYS_TO_LOOK_BACK=60                        # Optional: Days to look back for recent releases
      - INTERVAL_HOURS=24                           # Optional: Hours between script executions
    restart: unless-stopped
```

## How It Works

The script uses the Lidarr API to:

1. Fetch all albums in your library
2. Filter to find albums released within the specified time period (default: last 60 days)
3. Set these albums' "monitored" status to true
4. Update the albums via the API
5. When run in Docker, the script can be configured to execute at regular intervals (default: every 24 hours)

This effectively works around the Lidarr issue where newly added albums aren't being properly monitored despite having the "monitor new albums" setting enabled.

## Development

This project includes a development container configuration for VS Code. To use it:

1. Install the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
2. Set up your development environment variables:
   ```bash
   # Copy the template file
   cp .devcontainer/devcontainer.env.template .devcontainer/devcontainer.env
   
   # Edit the file with your Lidarr instance details
   ```
3. Open the project folder in VS Code
4. Click "Reopen in Container" when prompted, or run the "Remote-Containers: Reopen in Container" command

## References

- [Lidarr Issue #3778: Monitor New Albums :: No longer working](https://github.com/Lidarr/Lidarr/issues/3778)
- Many thanks to @aevrard and @bjaudon for the framework for the script!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
