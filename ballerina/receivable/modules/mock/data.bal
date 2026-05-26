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

// Stub data for the receivable module mock: CustomersV3, CustomerGroups.

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
        "PrimaryContactEmail": "orders@tailwind.example"
    }
];

final readonly & json[] customerGroups = [
    {"@odata.etag": "W/\"CG01\"", "dataAreaId": "USMF", "CustomerGroupId": "10", "Description": "Retail customers", "PaymentTermId": "Net30"},
    {"@odata.etag": "W/\"CG02\"", "dataAreaId": "USMF", "CustomerGroupId": "20", "Description": "Manufacturing partners", "PaymentTermId": "Net15"},
    {"@odata.etag": "W/\"CG03\"", "dataAreaId": "USMF", "CustomerGroupId": "30", "Description": "Logistics & 3PL", "PaymentTermId": "Net60"}
];

isolated function dataFor(string entitySet) returns json[] {
    match entitySet {
        "CustomersV3" => { return customers; }
        "CustomerGroups" => { return customerGroups; }
        _ => { return []; }
    }
}
