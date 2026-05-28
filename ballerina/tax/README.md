## Overview

[Microsoft Dynamics 365 Finance](https://www.microsoft.com/en-us/dynamics-365/products/finance) is Microsoft's cloud ERP solution for financial management, covering general ledger, accounts receivable and payable, fixed assets, budgeting, cash and bank management, and tax.

The `microsoft.dynamics365.finance.tax` connector provides APIs for tax configuration in Microsoft Dynamics 365 Finance. It covers sales tax codes and groups, withholding tax, and country-specific tax settings including Brazil (CFOP, CST), India (GST, HSN), Switzerland (ISR), Belgium (Intervat), Poland (NIP), and Norway (NRT).

### Key Features

- Sales tax codes, sales tax groups, and item sales tax groups
- Withholding tax code and group configuration
- Electronic fiscal document (EFDoc) setup for Brazil
- India-specific GST and HSN code management
- Country-specific tax reporting (Intervat, ISR, NRT, NIP)

## Setup guide

### Prerequisites

- A Microsoft Dynamics 365 Finance & Operations environment (cloud-hosted or sandbox)
- An Azure Active Directory (Entra ID) app registration with API permissions for Dynamics 365

### Step 1: Register an application in Azure AD

1. Sign in to the [Azure portal](https://portal.azure.com/) and navigate to **Azure Active Directory → App registrations → New registration**.

2. Give the application a name, select the appropriate account type, and click **Register**.

3. Note the **Application (client) ID** and **Directory (tenant) ID** from the overview page.

4. Under **Certificates & secrets**, create a new client secret and note the value immediately — it is only shown once.

### Step 2: Grant Dynamics 365 API permissions

1. In the app registration, go to **API permissions → Add a permission → APIs my organization uses**.

2. Search for **Dynamics 365** (or `Microsoft Dynamics ERP`) and add the `user_impersonation` (or `.default`) delegated/application scope.

3. Click **Grant admin consent** for your tenant.

### Step 3: Add the app as a D365 user

1. In your D365 Finance environment, go to **System administration → Users → New**.

2. Set the **User ID** and **User name**, then paste the Azure AD **Application (client) ID** into the **Azure AD application** field.

3. Assign appropriate security roles and save.

## Quickstart

To use the `microsoft.dynamics365.finance.tax` connector in your Ballerina application, modify the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/microsoft.dynamics365.finance.tax as finTax;
```

### Step 2: Instantiate a new connector

```ballerina
configurable string tenantId = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string serviceUrl = ?;   // e.g. "https://<env>.operations.dynamics.com/data"

finTax:Client finTaxClient = check new (
    config = {
        auth: {
            tokenUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
            clientId,
            clientSecret,
            scopes: [string `${serviceUrl}/.default`]
        }
    },
    serviceUrl
);
```

### Step 3: Invoke the connector operation

```ballerina
finTax:TaxGroupsCollection taxGroups = check finTaxClient->listTaxGroups();
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The Dynamics 365 Finance Ballerina connectors provide practical examples illustrating usage in various scenarios.
Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/tree/main/examples).
