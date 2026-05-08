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

// List existing ledger journals, then create a new daily journal header.
// LedgerJournal* lives in the `ledger` submodule.

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

    io:println("Existing ledger journals:");
    ledger:LedgerJournalHeadersCollection page = check led->listLedgerJournalHeaders();
    foreach ledger:LedgerJournalHeader j in page.value ?: [] {
        io:println(string `  ${j.JournalBatchNumber ?: ""}   ${j.JournalName ?: ""}   posted=${j.IsPosted ?: ""}   ${j.Description ?: ""}`);
    }

    ledger:LedgerJournalHeader draft = {
        dataAreaId: "USMF",
        JournalBatchNumber: "DEMO-0001",
        JournalName: "GenJrn",
        Description: "Posted via Ballerina",
        IsPosted: "No"
    };
    ledger:LedgerJournalHeader created = check led->createLedgerJournalHeaders(payload = draft);
    io:println("");
    io:println(string `Created ${created.JournalBatchNumber ?: ""}`);
    io:println(string `  etag:  ${created["@odata.etag"].toString()}`);

    check mockListener.gracefulStop();
}
