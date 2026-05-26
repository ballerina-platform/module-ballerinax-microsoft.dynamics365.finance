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

# Configuration for the mock server.
public type MockConfig record {|
    # Port to listen on (default 9090)
    int port = 9090;
    # Default company used when cross-company is not requested
    string defaultCompany = "USMF";
|};

# Start a lightweight mock OData + OAuth2-token server.
# Returns the listener so the caller can stop it cleanly.
public isolated function startMock(MockConfig config = {}) returns http:Listener|error {
    http:Listener ln = check new (config.port);
    check ln.attach(new TokenService(), "/token");
    check ln.attach(new ODataService(config), "/data");
    check ln.'start();
    return ln;
}

isolated service class TokenService {
    *http:Service;

    // Return a synthetic bearer token for any client-credentials request.
    isolated resource function post .(http:Caller caller, http:Request req) returns error? {
        check caller->respond({
            "access_token": "mock-bearer-token",
            "token_type": "Bearer",
            "expires_in": 3600
        });
    }
}

isolated service class ODataService {
    *http:Service;
    private final MockConfig & readonly config;

    isolated function init(MockConfig config) {
        self.config = config.cloneReadOnly();
    }

    isolated resource function 'default [string... segments](http:Request req) returns http:Response|error {
        http:Response response = new;
        if segments.length() == 0 {
            response.statusCode = 200;
            response.setJsonPayload({"@odata.context": "$metadata", "value": []});
            return response;
        }
        string firstSeg = segments[0];
        if firstSeg == "$metadata" {
            response.statusCode = 200;
            response.setTextPayload("<edmx:Edmx/>", "application/xml");
            return response;
        }

        [string, map<string>] parsed = parseEntitySetAndKey(firstSeg);
        string entitySet = parsed[0];
        map<string> key = parsed[1];
        ODataQueries q = parseQueries(req.getQueryParams());
        string method = req.method;

        string contextBase = string `http://localhost:${self.config.port}/data/`;

        if key.length() == 0 {
            return self.handleCollection(method, entitySet, q, contextBase, req);
        }
        return self.handleEntity(method, entitySet, key, q, req);
    }

    private isolated function handleCollection(string method, string entitySet, ODataQueries q,
            string contextBase, http:Request req) returns http:Response|error {
        if method == "GET" {
            json[] data = dataFor(entitySet);
            map<json> envelope = buildCollection(contextBase, entitySet, data, q, self.config.defaultCompany);
            http:Response response = new;
            response.statusCode = 200;
            response.setJsonPayload(envelope);
            return response;
        }
        if method == "POST" {
            json payload = check req.getJsonPayload();
            http:Response response = new;
            response.statusCode = 201;
            response.setJsonPayload(stampEtag(payload));
            return response;
        }
        http:Response r = new;
        r.statusCode = 405;
        r.setJsonPayload({"error": {"code": "MethodNotAllowed", "message": string `${method} not supported on collection`}});
        return r;
    }

    private isolated function handleEntity(string method, string entitySet, map<string> key,
            ODataQueries q, http:Request req) returns http:Response|error {
        json[] data = dataFor(entitySet);
        if method == "GET" {
            json? found = findByKey(data, key);
            if found is () {
                return notFound(entitySet, key);
            }
            string? selectExpr = q.selectFields;
            if selectExpr is string {
                found = projectRow(found, re `,`.split(selectExpr));
            }
            http:Response response = new;
            response.statusCode = 200;
            response.setJsonPayload(found);
            return response;
        }
        if method == "PATCH" {
            json? existing = findByKey(data, key);
            if existing is () {
                return notFound(entitySet, key);
            }
            json payload = check req.getJsonPayload();
            json merged = mergeJson(existing, payload);
            http:Response response = new;
            response.statusCode = 200;
            response.setJsonPayload(stampEtag(merged));
            return response;
        }
        if method == "DELETE" {
            json? existing = findByKey(data, key);
            if existing is () {
                return notFound(entitySet, key);
            }
            http:Response response = new;
            response.statusCode = 204;
            return response;
        }
        http:Response r = new;
        r.statusCode = 405;
        r.setJsonPayload({"error": {"code": "MethodNotAllowed", "message": string `${method} not supported`}});
        return r;
    }
}

isolated function stampEtag(json payload) returns json {
    if !(payload is map<json>) {
        return payload;
    }
    map<json> stamped = {};
    foreach [string, json] [k, v] in payload.entries() {
        stamped[k] = v;
    }
    stamped["@odata.etag"] = string `W/"${0.toString()}"`;
    return stamped;
}

isolated function mergeJson(json base, json patch) returns json {
    if !(base is map<json>) || !(patch is map<json>) {
        return patch;
    }
    map<json> merged = {};
    foreach [string, json] [k, v] in base.entries() {
        merged[k] = v;
    }
    foreach [string, json] [k, v] in patch.entries() {
        merged[k] = v;
    }
    return merged;
}

isolated function notFound(string entitySet, map<string> key) returns http:Response {
    http:Response r = new;
    r.statusCode = 404;
    r.setJsonPayload({
        "error": {
            "code": "Resource_EntityNotFound",
            "message": string `No ${entitySet} record matched key ${key.toString()}.`
        }
    });
    return r;
}
