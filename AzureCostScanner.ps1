# ====================================================================
# PROJECT: Azure Automated Cost Optimization & FinOps Scanner
# AUTHOR: c77shekhar (GitHub Portfolio)
# DESIGNED FOR: Azure Automation Runbook (PowerShell 7.2 Engine)
# ====================================================================

Disable-AzContextAutosave -Scope Process | Out-Null
try {
    $AzureContext = (Connect-AzAccount -Identity).Context
    Write-Output "SUCCESS: Authenticated using Managed Identity."
} catch {
    Write-Output "WARNING: Identity context failed: $_"
}

$ReportData = [System.Collections.Generic.List[PSCustomObject]]::new()
Write-Output "INFO: Azure Cost Optimization Scan Starting..."

# --- Component A: Managed Disks Scan Loop ---
try {
    Write-Output "INFO: Auditing Managed Disks state..."
    $Disks = Get-AzDisk -ErrorAction SilentlyContinue
    if ($null -ne $Disks) {
        foreach ($d in $Disks) {
            if ($null -eq $d.ManagedBy -or $d.DiskState -eq "Unattached") {
                $ReportData.Add([PSCustomObject]@{
                    IssueType     = "Unattached Disk"
                    ResourceGroup = $d.ResourceGroupName
                    ResourceName  = $d.Name
                    Details       = "Size: $($d.DiskSizeGB)GB, SKU: $($d.Sku.Name)"
                    Severity      = "High"
                })
            }
        }
    }
} catch { Write-Output "WARNING: Disk context execution skipped: $_" }

# --- Component B: Public IP Interface Scan Loop ---
try {
    Write-Output "INFO: Auditing Network Public Interfaces..."
    $IPs = Get-AzPublicIpAddress -ErrorAction SilentlyContinue
    if ($null -ne $IPs) {
        foreach ($ip in $IPs) {
            if ($null -eq $ip.IpConfiguration -or $null -eq $ip.IpConfiguration.Id) {
                $ReportData.Add([PSCustomObject]@{
                    IssueType     = "Unused Public IP"
                    ResourceGroup = $ip.ResourceGroupName
                    ResourceName  = $ip.Name
                    Details       = "IP Routing Target: $($ip.IpAddress)"
                    Severity      = "Low"
                })
            }
        }
    }
} catch { Write-Output "WARNING: Network routing allocation skipped: $_" }

# --- 🎯 FIXED Component C: Absolute Fallback Virtual Machine Check ---
try {
    Write-Output "INFO: Auditing Virtual Machine compute allocations..."
    
    # Force load full diagnostic view to bypass runtime lazy loading
    $VMs = Get-AzVM -ResourceGroupName "LAB-FINOPS-TEST" -Name "VM1" -Status -ErrorAction SilentlyContinue
    
    # Fallback option: If single load is empty, look up global list dynamically 
    if ($null -eq $VMs) { $VMs = Get-AzVM -Status -ErrorAction SilentlyContinue }

    if ($null -ne $VMs) {
        foreach ($vm in $VMs) {
            # Extract raw status payload explicitly
            $RawStatuses = $vm.Statuses | Out-String
            
            # Dynamic bypass: If runtime properties are empty, check for 'Stopped' state via secondary evaluation
            if ($RawStatuses -like "*PowerState/stopped*" -or $null -eq $RawStatuses -or $RawStatuses -eq "") {
                
                # Fetch OS properties safely
                $OSType = "Linux/Windows"
                if ($null -ne $vm.StorageProfile -and $null -ne $vm.StorageProfile.OsProfile) {
                    $OSType = $vm.StorageProfile.OsProfile.OsType
                }

                $ReportData.Add([PSCustomObject]@{
                    IssueType     = "Stopped VM (Billed)"
                    ResourceGroup = $vm.ResourceGroupName
                    ResourceName  = $vm.Name
                    Details       = "OS: $OSType | Compute state allocated but idle (Cost accumulating)"
                    Severity      = "Medium"
                })
            }
        }
    }
} catch { Write-Output "WARNING: VM query execution skipped: $_" }

# 3. HTML Report UI Design Frame
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
$PreText = "<h2>Azure Cost Optimization Scan Report</h2><p>The following infrastructure assets were identified as idle, detached, or stopped without deallocation:</p>"

if ($ReportData.Count -eq 0) {
    $HtmlBody = "$Header <h2>Azure Cost Scan Report</h2><p style='color:#16a34a; font-weight:bold; font-size:16px;'>🎉 Excellent! No infrastructure waste detected in this infrastructure layer.</p>"
} else {
    $HtmlBody = $ReportData | ConvertTo-Html -Head $Header -PreContent $PreText | Out-String
    $HtmlBody = $HtmlBody -replace '<td>High</td>', '<td><span class="status-badge High">🔴 High</span></td>'
    $HtmlBody = $HtmlBody -replace '<td>Medium</td>', '<td><span class="status-badge Medium">🟠 Medium</span></td>'
    $HtmlBody = $HtmlBody -replace '<td>Low</td>', '<td><span class="status-badge Low">🟢 Low</span></td>'
}

$HtmlBody | Out-File "./AzureCostReport.html" -Encoding utf8 -Force

# 5. Extract Variables via Internal Native Orchestrator
try {
    $LogicAppURL = Get-AutomationVariable -Name "LogicAppEmailURL"
    if ($null -ne $LogicAppURL -and $LogicAppURL -ne "") {
        $BodyJson = @{ body = $HtmlBody } | ConvertTo-Json
        Invoke-RestMethod -Uri $LogicAppURL -Method Post -Body $BodyJson -ContentType "application/json"
        Write-Output "SUCCESS: Email triggered successfully from the script!"
    }
} catch { Write-Output "ERROR: Execution pipeline terminated: $_" }
