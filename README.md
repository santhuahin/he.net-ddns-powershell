# Hurricane Electric (he.net) DDNS Powershell Script
- Inspired by and a modification of https://github.com/fire1ce/DDNS-Cloudflare-PowerShell
- [dns.he.net](https://dns.he.net/) DDNS PowerShell script for **Windows**.
- Choose any source IP address to update **private** or **public**.
- For multiple LAN interfaces, script will automatically detect primary Interface.

## Requirements

- dns.he.net DDNS key
- DNS Record must be pre-created
- Enable running unsigned PowerShell

## Limitations

- Does not support IPv6 at this time (contributions to add IPv6 support welcome)

## Installation

[Download .zip from latest release](https://github.com/santhuahin/he.net-ddns-powershell/releases) and Unzip

## Config Parameters

Update the config parameters inside he.net-ddns.conf.ps1 by editing accordingly. See below for examples.

| **Option**                | **Example**      | **Description**                                           |
| ------------------------- | ---------------- | --------------------------------------------------------- |
| ipType                    | private          | Which ip should be used for the record: private/public    |
| hostname                  | ddns.example.com | DNS **A** record which will be updated                    |
| key                       | put_key_here     | he.net DDNS key                                           |

## Running The Script

Open cmd/powershell

```
powershell.exe -ExecutionPolicy Bypass -File $PATH TO SCRIPT
```

## Automation Using Windows Task Scheduler

Example:
Run at boot after 1 minute delay and repeat every minute

- Open Task Scheduler
- Action -> Crate Task
- **General**
  - Name: 
  - Run whether user is logged on or not
- **Trigger**
  - New...
  - Begin the task: At startup
  - Delay task for: 1 minute
  - Repeat task every: 1 minute
  - for duration of: indefinitely
  - Enabled
- **Actions**
  - New...
  - Action: Start a Program
  - Program/script: _C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe_
  - Add arguments: _-ExecutionPolicy Bypass -File $PATH TO SCRIPT_
  - Enter password when prompted
## Logs

This Script will create a log file with information from the last run  **only**  
Log file will be located in same directory as the script
