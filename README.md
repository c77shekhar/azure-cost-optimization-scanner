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

