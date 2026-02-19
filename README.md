☁️ Azure Cloud Resume Challenge
This repository contains my implementation of the Cloud Resume Challenge (Azure Edition). This project demonstrates my ability to build, deploy, and automate a full-stack, serverless web application using Microsoft Azure and DevOps best practices.

LIVE DEMO : https://streschallenge022025v2.z16.web.core.windows.net/

🛠 Architecture
The project is built entirely on a serverless architecture to ensure high availability and cost-efficiency (Pay-as-you-go).

Current Stack :
    Frontend: Built with HTML5, CSS3, and JavaScript.

    Hosting: Azure Storage (Static Website) – Used to host the static assets directly without managing servers.

    Backend API: Azure Functions (HTTP Trigger) – A serverless function that handles the logic for the visitor counter.

    Database: Azure Cosmos DB (Serverless) – A NoSQL database used to store and increment the visitor count.

    CI/CD: GitHub Actions – Automatically deploys frontend and backend changes upon every push to the repository.

The project was handled as a IaC since I initially did the Cloud Resume challenge in AWS using a console, therefore I moved to Azure and decided to try out IaC - Terraform
The terraform structure was divided into segments like storage, database, function, main & provider

For the state file location I used a remote backend and hosted it in a storage account directly in Azure

🏗 Key Features & Implementation
1. Static Web Hosting
The frontend is hosted in an Azure Storage Account enabled for "Static Website" hosting. Since I am using the native Azure-provided endpoint, the site is served over a secure HTTPS connection by default.

2. Serverless API (Azure Functions)
I developed a backend API using Python.
The function acts as the bridge between the frontend and the database.
It utilizes the Cosmos DB SDK to interact with the data layer securely.

    The Function has a custom role assgined named CosmosDBDataContributor which can only interact only with the database
    This follows the Least Privilige principle

3. Database Layer
Azure Cosmos DB was chosen for its serverless capabilities. It stores a single JSON document that tracks the total number of visits. Each time the API is triggered, the count is incremented and returned to the frontend.

4. Automation
    For the automation I created 3 different Github Action workflows each handling updates / changes to a specific folder
    The workflows are divided as below
        Terraform push - this one triggers when a commit is made on main branch under /terraform/ folder
        Backend push - this one triggers when a commit is made on main branch under /backend/ folder
        Frontend push - this one triggers when a commit is made on main branch under /frontend/ folder

What did not work, what I broke and how I fixed it

1. The first obstacle was realizing how to securely authenticate with Github Action identity since its not best practice to hardcode IDs into code, for this obstacle I leveraged a Github Action Secrets
    This ensures no hardcoded IDs are present in the workflow code and its stored securely within Github

2. Initially I was having issues with quote limit upon Azure Function creation - there was simply 0 available for my subscriptions, after trying a bunch of different regions and still failing to create any  
    functions I had to ask the Azure support for increasing my quota for my account

<details>
<summary><b>3. The Python V2 "Missing Functions" Bug (The Final Boss)</b></summary>

The Issue: After successful deployment, the Portal reported "No functions found," and logs showed a ModuleNotFoundError for cryptography.

The Cause: 
1.  Binary Incompatibility: The GitHub Runner (ubuntu-latest) built libraries on a newer Linux kernel than the Azure host.
2.  Platform Bug: A known conflict in the cryptography library (post-Nov 2024) crashed the Python worker.
3.  Deployment Conflict: The standard functions-action forced a Zip-Deploy that bypassed the necessary build engine.

The Resolution: * Library Pinning: Explicitly pinned cryptography==43.0.3 in requirements.txt.

Remote Build Strategy: Switched to Azure Remote Build (SCM_DO_BUILD_DURING_DEPLOYMENT = true).

Terraform Lock: Set WEBSITE_RUN_FROM_PACKAGE = 0 and used a lifecycle block to prevent GitHub from overriding the setting.

CLI Deployment: Replaced the default action with Azure CLI (az functionapp deployment source config-zip) to force a clean remote build.

</details>


🚀 Future Enhancements
Implementation of Azure CDN for global content delivery and custom domain mapping.

Addition of Unit Tests for the Python backend.
