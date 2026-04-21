# Examples

Self-contained Ballerina programs that exercise the `ballerinax/microsoft.dynamics365.finance` connector against an in-process mock server. Each example starts the mock on port 9090, points the client at it, runs a flow, prints the result, and shuts the mock down.

No real D365 tenant is required to run these.

## Setup (once)

From the repository root, build and publish the connector (and its `mock.server` sub-module) to your local Ballerina repository:

```bash
cd ballerina
bal pack
bal push --repository=local
cd ..
```

The examples declare `repository = "local"` on their dependency, so they will pick the just-published package up.

## Run

```bash
cd examples/list-customers
bal run
```

Swap the directory for any of the three examples:

| Example | What it demonstrates |
| --- | --- |
| `list-customers` | Default-company scoping, cross-company override, `$filter` with `contains`, `$top` |
| `create-sales-order` | Two-call flow: look up a customer, POST a new `SalesOrderHeader` that reuses the customer's defaults |
| `filter-general-ledger` | `$filter` on enum-like fields, `$orderby desc`, `$count=true` envelope access |

## Pointing at a real tenant

Each example constructs the client with:

```ballerina
finance:Client fo = check new (
    config = {auth: {token: "demo-bearer-token"}},
    serviceUrl = "http://localhost:9090/data"
);
```

To hit a real tenant, drop the `server:startMock()` / `mockListener.gracefulStop()` calls and swap the client config for a live one:

```ballerina
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
```
