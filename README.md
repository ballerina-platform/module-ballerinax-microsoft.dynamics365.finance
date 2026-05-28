# Ballerina Microsoft Dynamics 365 Finance Connectors

[![Build](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/ci.yml)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/trivy-scan.yml)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/build-with-bal-test-graalvm.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/actions/workflows/build-with-bal-test-graalvm.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance.svg)](https://github.com/ballerina-platform/module-ballerinax-microsoft.dynamics365.finance/commits/main)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Microsoft Dynamics 365 Finance](https://www.microsoft.com/en-us/dynamics-365/products/finance) is Microsoft's cloud ERP solution for financial management, covering general ledger, accounts receivable and payable, fixed assets, budgeting, cash and bank management, and tax.

This repository contains Ballerina connector packages for the Dynamics 365 Finance & Operations OData REST API (version 10.0.47). The 300 finance-domain entities are split across 8 independently publishable packages to stay within compiler memory limits:

1. The `ballerinax/microsoft.dynamics365.finance.ledger` package provides APIs for general ledger, journal management, main accounts, budget plans, fiscal calendars, fund accounting, and posting definitions.

2. The `ballerinax/microsoft.dynamics365.finance.receivable` package provides APIs for accounts receivable — customer master data, customer groups, collections, dunning, and credit management.

3. The `ballerinax/microsoft.dynamics365.finance.payable` package provides APIs for accounts payable — vendor master data, vendor groups, vendor payment journals, and purchase agreements.

4. The `ballerinax/microsoft.dynamics365.finance.tax` package provides APIs for tax configuration — sales tax codes and groups, withholding tax, and country-specific tax settings (Brazil, India, Switzerland, Belgium, Poland, Norway).

5. The `ballerinax/microsoft.dynamics365.finance.asset` package provides APIs for fixed assets, bank accounts, cash management, project accounting categories, and expense management.

6. The `ballerinax/microsoft.dynamics365.finance.core` package provides APIs for core reference data — currencies, exchange rates, payment terms and methods, legal entities, and global address book entries.

7. The `ballerinax/microsoft.dynamics365.finance.hr` package provides APIs for human resources — workers, employment, job templates, teams, skills, absence codes, and vesting rules.

8. The `ballerinax/microsoft.dynamics365.finance.system` package provides APIs for system administration — workflows, security roles, batch jobs, document management, and system parameters.

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

# Build a single package
./gradlew clean :microsoft.dynamics365.finance-ballerina-<bucket>:build
```

| Bucket name  | Connector package                                          |
|--------------|------------------------------------------------------------|
| `ledger`     | `ballerinax/microsoft.dynamics365.finance.ledger`          |
| `receivable` | `ballerinax/microsoft.dynamics365.finance.receivable`      |
| `payable`    | `ballerinax/microsoft.dynamics365.finance.payable`         |
| `tax`        | `ballerinax/microsoft.dynamics365.finance.tax`             |
| `asset`      | `ballerinax/microsoft.dynamics365.finance.asset`           |
| `core`       | `ballerinax/microsoft.dynamics365.finance.core`            |
| `hr`         | `ballerinax/microsoft.dynamics365.finance.hr`              |
| `system`     | `ballerinax/microsoft.dynamics365.finance.system`          |

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
