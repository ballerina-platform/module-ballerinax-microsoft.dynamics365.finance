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

// Top-level module marker. Connector functionality lives in the per-domain
// submodules (`common`, `customer`, `vendor`, `ledger`, `tax`, ...).
//
// To use the connector:
//
//     import ballerinax/microsoft.dynamics365.finance.common;
//     import ballerinax/microsoft.dynamics365.finance.customer;
//
//     common:Connection conn = check new (
//         config = {auth: {token: "<bearer>"}},
//         serviceUrl = "https://<tenant>.operations.dynamics.com/data"
//     );
//     customer:Client cust = check new (conn);
//     customer:CustomersV3Collection page = check cust->listCustomersV3();
