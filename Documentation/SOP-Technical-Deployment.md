# Technical & Deployment SOP: Azure Automated Cost Optimization & FinOps Scanner

*   **Document ID**: SOP-FINOPS-TECH-V6
*   **Target Audience**: Systems Administrators, Cloud DevOps Engineers, Infrastructure Leads
*   **Objective**: Comprehensive technical blueprint for provisioning, configuring, and maintaining the automated FinOps scanner runbook framework.

---

## 1. System Architecture

The Version 6.0 engine utilizes native Azure Resource Manager (ARM) tracking primitives over the lightweight PowerShell 5.1 runtime. This design explicitly eliminates custom library compilation anomalies, missing `.dll` errors, and token acquisition blockages.

[Azure Automation Schedule]│▼[System-Assigned Managed Identity] ──► Authenticates to Subscription Graph│▼[Loop Normalized Context Matrix]  ──► Sweeps Storage, Network, and Compute│▼[Clean CSS HTML Render Engine]     ──► Compiles Strict Text-Based Badges│▼[Invoke-RestMethod Webhook]        ──► Dispatches Report Payload to Logic App

## 2. Infrastructure Prerequisites

Configure the underlying platform layers prior to code ingestion:

### 2.1 Identity & Access Management (IAM)
*   **Identity Configuration**: Enable **System-assigned Managed Identity** on the hosting Azure Automation Account.
*   **RBAC Scope Assignment**: Assign the **Reader** role to the Managed Identity principal.
    *   *Single-Subscription Model*: Assign directly at the Subscription scope root.
    *   *Enterprise Multi-Subscription/Tenant Model*: Assign at the **Management Group** root level to ensure seamless child subscription enumeration.

### 2.2 Shared Automation Variables
Create the mandatory system routing asset within the Automation account workspace:
*   **Name**: `LogicAppEmailURL`
*   **Type**: `String`
*   **Setting**: **Encrypted** (Recommended)
*   **Value**: The complete, authenticated HTTP POST URL string pulled from your business notification engine pipeline (e.g., Azure Logic Apps, Power Automate, or a webhook listener).

---

## 3. Provisioning & Deployment Steps

Follow these explicit procedures to instantiate the runbook tracking engine:

1.  Navigate to your **Azure Automation Account** inside the Azure Portal.
2.  Expand the **Process Automation** section on the left-hand navigation sidebar and click **Runbooks**.
3.  Click **+ Create a runbook** from the top command panel.
4.  Configure the creation metadata exactly as specified below:
    *   **Name**: `Azure-FinOps-Scanner-V6`
    *   **Runbook type**: `PowerShell`
    *   **Runtime version**: **`5.1`** 🔐 *(Crucial: Selecting 5.1 bypasses broken .NET assembly loading bugs).*
    *   **Description**: Enterprise Cloud Waste Scanner for Disks, IPs, and Compute.
5.  Click **Create**.
6.  Paste the finalized **Version 6.0 Universal Production Script** into the native web text editor.
7.  Click **Save**, then click **Publish** to release the runbook to production status.

---

## 4. Automation Scheduling Configuration

To configure programmatic execution tracking (e.g., Weekly Scan):

1.  Inside your published runbook window, click **Schedules** -> **+ Add a schedule**.
2.  Click **Link a schedule to your runbook** -> **+ Create a new schedule**.
3.  Define the execution timing schema (e.g., *Name: FinOps-Weekly-Prod*, *Recurrence: Weekly on Monday mornings*). Click **Create**.
4.  Select **Configure parameters and run settings**.
5.  Locate the **TargetSubscriptions** input parameter text area field:
    *   **To run a full Tenant sweep**: Leave the parameter text box **completely empty**.
    *   **To isolate specific environments**: Provide the targeted subscription ID parameters matching the Client Configuration Matrix formatting standards (comma-separated if entering multiple IDs).
6.  Click **OK** to permanently link the recurring lifecycle target tracking matrix.

---

## 5. Technical Troubleshooting Matrix

| Runtime Symptom Log | Root Cause Analysis | Remediation Protocol |
| :--- | :--- | :--- |
| `CRITICAL FAILURE: Managed Identity token acquisition failed.` | The Automation Account's identity toggle is turned off or lacks IAM rights. | Verify the System-assigned identity status is set to **On**. Re-apply the **Reader** role assignment at the target Subscription scope. |
| Report delivers cleanly but is empty (`SUCCESS: No passive waste...`) | Active resource leaks exist but their host environments are completely invisible to the runner. | Ensure no structural subscription blueprint locks or cross-context exclusion filters are preventing execution block evaluations. |
| `ERROR: Webhook interface failed: ...` | The pipeline endpoint is dead, corrupted, or the automation variable string contains broken tokens. | Validate that the Logic App workflow is up and running. Verify the target endpoint URL inside the `LogicAppEmailURL` Automation asset variable. |
