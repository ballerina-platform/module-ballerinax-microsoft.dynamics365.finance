_Author_: Ballerina OpenAPI Tool \
_Created_: 2025-07-30 \
_Updated_: 2025-07-30 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the comprehensive sanitization and enhancement done on top of the official OpenAPI specification from Microsoft Dynamics 365 Finance. 
The OpenAPI specification is obtained from Microsoft Dynamics 365 Finance APIs and has been significantly enhanced to provide proper response types and improved usability.

## Issues Addressed

1. **Missing Response Schemas**: The original OpenAPI specification only had generic "Successful response" descriptions without proper response schemas, resulting in Ballerina client methods returning `error?` instead of actual data types.

2. **Parameter Names with Special Characters**: OData parameters like `$select`, `$filter`, and `cross-company` contained special characters that are not valid Ballerina identifiers.

3. **Client Method Type**: Remote methods were preferred over resource methods for better API interaction patterns.

4. **Incomplete Type Definitions**: The original specification lacked comprehensive data entity schemas for customers, vendors, products, and other Microsoft Dynamics 365 Finance entities.

## Major Enhancements Applied

### 1. **Comprehensive Response Schema Definitions**
Added detailed response schemas based on Microsoft Dynamics 365 Finance official documentation:

- **OData Collection Structure**: Proper `@odata.context`, `@odata.count`, and `value` array structure
- **Entity-Specific Types**: 
  - `CustomerV3` - Complete customer entity with all fields
  - `VendorV2` - Complete vendor entity with all fields  
  - `ReleasedProductV2` - Complete product entity with all fields
  - `CustomerGroup` - Customer group entity
  - `ExchangeRate` - Exchange rate entity
  - `SystemUser` - System user entity
- **Collection Types**: 
  - `CustomersV3Collection` - Collection of customers
  - `VendorsV2Collection` - Collection of vendors
  - `ReleasedProductsV2Collection` - Collection of products
  - `CustomerGroupsCollection` - Collection of customer groups
  - `ExchangeRatesCollection` - Collection of exchange rates
  - `SystemUsersCollection` - Collection of system users
- **Error Handling**: Proper error response schemas with structured error information

### 2. **Enhanced Endpoint Definitions**
- Added proper HTTP status codes (200, 201, 400, 401, 404)
- Added content-type specifications (`application/json`, `text/plain`, `application/xml`)
- Enhanced parameter descriptions and examples
- Added request body schemas for POST/PATCH operations

### 3. **Parameter Name Sanitization**
Applied `x-ballerina-name` extensions for clean Ballerina identifiers:
- `$select` → `selectFields` (avoiding reserved word `select`)
- `$filter` → `filter`
- `cross-company` → `crossCompany`
- Added proper parameter descriptions and constraints

### 4. **OData Compliance**
- Added proper OData query parameter support (`$top`, `$skip`, `$orderby`)
- Implemented count endpoints returning proper integer types
- Added OData metadata endpoint returning XML
- Enhanced server configuration with proper base URLs

### 5. **Security and Authentication**
- Added Bearer token authentication scheme
- Proper security definitions for all endpoints

## Client Generation Process

### Before Sanitization
```ballerina
// Original - unusable return types
remote isolated function getCustomersV3(...) returns error? {
    // Could only return null or error - no actual data
}
```

### After Sanitization  
```ballerina
// Enhanced - proper return types
remote isolated function getCustomersV3FieldListCrossCompanyGbsiUssi(...) returns CustomersV3Collection|error {
    // Returns structured customer data with proper typing
}
```

## Final Client Generation Command

```bash
# Generate enhanced Ballerina client with remote methods and proper response types
bal openapi -i docs/spec/openapi.json --mode client --client-methods remote -o ballerina
```