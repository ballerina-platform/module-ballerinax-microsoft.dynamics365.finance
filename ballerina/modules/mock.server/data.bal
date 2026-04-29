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

// In-memory stub data for a representative slice of the connector surface.
// Other entity sets respond with an empty collection; more can be stubbed
// from the published metadata as demos require.

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

final readonly & json[] vendors = [
    {
        "@odata.etag": "W/\"Jzs7MDs7VjAxJyk=\"",
        "dataAreaId": "USMF",
        "VendorAccountNumber": "V-001",
        "VendorOrganizationName": "Litware Components, LLC",
        "VendorGroupId": "40",
        "AddressCountryRegionId": "USA",
        "AddressCity": "San Jose",
        "PrimaryContactEmail": "billing@litware.example",
        "PrimaryContactPhone": "+1-408-555-0123"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7VjAyJyk=\"",
        "dataAreaId": "USMF",
        "VendorAccountNumber": "V-002",
        "VendorOrganizationName": "Proseware, Inc.",
        "VendorGroupId": "40",
        "AddressCountryRegionId": "USA",
        "AddressCity": "Detroit",
        "PrimaryContactEmail": "ar@proseware.example",
        "PrimaryContactPhone": "+1-313-555-0198"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7VjAzJyk=\"",
        "dataAreaId": "GBSI",
        "VendorAccountNumber": "V-UK-001",
        "VendorOrganizationName": "Graphic Design Institute Ltd",
        "VendorGroupId": "50",
        "AddressCountryRegionId": "GBR",
        "AddressCity": "Manchester",
        "PrimaryContactEmail": "finance@gdi.example",
        "PrimaryContactPhone": "+44-161-555-0123"
    }
];

final readonly & json[] vendorGroups = [
    {
        "@odata.etag": "W/\"Jzs7MDs7VkcwMScp\"",
        "dataAreaId": "USMF",
        "VendorGroupId": "40",
        "Description": "Domestic suppliers",
        "DefaultPaymentTermName": "Net30"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7VkcwMicp\"",
        "dataAreaId": "USMF",
        "VendorGroupId": "70",
        "Description": "Logistics & freight",
        "DefaultPaymentTermName": "Net15"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7VkcwMycp\"",
        "dataAreaId": "GBSI",
        "VendorGroupId": "50",
        "Description": "International suppliers",
        "DefaultPaymentTermName": "Net30"
    }
];

final readonly & json[] customerGroups = [
    {
        "@odata.etag": "W/\"Jzs7MDs7Q0cwMScp\"",
        "dataAreaId": "USMF",
        "CustomerGroupId": "10",
        "Description": "Retail customers",
        "PaymentTermId": "Net30"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7Q0cwMicp\"",
        "dataAreaId": "USMF",
        "CustomerGroupId": "20",
        "Description": "Manufacturing partners",
        "PaymentTermId": "Net15"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7Q0cwMycp\"",
        "dataAreaId": "USMF",
        "CustomerGroupId": "30",
        "Description": "Logistics & 3PL",
        "PaymentTermId": "Net60"
    }
];

final readonly & json[] paymentTerms = [
    {
        "@odata.etag": "W/\"Jzs7MDs7UFQwMScp\"",
        "dataAreaId": "USMF",
        "Name": "Net30",
        "Description": "Net 30 days",
        "NumberOfDays": 30
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7UFQwMicp\"",
        "dataAreaId": "USMF",
        "Name": "Net15",
        "Description": "Net 15 days",
        "NumberOfDays": 15
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7UFQwMycp\"",
        "dataAreaId": "USMF",
        "Name": "Net60",
        "Description": "Net 60 days",
        "NumberOfDays": 60
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

final readonly & json[] ledgerJournalLines = [
    {
        "@odata.etag": "W/\"Jzs7MDs7TEowMScp\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000001_012",
        "LineNumber": 1.0,
        "TransDate": "2026-04-30",
        "AccountDisplayValue": "401100",
        "OffsetAccountDisplayValue": "140100",
        "DebitAmount": 0.00,
        "CreditAmount": 12500.00,
        "CurrencyCode": "USD",
        "Text": "Q2 retail accrual"
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7TEowMicp\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000001_012",
        "LineNumber": 2.0,
        "TransDate": "2026-04-30",
        "AccountDisplayValue": "200100",
        "OffsetAccountDisplayValue": "140100",
        "DebitAmount": 4750.00,
        "CreditAmount": 0.00,
        "CurrencyCode": "USD",
        "Text": "AP reclass - April"
    }
];

final readonly & json[] exchangeRates = [
    {
        "@odata.etag": "W/\"Jzs7MDs7RVIwMScp\"",
        "RateTypeName": "Default",
        "FromCurrency": "USD",
        "ToCurrency": "EUR",
        "StartDate": "2026-04-01",
        "EndDate": "2026-04-30",
        "Rate": 0.92
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7RVIwMicp\"",
        "RateTypeName": "Default",
        "FromCurrency": "USD",
        "ToCurrency": "GBP",
        "StartDate": "2026-04-01",
        "EndDate": "2026-04-30",
        "Rate": 0.79
    },
    {
        "@odata.etag": "W/\"Jzs7MDs7RVIwMycp\"",
        "RateTypeName": "Default",
        "FromCurrency": "USD",
        "ToCurrency": "JPY",
        "StartDate": "2026-04-01",
        "EndDate": "2026-04-30",
        "Rate": 154.20
    }
];
