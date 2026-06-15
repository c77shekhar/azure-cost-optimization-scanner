# ====================================================================
# PROJECT: Azure Automated Cost Optimization & FinOps Scanner
# AUTHOR: c77shekhar (GitHub Portfolio)
# DESIGNED FOR: Azure Automation Runbook (PowerShell 7.2)
# ====================================================================

# 1. Authenticate using Automation Managed Identity
Disable-AzContextAutosave -Scope Process | Out-Null
try {
    $AzureContext = (Connect-AzAccount -Identity).Context
    Write-Output "SUCCESS: Authenticated using Managed Identity."
} catch {
    Write-Output "WARNING: Managed Identity login failed. If running locally, please run Connect-AzAccount first."
}

# 2. Dummy Mock Data for 100% stable email testing
$ReportData = @(
    [PSCustomObject]@{
        IssueType     = "Unattached Disk (Test)"
        ResourceGroup = "Lab-FinOps-Test"
        ResourceName  = "unused-os-disk-01"
        Details       = "Size: 128GB, SKU: Premium_LRS"
        Severity      = "High"
    },
    [PSCustomObject]@{
        IssueType     = "Stopped VM (Test)"
        ResourceGroup = "Lab-FinOps-Test"
        ResourceName  = "dev-environment-vm"
        Details       = "Location: EastUS"
        Severity      = "Medium"
    }
)

Write-Output "INFO: Azure Cost Optimization Scan Starting..."

# 3. HTML Report UI Design
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

# 4. Convert and Compile HTML Dashboard
$HtmlBody = $ReportData | ConvertTo-Html -Head $Header | Out-String
$HtmlBody = $HtmlBody -replace '<td>High</td>', '<td class="High">High</td>'
$HtmlBody = $HtmlBody -replace '<td>Medium</td>', '<td class="Medium">Medium</td>'
$HtmlBody = $HtmlBody -replace '<td>Low</td>', '<td class="Low">Low</td>'

$HtmlBody | Out-File "./AzureCostReport.html"
Write-Output "SUCCESS: HTML Report saved as AzureCostReport.html"

# 5. Fetch Encrypted Variable explicitly and trigger the Logic App Webhook
try {
    # ⚠️ CHANGE THESE TWO VALUES TO YOUR ACTUAL AZURE PORTAL NAMES ⚠️
    $RGName = "Lab-FinOps-Test"
    $AutoAccountName = "azure-cost-optimizer-free"

    # Direct extraction using explicit parameters to bypass module limitations
    $LogicAppURL = (Get-AzAutomationVariable -Name "LogicAppEmailURL" -ResourceGroupName $RGName -AutomationAccountName $AutoAccountName).Value
    
    if ($null -ne $LogicAppURL -and $LogicAppURL -ne "") {
        Write-Output "SUCCESS: Webhook URL fetched properly from variables."
        
        $BodyJson = @{ body = $HtmlBody } | ConvertTo-Json
        Write-Output "INFO: Sending report via HTTP Post to Logic App..."
        
        # Trigger the secure Logic App pipeline
        Invoke-RestMethod -Uri $LogicAppURL -Method Post -Body $BodyJson -ContentType "application/json"
        Write-Output "SUCCESS: Email triggered successfully from the script!"
    } else {
        Write-Output "ERROR: Variable 'LogicAppEmailURL' is empty or null in this account."
    }
} catch {
    Write-Output "ERROR: Cannot fetch Azure Automation Variable. Details: $_"
}
