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

// Stub data for the payable module mock: VendorsV3, VendorGroups.

final readonly & json[] vendors = [
    {
        "@odata.etag": "W/\"V01\"",
        "dataAreaId": "USMF",
        "VendorAccountNumber": "V-001",
        "VendorOrganizationName": "Litware Components, LLC",
        "VendorGroupId": "40",
        "AddressCountryRegionId": "USA",
        "PrimaryContactEmail": "billing@litware.example"
    },
    {
        "@odata.etag": "W/\"V02\"",
        "dataAreaId": "USMF",
        "VendorAccountNumber": "V-002",
        "VendorOrganizationName": "Proseware, Inc.",
        "VendorGroupId": "40",
        "AddressCountryRegionId": "USA",
        "PrimaryContactEmail": "ar@proseware.example"
    },
    {
        "@odata.etag": "W/\"V03\"",
        "dataAreaId": "GBSI",
        "VendorAccountNumber": "V-UK-001",
        "VendorOrganizationName": "Graphic Design Institute Ltd",
        "VendorGroupId": "50",
        "AddressCountryRegionId": "GBR"
    }
];

final readonly & json[] vendorGroups = [
    {"@odata.etag": "W/\"VG01\"", "dataAreaId": "USMF", "VendorGroupId": "40", "Description": "Domestic suppliers", "DefaultPaymentTermName": "Net30"},
    {"@odata.etag": "W/\"VG02\"", "dataAreaId": "USMF", "VendorGroupId": "70", "Description": "Logistics & freight", "DefaultPaymentTermName": "Net15"},
    {"@odata.etag": "W/\"VG03\"", "dataAreaId": "GBSI", "VendorGroupId": "50", "Description": "International suppliers", "DefaultPaymentTermName": "Net30"}
];

isolated function dataFor(string entitySet) returns json[] {
    match entitySet {
        "VendorsV3" => { return vendors; }
        "VendorGroups" => { return vendorGroups; }
        _ => { return []; }
    }
}
