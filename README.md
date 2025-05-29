# Lidarr Album Monitoring

This project provides tools to automatically set monitoring for Lidarr albums released in the last 60 days (configurable).

## Background

This script was created as a workaround for a known issue in Lidarr where the "monitor new albums" feature is not working correctly ([Lidarr issue #3778](https://github.com/Lidarr/Lidarr/issues/3778)). When you have "download monitored albums" selected and "monitor" set to "new albums", Lidarr will add new albums to the artist's page, but it fails to actually monitor them. As a result, new releases are not being automatically downloaded when they become available.

This script addresses this bug by periodically checking for albums released within a configurable time period and ensuring they're properly set to monitored, allowing Lidarr to download them as intended.

## Usage

### Docker

```bash
docker build -t lidarr-album-monitor .

docker run -e LIDARR_BASE_URL="https://your-lidarr-instance" \
           -e LIDARR_API_KEY="your-api-key" \
           -e DAYS_TO_LOOK_BACK="60" \
           lidarr-album-monitor
```

### Using Docker Compose

1. Create your environment file:
   ```bash
   # Copy the template file
   cp .env.template .env
   
   # Edit the .env file with your Lidarr details
   # Replace placeholder values with your actual configuration
   ```

2. Run the container:
   ```bash
   docker-compose up
   ```

### Environment Variables

**Required Variables**:

- `LIDARR_BASE_URL`: Your Lidarr base URL (e.g., "https://lidarr.example.com") - do not include "/api/v1" as it will be added automatically
- `LIDARR_API_KEY`: Your Lidarr API key

**Optional Variables**:

- `DAYS_TO_LOOK_BACK`: Number of days to look back for recent album releases (default: 60)

## How It Works

The script uses the Lidarr API to:

1. Fetch all albums in your library
2. Filter to find albums released within the specified time period (default: last 60 days)
3. Set these albums' "monitored" status to true
4. Update the albums via the API

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

## Releases and Docker Images

Docker images are automatically built and published to GitHub Container Registry with semantic versioning:

- `ghcr.io/OWNER/lidarr-album-monitor:latest` - Latest release version
- `ghcr.io/OWNER/lidarr-album-monitor:1.2.3` - Specific version
- `ghcr.io/OWNER/lidarr-album-monitor:1.2` - Latest patch version of 1.2.x
- `ghcr.io/OWNER/lidarr-album-monitor:1` - Latest minor and patch version of 1.x.x

To create a new release:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Create Release" workflow
3. Click "Run workflow"
4. Enter the version number (without the 'v' prefix, e.g., "1.2.3")
5. Optionally mark it as a pre-release
6. Click "Run workflow"

This will:
1. Create a git tag (e.g., v1.2.3)
2. Create a GitHub Release
3. Trigger the Docker build workflow automatically

Images will be available at `ghcr.io/OWNER/lidarr-album-monitor` shortly after the release is created.

## References

- [Lidarr Issue #3778: Monitor New Albums :: No longer working](https://github.com/Lidarr/Lidarr/issues/3778)
- This implementation is based on the workaround discussed in the issue

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
