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

$albumsUrl = "$lidarrApiUrl/album?apikey=$apiKey"
$artistsUrl = "$lidarrApiUrl/artist?apikey=$apiKey"

$artistsResponse = Invoke-RestMethod -Uri $artistsUrl -Method Get
$albumResponse = Invoke-RestMethod -Uri $albumsUrl -Method Get
$nextAlbum = $albumResponse | Where-Object { 
    $_.ReleaseDate -and (Get-Date $_.ReleaseDate) -gt (Get-Date).AddDays(-$daysToLookBack)
}

$updateAlbumUrl = "$lidarrApiUrl/album/monitor?apikey=$apiKey"

foreach ($album in $nextAlbum) {
    $albumPs = [PSCustomObject]@{
        albumIds  = @($album.id)
        monitored = $true
    }
    $albumJson = $albumPs | ConvertTo-Json -Depth 2
    $artistMatch = $artistsResponse | Where-Object { $_.id -eq $album.artist.id }
    if (($artistMatch.monitorNewItems -ne "none") -and ($artistMatch.monitored -eq $true)) {
        Invoke-RestMethod -Uri $updateAlbumUrl -Method Put -Body $albumJson -ContentType "application/json"
    }
}
