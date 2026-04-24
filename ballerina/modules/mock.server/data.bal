// Copyright (c) 2026 WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

// Minimal stub data. Only a few entity sets are populated — enough to drive
// the example programs. Any other entity set returns an empty collection.

final readonly & json[] customers = [
    {
        "@odata.etag": "W/\"Jzs7MDs7MCcp\"",
        "dataAreaId": "USMF",
        "CustomerAccount": "US-001",
        "OrganizationName": "Contoso Retail",
        "AddressCountryRegionId": "USA",
        "SalesCurrencyCode": "USD",
        "PrimaryContactEmail": "ap@contoso-retail.example",
        "PrimaryContactPhone": "+1-206-555-0101"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7MScp\"",
        "dataAreaId": "USMF",
        "CustomerAccount": "US-002",
        "OrganizationName": "Fabrikam Industries",
        "AddressCountryRegionId": "USA",
        "SalesCurrencyCode": "USD",
        "PrimaryContactEmail": "procurement@fabrikam.example",
        "PrimaryContactPhone": "+1-415-555-0142"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7MicpCw==\"",
        "dataAreaId": "GBSI",
        "CustomerAccount": "UK-001",
        "OrganizationName": "Tailwind Traders",
        "AddressCountryRegionId": "GBR",
        "SalesCurrencyCode": "GBP",
        "PrimaryContactEmail": "orders@tailwind.example",
        "PrimaryContactPhone": "+44-20-7946-0001"
    }
];

final readonly & json[] mainAccounts = [
    {
        "@odata.etag": "W/\"Jzs7MDs7MycpCw==\"",
        "ChartOfAccounts": "Shared",
        "MainAccountId": "401100",
        "Name": "Sales revenue - Retail",
        "MainAccountType": "Revenue",
        "Currency": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NCcpCw==\"",
        "ChartOfAccounts": "Shared",
        "MainAccountId": "140100",
        "Name": "Finished goods inventory",
        "MainAccountType": "Asset",
        "Currency": "USD"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NScpCw==\"",
        "ChartOfAccounts": "Shared",
        "MainAccountId": "200100",
        "Name": "Accounts payable - Trade",
        "MainAccountType": "Liability",
        "Currency": "USD"
    }
];

final readonly & json[] ledgerJournalHeaders = [
    {
        "@odata.etag": "W/\"Jzs7MDs7NicpCw==\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000001_012",
        "JournalName": "GenJrn",
        "Description": "April month-end accruals",
        "JournalType": "Daily",
        "IsPosted": "Yes",
        "PostingDate": "2026-04-30"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7NycpCw==\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000002_012",
        "JournalName": "InvReg",
        "Description": "Invoice register - April",
        "JournalType": "VendInvoiceRegister",
        "IsPosted": "Yes",
        "PostingDate": "2026-04-28"
    }
];
