# Dynamics 365 Finance and Operations OData metadata from a live tenant

We are building Ballerina connectors for Dynamics 365 Finance and Operations (Finance + Supply Chain) and need a real metadata dump to verify / replace the hand-reconstructed spec. This document is what the admin on the customer tenant needs to do and send back.

The same procedure covers **both** the Finance and the Supply Chain connectors - D365 F&O exposes a single OData service per tenant and the metadata document covers every data entity across all modules. A single dump satisfies both connectors.

---

## What we need (deliverables)

1. **`metadata.xml`** - the full CSDL EDMX document from the tenant. This is the primary artifact. Expect roughly 5–50 MB of XML.
2. **The tenant base URL pattern**, e.g. `https://contoso.operations.dynamics.com` or `https://contoso-test.sandbox.operations.dynamics.com`. The subdomain can be redacted if the customer prefers - we only need the pattern.
3. **The D365 F&O version**, from the Help menu (System administration → About) or LCS environment page - useful to pin compatibility.

Sample JSON responses from a few entity sets are a useful sanity check for serialization details (decimal precision, date formats, envelope shape), but they are **not required** - see the "Optional extras" section at the bottom. The metadata alone is enough to move forward.

Send these via a private channel (Slack DM, OneDrive, signed-URL, attached email). Nothing here is a secret, but tenant URLs are sensitive.

---

## Prerequisites on the customer tenant

There are two ways to authenticate the call. Pick one. **App-only is strongly preferred** - it's a one-off setup and doesn't require a user to sit through a login flow.

### Option A - Service principal (Azure AD app), app-only auth - preferred

1. A tenant admin registers a new Azure AD application (Azure Portal → Microsoft Entra ID → App registrations → New registration). Note the following - we need these to make the token call:
   - **Tenant ID** (directory / tenant GUID)
   - **Application (client) ID**
   - A new **client secret** (under Certificates & secrets → New client secret). Copy the *value* (not the ID) - it is only shown once.
2. In D365 F&O, go to **System administration → Setup → Azure Active Directory applications**, add a new row:
   - **Client Id** - the application (client) ID from step 1
   - **Name** - anything descriptive, e.g. `Ballerina metadata reader`
   - **User ID** - link to a real user account. For `$metadata` alone, any user with basic F&O access (e.g. `System user` role) is sufficient.
3. No API permissions need to be granted on the app registration itself - F&O performs authorization internally based on the AAD-application row above.

### Option B - User token (interactive / device-code flow)

Only use this if the customer cannot provision a service principal. A user signs in once; the token lasts ~60 minutes, which is plenty for a single metadata call.

---

## Step 1 - Acquire an access token

All examples below assume bash + curl. The same calls work unchanged in Postman.

Set a few placeholders once:

```bash
TENANT_ID='<Azure AD tenant (directory) GUID>'
CLIENT_ID='<application / client ID>'
CLIENT_SECRET='<client secret value>'
FO_HOST='https://<tenant>.operations.dynamics.com'   # no trailing slash
```

### Option A - Service principal (client credentials)

```bash
TOKEN=$(curl -sS -X POST \
  "https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "scope=${FO_HOST}/.default" \
  | jq -r .access_token)

echo "${TOKEN:0:20}…   (length=${#TOKEN})"
```

A successful response returns an `access_token` that is **≥ 1500 characters long**. If the response instead has `error` / `error_description`, the most common causes are:

- `invalid_client` - the client secret is wrong or has expired.
- `AADSTS50001 / invalid resource` - the `scope` is wrong; it must be the **exact F&O host URL** followed by `/.default`, not `https://erp.dynamics.com/.default` (that is the cross-tenant form and often doesn't work for client-credentials).
- `AADSTS700016` - the application isn't in this tenant; re-check the tenant ID.

### Option B - User token via device code

```bash
# 1. Initiate device-code flow
DEVICE_CODE_RESPONSE=$(curl -sS -X POST \
  "https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/devicecode" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${CLIENT_ID}" \
  -d "scope=${FO_HOST}/user_impersonation offline_access")

echo "$DEVICE_CODE_RESPONSE" | jq

# Follow the `user_code` and `verification_uri` fields - sign in at the URL,
# enter the code, then poll for the token:
DEVICE_CODE=$(echo "$DEVICE_CODE_RESPONSE" | jq -r .device_code)

TOKEN=$(curl -sS -X POST \
  "https://login.microsoftonline.com/${TENANT_ID}/oauth2/v2.0/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
  -d "client_id=${CLIENT_ID}" \
  -d "device_code=${DEVICE_CODE}" \
  | jq -r .access_token)
```

---

## Step 2 - Dump the metadata

This is the whole ask. The response is CSDL XML (Microsoft's OData Entity Data Model Language).

```bash
curl -sS -H "Authorization: Bearer ${TOKEN}" \
          -H "Accept: application/xml" \
          "${FO_HOST}/data/\$metadata" \
          -o metadata.xml

ls -lh metadata.xml
head -c 200 metadata.xml
```

Expected: a file of a few megabytes (typically 5–50 MB) beginning with `<?xml version="1.0" encoding="utf-8"?>` followed by `<edmx:Edmx …>`.

If the response is small (< 10 KB) and contains a JSON error envelope, authentication or authorization failed - see the troubleshooting section below.

---

## How to send the results back

Share the file via a private channel along with a one-liner noting the tenant URL pattern and the F&O version, e.g.:

```
metadata.xml        (the file)
tenant URL pattern: https://<tenant>.operations.dynamics.com
F&O version:        10.0.39 PU62
```

---

## Troubleshooting quick reference

| Symptom | Likely cause |
|---|---|
| 401 Unauthorized from `$metadata` | Bearer token missing, malformed, or expired (tokens live ~60 min). Re-run Step 1. |
| 403 Forbidden from `$metadata` | The service principal is not registered in **System administration → Setup → Azure Active Directory applications**, or the linked user lacks basic access. |
| 404 on `$metadata` | Wrong host shape. It should be `<something>.operations.dynamics.com/data/$metadata`. Do **not** use `/api/data/`, that is the Dataverse path, not F&O. |
| `invalid_resource` when getting the token | `scope` must match the exact F&O host URL with `/.default`, e.g. `https://contoso.operations.dynamics.com/.default`. |
| Response from `$metadata` is JSON, not XML | An error page was returned. Inspect the body. |

---

## Optional extras (only if quick)

If convenient, two or three sample JSON responses help us confirm serialization details that CSDL doesn't fully pin down - decimal precision, date formats, and the exact envelope shape. Skip this if it adds friction; the metadata alone is enough.

```bash
# Finance
curl -sS -H "Authorization: Bearer ${TOKEN}" \
          "${FO_HOST}/data/CustomersV3?\$top=2" \
          -o customers-sample.json

# Supply Chain
curl -sS -H "Authorization: Bearer ${TOKEN}" \
          "${FO_HOST}/data/Warehouses?\$top=2" \
          -o warehouses-sample.json
```

Each file should start with `{"@odata.context": "…", "value": [ … ]}`. It is fine to redact personally-identifiable fields (customer names, email, phone, addresses) - we only need the shape, not the data.

---

## Notes

- For **on-premises** deployments the host shape is different (typically `https://<hostname>/namespaces/AXDeployment/data/`) and the token scope is also different. If the customer is on-prem, share that detail and we will send a tweaked version of this doc.
- The `metadata.xml` file contains **schema only** - entity names, field names, types, keys, navigation properties, enum values. No business data. It is safe to share outside the customer's security boundary in almost all cases, but confirm with their compliance team.
