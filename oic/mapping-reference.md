# OIO mapping reference

## 1. Purpose

This document is the source of truth for OIC field mapping and serialization.

The canonical property definitions, limits, and operation requirements are maintained in the [logging contract](../docs/logging-contract.md). Complete payload samples are maintained under [contracts/examples](../contracts/examples/README.md).

## 2. Responsibility

The parent business integration supplies the business and fault context. It dispatches the request asynchronously to `OIO_LOG_EVENT`, which preserves the flat field set, serializes it as JSON text, and maps it to the package parameter:

```text
P_PAYLOAD
```

Database parsing and normalization are handled by `OIO_TRACE_API` in the asynchronous child instance. The parent does not receive the database result.

## 3. Create trace mapping

Operation:

```text
OIO_LOG_EVENT.CreateTrace
```

Procedure:

```text
OIO_OWNER.OIO_TRACE_API.PR_CREATE_TRACE_LOG
```

| JSON property | Typical OIC source | Mapping note |
|---|---|---|
| `integrationKey` | Constant, lookup, or project configuration | Must identify an active OIO configuration. |
| `correlationId` | Incoming header, request ID, or generated reference | Propagate it across systems when possible. |
| `oicInstanceId` | Current OIC flow ID | Required for trace creation. |
| `userName` | Authenticated user or component name | Use `OIC` when no meaningful user is available. |
| `logLevel` | Processing outcome | Use `I` or `E`. |
| `summary` | Concise event description | Do not use it as a stack-trace store. |
| `errorCode` | Business or technical code | Null for successful events. |
| `errorMessage` | Sanitized error text | Null for successful events. |
| `attr1Value` | Configured integration attribute | Required by the current package. |
| `attr2Value`–`attr10Value` | Configured integration attributes | Populate only documented positions. |
| `transactionId1` | Primary business identifier | Recommended. |
| `transactionId2` | Secondary identifier | Optional. |
| `transactionId3` | Tertiary or batch identifier | Optional. |
| `transactionStatus` | Current business status | Required. |
| `requestPayload` | Approved serialized content | Optional. |
| `responsePayload` | Approved serialized content | Optional. |

## 4. Status update mapping

Operation:

```text
OIO_LOG_EVENT.UpdateTransactionStatus
```

Procedure:

```text
OIO_OWNER.OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS
```

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
| `requestPayload` | Approved supporting content | Optional and implementation-dependent. |
| `responsePayload` | Approved supporting content | Optional and implementation-dependent. |

Use all available business identifiers needed to avoid unintended multi-row updates.

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

The Database Adapter receives the complete flat document as JSON text in the `P_PAYLOAD` CLOB.

Serialization rules:

- preserve camel-case property names;
- keep the top-level structure flat;
- represent unavailable optional values as null;
- avoid placeholder identifiers such as `N/A`;
- escape quotation marks and control characters inside embedded JSON or XML;
- keep `requestPayload` and `responsePayload` as string properties;
- use UTF-8;
- validate the serialized document before invoking the database.

Example of embedded JSON strings:

```json
{
  "requestPayload": "{\"purchaseOrder\":\"PO-100045\"}",
  "responsePayload": "{\"status\":\"ERROR\"}"
}
```

Payload storage is optional and must follow the [logging contract](../docs/logging-contract.md) and [security considerations](../README.md#security-considerations).

## 7. Mapping checklist

- [ ] `integrationKey` exists and is active.
- [ ] Attribute positions match the selected configuration.
- [ ] `attr1Value` is populated for create operations.
- [ ] `oicInstanceId` is captured.
- [ ] `transactionStatus` is populated.
- [ ] Status-update identifiers are sufficiently selective.
- [ ] Successful events do not contain error values.
- [ ] Error text is sanitized.
- [ ] Optional payloads remain null unless approved.
- [ ] The serialized document is valid JSON.
- [ ] The complete JSON text is mapped to `P_PAYLOAD`.

## 8. Related documentation

- [Logging contract](../docs/logging-contract.md)
- [JSON examples](../contracts/examples/README.md)
- [Implementation pattern](implementation-pattern.md)
- [Fault-handler pattern](fault-handler-pattern.md)
