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
