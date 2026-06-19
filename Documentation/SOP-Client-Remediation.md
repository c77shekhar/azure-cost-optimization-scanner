# 📘 Azure FinOps Automation Framework: Master SOP Operations Guide

*   **Document Schema**: SOP-FINOPS-MASTER-V6
*   **Target Audience**: Systems Administrators, DevOps Engineers, Application Owners, and FinOps Lead Management
*   **Core Objective**: Comprehensive technical provisioning, execution scoping, and compliance-driven remediation playbook for the Version 6.0 Cost Scanner.
*   
## PART 1: TECHNICAL DEPLOYMENT & PROVISIONING HANDBOOK
*Target Audience: Cloud Engineering, Systems Administrators, Infrastructure Leads*

### 1. System Architecture Blueprint
The Version 6.0 engine utilizes native Azure Resource Manager (ARM) tracking primitives over the lightweight PowerShell 5.1 runtime. This design explicitly eliminates custom library compilation anomalies, missing `.dll` errors, and token acquisition blockages.

[Azure Automation Schedule]│▼[System-Assigned Managed Identity] ──► Authenticates to Subscription Graph│▼[Loop Normalized Context Matrix]  ──► Sweeps Storage, Network, and Compute│▼[Clean CSS HTML Render Engine]     ──► Compiles Strict Text-Based Badges│▼[Invoke-RestMethod Webhook]        ──► Dispatches Report Payload to Logic App

### 2. Infrastructure Prerequisites
Configure the underlying platform layers prior to runbook ingestion:

#### 2.1 Identity & Access Management (IAM)
*   **Identity Configuration**: Enable the **System-assigned Managed Identity** toggle inside your hosting Azure Automation Account.
*   **RBAC Scope Assignment**: Assign the standard **Reader** role to the Managed Identity principal.
    *   *Single-Subscription Model*: Assign directly at the target Subscription root.
    *   *Enterprise Multi-Subscription Model*: Assign at the **Management Group** root level to ensure automated child subscription context enumeration.

#### 2.2 Shared Automation Variables
Create the mandatory system routing asset within the Automation account workspace:
*   **Name**: `LogicAppEmailURL`
*   **Type**: `String`
*   **Setting**: **Encrypted** (Recommended)
*   **Value**: The complete, authenticated HTTP POST URL string pulled from your logic notifications pipeline (e.g., Azure Logic Apps or Power Automate).

### 3. Provisioning & Runbook Deployment Steps
1.  Navigate to your **Azure Automation Account** inside the Azure Portal.
2.  Expand **Process Automation** on the left navigation sidebar and click **Runbooks**.
3.  Click **+ Create a runbook** from the top command panel.
4.  Configure the creation metadata exactly as specified below:
    *   **Name**: `Azure-FinOps-Scanner-V6`
    *   **Runbook type**: `PowerShell`
    *   **Runtime version**: **`5.1`** 🔐 *(Crucial: Selecting 5.1 loads native, stable modules without library load errors).*
5.  Click **Create**.
6.  Paste the finalized **Version 6.0 Universal Production Script** into the web editor window.
7.  Click **Save**, then click **Publish** to release the runbook to active operational status.

### 4. Automation Scheduling Configuration
1.  Inside your published runbook window, click **Schedules** -> **+ Add a schedule**.
2.  Click **Link a schedule to your runbook** -> **+ Create a new schedule**.
3.  Define the execution timing schema (e.g., *Name: FinOps-Weekly-Prod*, *Recurrence: Weekly on Monday mornings*). Click **Create**.
4.  Select **Configure parameters and run settings**.
5.  Locate the **TargetSubscriptions** input parameter text area field and inject parameters following the guidelines inside the *Client Scope Configuration Matrix* detailed below.
6.  Click **OK** to permanently map the recurring execution target framework.

---

## PART 2: END-USER EXECUTION & REMEDIATION PLAYBOOK
*Target Audience: Client IT Operations, Application Owners, Project Managers*

### 5. Operational Scope Control (Zero Code Changes)
This framework does not require code updates. Control the targeted scanning workspace scope directly through the native **TargetSubscriptions** parameter field within your portal scheduler window:

| Intended Scanning Target | Input Value to Enter in Portal Field | Backend Script Execution Behavior |
| :--- | :--- | :--- |
| **Full Tenant Sweep** | *Leave the field completely blank* | Discovers and scans **all accessible subscriptions** across your entire active Azure tenant workspace automatically. |
| **Isolate Single Environment** | `1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p` | Locks target context onto that specific subscription scope immediately. |
| **Target Multiple Environments** | `1a2b3c4d-5e6f..., 9z8y7x6w-5v4u...` | Automatically tokenizes, splits, and loops through your comma-separated array string parameters. |

### 6. Waste Remediation Action Playbooks
When the weekly execution concludes processing, an interactive HTML dashboard delivers to your configured notification email box. Use these steps to safely clear flagged structural overhead charges:

#### 🔴 CRITICAL SEVERITY: Unattached Disks
*   **The Issue**: Standalone storage disks left orphan after a Virtual Machine deletion. Azure continues billing for the full provisioned capacity.
*   **Remediation Protocol**:
    1. Search for **Disks** in the top global Azure Portal search bar.
    2. Cross-reference the **Resource Group** and **Resource Name** listed in your cost report.
    3. Verify data retention compliance with your respective application owners.
    4. *If historical records are mandatory*: Take a final snapshot backup of the storage volume, then delete the disk.
    5. *If the disk is obsolete*: Click **Delete** to instantly strip the asset from your cloud statement.

#### 🟠 WARNING SEVERITY: Stopped VM (Billed)
*   **The Issue**: Virtual Machine instances shutdown directly from inside the Guest OS terminal (`shutdown /s` or `poweroff`). The cloud fabric still reserves the hardware layer, resulting in full ongoing compute charges.
*   **Remediation Protocol**:
    1. Search for **Virtual Machines** in the top global Azure Portal search bar.
    2. Select the flagged instance name. The runtime status will reflect as **"Stopped"**.
    3. Click the explicit **Stop** button located on the top horizontal overview navigation menu bar.
    4. Confirm that the resource status state transforms into **"Stopped (Deallocated)"**. All passive compute billing stops immediately.

#### 🟢 INFO SEVERITY: Unused Public IP
*   **The Issue**: Static Public routing IP allocations sitting unattached to active Network Interfaces (NICs) or Gateways, accumulating reservation holding fees.
*   **Remediation Protocol**:
    1. Search for **Public IP addresses** in the top global Azure Portal search bar.
    2. Select the string record matching your cost report matrix.
    3. If the asset remains tethered, click the active **Dissociate** button from the top panel.
    4. Click **Delete** to safely release the static IP address space allocation back to the global Azure block.

---

## PART 3: RECOVERY, GOVERNANCE & COMPLIANCE POLICY

### 7. Exception & Compliance SLA Policy
To balance automation audits with critical production environment operations (e.g., scheduled testing windows or active Disaster Recovery nodes), engineers can log an asset exception:

*   **The Exception Tag Rule**: Apply this explicit tracking metadata tag directly to the flagged resource inside the portal to bypass manual remediation mandates:
    *   **Tag Key**: `FinOps-Exception`
    *   **Tag Value**: `Approved-By-[StakeholderName]`
*   **7-Day Enforcement SLA**: Every flagged item surfaced on the weekly dashboard must be completely remediated (Deleted/Deallocated) or marked with a verified, active `FinOps-Exception` tag within **7 business days** of report delivery.

### 8. Technical Troubleshooting Matrix

| Runtime Symptom Log | Root Cause Analysis | Remediation Protocol |
| :--- | :--- | :--- |
| `CRITICAL FAILURE: Managed Identity token acquisition failed.` | The Automation Account's identity toggle is turned off or lacks IAM rights. | Verify the System-assigned identity status is set to **On**. Re-apply the **Reader** role assignment at the target Subscription scope. |
| Report delivers cleanly but is empty (`SUCCESS: No passive waste...`) | Active resource leaks exist but their host environments are completely invisible to the runner. | Ensure no structural subscription blueprint locks or cross-context exclusion filters are preventing execution block evaluations. |
| `ERROR: Webhook interface failed: ...` | The pipeline endpoint is dead, corrupted, or the automation variable string contains broken tokens. | Validate that the Logic App workflow is up and running. Verify the target endpoint URL inside the `LogicAppEmailURL` Automation asset variable. |
