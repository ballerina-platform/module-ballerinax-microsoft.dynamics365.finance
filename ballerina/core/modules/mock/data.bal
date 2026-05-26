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

// Stub data for the core module mock: ExchangeRates, PaymentTerms, Currencies.

final readonly & json[] exchangeRates = [
    {"@odata.etag": "W/\"ER01\"", "RateTypeName": "Default", "FromCurrency": "USD", "ToCurrency": "EUR", "StartDate": "2026-04-01", "Rate": 0.92},
    {"@odata.etag": "W/\"ER02\"", "RateTypeName": "Default", "FromCurrency": "USD", "ToCurrency": "GBP", "StartDate": "2026-04-01", "Rate": 0.79},
    {"@odata.etag": "W/\"ER03\"", "RateTypeName": "Default", "FromCurrency": "USD", "ToCurrency": "JPY", "StartDate": "2026-04-01", "Rate": 154.20}
];

final readonly & json[] paymentTerms = [
    {"@odata.etag": "W/\"PT01\"", "dataAreaId": "USMF", "Name": "Net30", "Description": "Net 30 days", "NumberOfDays": 30},
    {"@odata.etag": "W/\"PT02\"", "dataAreaId": "USMF", "Name": "Net15", "Description": "Net 15 days", "NumberOfDays": 15},
    {"@odata.etag": "W/\"PT03\"", "dataAreaId": "USMF", "Name": "Net60", "Description": "Net 60 days", "NumberOfDays": 60}
];

final readonly & json[] currencies = [
    {"@odata.etag": "W/\"CUR01\"", "CurrencyCode": "USD", "CurrencyName": "US Dollar", "Symbol": "$"},
    {"@odata.etag": "W/\"CUR02\"", "CurrencyCode": "EUR", "CurrencyName": "Euro", "Symbol": "€"},
    {"@odata.etag": "W/\"CUR03\"", "CurrencyCode": "GBP", "CurrencyName": "British Pound", "Symbol": "£"}
];

isolated function dataFor(string entitySet) returns json[] {
    match entitySet {
        "ExchangeRates" => { return exchangeRates; }
        "PaymentTerms" => { return paymentTerms; }
        "Currencies" => { return currencies; }
        _ => { return []; }
    }
}
