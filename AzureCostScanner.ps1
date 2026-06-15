# Azure Cost Optimization Scanner Script
$ReportData = @()

Write-Host "--- Azure Cost Optimization Scan Starting ---" -ForegroundColor Cyan

# 1. Unattached Disks स्कैन
$unattachedDisks = Get-AzDisk | Where-Object {$_.DiskState -eq 'Unattached'}
foreach ($disk in $unattachedDisks) {
    $ReportData += [PSCustomObject]@{
        IssueType     = "Unattached Disk"
        ResourceGroup = $disk.ResourceGroupName
        ResourceName  = $disk.Name
        Details       = "Size: $($disk.DiskSizeGB)GB, SKU: $($disk.Sku.Name)"
        Severity      = "High"
    }
}

# 2. Stopped VMs स्कैन (जो Deallocated नहीं हैं)
$vms = Get-AzVM -Status
$stoppedVMs = $vms | Where-Object {$_.PowerState -eq 'VM stopped'}
foreach ($vm in $stoppedVMs) {
    $ReportData += [PSCustomObject]@{
        IssueType     = "Stopped (Billed) VM"
        ResourceGroup = $vm.ResourceGroupName
        ResourceName  = $vm.Name
        Details       = "Location: $($vm.Location)"
        Severity      = "Medium"
    }
}

# 3. Unused Public IPs स्कैन
$publicIPs = Get-AzPublicIpAddress
$unusedIPs = $publicIPs | Where-Object {$_.IpConfiguration -eq $null}
foreach ($ip in $unusedIPs) {
    $ReportData += [PSCustomObject]@{
        IssueType     = "Unused Public IP"
        ResourceGroup = $ip.ResourceGroupName
        ResourceName  = $ip.Name
        Details       = "IP Address: $($ip.IpAddress)"
        Severity      = "Low"
    }
}

# 4. HTML स्टाइल और डिजाइन
$Header = @"
<style>
    body { font-family: Arial, sans-serif; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th { background-color: #0078D4; color: white; padding: 10px; text-align: left; }
    td { border: 1px solid #dddddd; padding: 8px; text-align: left; }
    tr:nth-child(even) { background-color: #f2f2f2; }
    .High { color: red; font-weight: bold; }
    .Medium { color: orange; font-weight: bold; }
    .Low { color: green; font-weight: bold; }
</style>
<h2>Azure Cost Optimization Scan Report</h2>
<p>The following resources are consuming budget without active usage:</p>
"@

# 5. HTML रिपोर्ट जनरेट करना
if ($ReportData.Count -gt 0) {
    $HtmlBody = $ReportData | ConvertTo-Html -Head $Header | Out-String
    $HtmlBody = $HtmlBody -replace '<td>High</td>', '<td class="High">High</td>'
    $HtmlBody = $HtmlBody -replace '<td>Medium</td>', '<td class="Medium">Medium</td>'
    $HtmlBody = $HtmlBody -replace '<td>Low</td>', '<td class="Low">Low</td>'
    
    $HtmlBody | Out-File "./AzureCostReport.html"
    Write-Host "Report saved as AzureCostReport.html" -ForegroundColor Green
} else {
    Write-Host "All clear! No optimization needed." -ForegroundColor Green
}
