## Overview

Microsoft Dynamics 365 Finance is Microsoft's cloud enterprise-resource-planning application for financial management, covering accounts receivable, accounts payable, general ledger, fixed assets, budgeting, cash and bank management, and tax. The Dynamics 365 Finance connector enables integration with the Finance OData REST API, providing programmatic access to master and transactional data including customers, vendors, released products, sales and purchase orders, general-ledger entries, exchange rates, and customer groups.

### Key Features

- Customer and vendor master-data management (list, read, create, update, delete)
- Sales order and purchase order workflows with OData-based querying
- General-ledger entry and ledger-journal access for financial reporting
- Multi-currency support with configurable exchange rates
- Cross-company queries spanning multiple legal entities (`dataAreaId`)
- OAuth 2.0 client-credentials and bearer-token authentication against Microsoft Entra ID (Azure AD)

## Setup

Dynamics 365 Finance and Operations is protected by Azure Active Directory. Acquire an access token via the client-credentials flow (or pass one in directly via a bearer-token config) and point the client at your tenant's `/data` endpoint.

## Quickstart

```ballerina
import ballerinax/microsoft.dynamics365.finance;

public function main() returns error? {
    finance:Client fo = check new (
        config = {
            auth: {
                tokenUrl: "https://login.microsoftonline.com/<tenant-id>/oauth2/v2.0/token",
                clientId: "<client-id>",
                clientSecret: "<client-secret>",
                scopes: ["https://<tenant>.operations.dynamics.com/.default"]
            }
        },
        serviceUrl = "https://<tenant>.operations.dynamics.com/data"
    );

    finance:CustomersV3Collection customers = check fo->listCustomers(queries = {top: 5});
    // ...
}
```

## Examples

Runnable examples live in [`examples/`](../examples) at the repository root. They use the bundled mock server so they can run without a live tenant.
