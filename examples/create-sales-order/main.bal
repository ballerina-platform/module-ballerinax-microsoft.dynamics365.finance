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

// Create a sales order - demonstrates a two-call flow: look up a customer,
// then POST a new SalesOrderHeader that reuses that customer's defaults.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.finance;
import ballerinax/microsoft.dynamics365.finance.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    finance:Client fo = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9090/data"
    );

    finance:CustomerV3 customer = check fo->getCustomer(dataAreaId = "USMF", customerAccount = "US-001");
    io:println(string `Customer: ${customer.OrganizationName ?: ""} (${customer.CustomerAccount ?: ""})`);
    io:println(string `  currency=${customer.SalesCurrencyCode ?: ""}  terms=${customer.PaymentTermsName ?: ""}`);

    finance:SalesOrderHeaderV2 draft = {
        dataAreaId: "USMF",
        SalesOrderNumber: "SO-DEMO-001",
        SalesOrderName: "Demo order via Ballerina",
        OrderingCustomerAccountNumber: customer.CustomerAccount,
        InvoiceCustomerAccountNumber: customer.CustomerAccount,
        RequestedShippingDate: "2026-05-20",
        CurrencyCode: customer.SalesCurrencyCode,
        PaymentTermsName: customer.PaymentTermsName,
        DeliveryModeCode: "Ground",
        CustomerRequisitionNumber: "REF-DEMO-001"
    };

    finance:SalesOrderHeaderV2 created = check fo->createSalesOrder(payload = draft);
    io:println("");
    io:println(string `Created ${created.SalesOrderNumber ?: ""}`);
    io:println(string `  etag:  ${created["@odata.etag"].toString()}`);
    io:println(string `  name:  ${created.SalesOrderName ?: ""}`);

    check mockListener.gracefulStop();
}
