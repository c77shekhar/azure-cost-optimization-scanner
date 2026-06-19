# ====================================================================
# PROJECT: Azure Automated Cost Optimization & FinOps Scanner
# AUTHOR: c77shekhar (GitHub Portfolio) & Enterprise DevOps Team
# DESIGNED FOR: Azure Automation Runbook (PowerShell 7.2 Engine)
# ====================================================================

Disable-AzContextAutosave -Scope Process | Out-Null

try {
    $AzureContext = (Connect-AzAccount -Identity).Context
    Write-Output "SUCCESS: Authenticated via Managed Identity."
} catch {
    Write-Error "CRITICAL: Managed Identity authentication failed: $_"
    exit
}

# Pull all accessible subscriptions to prevent siloed context execution
$Subscriptions = Get-AzSubscription
$ReportData = [System.Collections.Generic.List[PSCustomObject]]::new()

Write-Output "INFO: Azure Cost Optimization Scan Starting..."

foreach ($Sub in $Subscriptions) {
    Write-Output "INFO: Targeting context for subscription: $($Sub.Name) ($($Sub.Id))"
    $null = Set-AzContext -SubscriptionId $Sub.Id -ErrorAction SilentlyContinue

    # --- Component A: Managed Disks Scan Loop ---
    try {
        $Disks = Get-AzDisk -ErrorAction SilentlyContinue
        if ($null -ne $Disks) {
            foreach ($d in $Disks) {
                if ($null -eq $d.ManagedBy -or $d.DiskState -eq "Unattached") {
                    $ReportData.Add([PSCustomObject]@{
                        Subscription  = $Sub.Name
                        IssueType     = "Unattached Disk"
                        ResourceGroup = $d.ResourceGroupName
                        ResourceName  = $d.Name
                        Details       = "Size: $($d.DiskSizeGB)GB, SKU: $($d.Sku.Name)"
                        Severity      = "High"
                    })
                }
            }
        }
    } catch { Write-Output "WARNING: Disk context execution skipped on Sub $($Sub.Name): $_" }

    # --- Component B: Public IP Interface Scan Loop ---
    try {
        $IPs = Get-AzPublicIpAddress -ErrorAction SilentlyContinue
        if ($null -ne $IPs) {
            foreach ($ip in $IPs) {
                if ($null -eq $ip.IpConfiguration -or $null -eq $ip.IpConfiguration.Id) {
                    $ReportData.Add([PSCustomObject]@{
                        Subscription  = $Sub.Name
                        IssueType     = "Unused Public IP"
                        ResourceGroup = $ip.ResourceGroupName
                        ResourceName  = $ip.Name
                        Details       = "IP Routing Target: $($ip.IpAddress)"
                        Severity      = "Low"
                    })
                }
            }
        }
    } catch { Write-Output "WARNING: Network routing allocation skipped on Sub $($Sub.Name): $_" }

    # --- Component C: Optimized Virtual Machine Compute Check ---
    try {
        # Fetch high-level inventory list first (Lightweight metadata payload)
        $VMs = Get-AzVM -ErrorAction SilentlyContinue
        
        foreach ($BaseVM in $VMs) {
            # Query instance view explicitly per VM to bypass lazy loading and throttling limits
            $VMStatus = Get-AzVM -ResourceGroupName $BaseVM.ResourceGroupName -Name $BaseVM.Name -Status -ErrorAction SilentlyContinue
            
            if ($null -ne $VMStatus) {
                # Target exact Azure API status code objects cleanly
                $PowerState = $VMStatus.Statuses | Where-Object { $_.Code -like "PowerState/*" }
                
                # Check for "PowerState/stopped" (Allocated/Billed). Exclude "PowerState/deallocated" (Unbilled).
                if ($PowerState.Code -eq "PowerState/stopped") {
                    
                    $OSType = "Linux/Windows"
                    if ($null -ne $BaseVM.StorageProfile -and $null -ne $BaseVM.StorageProfile.OsProfile) {
                        $OSType = $BaseVM.StorageProfile.OsProfile.OsType
                    }

                    $ReportData.Add([PSCustomObject]@{
                        Subscription  = $Sub.Name
                        IssueType     = "Stopped VM (Billed)"
                        ResourceGroup = $BaseVM.ResourceGroupName
                        ResourceName  = $BaseVM.Name
                        Details       = "OS: $OSType | Compute state allocated but idle (Cost accumulating)"
                        Severity      = "Medium"
                    })
                }
            }
        }
    } catch { Write-Output "WARNING: VM query execution skipped on Sub $($Sub.Name): $_" }
}

# --- Component D: HTML Report UI Design Frame ---
$Header = @"
<style>
    body { font-family: 'Segoe UI', Arial, sans-serif; margin: 25px; background-color: #fafafa; }
    h2 { color: #0078D4; font-weight: 600; }
    p { color: #555; font-size: 14px; }
    table { border-collapse: collapse; width: 100%; box-shadow: 0 4px 6px rgba(0,0,0,0.05); background-color: #fff; border-radius: 4px; overflow: hidden; }
    th { background-color: #0078D4; color: white; padding: 12px; text-align: left; font-size: 14px; }
    td { border: 1px solid #e2e8f0; padding: 12px; text-align: left; font-size: 13px; }
    tr:nth-child(even) { background-color: #f8fafc; }
    .status-badge { font-weight: bold; border-radius: 4px; padding: 4px 8px; display: inline-block; font-size: 11px; text-transform: uppercase; }
    .High { background-color: #ffeeec; color: #d9383a; border: 1px solid #fcd2d1; }
    .Medium { background-color: #fff7ed; color: #ea580c; border: 1px solid #ffedd5; }
    .Low { background-color: #f0fdf4; color: #16a34a; border: 1px solid #dcfce7; }
</style>
"@
$PreText = "<h2>Azure Cost Optimization Scan Report</h2><p>The following infrastructure assets were identified across your tenant as idle, detached, or stopped without deallocation:</p>"

if ($ReportData.Count -eq 0) {
    $HtmlBody = "$Header <h2>Azure Cost Scan Report</h2><p style='color:#16a34a; font-weight:bold; font-size:16px;'>🎉 Excellent! No infrastructure waste detected in this infrastructure layer.</p>"
} else {
    $HtmlBody = $ReportData | ConvertTo-Html -Head $Header -PreContent $PreText | Out-String
    $HtmlBody = $HtmlBody -replace '<td>High</td>', '<td><span class="status-badge High">🔴 High</span></td>'
    $HtmlBody = $HtmlBody -replace '<td>Medium</td>', '<td><span class="status-badge Medium">🟠 Medium</span></td>'
    $HtmlBody = $HtmlBody -replace '<td>Low</td>', '<td><span class="status-badge Low">🟢 Low</span></td>'
}

$HtmlBody | Out-File "./AzureCostReport.html" -Encoding utf8 -Force

# --- Component E: Extract Variables & Trigger Notification Webhook ---
try {
    $LogicAppURL = Get-AutomationVariable -Name "LogicAppEmailURL" -ErrorAction SilentlyContinue
    if ($null -ne $LogicAppURL -and $LogicAppURL -ne "") {
        $BodyJson = @{ body = $HtmlBody } | ConvertTo-Json
        Invoke-RestMethod -Uri $LogicAppURL -Method Post -Body $BodyJson -ContentType "application/json"
        Write-Output "SUCCESS: Email triggered successfully from the script!"
    } else {
        Write-Output "INFO: LogicAppEmailURL automation variable is empty or unconfigured. Webhook execution skipped."
    }
} catch { Write-Error "ERROR: Notification dispatch pipeline failed: $_" }
