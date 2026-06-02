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

// List customers — default company, cross-company override, and name filter.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.finance.receivable;
import ballerinax/microsoft.dynamics365.finance.receivable.mock as mockSrv;

public function main() returns error? {
    http:Listener mockListener = check mockSrv:startMock();

    receivable:Client fo = check new (
        {
            auth: {
                tokenUrl: "http://localhost:9090/token",
                clientId: "mock-client-id",
                clientSecret: "mock-client-secret"
            }
        },
        "http://localhost:9090/data"
    );

    io:println("Default company (USMF) customers:");
    receivable:CustomersV3Collection page = check fo->listCustomersV3();
    foreach receivable:CustomerV3 c in page.value ?: [] {
        io:println(string `  ${c.customerAccount ?: ""}   ${c.organizationName ?: ""}   [${c.dataAreaId ?: ""}]`);
    }

    io:println("");
    io:println("All companies (cross-company):");
    receivable:CustomersV3Collection all = check fo->listCustomersV3(queries = {crossCompany: true});
    foreach receivable:CustomerV3 c in all.value ?: [] {
        io:println(string `  ${c.customerAccount ?: ""}   ${c.organizationName ?: ""}   [${c.dataAreaId ?: ""}]`);
    }

    io:println("");
    io:println("Filter — contains 'Contoso':");
    receivable:CustomersV3Collection filtered = check fo->listCustomersV3(
        queries = {filter: "contains(OrganizationName,'Contoso')"}
    );
    foreach receivable:CustomerV3 c in filtered.value ?: [] {
        io:println(string `  ${c.customerAccount ?: ""}   ${c.organizationName ?: ""}`);
    }

    check mockListener.gracefulStop();
}
