# OIO mapping reference

## 1. Purpose

This document is the source of truth for Oracle Integration field mapping and JSON serialization.

Canonical property definitions, limits, required fields, matching rules, and database behavior are maintained in the [logging contract](../docs/logging-contract.md). Complete payload examples are maintained under [contracts/examples](../contracts/examples/README.md).

## 2. Mapping responsibility

The parent business integration supplies the business, execution, and fault context. `OIO_LOG_EVENT` preserves the flat field set, serializes it as JSON text, and maps the complete document to the `P_PAYLOAD` CLOB expected by `OIO_TRACE_API`.

Runtime sequencing and post-invoke behavior are defined in the [implementation pattern](implementation-pattern.md).

## 3. Create trace mapping

Operation: `OIO_LOG_EVENT.CreateTrace`

Procedure: `OIO_OWNER.OIO_TRACE_API.PR_CREATE_TRACE_LOG`

| JSON property | Typical OIC source | Mapping note |
|---|---|---|
| `integrationKey` | Constant, lookup, or project configuration | Must identify an active OIO configuration. |
| `correlationId` | Incoming header, request ID, or generated reference | Propagate across systems when possible. |
| `oicInstanceId` | Current OIC flow ID | Required for trace creation. |
| `userName` | Authenticated user or component name | Use `OIC` when no meaningful user is available. |
| `logLevel` | Processing outcome | Use `I` or `E`. |
| `summary` | Concise event description | Do not use as a stack-trace store. |
| `errorCode` | Business or technical code | Null for successful events. |
| `errorMessage` | Sanitized error text | Null for successful events. |
| `attr1Value` | Configured integration attribute | Required by the current package. |
| `attr2Value`–`attr10Value` | Configured integration attributes | Populate according to `OIO_INTEGRATION_CFG`. |
| `transactionId1` | Primary business identifier | Recommended. |
| `transactionId2` | Secondary identifier | Optional. |
| `transactionId3` | Tertiary or batch identifier | Optional. |
| `transactionStatus` | Current business status | Required. |
| `requestPayload` | Approved serialized content | Optional. |
| `responsePayload` | Approved serialized content | Optional. |

## 4. Status update mapping

Operation: `OIO_LOG_EVENT.UpdateTransactionStatus`

Procedure: `OIO_OWNER.OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS`

| JSON property | Typical OIC source | Mapping note |
|---|---|---|
| `integrationKey` | Same key used at creation | Required. |
| `transactionId1` | Original primary identifier | At least one transaction identifier is required. |
| `transactionId2` | Original secondary identifier | Add when needed for selectivity. |
| `transactionId3` | Original tertiary identifier | Add when needed for selectivity. |
| `transactionStatus` | New lifecycle status | Required. |
| `oicInstanceId` | Current update-flow ID | Recommended for support correlation. |
| `userName` | User or component performing the update | Optional. |
| `logLevel` | Update outcome | Optional in the current procedure. |
| `summary` | Transition description | Recommended. |
| `errorCode` | Error or resolution code | Optional. |
| `errorMessage` | Sanitized description | Optional. |
| `requestPayload` | Approved supporting content | Optional. |
| `responsePayload` | Approved supporting content | Optional. |

Use all business identifiers required to avoid unintended multi-trace updates. The package matches every supplied non-null transaction identifier.

## 5. Sample mapping

For `SCM_PO_SYNC`, an illustrative mapping is:

| OIO field | Example source |
|---|---|
| `correlationId` | Incoming request ID |
| `oicInstanceId` | Current OIC flow ID |
| `userName` | `OIC` |
| `transactionId1` | Purchase order number |
| `transactionId2` | Source request ID |
| `transactionId3` | Synchronization batch ID |
| `attr1Value` | First configured mandatory attribute |
| `transactionStatus` | Business-defined lifecycle status |

Confirm the actual `OIO_INTEGRATION_CFG` labels before implementation.

## 6. JSON serialization

The Database Adapter receives the complete flat document as JSON text in `P_PAYLOAD`.

Serialization rules:

- preserve camel-case property names;
- keep the top-level structure flat;
- represent unavailable optional values as null;
- avoid placeholder identifiers such as `N/A`;
- escape quotation marks and control characters inside embedded JSON or XML;
- keep `requestPayload` and `responsePayload` as string properties;
- use UTF-8;
- validate the serialized document before invoking the database.

Example:

```json
{
  "requestPayload": "{\"purchaseOrder\":\"PO-100045\"}",
  "responsePayload": "{\"status\":\"ERROR\"}"
}
```

Payload persistence is optional and must follow the [logging contract](../docs/logging-contract.md) and repository [security considerations](../README.md#security-considerations).

## 7. Database Adapter outputs

Both primary procedures expose:

| Output | Mapping purpose |
|---|---|
| `O_STATUS` | Make the package result available to the child integration. |
| `O_MESSAGE` | Make informational or diagnostic context available to the child integration. |

These outputs are not part of the flat JSON contract and are not returned to the parent business integration. Their runtime use is defined in the [implementation pattern](implementation-pattern.md).

## 8. Mapping checklist

- [ ] `integrationKey` exists and is active.
- [ ] Attribute positions match `OIO_INTEGRATION_CFG`.
- [ ] `attr1Value` is populated for create operations.
- [ ] `oicInstanceId` is captured for create operations.
- [ ] `transactionStatus` is populated.
- [ ] Status-update identifiers are sufficiently selective.
- [ ] Successful events do not contain error values.
- [ ] Error text is sanitized.
- [ ] Optional payloads remain null unless retention is approved.
- [ ] The serialized document is valid JSON and is mapped completely to `P_PAYLOAD`.
- [ ] `O_STATUS` and `O_MESSAGE` are available to the post-invoke flow.

## 9. Related documentation

- [Logging contract](../docs/logging-contract.md)
- [JSON examples](../contracts/examples/README.md)
- [Implementation pattern](implementation-pattern.md)
- [Fault-handler pattern](fault-handler-pattern.md)
