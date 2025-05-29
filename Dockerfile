FROM mcr.microsoft.com/powershell:lts-7.4-ubuntu-22.04

# Set working directory
WORKDIR /app

# Copy the module and script to the container
COPY src/ ./src/

# Set the script as the entrypoint
ENTRYPOINT ["pwsh", "-File", "src/Update-LidarrAlbumMonitoring.ps1"]
