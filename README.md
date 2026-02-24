# ☁️ Azure Cloud Resume Challenge

![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

An end-to-end serverless web application demonstrating expertise in **Cloud Architecture**, **Infrastructure as Code (IaC)**, and **Modern DevOps** workflows.

🔗 **[VIEW LIVE DEMO](https://streschallenge022025v2.z16.web.core.windows.net/)**

---

## 🏛 Architecture & Stack

The project is built entirely on a serverless architecture to ensure high availability and cost-efficiency (Pay-as-you-go). Having previously completed this challenge in AWS via the console, I refactored the entire approach for Azure using **Terraform** to implement a "DevOps-first" methodology.

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | HTML5, CSS3, JavaScript | Responsive UI hosted as a Static Website. |
| **Hosting** | Azure Storage | High-performance static asset delivery via Blob Storage. |
| **Compute** | Azure Functions (Python) | Serverless API (HTTP Trigger) handling visitor logic. |
| **Database** | Azure Cosmos DB | Serverless NoSQL storage for visitor telemetry. |
| **IaC** | Terraform | Automated provisioning with remote state management. |
| **CI/CD** | GitHub Actions | Granular pipelines for Frontend, Backend, and Infra. |
| **Monitoring** | Azure Monitor | Set up monitoring with live alerts to let me know when function returns 5xx errors. |

---

## 🏗 Key Features & Implementation

### 1. Infrastructure as Code (IaC)

I moved away from manual configuration to a modular Terraform structure.

* **State Management:** Used a remote backend hosted in an Azure Storage account to ensure state persistence and security.
* **Modularity:** Divided the configuration into logical segments: `storage`, `database`, `functions`, and `provider`.

---

### 2. Serverless API & Security

* **Least Privilege:** The Azure Function uses a **System-Assigned Managed Identity** with a custom role (`CosmosDBDataContributor`), ensuring it only has the specific permissions required to interact with the database.
* **OIDC Authentication:** Implemented passwordless authentication between GitHub and Azure using **OpenID Connect (OIDC)**, eliminating the need for hardcoded secrets.
* **COSMOSDB Network Security:** The CosmosDB account is secured via Managed Identity. I wanted to go further and block public access and create IP filter so only Azure Functions outbound IPs would be allowed, but this approach creates a cirlucar dependency - CosmosDB would need to reference the Function App's IPs before the Function App exists.<br>In production env this would be solved via Vnet Private Endpoint.

---

### 3. Granular CI/CD

Three independent GitHub Action workflows handle updates based on folder-specific commits:

* **Terraform Push:** Provisions infrastructure on changes to `/terraform/`.
* **Backend Push:** Deploys the Python API on changes to `/backend/`.
* **Frontend Push:** Syncs static assets on changes to `/frontend/`.

---

## 🛠 Lessons from the Trenches: Troubleshooting

<details>
<summary><b>🔓 1. Secure Authentication & Secrets</b></summary>
The first obstacle was securing the GitHub-to-Azure handshake. I moved away from static credentials by leveraging GitHub Action Secrets and Federated Identity (OIDC), ensuring no sensitive IDs are exposed in the repository code.
</details>

<details>
<summary><b>📈 2. Regional Resource Quotas</b></summary>
Encountered a `0` quota limit for Function App instances across several regions. I successfully advocated for a subscription quota increase through Azure Support, enabling the deployment to proceed in my target region.
</details>

<details>
<summary><b>🐛 3. The Python V2 "Missing Functions" Bug (The Final Boss)</b></summary>

**The Issue:** Functions were reported as "successful" in deployment but remained invisible in the Azure Portal.

**The Root Cause:**

* **Binary Incompatibility:** The GitHub Runner (`ubuntu-latest`) built libraries on a newer Linux kernel than the Azure host, leading to `GLIBC` mismatches.
* **Cryptography Bug:** A specific version conflict in the `cryptography` library crashed the Python worker.
* **Deployment Conflict:** The standard `functions-action` forced a `Zip-Deploy` that bypassed the necessary build engine.

**The Resolution:**

1. **Library Pinning:** Explicitly pinned `cryptography==43.0.3` in `requirements.txt`.
2. **Remote Build Strategy:** Switched to **Azure Remote Build** (`SCM_DO_BUILD_DURING_DEPLOYMENT = true`).
3. **Terraform Lifecycle:** Implemented a `lifecycle` block in Terraform to prevent state-drift conflicts with GitHub Actions.
4. **CLI Precision:** Replaced the standard action with **Azure CLI** (`az functionapp deployment source config-zip`) to ensure the zip structure was correctly nested and the build was explicitly triggered.

</details>

---

## 🚀 Future Enhancements

* [ ] **Edge Delivery:** Integrate Azure CDN with Custom Domain & Managed SSL.
* [ ] **Testing:** Implement PyTest for backend logic validation.
* [x] **Monitoring:** Configure Application Insights for real-time telemetry.
