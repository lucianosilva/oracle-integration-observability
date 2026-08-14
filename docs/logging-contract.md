# OIO Logging Contract

## 1. Purpose

This document defines the canonical flat JSON contract accepted by the Oracle Integration Observability (OIO) database API.

The same field set supports:

- creating a trace and its initial event;
- appending a transaction-status event to an existing trace.

JSON examples are maintained under [`contracts/examples/`](../contracts/examples/README.md).

## 2. Canonical format

- Media type: `application/json`
- Encoding: UTF-8
- Top-level type: JSON object
- Property naming: camel case
- Contract shape: flat
- Generic attribute values: strings
- Optional request/response content: strings in `requestPayload` and `responsePayload`

Nested objects are not part of the canonical OIO contract. JSON, XML, or text payload content is serialized into the corresponding payload property.

## 3. Operations

### Create trace

Primary entry point:

```text
OIO_TRACE_API.PR_CREATE_TRACE_LOG
```

The operation validates the integration configuration, creates `OIO_TRACE` and the initial `OIO_TRACE_EVENT`, and optionally creates `OIO_TRACE_PAYLOAD`.

Compatibility entry point:

```text
OIO_TRACE_API.REGISTER_EVENT_JSON
```

### Update transaction status

Primary entry point:

```text
OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS
```

The operation validates the integration, locates matching traces using the supplied transaction identifiers, updates non-null master values, and appends a `STATUS_UPDATE` event for each match. Payload content is stored when supplied.

Operation selection belongs to the API endpoint and is not represented by an additional JSON property.

## 4. Field reference

| JSON property | Type | Max processed length | Create | Status update | Meaning |
|---|---|---:|---|---|---|
| `integrationKey` | string | 250 | Required | Required | Active integration identifier defined in `OIO_INTEGRATION_CFG`. |
| `correlationId` | string | 250 | Optional | Optional | Cross-system or business correlation reference. |
| `oicInstanceId` | string | 250 | Required | Optional | Oracle Integration instance identifier. |
| `userName` | string | 250 | Optional | Optional | User, service account, or component. Defaults to `OIC`. |
| `logLevel` | string | 1 | Required | Optional | `I` or `E`. |
| `summary` | string | 4000 | Required | Optional | Business or technical event summary. |
| `errorCode` | string | 250 | Optional | Optional | Business or technical error code. |
| `errorMessage` | string | 4000 | Optional | Optional | Business or technical error description. |
| `attr1Value` | string | 4000 | Required | Optional | Metadata-driven attribute 1. |
| `attr2Value` ... `attr10Value` | string | 4000 | Optional | Optional | Metadata-driven attributes 2 through 10. |
| `transactionId1` | string | 250 | Optional | Conditionally required | Primary business transaction identifier. |
| `transactionId2` | string | 250 | Optional | Conditionally required | Secondary business transaction identifier. |
| `transactionId3` | string | 250 | Optional | Conditionally required | Tertiary business transaction identifier. |
| `transactionStatus` | string | 250 | Required | Required | Business-defined lifecycle status. |
| `requestPayload` | string | CLOB | Optional | Optional | Optional request content associated with the event. |
| `responsePayload` | string | CLOB | Optional | Optional response or fault content associated with the event. |

For status updates, at least one transaction identifier is required.

## 5. Required fields

### Create trace

```text
integrationKey
oicInstanceId
logLevel
summary
attr1Value
transactionStatus
```

`integrationKey` must identify an active row in `OIO_INTEGRATION_CFG`.

### Update transaction status

```text
integrationKey
transactionStatus
at least one of transactionId1, transactionId2, transactionId3
```

## 6. Metadata-driven fields

The physical attribute and transaction identifier positions are generic. Their business meaning is defined per integration in `OIO_INTEGRATION_CFG`.

For example, one integration may define:

| Configuration field | Example meaning |
|---|---|
| `TRANSACTION_ID1_NAME` | Invoice Number |
| `TRANSACTION_ID2_NAME` | Payment Number |
| `ATTR1_NAME` | Invoice Number |
| `ATTR2_NAME` | Supplier Number |
| `ATTR3_NAME` | Business Unit |

Consumers must not assume that the same attribute position has the same meaning across integrations.

## 7. Status, severity, and event type

`logLevel` supports:

| Value | Meaning |
|---|---|
| `I` | Informational or successful processing state |
| `E` | Business or technical error state |

`transactionStatus` is business-defined and is not restricted to a global database list.

For create operations, event type is derived as follows:

| Condition | Event type |
|---|---|
| `logLevel = E`, `errorCode` populated, or `errorMessage` populated | `ERROR` |
| Otherwise, `transactionStatus` populated | `STATUS_EVENT` |
| Otherwise | `INFO` |

Status updates are stored as `STATUS_UPDATE` events.

## 8. Correlation and matching

`correlationId` is a flexible cross-system reference. It is not used by the current status-update procedure to locate a trace.

`oicInstanceId` links OIO records to native Oracle Integration monitoring.

Status updates match on:

```text
integrationKey
+ every non-null transaction identifier supplied
```

Null transaction identifiers are ignored. If more than one trace satisfies the criteria, the current implementation appends the update to every matching trace. Integrations should therefore use identifiers that are sufficiently selective for the intended operation.

## 9. Payload handling

`requestPayload` and `responsePayload` may contain escaped JSON, XML, plain text, or a reduced diagnostic representation.

Payloads are optional and should not contain credentials, tokens, private keys, unmasked regulated information, or unnecessary production data. Each implementation is responsible for masking, access, retention, and deletion controls.

Use JSON `null` or omit an optional property when no value is available. Do not use literal strings such as `"null"`, `"N/A"`, or `"undefined"` unless they are meaningful business values.

## 10. Result behavior

`PR_CREATE_TRACE_LOG` and `PR_UPDATE_TRANSACTION_STATUS` accept the JSON document as `P_PAYLOAD` and return:

| Parameter | Direction | Meaning |
|---|---|---|
| `P_PAYLOAD` | IN | Flat OIO document serialized as CLOB. |
| `O_STATUS` | OUT | Database operation result. |
| `O_MESSAGE` | OUT | Informational or diagnostic message. |

Expected result values:

| `O_STATUS` | Meaning |
|---|---|
| `SUCCESS` | Operation completed and committed. |
| `ERROR` | Operation failed and was rolled back. |

The primary procedures use autonomous transactions. Internal validation and persistence errors are returned through `O_STATUS` and `O_MESSAGE` for evaluation by `OIO_LOG_EVENT`.

`REGISTER_EVENT_JSON` remains a compatibility wrapper. It returns `OK` / `ERROR`, exposes `O_TRACE_ID`, and currently re-raises an exception after setting its error outputs.

## 11. Validation errors

| Error | Meaning |
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

For the two primary procedures, these validation errors are converted into the `O_STATUS` / `O_MESSAGE` result contract.

## 12. Repository examples

Illustrative and anonymized payloads are maintained under [`contracts/examples/`](../contracts/examples/README.md), including successful creates, business and technical errors, and status updates.

The referenced `integrationKey` must exist in `OIO_INTEGRATION_CFG` before an example can be processed successfully.

## 13. Compatibility note

JSON is the canonical and documented OIO contract.

The current package also contains compatibility parsing for an XML document with a `request-wrapper` root and child elements using the same property names. XML is not the primary repository contract.
