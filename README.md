# 💰 Automated Azure Cost Optimization & FinOps Scanner (V6.0)

An enterprise-grade, 100% serverless cloud waste tracking engine designed for **Azure Automation Runbooks (PowerShell 5.1 native runtime)**. This scanner crawls single, multiple, or tenant-wide infrastructure layers to locate unattached storage, abandoned network interfaces, and idle compute allocations, compiling them into a text-only, web-safe CSS HTML executive dashboard delivered directly to your inbox.

---

## 💼 Looking to Optimize Your Corporate Azure Bill?
I am a specialized Cloud FinOps & DevOps Consultant. If your engineering layers are bleeding credit quotas or you want to safely shave **20% to 40%** off your monthly Azure infrastructure statements, let's align!

*   **⚡ Hire me on Upwork:** [Insert Your Upwork Profile URL Link Here]
*   **🌐 Connect on LinkedIn:** [Insert Your LinkedIn Profile URL Link Here]
*   **📨 Business Email:** `your.email@domain.com`

---

## 🚀 Key Technical Features & Performance Engine

*   **Zero-Friction Module Dependencies (V6.0 Upgrade):** Re-engineered for the native **PowerShell 5.1 environment**. It leverages Azure's built-in global library pools out-of-the-box, completely eliminating broken `.NET assembly/MSAL` load bugs and complex module syncing failures.
*   **Unattached Disks Scan Matrix:** Automatically tracks down detached, orphaned managed storage volumes bleeding money without active compute bindings.
*   **Multi-OS Stopped Instance Auditor:** Pinpoints Windows/Linux VMs sitting in a "Stopped" (Allocated/Billed) state instead of Deallocated, catching internal Guest OS shutdowns cleanly.
*   **Orphaned Public IPs Detector:** Highlights loose, disassociated network public IP allocations charging ongoing standard reservation fees.
*   **Anti-Throttling & Character Guard:** Safe, sandboxed loops prevent ARM API read exhaustion. Stripped of vulnerable graphical assets/emoticons, the table dashboard uses clean text-based CSS badges to guarantee notification reports will **never** display broken `??` placeholders inside email clients.

---

## 📊 Sample Report Dashboard Layout
*Below is a structural preview of the automated report delivered to stakeholders' Outlook inboxes:*

| Issue Type | Resource Group | Resource Name | Details / Specifications | Severity Status |
| :--- | :--- | :--- | :--- | :--- |
| **Unattached Disk** | rg-production-vms | prod-db-disk-02 | Size: 1024GB \| SKU: Premium_LRS | CRITICAL |
| **Stopped VM (Billed)** | rg-testing-environment | dev-linux-node01 | OS: Linux \| Compute allocated but idle | WARNING |
| **Unused Public IP** | rg-networking-prod | web-alb-public-ip | IP Routing Target: 9.205.xx.xx | INFO |

---

## 🔒 Enterprise Safety & Data Compliance (Client Peace of Mind)

*   **100% Read-Only Scope:** The engine strictly leverages standard `Get-Az*` data-plane commands. It possesses **zero deletion or mutation capabilities**, ensuring absolute safety for live production environments.
*   **Enforced Least Privilege Model:** Operates perfectly under the native Microsoft **Reader** RBAC role context. No Global Admin or Subscription Owner permissions required.
*   **100% Strict Data Privacy:** Completely self-contained and local. Your cloud topology infrastructure and billing data never leave your secure Azure tenant boundary layer.

---

## ⚙️ Operational Scope Control (Zero Code Changes)

The script handles scaling and data normalization natively on autopilot. Control the target scanning workspace directly via the **TargetSubscriptions** parameter box inside the Azure Portal scheduler window:

| Intended Scanning Target | Input Value to Enter in Portal Field | Backend Script Execution Behavior |
| :--- | :--- | :--- |
| **Full Tenant Sweep** | *Leave the field completely blank* | Discovers and scans **all accessible subscriptions** across your entire active Azure tenant. |
| **Isolate Single Environment** | `1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p` | Locks target context onto that specific subscription scope immediately. |
| **Target Multiple Environments** | `1a2b3c4d-5e6f..., 9z8y7x6w-5v4u...` | Automatically tokenizes, splits, and loops through your comma-separated array string parameters. |

---

## 🛠️ Infrastructure Provisioning Requirements

1.  **Identity Management:** Enable **System-assigned Managed Identity** inside your hosting Azure Automation Account.
2.  **Access Control (IAM):** Assign the **Reader** role to the Managed Identity principal at the **Subscription root** (for single/multiple targets) or **Management Group root** (for automated tenant-wide sweeps).
3.  **Automation Variables:** Create an encrypted String variable named exactly **`LogicAppEmailURL`** containing your HTTP POST webhook routing token link (Azure Logic Apps/Power Automate/Webhook listener).

---

## 📋 Exception & Compliance SLA Policy

If a specific testing framework or Disaster Recovery (DR) resource must be excluded from active remediation loops despite matching scanner criteria, apply this tracking metadata flag directly to the target resource:
*   **Tag Key**: `FinOps-Exception`
*   **Tag Value**: `Approved-By-[StakeholderName]`

*Note: All flagged cost-accumulation resources must be either remediated (Deleted/Deallocated) or marked with a verified Exception Tag within **7 business days** of automated notification delivery.*

---

## 📁 Repository & Delivery Structure

```text
├── Azure-FinOps-Scanner.ps1     # Production-hardened PowerShell 5.1 Runbook Script
├── SOP-Client-Remediation.md    # End-User Playbook for Application Owners & Managers
└── SOP-Technical-Deployment.md  # Infrastructure Blueprint for Systems Administrators
```
