Hi,

We're building Ballerina connectors for Dynamics 365 Finance and Operations and need a metadata dump from a live tenant. A single dump covers both Finance and Supply Chain — they share one OData service.

**What we need back**

1. `metadata.xml` — the full CSDL document (a few MB).
2. The tenant URL pattern (e.g. `https://contoso.operations.dynamics.com`) and the F&O version (System administration → About).

**One-time setup (tenant admin, ~5 min)**

1. Register an Azure AD app — note the **tenant ID**, **client ID**, and a **client secret**.
2. In D365 F&O → System administration → Setup → Azure Active Directory applications, add a row with the client ID and link it to any user with basic F&O access.

**Commands to run**

```bash
TENANT_ID='<tenant GUID>'
CLIENT_ID='<client ID>'
CLIENT_SECRET='<client secret>'
FO_HOST='https://<tenant>.operations.dynamics.com'

TOKEN=$(curl -sS -X POST \
  "https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token" \
  -d "grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&scope=${FO_HOST}/.default" \
  | jq -r .access_token)

curl -sS -H "Authorization: Bearer ${TOKEN}" "${FO_HOST}/data/\$metadata" -o metadata.xml
```

Please send the file back via any private channel along with the tenant URL pattern and F&O version.

If the tenant is on-premises (not `*.operations.dynamics.com`), let us know — the host path and OAuth scope differ slightly.

Thanks!
