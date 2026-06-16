# 💰 Azure Cost Optimization & Savings Scanner

An automated, 100% serverless PowerShell tool designed to scan Azure infrastructure, identify wasted resources, and generate professional HTML cost-audit reports.

---

## 🚀 Key Features
- **Unattached Disks Scanner:** Automatically detects detached managed disks that are costing money without active use.
- **Stopped (Billed) VMs:** Finds virtual machines that are stopped but still consuming cloud budget (Not Deallocated).
- **Orphaned Public IPs:** Highlights unused public IP addresses that are incurring charges.
- **Client-Ready HTML Reports:** Generates a clean, color-coded dashboard summarizing potential monthly savings.

---

## 📊 Sample Report Preview
*Below is a preview of the automated daily/weekly report sent directly to clients:*

| Issue Type | Resource Group | Resource Name | Details | Severity |
| :--- | :--- | :--- | :--- | :--- |
| **Unattached Disk** | rg-production-vms | prod-db-disk-02 | Size: 128GB, SKU: Premium_LRS | 🔴 High |
| **Stopped (Billed) VM** | rg-testing-environment | dev-test-vm01 | Location: EastUS | 🟠 Medium |
| **Unused Public IP** | rg-networking-prod | web-alb-public-ip | IP Address: 40.85.xx.xx | 🟢 Low |

---

## ⚙️ How to Run This Tool

### Method 1: Local / Azure Cloud Shell (Manual Audit)
1. Log in to your Azure Account:
   ```powershell
   Connect-AzAccount
   ```
2. Run the script:
   ```powershell
   ./AzureCostScanner.ps1
   ```
3. Open the generated `AzureCostReport.html` to view the findings.

---

## 💼 Looking to Optimize Your Azure Cloud Bill?
I am a freelance Cloud Optimization Specialist. If your business wants to cut down its monthly Azure bill by **20% to 40%** without risking any data loss, let's connect!
## 🔒 Security & Compliance (Client Peace of Mind)
This tool is designed with enterprise security standards in mind to ensure zero operational risk:
- **Read-Only Actions:** The scanner strictly uses `Get-Az*` commands. It possesses **zero deletion capability** and cannot modify your infrastructure.
- **Least Privilege Access:** Runs perfectly under the standard Azure **Reader** RBAC role. No owner or global admin privileges required.
- **Data Privacy:** 100% serverless execution. Your cloud infrastructure data never leaves your secure Azure tenant or GitHub runner environment.

---

## 🛠️ Automated Deployment (GitHub Actions Setup)
To schedule this scanner to run automatically every Monday morning, configure this GitHub workflow (`.github/workflows/azure-cost-scan.yml`):

```yaml
name: Scheduled Azure Cost Audit

on:
  schedule:
    - cron: '0 4 * * 1' # Runs every Monday at 4:00 AM UTC
  workflow_dispatch:

jobs:
  audit:
    runs-on: windows-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Login to Azure
        uses: azure/login@v2
        with:
          creds: \${{ secrets.AZURE_CREDENTIALS }}
          enable-AzPSSession: true

      - name: Run Scanner & Generate Report
        uses: azure/powershell@v2
        with:
          inlineScript: |
            ./AzureCostScanner.ps1
          azPSVersion: "latest"

      - name: Archive Production Report
        uses: actions/upload-artifact@v4
        with:
          name: Azure-Cost-Audit-Report
          path: AzureCostReport.html
```

---

## 📬 Commercial Consultation & Customization
Need this script customized for enterprise-wide multi-subscription scanning, Slack/Teams automated alerts, or safe automated remediation?

- **Upwork Profile:** [Insert Your Upwork Link Here]
- **LinkedIn Portfolio:** [Insert Your LinkedIn Link Here]
- **Email:** `your.email@domain.com`

*Let's jump on a quick 10-minute discovery call to run a Proof of Concept (PoC) audit on your dev subscription.*

