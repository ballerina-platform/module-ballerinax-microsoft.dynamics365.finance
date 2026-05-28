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

// List existing ledger journals, then post a new daily journal header.

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

    io:println("Existing ledger journals:");
    ledger:LedgerJournalHeadersCollection page = check fo->listLedgerJournalHeaders();
    foreach ledger:LedgerJournalHeader j in page.value ?: [] {
        io:println(string `  ${j.journalBatchNumber}   ${j.journalName ?: ""}   posted=${j.isPosted ?: ""}   ${j.description ?: ""}`);
    }

    ledger:LedgerJournalHeader draft = {
        dataAreaId: "USMF",
        journalBatchNumber: "DEMO-0001",
        journalName: "GenJrn",
        description: "Posted via Ballerina",
        isPosted: "No",
        journalTotalDebit: 0.0d,
        journalTotalCredit: 0.0d
    };
    ledger:LedgerJournalHeader created = check fo->createLedgerJournalHeaders(payload = draft);
    io:println("");
    io:println(string `Created: ${created.journalBatchNumber}`);
    io:println(string `  etag:  ${(created["@odata.etag"] ?: "").toString()}`);

    check mockListener.gracefulStop();
}
