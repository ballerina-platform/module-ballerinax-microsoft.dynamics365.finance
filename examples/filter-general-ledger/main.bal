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
