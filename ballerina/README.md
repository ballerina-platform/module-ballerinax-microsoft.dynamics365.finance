## Overview

The `ballerinax/microsoft.dynamics365.finance` connector wraps a curated subset of the Microsoft Dynamics 365 Finance and Operations OData REST API: customers, vendors, released products, sales and purchase orders, general-ledger entries, exchange rates, and customer groups. It is generated from the OpenAPI spec in `docs/spec/openapi.json`.

The repository also ships an in-process mock server (`modules/mock.server`) useful for tests and UI demos without a live D365 tenant.

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
