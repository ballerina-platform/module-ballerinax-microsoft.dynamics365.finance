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

// A workflow that pulls together data from three submodules behind a single
// shared Connection: customers (`customer`), the payment-terms catalogue
// (`payment`), and exchange rates (`currency`).
//
// The point: build the connection once, then hand it to as many domain
// clients as the workflow needs. There is exactly one underlying http:Client
// regardless of how many submodules participate.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.finance.common;
import ballerinax/microsoft.dynamics365.finance.currency;
import ballerinax/microsoft.dynamics365.finance.customer;
import ballerinax/microsoft.dynamics365.finance.payment;
import ballerinax/microsoft.dynamics365.finance.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    // Build the shared connection once.
    common:Connection conn = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9090/data"
    );

    // Inject it into every domain client this workflow needs.
    customer:Client cust = check new (conn);
    payment:Client pay = check new (conn);
    currency:Client cur = check new (conn);

    io:println("Customers (USMF):");
    customer:CustomersV3Collection customers = check cust->listCustomersV3();
    foreach customer:CustomerV3 c in customers.value ?: [] {
        io:println(string `  ${c.CustomerAccount ?: ""}   ${c.OrganizationName ?: ""}   currency=${c.SalesCurrencyCode ?: ""}`);
    }

    io:println("");
    io:println("Payment terms catalogue:");
    payment:PaymentTermsCollection terms = check pay->listPaymentTerms();
    foreach payment:PaymentTerm t in terms.value ?: [] {
        io:println(string `  ${t.Name ?: ""}   ${t.Description ?: ""}`);
    }

    io:println("");
    io:println("Active exchange rates (USD source):");
    currency:ExchangeRatesCollection rates = check cur->listExchangeRates(
        queries = {filter: "FromCurrency eq 'USD'"}
    );
    foreach currency:ExchangeRate r in rates.value ?: [] {
        io:println(string `  ${r.FromCurrency ?: ""} -> ${r.ToCurrency ?: ""}   rate=${r.Rate ?: 0d}   from=${r.StartDate ?: ""}`);
    }

    check mockListener.gracefulStop();
}
