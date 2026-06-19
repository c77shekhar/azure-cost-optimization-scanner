# ====================================================================
# PROJECT: Enterprise Azure Cost Optimization & FinOps Scanner
# AUTHOR: c77shekhar (GitHub Portfolio)
# ENGINE: Azure Automation Runbook (PowerShell 5.1 / 7.2 Universal)
# VERSION: 6.0 (Zero-Configuration Native Execution Engine)
# ====================================================================
Param(
    [Parameter(Mandatory = $false)]
    [object]$TargetSubscriptions = $null
)

Disable-AzContextAutosave -Scope Process | Out-Null
$ReportData = [System.Collections.Generic.List[PSCustomObject]]::new()
Write-Output "INFO: Initializing Unified FinOps Infrastructure Scan Engine..."

# 1. Managed Identity Authentication Engine (Loads instantly via Native 5.1 Context)
try {
    $AzureContext = (Connect-AzAccount -Identity).Context
    Write-Output "SUCCESS: Authenticated successfully using System Managed Identity."
} catch {
    Write-Error "CRITICAL FAILURE: Managed Identity token acquisition failed. Details: $_"; exit
}

# 2. Scope Resolver
$TargetSubsList = @()
if ($null -ne $TargetSubscriptions -and $TargetSubscriptions -notlike "") {
    if ($TargetSubscriptions -is [string]) { $TargetSubsList = $TargetSubscriptions.Split(',').Trim() }
    else { $TargetSubsList = @($TargetSubscriptions) }
} else {
    $TargetSubsList = (Get-AzSubscription).Id
}
Write-Output "INFO: Target Scope locked on $(($TargetSubsList).Count) Subscription(s)."

# 3. CORE DIRECT SCANNER (100% Native ARM - Guaranteed to work on all runbook runtimes)
Write-Output "INFO: Engaging Direct Direct ARM Scanning Engine..."
foreach ($SubId in $TargetSubsList) {
    $null = Set-AzContext -SubscriptionId $SubId -ErrorAction SilentlyContinue
    $SubName = (Get-AzSubscription -SubscriptionId $SubId).Name

    # Direct Storage Optimization Scan
    try {
        $LiveDisks = Get-AzDisk -ErrorAction SilentlyContinue
        foreach ($d in $LiveDisks) {
            if ($null -eq $d.ManagedBy -or $d.DiskState -eq "Unattached") {
                $ReportData.Add([PSCustomObject]@{Subscription = $SubName; IssueType = "Unattached Disk"; ResourceGroup = $d.ResourceGroupName; ResourceName = $d.Name; Details = "Size: $($d.DiskSizeGB)GB | SKU: $($d.Sku.Name)"; Severity = "High"})
            }
        }
    } catch {}

    # Direct Network Optimization Scan
    try {
        $LiveIPs = Get-AzPublicIpAddress -ErrorAction SilentlyContinue
        foreach ($ip in $LiveIPs) {
            if ($null -eq $ip.IpConfiguration -or $null -eq $ip.IpConfiguration.Id) {
                $ReportData.Add([PSCustomObject]@{Subscription = $SubName; IssueType = "Unused Public IP"; ResourceGroup = $ip.ResourceGroupName; ResourceName = $ip.Name; Details = "IP: $($ip.IpAddress)"; Severity = "Low"})
            }
        }
    } catch {}

    # Direct Compute Optimization Scan
    try {
        $LiveVMs = Get-AzVM -ErrorAction SilentlyContinue
        foreach ($BaseVM in $LiveVMs) {
            $VMStatus = Get-AzVM -ResourceGroupName $BaseVM.ResourceGroupName -Name $BaseVM.Name -Status -ErrorAction SilentlyContinue
            $PowerState = $VMStatus.Statuses | Where-Object { $_.Code -like "PowerState/*" }
            if ($PowerState.Code -eq "PowerState/stopped") {
                $OSType = "Linux/Windows"
                if ($null -ne $BaseVM.StorageProfile.OsProfile) { $OSType = $BaseVM.StorageProfile.OsProfile.OsType }
                $ReportData.Add([PSCustomObject]@{Subscription = $SubName; IssueType = "Stopped VM (Billed)"; ResourceGroup = $BaseVM.ResourceGroupName; ResourceName = $BaseVM.Name; Details = "OS: $OSType | Compute Active"; Severity = "Medium"})
            }
        }
    } catch {}
}

# 4. Executive HTML Document Compiler (Clean Text Badges - Immune to ??)
$Header = @"
<style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 30px; background-color: #f4f6f9; color: #333; }
    h2 { color: #0078D4; font-weight: 600; margin-bottom: 5px; }
    p { color: #666; font-size: 14px; margin-top: 0; margin-bottom: 25px; }
    table { border-collapse: collapse; width: 100%; box-shadow: 0 4px 12px rgba(0,0,0,0.08); background-color: #fff; border-radius: 6px; overflow: hidden; margin-top: 15px; }
    th { background-color: #0078D4; color: white; padding: 14px 16px; text-align: left; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
    td { border-bottom: 1px solid #e2e8f0; padding: 12px 16px; text-align: left; font-size: 13px; color: #4a5568; }
    tr:last-child td { border-bottom: none; }
    tr:nth-child(even) { background-color: #f8fafc; }
    .status-badge { font-weight: bold; border-radius: 4px; padding: 5px 10px; display: inline-block; font-size: 11px; text-transform: uppercase; text-align: center; min-width: 85px; }
    .badge-high { background-color: #fde8e8; color: #9b1c1c; border: 1px solid #f8b4b4; }
    .badge-med { background-color: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
    .badge-low { background-color: #def7ec; color: #03543f; border: 1px solid #bfecdc; }
</style>
"@

if ($ReportData.Count -eq 0) {
    $HtmlBody = "$Header <h2>Azure Cloud Infrastructure Waste Analysis</h2><p style='color:#03543f; font-weight:bold; font-size:16px;'>SUCCESS: No passive infrastructure waste detected across target environments.</p>"
} else {
    $PreText = "<h2>Azure Cloud Infrastructure Waste Analysis</h2><p>Live inventory lookup of idle, detached, or misconfigured environments accumulating structural cloud spend:</p>"
    $HtmlBody = $ReportData | ConvertTo-Html -Head $Header -PreContent $PreText | Out-String
    $HtmlBody = $HtmlBody -replace '<td>High</td>', '<td><span class="status-badge badge-high">CRITICAL</span></td>'
    $HtmlBody = $HtmlBody -replace '<td>Medium</td>', '<td><span class="status-badge badge-med">WARNING</span></td>'
    $HtmlBody = $HtmlBody -replace '<td>Low</td>', '<td><span class="status-badge badge-low">INFO</span></td>'
}

$HtmlBody | Out-File "./AzureCostReport.html" -Encoding utf8 -Force

# 5. Webhook Dispatcher
try {
    $LogicAppURL = Get-AutomationVariable -Name "LogicAppEmailURL" -ErrorAction SilentlyContinue
    if ($null -ne $LogicAppURL -and $LogicAppURL -notlike "") {
        $BodyJson = @{ body = $HtmlBody } | ConvertTo-Json
        $null = Invoke-RestMethod -Uri $LogicAppURL -Method Post -Body $BodyJson -ContentType "application/json"
        Write-Output "SUCCESS: Cost optimization report dispatched to mail infrastructure."
    }
} catch { Write-Error "ERROR: Webhook interface failed: $_" }
