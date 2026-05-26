# Microsoft Dynamics 365 Finance OpenAPI Specification Sanitization

_Author_: @ballerina \
_Created_: 2026/01/01 \
_Updated_: 2026/05/26 \
_Edition_: Swan Lake

## Source

The OpenAPI specifications in `docs/spec/` are derived from the **Microsoft Dynamics 365 Finance & Operations CSDL XML metadata** (version 10.0.47). The raw XML is **not committed**; only the derived OpenAPI 3.0 JSON specs are stored here.

## Pipeline

```
D365 F&O CSDL XML (10.0.47)
  └─► split_to_buckets.py        (parse XML → 8 domain buckets → raw OAS 3.0 per bucket)
        └─► bal openapi flatten  ({bucket}.json → {bucket}_flat.json)
              └─► bal openapi align  ({bucket}_flat.json → {bucket}_aligned.json)
                    └─► bal openapi --mode client  (generates client.bal, types.bal, utils.bal)
```

## Entity Classification (8 Buckets)

Entities are classified by longest-prefix match on the entity set name:

| Bucket       | Entity count | Representative prefixes |
|--------------|-------------|------------------------|
| `ledger`     | 45          | LedgerJournal, MainAccount, Budget, Fiscal, Fund, PostingDefinition, Accrual, JournalName |
| `receivable` | 23          | Customer, Cust, Collection, Dunning, Credit, SalesCarrier |
| `payable`    | 15          | Vendor, Vend, Purch, Purchase, DeliveryTerm, IntentLetter |
| `tax`        | 25          | Tax, Withhold, CFOP, CSTTable, EFDoc, GST, HSN, Intervat, NIP, NRT |
| `asset`      | 37          | FixedAsset, AssetLending, LeasingGroup, Bank, Cash, Expense, Trv, Project, Proj |
| `core`       | 39          | Currency, ExchangeRate, PaymentTerm, PaymentDay, PaymentMethod, LegalEntity, Address |
| `hr`         | 27          | AbsenceCode, EssWorker, Employ, InjuryType, JobTask, Team, Skill, VestingRule, Person |
| `system`     | 85          | Workflow, SecurityRole, Batch, Document, Parameter, Policy, Table, ApprovalUser |

## Sanitization Steps Applied

### 1. Duplicate operationId fix
The raw CSDL XML contains two action paths (`/Submit` and `/Complete`) that `bal openapi` would assign identical operationIds. Fixed by renaming:
- `/Submit` → operationId: `submitWorkflowAction`
- `/Complete` → operationId: `completeSystemAction`

### 2. Composite-key path parameters
D365 OData uses composite keys: `CustomersV3(dataAreaId='USMF',CustomerAccount='US-001')`. The generator produces typed key parameters (`dataAreaId`, `CustomerAccount`, etc.) from the XML entity key definitions.

### 3. Ballerina reserved keywords as field names
Several D365 entity properties are Ballerina reserved words. These are quoted with the `'` prefix in `types.bal`:

| Field name   | Fix applied       |
|--------------|-------------------|
| `select`     | `'select`         |
| `type`       | `'type`           |
| `resource`   | `'resource`       |
| `transaction`| `'transaction`    |
| `from`       | `'from`           |
| `by`         | `'by`             |

### 4. Redeclared `value` field in ODataCollection
`ODataCollection` contains `anydata[] value?`. Each `*CollectionAllOf2` record also declares a typed `value?`. Ballerina disallows overriding included-type fields, so `anydata[] value?` was removed from `ODataCollection` — the typed field from each `CollectionAllOf2` inclusion takes effect instead.

### 5. Bucket size constraint
Each bucket is capped at ≤ 85 entities (~425 operations) to stay well below the Ballerina compiler OOM threshold (~1,500 ops). The monolithic 300-entity / 1,500-operation package triggered OOM during `bal build`.
