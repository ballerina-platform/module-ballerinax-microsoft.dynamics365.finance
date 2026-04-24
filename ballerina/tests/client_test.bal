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
function testListCustomersV3CrossCompany() returns error? {
    CustomersV3Collection response = check financeClient->listCustomersV3(queries = {crossCompany: true, count: true});
    int? count = <int?>response["@odata.count"];
    test:assertTrue(count is int && count >= 3, "cross-company should return all seeded customers");
}

@test:Config
function testGetCustomerV3() returns error? {
    CustomerV3 c = check financeClient->getCustomersV3(dataAreaId = "USMF", customerAccount = "US-001");
    test:assertEquals(c.OrganizationName, "Contoso Retail");
}

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
function testGetCustomerV3MissingKeyReturns404() returns error? {
    CustomerV3|error result = financeClient->getCustomersV3(dataAreaId = "USMF", customerAccount = "DOES-NOT-EXIST");
    test:assertTrue(result is error, "GET on missing key should surface an error from the 404");
}

@test:Config
function testListMainAccounts() returns error? {
    MainAccountsCollection response = check financeClient->listMainAccounts();
    MainAccount[] rows = <MainAccount[]>response.value;
    test:assertTrue(rows.length() >= 3, "stub data has 3 main accounts");
}

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
function testListUnmappedEntityReturnsEmpty() returns error? {
    // Fiscal calendars are in the spec but have no stub data; mock should
    // return an empty collection without crashing.
    FiscalCalendarsCollection response = check financeClient->listFiscalCalendars();
    FiscalCalendar[] rows = <FiscalCalendar[]>response.value;
    test:assertEquals(rows.length(), 0);
}
