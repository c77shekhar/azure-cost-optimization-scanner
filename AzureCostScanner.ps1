# ====================================================================
# PROJECT: Azure Automated Cost Optimization & FinOps Scanner
# AUTHOR: c77shekhar (GitHub Portfolio)
# ====================================================================

# 1. अज़्योर ऑटोमेशन की आइडेंटिटी से लॉगिन करना
Disable-AzContextAutosave -Scope Process | Out-Null
try {
    $AzureContext = (Connect-AzAccount -Identity).Context
    Write-Host "Successfully authenticated using Managed Identity." -ForegroundColor Green
} catch {
    Write-Host "Managed Identity login failed. If running locally, please run Connect-AzAccount first." -ForegroundColor Yellow
}

# 2. डमी डेटा (ताकि टेस्ट करते समय खाली रिपोर्ट न बने और ईमेल हमेशा आए)
$ReportData = @(
    [PSCustomObject]@{
        IssueType     = "Unattached Disk (Test)"
        ResourceGroup = "rg-demo-testing"
        ResourceName  = "unused-os-disk-01"
        Details       = "Size: 128GB, SKU: Premium_LRS"
        Severity      = "High"
    },
    [PSCustomObject]@{
        IssueType     = "Stopped VM (Test)"
        ResourceGroup = "rg-demo-testing"
        ResourceName  = "dev-environment-vm"
        Details       = "Location: EastUS"
        Severity      = "Medium"
    }
)

Write-Host "--- Azure Cost Optimization Scan Starting ---" -ForegroundColor Cyan

# 3. HTML रिपोर्ट का डिजाइन
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

# 4. HTML रिपोर्ट बनाना
$HtmlBody = $ReportData | ConvertTo-Html -Head $Header | Out-String
$HtmlBody = $HtmlBody -replace '<td>High</td>', '<td class="High">High</td>'
$HtmlBody = $HtmlBody -replace '<td>Medium</td>', '<td class="Medium">Medium</td>'
$HtmlBody = $HtmlBody -replace '<td>Low</td>', '<td class="Low">Low</td>'

$HtmlBody | Out-File "./AzureCostReport.html"
Write-Host "Report saved as AzureCostReport.html" -ForegroundColor Green

# 5. अज़्योर की तिजोरी (Variable) से सुरक्षित तरीके से URL निकालना
try {
    $LogicAppURL = (Get-AzAutomationVariable -Name "LogicAppEmailURL").Value
    
    if ($null -ne $LogicAppURL -and $LogicAppURL -ne "") {
        Write-Host "Fetched Webhook URL successfully: $LogicAppURL" -ForegroundColor Cyan
        
        $BodyJson = @{ body = $HtmlBody } | ConvertTo-Json
        Write-Host "Sending report to Gmail via Logic App..." -ForegroundColor Yellow
        
        # लॉजिक ऐप को डेटा भेजना
        Invoke-RestMethod -Uri $LogicAppURL -Method Post -Body $BodyJson -ContentType "application/json"
        Write-Host "Email triggered successfully from the script!" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Variable 'LogicAppEmailURL' is empty or null." -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: Cannot fetch Azure Automation Variable. Details: $_" -ForegroundColor Red
}

