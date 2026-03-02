# =========================================================================================
# MICRO-HONEYPOT & THREAT INTEL LOGGER
# Description: Autonomous PowerShell script to monitor failed RDP attempts (Event ID 4625),
#              extract attacker IP, fetch geolocation data, and log it for ML datasets.
# Features:    In-memory Caching (API Limit Protection), Event RecordID Tracking.
# =========================================================================================

# 1. CONFIGURATION (AYARLAR)
# DİKKAT: Kendi ipgeolocation.io API anahtarınızı buraya girin!
$API_KEY      = "<YOUR_API_KEY_HERE>" 
$LOGFILE_PATH = "$env:ProgramData\failed_rdp_dataset.log"

if ((Test-Path $LOGFILE_PATH) -eq $false) { New-Item -ItemType File -Path $LOGFILE_PATH | Out-Null }

# 2. MEMORY & CACHE SYSTEMS (HAFIZA SİSTEMLERİ)
$ipCache = @{}           # To protect API limits (IP -> Geolocation mapping)
$processedEvents = @{}   # To prevent logging the same Event RecordID twice

Write-Host "[+] Comprehensive Threat Hunter Initialized! (Logging all attack frequencies)" -ForegroundColor Cyan

# 3. MAIN LISTENER LOOP (ANA DÖNGÜ)
while ($true) {
    # Listen to the last 50 failed RDP attempts
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 50 -ErrorAction SilentlyContinue

    foreach ($event in $events) {
        $recordId = $event.RecordId
        
        # Duplication Protection: Skip if already processed
        if ($processedEvents.ContainsKey($recordId)) { continue }
        
        # Mark as processed
        $processedEvents[$recordId] = $true

        [xml]$xmlEvent = $event.ToXml()
        $ipAddress = $xmlEvent.Event.EventData.Data | Where-Object {$_.Name -eq "IpAddress"} | Select-Object -ExpandProperty '#text'
        $username = $xmlEvent.Event.EventData.Data | Where-Object {$_.Name -eq "TargetUserName"} | Select-Object -ExpandProperty '#text'

        # Filter out local and loopback IPs
        if ($ipAddress -ne $null -and $ipAddress -ne "-" -and $ipAddress -notmatch "^192\.168\.|^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^127\.|^::1") {

            # INNOVATION: Check Memory Cache before hitting the API
            if (-not $ipCache.ContainsKey($ipAddress)) {
                Write-Host "[!] New Attacker Detected, Fetching Intel: $ipAddress" -ForegroundColor Yellow
                try {
                    $apiUrl = "https://api.ipgeolocation.io/ipgeo?apiKey=$API_KEY&ip=$ipAddress"
                    $response = Invoke-RestMethod -Uri $apiUrl -Method Get
                    
                    # Store data in RAM
                    $ipCache[$ipAddress] = @{
                        latitude = $response.latitude
                        longitude = $response.longitude
                        state = $response.state_prov
                        country = $response.country_name
                        label = $response.country_name
                    }
                } catch {
                    Write-Host "[-] API Limit Reached! Caching IP without labels: $ipAddress" -ForegroundColor Red
                    $ipCache[$ipAddress] = @{
                        latitude = 0; longitude = 0; state = "API_Limit"; country = "API_Limit"; label = "API_Limit"
                    }
                }
            }

            # Fetch coordinates from Cache and format the log line
            $geoData = $ipCache[$ipAddress]
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            
            $logLine = "latitude:$($geoData.latitude),longitude:$($geoData.longitude),destinationhost:$($env:computername),username:$username,sourcehost:$ipAddress,state:$($geoData.state),country:$($geoData.country),label:$($geoData.label),timestamp:$timestamp"
            
            Add-Content -Path $LOGFILE_PATH -Value $logLine
            Write-Host "[+] ATTACK LOGGED: $ipAddress (Target User: $username)" -ForegroundColor Green
        }
    }
    Start-Sleep -Seconds 5
}