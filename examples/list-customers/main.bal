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

// List customers — showcases default-company scoping, cross-company override,
// and OData $filter / $top.

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

    io:println("Default company (USMF) - top 5 customers:");
    finance:CustomersV3Collection defaultPage = check fo->listCustomers(queries = {top: 5});
    printCustomers(<finance:CustomerV3[]>defaultPage.value);

    io:println("\nAll companies, OrganizationName contains 'trad':");
    finance:CustomersV3Collection matches = check fo->listCustomers(queries = {
        filter: "contains(OrganizationName,'trad')",
        crossCompany: true
    });
    printCustomers(<finance:CustomerV3[]>matches.value);

    check mockListener.gracefulStop();
}

function printCustomers(finance:CustomerV3[] rows) {
    foreach finance:CustomerV3 c in rows {
        io:println(string `  ${c.CustomerAccount ?: ""}   ${c.OrganizationName ?: ""}   [${c.dataAreaId ?: ""}]`);
    }
}
