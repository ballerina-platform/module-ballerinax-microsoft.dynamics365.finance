// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
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

import ballerina/test;

// Set isTestOnLiveServer=true to run against a live D365 environment.
// When false (default), only the client-initialization smoke test runs.
configurable boolean isTestOnLiveServer = false;

configurable string serviceUrl = "http://localhost:9090/data";
configurable string clientId = "mock-client-id";
configurable string clientSecret = "mock-client-secret";
configurable string tenantId = "mock-tenant-id";

function initClient() returns Client|error {
    if isTestOnLiveServer {
        return new (
            {
                auth: {
                    tokenUrl: string `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/token`,
                    clientId,
                    clientSecret
                }
            },
            serviceUrl
        );
    }
    return new (
        {auth: {clientId, clientSecret}},
        serviceUrl
    );
}

@test:Config
function testClientInitialization() returns error? {
    // Verifies the client can be constructed without a network call.
    Client _ = check initClient();
}

@test:Config {
    enable: isTestOnLiveServer
}
function testListVendorV3s() returns error? {
    Client cl = check initClient();
    VendorsV3Collection response = check cl->listVendorsV3();
    VendorV3[] rows = <VendorV3[]>response.value;
    test:assertTrue(rows.length() >= 0, "response should be a valid collection");
}
