FROM mcr.microsoft.com/powershell:lts-7.4-ubuntu-22.04

# Set working directory
WORKDIR /app

# Copy the module and script to the container
COPY src/ ./src/

# Make the wrapper script executable
RUN chmod +x /app/src/run-with-interval.sh

# Set the wrapper script as the entrypoint
ENTRYPOINT ["/app/src/run-with-interval.sh"]
