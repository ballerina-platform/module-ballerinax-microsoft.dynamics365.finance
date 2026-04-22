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

// Integration tests. A mock D365 F&O service (modules/mock.server) is started
// before the suite, a Client is pointed at it, every remote function is
// exercised, and shape/value assertions are made against the stub data
// shipped in modules/mock.server/data.bal.

import ballerina/http;
import ballerina/test;
import ballerinax/microsoft.dynamics365.finance.mock.server;

const int MOCK_PORT = 9090;
const string MOCK_URL = "http://localhost:9090/data";

http:Listener mockListener = check new (MOCK_PORT);
Client financeClient = check new (
    config = {
        auth: {token: "demo-bearer-token"}
    },
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

// ---- Customers ----------------------------------------------------------

@test:Config
function testListCustomersDefaultCompany() returns error? {
    CustomersV3Collection response = check financeClient->listCustomers();
    CustomerV3[]? value = response.value;
    test:assertTrue(value is CustomerV3[]);
    CustomerV3[] customers = <CustomerV3[]>value;
    test:assertTrue(customers.length() >= 3, "expected at least 3 customers in default (USMF) company");
    foreach CustomerV3 c in customers {
        test:assertEquals(c.dataAreaId, "USMF", "without cross-company, every row should be in the default company");
    }
}

@test:Config
function testListCustomersCrossCompanyAndCount() returns error? {
    CustomersV3Collection response = check financeClient->listCustomers(queries = {crossCompany: true, count: true});
    int? count = <int?>response["@odata.count"];
    test:assertTrue(count is int && count >= 5, "cross-company should return all 5 seeded customers with count");
}

@test:Config
function testListCustomersFilterAndTop() returns error? {
    CustomersV3Collection response = check financeClient->listCustomers(
        queries = {filter: "contains(OrganizationName,'Contoso')", top: 10}
    );
    CustomerV3[] filtered = <CustomerV3[]>response.value;
    test:assertEquals(filtered.length(), 1, "only Contoso Retail should match");
    test:assertEquals(filtered[0].OrganizationName, "Contoso Retail");
}

@test:Config
function testGetCustomer() returns error? {
    CustomerV3 c = check financeClient->getCustomer(dataAreaId = "USMF", customerAccount = "US-001");
    test:assertEquals(c.CustomerAccount, "US-001");
    test:assertEquals(c.OrganizationName, "Contoso Retail");
}

@test:Config
function testGetCustomerSelect() returns error? {
    CustomerV3 c = check financeClient->getCustomer(
        dataAreaId = "USMF",
        customerAccount = "US-001",
        queries = {selectFields: "CustomerAccount,OrganizationName"}
    );
    test:assertEquals(c.CustomerAccount, "US-001");
    test:assertEquals(c.OrganizationName, "Contoso Retail");
    test:assertTrue(c.CreditLimit is (), "$select should have dropped unprojected fields");
}

@test:Config
function testCreateCustomer() returns error? {
    CustomerV3 newCustomer = {
        dataAreaId: "USMF",
        CustomerAccount: "US-999",
        OrganizationName: "Integration Test Co",
        CustomerGroupId: "10",
        AddressCountryRegionId: "USA",
        SalesCurrencyCode: "USD"
    };
    CustomerV3 created = check financeClient->createCustomer(payload = newCustomer);
    test:assertEquals(created.CustomerAccount, "US-999");
    test:assertTrue(created["@odata.etag"] is string, "echoed record should carry a server-stamped etag");
}

@test:Config
function testUpdateCustomer() returns error? {
    CustomerV3 patch = {CreditLimit: 999999.00, CreditRating: "AA+"};
    CustomerV3 updated = check financeClient->updateCustomer(
        dataAreaId = "USMF",
        customerAccount = "US-001",
        payload = patch
    );
    test:assertEquals(updated.CreditLimit, 999999.00d);
    test:assertEquals(updated.CreditRating, "AA+");
    test:assertEquals(updated.OrganizationName, "Contoso Retail", "merged PATCH should preserve untouched fields");
}

@test:Config
function testDeleteCustomer() returns error? {
    error? result = financeClient->deleteCustomer(dataAreaId = "USMF", customerAccount = "US-001");
    test:assertTrue(result is (), "DELETE should succeed with 204");
}

// ---- Vendors -------------------------------------------------------------

@test:Config
function testListVendors() returns error? {
    VendorsV2Collection response = check financeClient->listVendors();
    VendorV2[] vendors = <VendorV2[]>response.value;
    test:assertTrue(vendors.length() >= 3);
}

@test:Config
function testGetVendor() returns error? {
    VendorV2 v = check financeClient->getVendor(dataAreaId = "USMF", vendorAccountNumber = "V-001");
    test:assertEquals(v.VendorName, "Litware Components");
    test:assertEquals(v.VendorHoldingStatus, "No");
}

@test:Config
function testCreateVendor() returns error? {
    VendorV2 newVendor = {
        dataAreaId: "USMF",
        VendorAccountNumber: "V-999",
        VendorName: "Test Vendor Inc.",
        VendorCurrencyCode: "USD",
        PaymentTermsName: "Net30"
    };
    VendorV2 created = check financeClient->createVendor(payload = newVendor);
    test:assertEquals(created.VendorAccountNumber, "V-999");
}

@test:Config
function testUpdateVendorHold() returns error? {
    VendorV2 patched = check financeClient->updateVendor(
        dataAreaId = "USMF",
        vendorAccountNumber = "V-003",
        payload = {VendorHoldingStatus: "All"}
    );
    test:assertEquals(patched.VendorHoldingStatus, "All");
}

// ---- Released Products ---------------------------------------------------

@test:Config
function testListReleasedProducts() returns error? {
    ReleasedProductsV2Collection response = check financeClient->listReleasedProducts(
        queries = {orderBy: "SalesPrice desc", top: 2}
    );
    ReleasedProductV2[] products = <ReleasedProductV2[]>response.value;
    test:assertEquals(products.length(), 2);
    test:assertTrue(<decimal>products[0].SalesPrice >= <decimal>products[1].SalesPrice,
        "results should be sorted by SalesPrice descending");
}

@test:Config
function testGetReleasedProduct() returns error? {
    ReleasedProductV2 p = check financeClient->getReleasedProduct(dataAreaId = "USMF", itemNumber = "ITM-1001");
    test:assertEquals(p.ProductName, "Surface Pro Hub");
    test:assertEquals(p.ProductType, "Item");
}

// ---- Sales Orders --------------------------------------------------------

@test:Config
function testListSalesOrdersBackorderOnly() returns error? {
    SalesOrderHeadersV2Collection response = check financeClient->listSalesOrders(
        queries = {filter: "SalesOrderStatus eq 'Backorder'"}
    );
    SalesOrderHeaderV2[] orders = <SalesOrderHeaderV2[]>response.value;
    test:assertTrue(orders.length() >= 1);
    foreach SalesOrderHeaderV2 o in orders {
        test:assertEquals(o.SalesOrderStatus, "Backorder");
    }
}

@test:Config
function testGetSalesOrder() returns error? {
    SalesOrderHeaderV2 o = check financeClient->getSalesOrder(
        dataAreaId = "USMF",
        salesOrderNumber = "SO-100045"
    );
    test:assertEquals(o.OrderingCustomerAccountNumber, "US-001");
}

@test:Config
function testCreateSalesOrder() returns error? {
    SalesOrderHeaderV2 draft = {
        dataAreaId: "USMF",
        SalesOrderNumber: "SO-200999",
        OrderingCustomerAccountNumber: "US-001",
        InvoiceCustomerAccountNumber: "US-001",
        CurrencyCode: "USD",
        RequestedShippingDate: "2026-05-20"
    };
    SalesOrderHeaderV2 created = check financeClient->createSalesOrder(payload = draft);
    test:assertEquals(created.SalesOrderNumber, "SO-200999");
}

// ---- Purchase Orders -----------------------------------------------------

@test:Config
function testListPurchaseOrdersPaging() returns error? {
    PurchaseOrderHeadersV2Collection page1 = check financeClient->listPurchaseOrders(
        queries = {top: 2, skip: 0, count: true, crossCompany: true}
    );
    PurchaseOrderHeaderV2[] rows1 = <PurchaseOrderHeaderV2[]>page1.value;
    test:assertEquals(rows1.length(), 2);
    int? total = <int?>page1["@odata.count"];
    test:assertTrue(total is int && total >= 5);

    PurchaseOrderHeadersV2Collection page2 = check financeClient->listPurchaseOrders(
        queries = {top: 2, skip: 2, crossCompany: true}
    );
    PurchaseOrderHeaderV2[] rows2 = <PurchaseOrderHeaderV2[]>page2.value;
    test:assertTrue(rows2.length() > 0);
    test:assertNotEquals(rows1[0].PurchaseOrderNumber, rows2[0].PurchaseOrderNumber);
}

@test:Config
function testGetPurchaseOrder() returns error? {
    PurchaseOrderHeaderV2 po = check financeClient->getPurchaseOrder(
        dataAreaId = "USMF",
        purchaseOrderNumber = "PO-200019"
    );
    test:assertEquals(po.VendorAccountNumber, "V-001");
    test:assertEquals(po.ApprovalStatus, "Approved");
}

// ---- Finance -------------------------------------------------------------

@test:Config
function testListGeneralJournalAccountEntries() returns error? {
    GeneralJournalAccountEntriesCollection response = check financeClient->listGeneralJournalAccountEntries(
        queries = {filter: "AccountType eq 'Ledger'"}
    );
    GeneralJournalAccountEntry[] entries = <GeneralJournalAccountEntry[]>response.value;
    test:assertTrue(entries.length() >= 1);
    foreach GeneralJournalAccountEntry e in entries {
        test:assertEquals(e.AccountType, "Ledger");
    }
}

@test:Config
function testListLedgerJournalHeaders() returns error? {
    LedgerJournalHeadersCollection response = check financeClient->listLedgerJournalHeaders();
    LedgerJournalHeader[] journals = <LedgerJournalHeader[]>response.value;
    test:assertTrue(journals.length() >= 2);
}

@test:Config
function testListExchangeRatesFilterFrom() returns error? {
    ExchangeRatesCollection response = check financeClient->listExchangeRates(
        queries = {filter: "FromCurrencyCode eq 'GBP'"}
    );
    ExchangeRate[] rates = <ExchangeRate[]>response.value;
    test:assertEquals(rates.length(), 1);
    test:assertEquals(rates[0].FromCurrencyCode, "GBP");
    test:assertEquals(rates[0].ToCurrencyCode, "USD");
}

@test:Config
function testListCustomerGroups() returns error? {
    CustomerGroupsCollection response = check financeClient->listCustomerGroups(
        queries = {crossCompany: true}
    );
    CustomerGroup[] groups = <CustomerGroup[]>response.value;
    test:assertTrue(groups.length() >= 5, "cross-company should yield all 5 seeded groups");
}

// ---- Review-feedback fixes -----------------------------------------------

@test:Config
function testFilterByNumericEqMatchesDecimalSeed() returns error? {
    // Seeded CreditLimit for US-001 is 250000.00 (parses as decimal).
    // Filter `eq 250000` previously took the int branch and returned nothing;
    // decimal-based comparison should now match.
    CustomersV3Collection response = check financeClient->listCustomers(
        queries = {filter: "CreditLimit eq 250000"}
    );
    CustomerV3[] rows = <CustomerV3[]>response.value;
    test:assertEquals(rows.length(), 1, "filter on numeric equality should match the seeded customer");
    test:assertEquals(rows[0].CustomerAccount, "US-001");
}

@test:Config
function testOrderByNumericDescSortsNumerically() returns error? {
    // Seeded glEntries amounts: 12500, -11500, -1000, -7400, 7400. Lexicographic
    // sort would produce 7400 > 12500, wrong. Numeric desc must put 12500 first.
    GeneralJournalAccountEntriesCollection response = check financeClient->listGeneralJournalAccountEntries(
        queries = {orderBy: "AccountingCurrencyAmount desc"}
    );
    GeneralJournalAccountEntry[] rows = <GeneralJournalAccountEntry[]>response.value;
    test:assertTrue(rows.length() >= 3);
    decimal first = rows[0].AccountingCurrencyAmount ?: 0d;
    decimal second = rows[1].AccountingCurrencyAmount ?: 0d;
    test:assertTrue(first >= second, "numeric desc should put the larger amount first");
}

@test:Config
function testUpdateCustomerMissingKeyReturns404() returns error? {
    CustomerV3 patch = {CreditLimit: 111.00};
    CustomerV3|error result = financeClient->updateCustomer(
        dataAreaId = "USMF",
        customerAccount = "DOES-NOT-EXIST",
        payload = patch
    );
    test:assertTrue(result is error, "PATCH on missing key should surface an error from the 404");
}

@test:Config
function testDeleteCustomerMissingKeyReturns404() returns error? {
    error? result = financeClient->deleteCustomer(
        dataAreaId = "USMF",
        customerAccount = "DOES-NOT-EXIST"
    );
    test:assertTrue(result is error, "DELETE on missing key should surface an error from the 404");
}

@test:Config
function testNegativeTopDoesNotPanic() returns error? {
    // Previously `filtered.slice(0, -1)` would panic. With the guard, negative
    // values are ignored and the full page is returned.
    CustomersV3Collection response = check financeClient->listCustomers(
        queries = {top: -1}
    );
    CustomerV3[] rows = <CustomerV3[]>response.value;
    test:assertTrue(rows.length() > 0, "negative $top should be ignored, not panic");
}
