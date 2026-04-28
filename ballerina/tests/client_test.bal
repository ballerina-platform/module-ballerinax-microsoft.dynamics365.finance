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

import ballerina/http;
import ballerina/test;
import ballerinax/microsoft.dynamics365.finance.mock.server;

const int MOCK_PORT = 9090;
const string MOCK_URL = "http://localhost:9090/data";

http:Listener mockListener = check new (MOCK_PORT);
Client financeClient = check new (
    config = {auth: {token: "demo-bearer-token"}},
    serviceUrl = MOCK_URL
);

@test:BeforeSuite
function startMockServer() returns error? {
    mockListener = check server:startMock({port: MOCK_PORT, contextBase: MOCK_URL + "/"});
}

@test:AfterSuite
function stopMockServer() returns error? {
    check mockListener.gracefulStop();
}

// ---- CustomersV3: read / filter / page / project --------------------------

@test:Config
function testListCustomersV3DefaultCompany() returns error? {
    CustomersV3Collection response = check financeClient->listCustomersV3();
    CustomerV3[] rows = <CustomerV3[]>response.value;
    test:assertTrue(rows.length() >= 2, "expected at least 2 USMF customers in stub data");
    foreach CustomerV3 c in rows {
        test:assertEquals(c.dataAreaId, "USMF");
    }
}

@test:Config
function testListCustomersV3CrossCompanyAndCount() returns error? {
    CustomersV3Collection response = check financeClient->listCustomersV3(queries = {crossCompany: true, count: true});
    int? count = <int?>response["@odata.count"];
    test:assertTrue(count is int && count >= 3, "cross-company should return all seeded customers");
}

@test:Config
function testListCustomersV3FilterContains() returns error? {
    CustomersV3Collection response = check financeClient->listCustomersV3(
        queries = {filter: "contains(OrganizationName,'Contoso')"}
    );
    CustomerV3[] rows = <CustomerV3[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertEquals(rows[0].OrganizationName, "Contoso Retail");
}

@test:Config
function testListCustomersV3FilterEq() returns error? {
    CustomersV3Collection response = check financeClient->listCustomersV3(
        queries = {filter: "CustomerAccount eq 'US-002'"}
    );
    CustomerV3[] rows = <CustomerV3[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertEquals(rows[0].OrganizationName, "Fabrikam Industries");
}

@test:Config
function testListCustomersV3TopSkipCount() returns error? {
    CustomersV3Collection page = check financeClient->listCustomersV3(
        queries = {top: 1, skip: 0, count: true, crossCompany: true}
    );
    CustomerV3[] rows = <CustomerV3[]>page.value;
    test:assertEquals(rows.length(), 1);
    int? total = <int?>page["@odata.count"];
    test:assertTrue(total is int && total >= 3, "cross-company count should include all rows");
}

@test:Config
function testListCustomersV3NegativeTopIsIgnored() returns error? {
    // Guards against panicking on negative $top.
    CustomersV3Collection response = check financeClient->listCustomersV3(queries = {top: -1});
    CustomerV3[] rows = <CustomerV3[]>response.value;
    test:assertTrue(rows.length() > 0, "negative \\$top should be ignored, not panic");
}

@test:Config
function testGetCustomerV3() returns error? {
    CustomerV3 c = check financeClient->getCustomersV3(dataAreaId = "USMF", customerAccount = "US-001");
    test:assertEquals(c.OrganizationName, "Contoso Retail");
    test:assertEquals(c.SalesCurrencyCode, "USD");
}

@test:Config
function testGetCustomerV3Select() returns error? {
    CustomerV3 c = check financeClient->getCustomersV3(
        dataAreaId = "USMF",
        customerAccount = "US-001",
        queries = {selectFields: "CustomerAccount,OrganizationName"}
    );
    test:assertEquals(c.CustomerAccount, "US-001");
    test:assertEquals(c.OrganizationName, "Contoso Retail");
    test:assertTrue(c.SalesCurrencyCode is (), "\\$select should have dropped unprojected fields");
}

@test:Config
function testGetCustomerV3MissingKeyReturns404() returns error? {
    CustomerV3|error result = financeClient->getCustomersV3(dataAreaId = "USMF", customerAccount = "DOES-NOT-EXIST");
    test:assertTrue(result is error);
}

// ---- CustomersV3: write --------------------------------------------------

@test:Config
function testCreateCustomerV3Echoes() returns error? {
    CustomerV3 draft = {
        dataAreaId: "USMF",
        CustomerAccount: "US-999",
        OrganizationName: "Integration Test Co"
    };
    CustomerV3 created = check financeClient->createCustomersV3(payload = draft);
    test:assertEquals(created.CustomerAccount, "US-999");
    test:assertTrue(created["@odata.etag"] is string, "mock should stamp an etag on echoed create");
}

@test:Config
function testUpdateCustomerV3Merges() returns error? {
    CustomerV3 patch = {AddressCountryRegionId: "MEX"};
    CustomerV3 updated = check financeClient->updateCustomersV3(
        dataAreaId = "USMF",
        customerAccount = "US-001",
        payload = patch
    );
    test:assertEquals(updated.AddressCountryRegionId, "MEX");
    test:assertEquals(updated.OrganizationName, "Contoso Retail", "PATCH should preserve untouched fields");
}

@test:Config
function testUpdateCustomerV3MissingKeyReturns404() returns error? {
    CustomerV3|error result = financeClient->updateCustomersV3(
        dataAreaId = "USMF",
        customerAccount = "DOES-NOT-EXIST",
        payload = {OrganizationName: "Ghost"}
    );
    test:assertTrue(result is error);
}

@test:Config
function testDeleteCustomerV3() returns error? {
    error? result = financeClient->deleteCustomersV3(dataAreaId = "USMF", customerAccount = "US-001");
    test:assertTrue(result is (), "DELETE on existing key should succeed with 204");
}

@test:Config
function testDeleteCustomerV3MissingKeyReturns404() returns error? {
    error? result = financeClient->deleteCustomersV3(dataAreaId = "USMF", customerAccount = "DOES-NOT-EXIST");
    test:assertTrue(result is error);
}

// ---- MainAccounts --------------------------------------------------------

@test:Config
function testListMainAccounts() returns error? {
    MainAccountsCollection response = check financeClient->listMainAccounts();
    MainAccount[] rows = <MainAccount[]>response.value;
    test:assertTrue(rows.length() >= 3);
}

@test:Config
function testGetMainAccount() returns error? {
    MainAccount acct = check financeClient->getMainAccounts(chartOfAccounts = "Shared", mainAccountId = "401100");
    test:assertEquals(acct.Name, "Sales revenue - Retail");
}

// ---- LedgerJournalHeaders: filter ----------------------------------------

@test:Config
function testListLedgerJournalHeadersFilter() returns error? {
    LedgerJournalHeadersCollection response = check financeClient->listLedgerJournalHeaders(
        queries = {filter: "JournalName eq 'GenJrn'"}
    );
    LedgerJournalHeader[] rows = <LedgerJournalHeader[]>response.value;
    test:assertEquals(rows.length(), 1);
    test:assertEquals(rows[0].JournalName, "GenJrn");
}

@test:Config
function testCreateLedgerJournalHeader() returns error? {
    LedgerJournalHeader draft = {
        dataAreaId: "USMF",
        JournalBatchNumber: "DEMO-001",
        JournalName: "GenJrn",
        Description: "Test journal"
    };
    LedgerJournalHeader created = check financeClient->createLedgerJournalHeaders(payload = draft);
    test:assertEquals(created.JournalBatchNumber, "DEMO-001");
}

// ---- Unmapped entities return empty --------------------------------------

@test:Config
function testListUnmappedEntityReturnsEmpty() returns error? {
    // FiscalCalendars is in the spec but has no stub data in the mock;
    // should still return an empty collection cleanly.
    FiscalCalendarsCollection response = check financeClient->listFiscalCalendars();
    FiscalCalendar[] rows = <FiscalCalendar[]>response.value;
    test:assertEquals(rows.length(), 0);
}
