[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$logPath = "$PSScriptRoot\he.net-ddns.log"
$fileName = "he.net-ddns.log"

if (!(Test-Path $logPath)) {
  New-Item -ItemType File -Path $PSScriptRoot -Name ($fileName) 
}

Clear-Content $logPath
$DATE = Get-Date -UFormat "%Y/%m/%d %H:%M:%S"
Write-Output "==> $DATE" | Tee-Object $logPath -Append

### Loads configuration file
Try {
  . $PSScriptRoot\he.net-ddns.conf.ps1
}
Catch {
  Write-Output "he.net-ddns.conf.ps1 is missing or contains invalid syntax" | Tee-Object $logPath -Append
  Exit
}

### Check ipType parameter
if (($ipType -ne "private") -and ($ipType -ne "public")) {
  Write-Output 'Error! Incorrect "ipType" parameter choose either "private" or "public"' | Tee-Object $logPath -Append
  Exit
}

### Get private ip from primary interface
if ($ipType -eq 'private'){
  $ip = $((Find-NetRoute -RemoteIPAddress 1.1.1.1).IPAddress|out-string).Trim()
  if (!([bool]$ip) -or ($ip -eq "127.0.0.1")) {
    Write-Output "Error! Can't get private ip address" | Tee-Object $logPath -Append
    Exit
  }
  Write-Output "Private ip is $ip" | Tee-Object $logPath -Append
}

### Get public ipv from seeip.org
if ($ipType -eq 'public'){
  $ip = (Invoke-RestMethod -Uri "https://ipv4.seeip.org" -TimeoutSec 10).Trim() 
  if (!([bool]$ip)) {
    Write-Output "Error! Can't get public ipv4 address" | Tee-Object $logPath -Append
    Exit
  }
  Write-Output "Public ip is: $ip" | Tee-Object $logPath -Append
}

### Get current ipv4 address
$dnsIp= (Resolve-DnsName -DnsOnly -Name $hostname -Server ns1.he.net -Type A | Select-Object -First 1).IPAddress.Trim()
if (![bool]$dnsIP) {
  Write-Output "Error! Can't resolve $hostname via ns1.he.net" | Tee-Object $logPath -Append
  Exit
}

### Check if ip has changed
if ($dnsIp -eq $ip) {
  Write-Output "DNS record of $hostname is $dnsIp, no changes needed. Exiting..." | Tee-Object $logPath -Append
  Exit
}

Write-Output "DNS record of $dns_record is: $dnsIp. Trying to update..." | Tee-Object $logPath -Append

### Update DNS records
$updateDNS = @{
  Uri     = "https://dyn.dns.he.net/nic/update"
  Method  = 'POST'
  Body    = @{
    "hostname" = $hostname
    "password" = $key
    "myip"     = $ip
  }
}

$updateResponse = Invoke-RestMethod @updateDNS
if ($updateResponse -ne "good $ip") {
  Write-Output "Error! Update Failed $updateResponse" | Tee-Object $logPath -Append
  Exit
}

Write-Output "==> Success!" | Tee-Object $logPath -Append
Write-Output "==> $hostname DNS Record Updated To: $ip" | Tee-Object $logPath -Append
