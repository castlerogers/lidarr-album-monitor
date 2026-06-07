# Get configuration from environment variables
$lidarrBaseUrl = $env:LIDARR_BASE_URL.TrimEnd('/')
$apiKey = $env:LIDARR_API_KEY
# Get days to look back with default of 60 if not specified
$daysToLookBack = if ($env:DAYS_TO_LOOK_BACK) { [int]$env:DAYS_TO_LOOK_BACK } else { 60 }

# Construct the API URL
$lidarrApiUrl = "$lidarrBaseUrl/api/v1"

# Validate required environment variables
if (-not $lidarrBaseUrl -or -not $apiKey) {
    Write-Error "Missing required environment variables. Please set LIDARR_BASE_URL and LIDARR_API_KEY."
    exit 1
}

Write-Output "Connecting to Lidarr API at $lidarrApiUrl"
Write-Output "Looking for albums released in the last $daysToLookBack days"

# Use the calendar endpoint so Lidarr filters by release date server-side.
# Fetching /album unfiltered returns the entire library and OOMs on large
# libraries during JSON deserialization. includeArtist embeds the artist on
# each album, so no separate /artist fetch is needed either.
$startDate = (Get-Date).AddDays(-$daysToLookBack).ToString('yyyy-MM-dd')
$endDate = (Get-Date).AddDays(1).ToString('yyyy-MM-dd')   # +1 to catch today across timezones
$calendarUrl = "$lidarrApiUrl/calendar?apikey=$apiKey&start=$startDate&end=$endDate&unmonitored=true&includeArtist=true"

$recentAlbums = Invoke-RestMethod -Uri $calendarUrl -Method Get

$updateAlbumUrl = "$lidarrApiUrl/album/monitor?apikey=$apiKey"

foreach ($album in $recentAlbums) {
    if ($album.monitored) { continue }
    if (($album.artist.monitorNewItems -ne "none") -and ($album.artist.monitored -eq $true)) {
        $albumPs = [PSCustomObject]@{
            albumIds  = @($album.id)
            monitored = $true
        }
        $albumJson = $albumPs | ConvertTo-Json -Depth 2
        Invoke-RestMethod -Uri $updateAlbumUrl -Method Put -Body $albumJson -ContentType "application/json"
    }
}
