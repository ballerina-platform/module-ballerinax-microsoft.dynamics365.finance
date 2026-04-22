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

// Filter general-ledger entries - demonstrates $filter, $orderby, $count,
// and reading from the envelope wrapper (`@odata.count`).

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

    finance:GeneralJournalAccountEntriesCollection entries = check fo->listGeneralJournalAccountEntries(queries = {
        filter: "AccountType eq 'Ledger'",
        orderBy: "AccountingCurrencyAmount desc",
        count: true
    });

    int total = <int>(entries["@odata.count"] ?: 0);
    io:println(string `Ledger entries (${total} total), sorted by amount desc:`);

    foreach finance:GeneralJournalAccountEntry e in <finance:GeneralJournalAccountEntry[]>entries.value {
        io:println(string `  ${e.AccountingDate ?: ""}   ${padRight(e.MainAccountId ?: "", 8)}   ${padRight(e.TransactionCurrencyCode ?: "", 4)} ${formatAmount(e.AccountingCurrencyAmount)}   ${e.Text ?: ""}`);
    }

    check mockListener.gracefulStop();
}

function padRight(string s, int width) returns string {
    if s.length() >= width {
        return s;
    }
    string padded = s;
    foreach int _ in s.length() ..< width {
        padded += " ";
    }
    return padded;
}

function formatAmount(decimal? amount) returns string {
    decimal value = amount ?: 0d;
    string s = value.toString();
    int pad = 12 - s.length();
    if pad <= 0 {
        return s;
    }
    string padded = "";
    foreach int _ in 0 ..< pad {
        padded += " ";
    }
    return padded + s;
}
