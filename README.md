# Ballerina Microsoft Dynamics 365 Finance Connectors

[![Build](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/ci.yml)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/trivy-scan.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/commits/main)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Microsoft Dynamics 365 Finance](https://www.microsoft.com/en-us/dynamics-365/products/finance) is Microsoft's cloud ERP solution for financial management, covering general ledger, accounts receivable and payable, fixed assets, budgeting, cash and bank management, and tax.

This repository contains Ballerina connector packages for the Dynamics 365 Finance & Operations OData REST API (version 10.0.47). The finance-domain entities are split across 30 independently publishable packages to stay within compiler memory limits, grouped by functional area:

### Finance & Accounting

1. `ballerinax/microsoft.dynamics365.finance.ledger` — general ledger, journals, accounting, and posting.
2. `ballerinax/microsoft.dynamics365.finance.journalentry` — general ledger journal entries and transactions.
3. `ballerinax/microsoft.dynamics365.finance.mainaccount` — main accounts and chart of accounts.
4. `ballerinax/microsoft.dynamics365.finance.budget` — budget registers, budget control, cost centers, funds, and control plans.
5. `ballerinax/microsoft.dynamics365.finance.fiscal` — fiscal calendars and financial dimensions.
6. `ballerinax/microsoft.dynamics365.finance.fixedasset` — fixed assets, leased assets, and asset registers.
7. `ballerinax/microsoft.dynamics365.finance.cashmanagement` — bank accounts, cash management, and currency exchange.
8. `ballerinax/microsoft.dynamics365.finance.payment` — payment configuration, currencies, and exchange rates.
9. `ballerinax/microsoft.dynamics365.finance.expense` — expense management, travel, mileage, and per diem.

### Core & Organization

10. `ballerinax/microsoft.dynamics365.finance.core` — core reference data: companies, organizations, addresses, and departments.
11. `ballerinax/microsoft.dynamics365.finance.coreorg` — legal entities, warehouses, and organizational reference data.

### Accounts Receivable

12. `ballerinax/microsoft.dynamics365.finance.customer` — accounts receivable customer master data.
13. `ballerinax/microsoft.dynamics365.finance.customermain` — primary customer master records.
14. `ballerinax/microsoft.dynamics365.finance.customeraccount` — customer account and customer payment data.
15. `ballerinax/microsoft.dynamics365.finance.receivable` — accounts receivable collections, disputes, and sales.

### Accounts Payable

16. `ballerinax/microsoft.dynamics365.finance.vendor` — accounts payable vendor master data.
17. `ballerinax/microsoft.dynamics365.finance.vendorextended` — extended vendor data for accounts payable.
18. `ballerinax/microsoft.dynamics365.finance.vendorpayment` — vendor payment data for accounts payable.
19. `ballerinax/microsoft.dynamics365.finance.procurement` — procurement: vendors, purchase orders, and deliveries.

### Tax & Compliance

20. `ballerinax/microsoft.dynamics365.finance.tax` — tax configuration: VAT, GST, and taxation.
21. `ballerinax/microsoft.dynamics365.finance.taxregion` — regional and country-specific tax compliance.
22. `ballerinax/microsoft.dynamics365.finance.trade` — trade compliance: Intrastat and international trade.

### Human Resources

23. `ballerinax/microsoft.dynamics365.finance.hr` — human resources: workers, employees, and persons.
24. `ballerinax/microsoft.dynamics365.finance.hrdev` — HR development: skills, training, and teams.

### Project Management

25. `ballerinax/microsoft.dynamics365.finance.project` — project management and accounting (PSA, project grants).

### System

26. `ballerinax/microsoft.dynamics365.finance.system` — system administration and reference data.
27. `ballerinax/microsoft.dynamics365.finance.sysconfig` — system configuration and reference tables.
28. `ballerinax/microsoft.dynamics365.finance.users` — user security: roles, identity, and access.
29. `ballerinax/microsoft.dynamics365.finance.workflow` — workflow automation: batch jobs and policies.
30. `ballerinax/microsoft.dynamics365.finance.document` — document management: media, messages, and agents.

## Issues and projects

The **Issues** and **Projects** tabs are disabled for this repository as this is part of the Ballerina library. To report bugs, request new features, or start new discussions, visit the Ballerina library [parent repository](https://github.com/ballerina-platform/ballerina-library).

## Build from the source

### Prerequisites

1. Download and install Java SE Development Kit (JDK) version 17:
   - [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
   - [OpenJDK](https://adoptium.net/)

   > **Note:** Set the `JAVA_HOME` environment variable to the JDK installation directory.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

### Build options

```bash
# Build all packages
./gradlew clean build

# Run tests in all packages
./gradlew clean test

# Build without tests
./gradlew clean build -x test

# Build a single package (see bucket names in the table below)
./gradlew clean :microsoft.dynamics365.finance-ballerina:<bucket>:build
```

| Bucket name       | Connector package                                          |
|-------------------|------------------------------------------------------------|
| `budget`          | `ballerinax/microsoft.dynamics365.finance.budget`          |
| `cashmanagement`  | `ballerinax/microsoft.dynamics365.finance.cashmanagement`  |
| `core`            | `ballerinax/microsoft.dynamics365.finance.core`            |
| `coreorg`         | `ballerinax/microsoft.dynamics365.finance.coreorg`         |
| `customer`        | `ballerinax/microsoft.dynamics365.finance.customer`        |
| `customeraccount` | `ballerinax/microsoft.dynamics365.finance.customeraccount` |
| `customermain`    | `ballerinax/microsoft.dynamics365.finance.customermain`    |
| `document`        | `ballerinax/microsoft.dynamics365.finance.document`        |
| `expense`         | `ballerinax/microsoft.dynamics365.finance.expense`         |
| `fiscal`          | `ballerinax/microsoft.dynamics365.finance.fiscal`          |
| `fixedasset`      | `ballerinax/microsoft.dynamics365.finance.fixedasset`      |
| `hr`              | `ballerinax/microsoft.dynamics365.finance.hr`              |
| `hrdev`           | `ballerinax/microsoft.dynamics365.finance.hrdev`           |
| `journalentry`    | `ballerinax/microsoft.dynamics365.finance.journalentry`    |
| `ledger`          | `ballerinax/microsoft.dynamics365.finance.ledger`          |
| `mainaccount`     | `ballerinax/microsoft.dynamics365.finance.mainaccount`     |
| `payment`         | `ballerinax/microsoft.dynamics365.finance.payment`         |
| `procurement`     | `ballerinax/microsoft.dynamics365.finance.procurement`     |
| `project`         | `ballerinax/microsoft.dynamics365.finance.project`         |
| `receivable`      | `ballerinax/microsoft.dynamics365.finance.receivable`      |
| `sysconfig`       | `ballerinax/microsoft.dynamics365.finance.sysconfig`       |
| `system`          | `ballerinax/microsoft.dynamics365.finance.system`          |
| `tax`             | `ballerinax/microsoft.dynamics365.finance.tax`             |
| `taxregion`       | `ballerinax/microsoft.dynamics365.finance.taxregion`       |
| `trade`           | `ballerinax/microsoft.dynamics365.finance.trade`           |
| `users`           | `ballerinax/microsoft.dynamics365.finance.users`           |
| `vendor`          | `ballerinax/microsoft.dynamics365.finance.vendor`          |
| `vendorextended`  | `ballerinax/microsoft.dynamics365.finance.vendorextended`  |
| `vendorpayment`   | `ballerinax/microsoft.dynamics365.finance.vendorpayment`   |
| `workflow`        | `ballerinax/microsoft.dynamics365.finance.workflow`        |

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
