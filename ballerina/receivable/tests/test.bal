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

import ballerina/http;
import ballerina/test;
import ballerinax/microsoft.dynamics365.finance.receivable.mock as mockSrv;

configurable boolean isTestOnLiveServer = false;

configurable string serviceUrl = "http://localhost:9090/data";
configurable string clientId = "mock-client-id";
configurable string clientSecret = "mock-client-secret";
configurable string tenantId = "mock-tenant-id";

http:Listener mockListener = check new (9090);

@test:BeforeSuite
function startMock() returns error? {
    if !isTestOnLiveServer {
        mockListener = check mockSrv:startMock();
    }
}

@test:AfterSuite
function stopMock() returns error? {
    if !isTestOnLiveServer {
        check mockListener.gracefulStop();
    }
}

function buildClient() returns Client|error {
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
        {
            auth: {
                tokenUrl: "http://localhost:9090/token",
                clientId,
                clientSecret
            }
        },
        serviceUrl
    );
}

@test:Config
function testListAdvLines() returns error? {
    Client cl = check buildClient();
    AdvLinesCollection response = check cl->listAdvLines();
    test:assertTrue(response.value !is (), "should return a valid collection");
}

