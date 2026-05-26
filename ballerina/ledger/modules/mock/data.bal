// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Stub data for the ledger module mock: MainAccounts, LedgerJournalHeaders, LedgerJournalLines.

final readonly & json[] mainAccounts = [
    {
        "@odata.etag": "W/\"MA01\"",
        "ChartOfAccounts": "Shared",
        "MainAccountId": "401100",
        "Name": "Sales revenue - Retail",
        "MainAccountType": "Revenue",
        "Currency": "USD"
    },
    {
        "@odata.etag": "W/\"MA02\"",
        "ChartOfAccounts": "Shared",
        "MainAccountId": "140100",
        "Name": "Finished goods inventory",
        "MainAccountType": "Asset",
        "Currency": "USD"
    },
    {
        "@odata.etag": "W/\"MA03\"",
        "ChartOfAccounts": "Shared",
        "MainAccountId": "200100",
        "Name": "Accounts payable - Trade",
        "MainAccountType": "Liability",
        "Currency": "USD"
    }
];

final readonly & json[] ledgerJournalHeaders = [
    {
        "@odata.etag": "W/\"LJH01\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000001_012",
        "JournalName": "GenJrn",
        "Description": "April month-end accruals",
        "JournalType": "Daily",
        "IsPosted": "Yes",
        "PostingDate": "2026-04-30"
    },
    {
        "@odata.etag": "W/\"LJH02\"",
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
        "@odata.etag": "W/\"LJL01\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000001_012",
        "LineNumber": 1.0,
        "TransDate": "2026-04-30",
        "AccountDisplayValue": "401100",
        "DebitAmount": 0.0,
        "CreditAmount": 12500.0,
        "CurrencyCode": "USD",
        "Text": "Q2 retail accrual"
    },
    {
        "@odata.etag": "W/\"LJL02\"",
        "dataAreaId": "USMF",
        "JournalBatchNumber": "000001_012",
        "LineNumber": 2.0,
        "TransDate": "2026-04-30",
        "AccountDisplayValue": "200100",
        "DebitAmount": 4750.0,
        "CreditAmount": 0.0,
        "CurrencyCode": "USD",
        "Text": "AP reclass - April"
    }
];

isolated function dataFor(string entitySet) returns json[] {
    match entitySet {
        "MainAccounts" => { return mainAccounts; }
        "LedgerJournalHeaders" => { return ledgerJournalHeaders; }
        "LedgerJournalLines" => { return ledgerJournalLines; }
        _ => { return []; }
    }
}
