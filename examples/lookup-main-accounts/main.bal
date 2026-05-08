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

// Look up main accounts from the chart of accounts, then fetch one by key.
// MainAccount lives in the `ledger` submodule.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.finance.common;
import ballerinax/microsoft.dynamics365.finance.ledger;
import ballerinax/microsoft.dynamics365.finance.mock.server;

public function main() returns error? {
    http:Listener mockListener = check server:startMock();

    common:Connection conn = check new (
        config = {auth: {token: "demo-bearer-token"}},
        serviceUrl = "http://localhost:9090/data"
    );
    ledger:Client led = check new (conn);

    io:println("Main accounts in the Shared chart:");
    ledger:MainAccountsCollection page = check led->listMainAccounts();
    foreach ledger:MainAccount m in page.value ?: [] {
        io:println(string `  ${m.MainAccountId ?: ""}   ${m.Name ?: ""}   [${m.MainAccountType ?: ""}]`);
    }

    io:println("");
    io:println("Detail for account 401100:");
    ledger:MainAccount revenue = check led->getMainAccounts(chartOfAccounts = "Shared", mainAccountId = "401100");
    io:println(string `  id:        ${revenue.MainAccountId ?: ""}`);
    io:println(string `  name:      ${revenue.Name ?: ""}`);
    io:println(string `  type:      ${revenue.MainAccountType ?: ""}`);

    check mockListener.gracefulStop();
}
