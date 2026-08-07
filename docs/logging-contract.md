# OIO Logging Contract

## 1. Purpose

This document defines the canonical flat JSON contract accepted by the Oracle Integration Observability (OIO) database API.

The contract is designed for Oracle Integration mappings. It keeps the top-level payload flat and delegates persistence normalization to `OIO_TRACE_API`.

The same field set supports two operations:

- Creating a new trace and its initial event.
- Appending a transaction status event to an existing trace.

## 2. Canonical format

- Media type: `application/json`
- Encoding: UTF-8
- Top-level type: JSON object
- Property naming: camel case
- Contract shape: flat
- Date and numeric business values: transmitted as strings when stored in generic attribute fields
- Optional payload content: transmitted as a string in `requestPayload` or `responsePayload`

Nested objects are not used in the canonical OIO contract. When a request or response contains JSON, XML, or text, that content is carried as a string inside the corresponding payload property.

Example with embedded JSON:

```json
{
  "requestPayload": "{\"invoiceNumber\":\"INV-100459\",\"paymentMethod\":\"Wire\"}",
  "responsePayload": "{\"status\":\"ERROR\",\"code\":\"PAYMENT_METHOD_INVALID\"}"
}
```

## 3. Supported database operations

### 3.1 Create trace

Primary OIC entry point:

- `OIO_TRACE_API.PR_CREATE_TRACE_LOG`

Compatibility entry point:

- `OIO_TRACE_API.REGISTER_EVENT_JSON`

`PR_CREATE_TRACE_LOG`:

1. Validates the `integrationKey` against `OIO_INTEGRATION_CFG`.
2. Creates one row in `OIO_TRACE`.
3. Creates the initial row in `OIO_TRACE_EVENT`.
4. Creates one `OIO_TRACE_PAYLOAD` row when a request or response payload is provided.
5. Commits the autonomous transaction on success.
6. Returns `O_STATUS` and `O_MESSAGE` to the calling OIC child integration.

### 3.2 Update transaction status

Primary OIC entry point:

- `OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS`

The operation:

1. Validates the `integrationKey`.
2. Requires at least one transaction identifier.
3. Locates matching `OIO_TRACE` records.
4. Updates non-null master values supplied in the event.
5. Appends a `STATUS_UPDATE` row to `OIO_TRACE_EVENT` for each match.
6. Creates an `OIO_TRACE_PAYLOAD` row for each new event when a request or response payload is provided.
7. Commits the autonomous transaction on success.
8. Returns `O_STATUS` and `O_MESSAGE` to the calling OIC child integration.

The JSON input shape is the same for both operations. Operation selection belongs to the OIC endpoint and is not represented by an additional JSON property.

## 4. Complete flat payload template

```json
{
  "integrationKey": "FIN_AP_PAYMENT_FLOW",
  "correlationId": "AP-PAYMENT-2026-000184",
  "oicInstanceId": "987654321001",
  "userName": "OIC",
  "logLevel": "I",
  "summary": "Invoice payment request received and registered successfully.",
  "errorCode": null,
  "errorMessage": null,
  "attr1Value": "INV-100458",
  "attr2Value": "SUP-00321",
  "attr3Value": "Brazil Business Unit",
  "attr4Value": "BRL",
  "attr5Value": "15750.90",
  "attr6Value": "Electronic",
  "attr7Value": "2026-08-20",
  "attr8Value": "PAY-BATCH-20260805-01",
  "attr9Value": "Brazil Primary Ledger",
  "attr10Value": "InvoiceValidated",
  "transactionId1": "INV-100458",
  "transactionId2": "PAY-908771",
  "transactionId3": "PAY-BATCH-20260805-01",
  "transactionStatus": "RECEIVED",
  "requestPayload": null,
  "responsePayload": null
}
```

## 5. Field reference

| JSON property | Type | Maximum processed length | Create | Status update | Persistence and meaning |
|---|---|---:|---|---|---|
| `integrationKey` | string | 250 | Required | Required | Integration identifier. Must match an active row in `OIO_INTEGRATION_CFG`. Stored in `OIO_TRACE.INTEGRATION_KEY`. |
| `correlationId` | string | 250 | Optional | Optional | Cross-system or business correlation reference. Stored as `OIO_TRACE.LOG_REF_ID` during creation. |
| `oicInstanceId` | string | 250 | Required | Optional | Oracle Integration instance identifier. Stored in the trace master and initial event during creation; stored in the new event during status update when provided. |
| `userName` | string | 250 | Optional | Optional | User, service account, or component registering the event. Defaults to `OIC` when omitted. |
| `logLevel` | string | 1 | Required | Optional | Event severity. Supported values are `I` and `E`. |
| `summary` | string | 4000 | Required | Optional | Short business or technical description. On status update, a non-null value replaces the current master summary and is stored in the new event. |
| `errorCode` | string | 250 | Optional | Optional | Technical or business error code. |
| `errorMessage` | string | 4000 | Optional | Optional | Technical or business error description. |
| `attr1Value` | string | 4000 | Required | Optional | First metadata-driven value. Its label is defined by `OIO_INTEGRATION_CFG.ATTR1_NAME`. |
| `attr2Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR2_NAME`. |
| `attr3Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR3_NAME`. |
| `attr4Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR4_NAME`. |
| `attr5Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR5_NAME`. |
| `attr6Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR6_NAME`. |
| `attr7Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR7_NAME`. |
| `attr8Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR8_NAME`. |
| `attr9Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR9_NAME`. |
| `attr10Value` | string | 4000 | Optional | Optional | Metadata-driven value defined by `ATTR10_NAME`. |
| `transactionId1` | string | 250 | Optional | Conditionally required | Primary business transaction identifier. Its label is defined by `TRANSACTION_ID1_NAME`. |
| `transactionId2` | string | 250 | Optional | Conditionally required | Secondary business transaction identifier. Its label is defined by `TRANSACTION_ID2_NAME`. |
| `transactionId3` | string | 250 | Optional | Conditionally required | Tertiary business transaction identifier. Its label is defined by `TRANSACTION_ID3_NAME`. |
| `transactionStatus` | string | 250 | Required | Required | Business-defined transaction status. Stored in `OIO_TRACE_EVENT`; current status is derived from the latest event. |
| `requestPayload` | string | CLOB | Optional | Optional | Optional request content associated with the event. May contain escaped JSON, XML, or text. |
| `responsePayload` | string | CLOB | Optional | Optional | Optional response or fault content associated with the event. May contain escaped JSON, XML, or text. |

For status updates, "conditionally required" means that at least one of `transactionId1`, `transactionId2`, or `transactionId3` must be provided.

## 6. Required fields by operation

### 6.1 Create trace

The current package requires:

```text
integrationKey
oicInstanceId
logLevel
summary
attr1Value
transactionStatus
```

The `integrationKey` must exist and be active in `OIO_INTEGRATION_CFG`.

### 6.2 Update transaction status

The current package requires:

```text
integrationKey
transactionStatus
at least one transaction identifier
```

The transaction identifiers are used together with the integration key to locate existing traces.

## 7. Metadata-driven fields

The contract intentionally uses generic attribute and transaction identifier names. Their business meaning is configured per integration.

Example configuration:

| Configuration field | Example value |
|---|---|
| `INTEGRATION_KEY` | `FIN_AP_PAYMENT_FLOW` |
| `TRANSACTION_ID1_NAME` | `Invoice Number` |
| `TRANSACTION_ID2_NAME` | `Payment Number` |
| `TRANSACTION_ID3_NAME` | `Payment Batch` |
| `ATTR1_NAME` | `Invoice Number` |
| `ATTR2_NAME` | `Supplier Number` |
| `ATTR3_NAME` | `Business Unit` |
| `ATTR4_NAME` | `Currency` |
| `ATTR5_NAME` | `Amount` |

With this configuration:

```json
{
  "transactionId1": "INV-100458",
  "transactionId2": "PAY-908771",
  "transactionId3": "PAY-BATCH-20260805-01",
  "attr1Value": "INV-100458",
  "attr2Value": "SUP-00321",
  "attr3Value": "Brazil Business Unit",
  "attr4Value": "BRL",
  "attr5Value": "15750.90"
}
```

Consumers must not assume that a given attribute position has the same meaning across all integrations. The `integrationKey` determines the metadata definition.

## 8. Log level

Supported values:

| Value | Meaning |
|---|---|
| `I` | Informational or successful processing state |
| `E` | Business or technical error state |

The package normalizes `logLevel` to uppercase before validation.

`logLevel` is intentionally compact because the current model uses a single-character database column. More detailed business lifecycle information belongs in `transactionStatus`, while error details belong in `errorCode` and `errorMessage`.

## 9. Transaction status

`transactionStatus` is business-defined. The database does not enforce a global list because different integrations may have different lifecycles.

Examples include:

```text
RECEIVED
VALIDATED
IN_PROGRESS
SYNCHRONIZED
FAILED
REJECTED
RESOLVED
```

Each integration should document its allowed status values and transitions. Status naming should be stable, uppercase, and understandable to both technical and business support teams.

## 10. Event type derivation

For create operations, `OIO_TRACE_API` derives the event type:

| Condition | Stored event type |
|---|---|
| `logLevel = E`, or `errorCode` is populated, or `errorMessage` is populated | `ERROR` |
| Otherwise, `transactionStatus` is populated | `STATUS_EVENT` |
| Otherwise | `INFO` |

Because `transactionStatus` is mandatory for creation in the current implementation, successful create examples normally produce `STATUS_EVENT`.

For status update operations, the stored event type is:

```text
STATUS_UPDATE
```

## 11. Correlation and transaction identifiers

These fields serve different purposes:

### `correlationId`

A flexible reference used to correlate the execution with another platform, request, batch, or end-to-end process. It is stored for search and support but is not used by the current status-update procedure to locate a trace.

### `oicInstanceId`

The Oracle Integration execution instance identifier. It connects OIO data to native Oracle Integration monitoring.

### `transactionId1` through `transactionId3`

Business identifiers used to locate and update trace records. The matching logic uses every non-null transaction identifier provided in the status update payload.

Example:

```json
{
  "integrationKey": "FIN_AR_SYSTEM_A",
  "transactionId1": "TRX-780041",
  "transactionId2": null,
  "transactionId3": "AR-BATCH-20260805-07",
  "transactionStatus": "RESOLVED"
}
```

This update matches traces with:

```text
INTEGRATION_KEY = FIN_AR_SYSTEM_A
TRANSACTION_ID1 = TRX-780041
TRANSACTION_ID3 = AR-BATCH-20260805-07
```

`transactionId2` is ignored because it is null.

The current implementation appends the update to every trace that satisfies the provided criteria. Integrations should therefore use a combination of identifiers that is sufficiently selective for the intended operation.

## 12. Request and response payloads

`requestPayload` and `responsePayload` are optional string properties persisted as CLOB values.

They may contain:

- Escaped JSON.
- XML.
- Plain text.
- A sanitized fault payload.
- A reduced diagnostic representation instead of the complete message.

Example:

```json
{
  "requestPayload": "{\"transactionNumber\":\"TRX-780041\",\"amount\":3250.75}",
  "responsePayload": "{\"httpStatus\":503,\"reason\":\"Service Unavailable\"}"
}
```

Payloads should not contain:

- Passwords or private keys.
- OAuth tokens or authorization headers.
- Unmasked bank account information.
- Personal or regulated data that is not required for support.
- Full documents when a reference or reduced diagnostic payload is sufficient.

## 13. Null, omitted, and empty values

The package trims string values after parsing.

General recommendations:

- Use `null` for optional values that are not available.
- Omitted optional properties are also interpreted as null by the current parser.
- Do not send whitespace-only values.
- Do not use the strings `"null"`, `"N/A"`, or `"undefined"` as substitutes for JSON null unless they are meaningful business values.

For reusable Oracle Integration mappings, keeping all properties present with null values can make the contract easier to understand and test. This is the pattern used in the repository examples.

## 14. Length handling

The current parser trims and truncates scalar values to match the target database column size.

Important limits include:

- 250 characters for identifiers, user, integration key, and error code.
- 4,000 characters for summaries, error messages, and generic attributes.
- One character for `logLevel`.
- CLOB storage for request and response payloads.

Producers should still enforce appropriate limits before calling OIO. Silent truncation can remove information needed for troubleshooting.

## 15. Processing and result behavior

The primary persistence procedures use autonomous transactions and expose an explicit database result contract.

### 15.1 `PR_CREATE_TRACE_LOG` and `PR_UPDATE_TRANSACTION_STATUS`

Both procedures accept:

| Parameter | Direction | Meaning |
|---|---|---|
| `P_PAYLOAD` | IN | Complete flat OIO document serialized as a CLOB. |
| `O_STATUS` | OUT | Execution result consumed by `OIO_LOG_EVENT`. |
| `O_MESSAGE` | OUT | Informational or diagnostic message associated with the result. |

Expected result values:

| `O_STATUS` | Meaning | OIC behavior |
|---|---|---|
| `SUCCESS` | The database operation completed and committed. | `OIO_LOG_EVENT` completes normally. |
| `ERROR` | The database operation failed and was rolled back. | `OIO_LOG_EVENT` executes `Throw New Fault`. |

Validation exceptions and other database errors raised during the internal processing of these procedures are caught by the public procedure. The OIO transaction is rolled back and the failure is returned through `O_STATUS` and `O_MESSAGE` rather than re-raised to the Database Adapter.

`O_STATUS` and `O_MESSAGE` are not properties of the canonical JSON contract. They are Database Adapter output parameters used internally by the asynchronous logger.

Because the parent business integration invokes `OIO_LOG_EVENT` asynchronously, it does not receive these output values. The result is evaluated only inside the child instance. See the [OIC implementation pattern](../oic/implementation-pattern.md).

### 15.2 `REGISTER_EVENT_JSON` compatibility behavior

`REGISTER_EVENT_JSON` remains available for compatibility and exposes:

| OUT parameter | Meaning |
|---|---|
| `O_STATUS` | `OK` after successful creation; `ERROR` when the exception handler is entered. |
| `O_TRACE_ID` | Generated trace identifier after successful creation. |
| `O_MESSAGE` | Success message or captured error text. |

Unlike the two primary OIC procedures, the compatibility wrapper currently re-raises an exception after setting its error outputs. It is therefore not the procedure used by the current `OIO_LOG_EVENT` design.

## 16. Validation errors

The internal package validation uses application errors in the `-20000` range.

| Error | Current meaning |
|---:|---|
| `-20000` | Payload could not be parsed or normalized |
| `-20001` | `integrationKey` is required |
| `-20002` | Integration key does not exist or is inactive |
| `-20003` | `oicInstanceId` is required for creation |
| `-20004` | `logLevel` must be `I` or `E` |
| `-20005` | `summary` is required for creation |
| `-20006` | `attr1Value` is required for creation |
| `-20007` | `transactionStatus` is required for creation |
| `-20008` | At least one transaction identifier is required for update |
| `-20009` | `transactionStatus` is required for update |
| `-20010` | No trace matched the update identifiers |

For `PR_CREATE_TRACE_LOG` and `PR_UPDATE_TRANSACTION_STATUS`, these exceptions are handled by the public procedure and converted into the `O_STATUS` / `O_MESSAGE` result contract. `OIO_LOG_EVENT` then generates an OIC fault when the returned status is not `SUCCESS`.

These codes describe the current internal validation behavior and should be kept stable once external consumers or operational procedures depend on them.

## 17. Create example

```json
{
  "integrationKey": "SCM_PO_SYNC",
  "correlationId": "PO-SYNC-2026-004210",
  "oicInstanceId": "987654321004",
  "userName": "OIC",
  "logLevel": "I",
  "summary": "Purchase order synchronized with the supplier portal.",
  "errorCode": null,
  "errorMessage": null,
  "attr1Value": "PO-4210",
  "attr2Value": "SUP-00814",
  "attr3Value": "BUYER.JSMITH",
  "attr4Value": "Brazil Procurement BU",
  "attr5Value": "BRL",
  "attr6Value": "45800.00",
  "attr7Value": "BR Inventory Organization",
  "attr8Value": "STANDARD_APPROVAL",
  "attr9Value": "PurchaseOrderApproved",
  "attr10Value": "PO-BATCH-20260805-03",
  "transactionId1": "PO-4210",
  "transactionId2": "ACK-778102",
  "transactionId3": "PO-BATCH-20260805-03",
  "transactionStatus": "SYNCHRONIZED",
  "requestPayload": "{\"purchaseOrderNumber\":\"PO-4210\",\"supplierNumber\":\"SUP-00814\"}",
  "responsePayload": "{\"acknowledgementNumber\":\"ACK-778102\",\"status\":\"ACCEPTED\"}"
}
```

## 18. Status update example

```json
{
  "integrationKey": "FIN_AR_SYSTEM_A",
  "correlationId": "AR-SYSTEM-A-2026-000731",
  "oicInstanceId": "987654321105",
  "userName": "OIC_SUPPORT",
  "logLevel": "I",
  "summary": "Transaction delivered successfully after retry.",
  "errorCode": null,
  "errorMessage": null,
  "attr1Value": null,
  "attr2Value": null,
  "attr3Value": null,
  "attr4Value": null,
  "attr5Value": null,
  "attr6Value": null,
  "attr7Value": null,
  "attr8Value": null,
  "attr9Value": null,
  "attr10Value": null,
  "transactionId1": "TRX-780041",
  "transactionId2": null,
  "transactionId3": "AR-BATCH-20260805-07",
  "transactionStatus": "RESOLVED",
  "requestPayload": null,
  "responsePayload": null
}
```

## 19. Repository examples

The example payloads are maintained under:

```text
contracts/examples/
├── 01_create_success.json
├── 02_create_business_error.json
├── 03_create_technical_error.json
├── 04_create_po_sync_success.json
├── 05_update_status_resolved.json
└── 06_update_status_in_progress.json
```

These examples are illustrative and contain anonymized values. Their `integrationKey` values must exist in `OIO_INTEGRATION_CFG` before the payloads can be processed successfully.

## 20. Compatibility note

JSON is the canonical and documented OIO contract.

The current package also contains compatibility parsing for an XML document with a `request-wrapper` root and child elements that use the same property names. XML support is not the primary repository contract and may be documented separately if it becomes a supported integration requirement.
