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

// Look up main accounts from the Shared chart of accounts, then fetch one by key.

import ballerina/http;
import ballerina/io;
import ballerinax/microsoft.dynamics365.finance.ledger;
import ballerinax/microsoft.dynamics365.finance.ledger.mock as mockSrv;

public function main() returns error? {
    http:Listener mockListener = check mockSrv:startMock();

    ledger:Client fo = check new (
        {
            auth: {
                tokenUrl: "http://localhost:9090/token",
                clientId: "mock-client-id",
                clientSecret: "mock-client-secret"
            }
        },
        "http://localhost:9090/data"
    );

    io:println("Main accounts in the Shared chart:");
    ledger:MainAccountsCollection page = check fo->listMainAccounts();
    foreach ledger:MainAccount m in page.value ?: [] {
        io:println(string `  ${m.mainAccountId}   ${m.name ?: ""}   [${m.mainAccountType ?: ""}]`);
    }

    io:println("");
    io:println("Detail for account 401100:");
    ledger:MainAccount revenue = check fo->getMainAccounts(chartOfAccounts = "Shared", mainAccountId = "401100");
    io:println(string `  id:    ${revenue.mainAccountId}`);
    io:println(string `  name:  ${revenue.name ?: ""}`);
    io:println(string `  type:  ${revenue.mainAccountType ?: ""}`);

    check mockListener.gracefulStop();
}
