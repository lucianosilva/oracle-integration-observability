# OIO mapping reference

## 1. Purpose

This document defines the mapping responsibilities of:

```text
OIO_SAMPLE_BUSINESS_FLOW
OIO_LOG_EVENT
```

The canonical contract remains the flat JSON structure documented in `docs/logging-contract.md`.

The parent business integration derives business and fault context. The reusable logger preserves that payload and serializes it into the CLOB input expected by `OIO_TRACE_API`.

## 2. Responsibility boundary

### Parent integration

`OIO_SAMPLE_BUSINESS_FLOW`, or any production parent integration, is responsible for:

- choosing the correct `integrationKey`;
- assigning business transaction identifiers;
- populating metadata-driven attributes;
- determining the business status;
- deciding whether request or response content may be retained;
- sanitizing any retained payload;
- capturing the original fault context;
- invoking the correct `OIO_LOG_EVENT` operation.

### Logger integration

`OIO_LOG_EVENT` is responsible for:

- validating basic operation requirements;
- preserving the submitted flat field set;
- constructing valid JSON text;
- mapping that text to the database CLOB input;
- invoking the selected package procedure;
- returning or propagating the logging result.

### Database package

`OIO_TRACE_API` is responsible for:

- parsing the JSON document;
- validating the integration configuration;
- applying package-level mandatory-field rules;
- normalizing the flat values into the database model;
- deriving the stored event type;
- committing or rolling back the OIO database transaction.

## 3. Create trace mapping

Operation:

```text
OIO_LOG_EVENT.CreateTrace
```

Database procedure:

```text
OIO_OWNER.OIO_TRACE_API.PR_CREATE_TRACE_LOG
```

| JSON property | Typical source in parent integration | Rule |
|---|---|---|
| `integrationKey` | Integration constant, lookup, or project configuration | Must match an active `OIO_INTEGRATION_CFG` row. |
| `correlationId` | Incoming correlation header, request identifier, or generated process reference | Use a value that can be propagated across systems when possible. |
| `oicInstanceId` | Current Oracle Integration flow identifier | Required for trace creation. |
| `userName` | Authenticated user, service account, or component name | Use `OIC` when no meaningful user is available. |
| `logLevel` | Derived from processing outcome | `I` for informational/success; `E` for business or technical error. |
| `summary` | Concise business or technical description | Required. Avoid copying an entire stack trace. |
| `errorCode` | Fault name, target error code, or business validation code | Null for successful events. |
| `errorMessage` | Sanitized fault or business-error text | Null for successful events. |
| `attr1Value` | Integration-specific value defined by configuration | Required by the current package. |
| `attr2Value`–`attr10Value` | Integration-specific context | Populate only positions documented for the integration key. |
| `transactionId1` | Primary business identifier | Recommended even when not required by the current create procedure. |
| `transactionId2` | Secondary business identifier | Optional. |
| `transactionId3` | Tertiary business or batch identifier | Optional. |
| `transactionStatus` | Current business lifecycle status | Required. |
| `requestPayload` | Sanitized request representation | Optional. Keep null unless retention is approved. |
| `responsePayload` | Sanitized response or fault representation | Optional. Keep null unless retention is approved. |

## 4. Status update mapping

Operation:

```text
OIO_LOG_EVENT.UpdateTransactionStatus
```

Database procedure:

```text
OIO_OWNER.OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS
```

| JSON property | Typical source | Rule |
|---|---|---|
| `integrationKey` | Same integration key used during creation | Required. |
| `transactionId1` | Original primary business identifier | At least one transaction identifier is required. |
| `transactionId2` | Original secondary identifier | Use when needed to make the match selective. |
| `transactionId3` | Original tertiary or batch identifier | Use when needed to make the match selective. |
| `transactionStatus` | New business lifecycle status | Required. |
| `oicInstanceId` | Current update-flow instance | Optional, but useful for support correlation. |
| `userName` | User, service account, or component performing the update | Optional. |
| `logLevel` | `I` or `E` according to the update | Optional in the current status operation. |
| `summary` | Description of the transition | Optional but recommended. |
| `errorCode` | Error or resolution code | Optional. |
| `errorMessage` | Sanitized description | Optional. |
| `requestPayload` | Optional supporting content | Use only if the package implementation stores payloads for status updates. |
| `responsePayload` | Optional supporting content | Use only if the package implementation stores payloads for status updates. |

The current database matching behavior uses every non-null transaction identifier supplied with `integrationKey`. If the combination is not unique, multiple traces may receive the update.

## 5. Suggested sample mapping

For the repository demonstration:

```text
integrationKey = SCM_PO_SYNC
```

| Field | Example source |
|---|---|
| `correlationId` | Incoming request ID |
| `oicInstanceId` | Current OIC flow ID |
| `userName` | `OIC` |
| `transactionId1` | Purchase order number |
| `transactionId2` | Source-system request ID |
| `transactionId3` | Synchronization batch ID |
| `attr1Value` | Purchase order number or the first configured mandatory attribute |
| `transactionStatus` | `RECEIVED`, `SYNCHRONIZED`, `FAILED`, or `RESOLVED` |

Before implementing the mapping, confirm the labels configured for `SCM_PO_SYNC` in `OIO_INTEGRATION_CFG`. Generic attribute positions must not be assigned based only on this example.

## 6. Success event example

```json
{
  "integrationKey": "SCM_PO_SYNC",
  "correlationId": "REQ-20260805-00041",
  "oicInstanceId": "987654321001",
  "userName": "OIC",
  "logLevel": "I",
  "summary": "Purchase order synchronized successfully.",
  "errorCode": null,
  "errorMessage": null,
  "attr1Value": "PO-100045",
  "attr2Value": "SOURCE-REQ-8841",
  "attr3Value": "Brazil Business Unit",
  "attr4Value": null,
  "attr5Value": null,
  "attr6Value": null,
  "attr7Value": null,
  "attr8Value": null,
  "attr9Value": null,
  "attr10Value": null,
  "transactionId1": "PO-100045",
  "transactionId2": "SOURCE-REQ-8841",
  "transactionId3": "SYNC-BATCH-20260805-01",
  "transactionStatus": "SYNCHRONIZED",
  "requestPayload": null,
  "responsePayload": null
}
```

The example values must be aligned with the actual sample configuration before end-to-end validation.

## 7. Error event mapping

Within a fault handler:

| OIO field | Fault-context source |
|---|---|
| `oicInstanceId` | Current integration flow ID |
| `logLevel` | Constant `E` |
| `summary` | Short description of the failed business step |
| `errorCode` | Fault name or approved target error code |
| `errorMessage` | Sanitized fault string |
| `transactionStatus` | Business-defined failure state such as `FAILED` |
| `responsePayload` | Optional reduced diagnostic representation |

Useful Oracle Integration fault functions include:

```text
getFaultAsString()
getFaultAsXML()
getFaultName()
getFaultedActionName()
getFlowId()
```

Do not persist the raw output automatically. Inspect and sanitize it first.

## 8. JSON serialization

The database procedures accept one `CLOB` parameter named `P_PAYLOAD`.

`OIO_LOG_EVENT` must therefore convert the mapped flat request into valid JSON text.

Implementation requirements:

- preserve camel-case property names;
- preserve explicit nulls when they are required by the chosen mapping approach;
- escape quotation marks and control characters inside embedded JSON strings;
- keep `requestPayload` and `responsePayload` as string properties;
- do not create nested objects in the canonical contract;
- use UTF-8;
- test large CLOB values separately from normal metadata fields.

Example embedded content:

```json
{
  "requestPayload": "{\"purchaseOrder\":\"PO-100045\",\"source\":\"EXTERNAL_PROCUREMENT\"}",
  "responsePayload": "{\"status\":\"ERROR\",\"reason\":\"Service Unavailable\"}"
}
```

## 9. Null and empty-value handling

Apply a consistent policy:

- use null for unavailable optional values;
- avoid empty strings when they have no business meaning;
- do not substitute placeholder values such as `N/A` into transaction identifiers;
- do not send a fabricated error code for successful events;
- do not populate payload fields merely to satisfy a mapper;
- confirm how the REST Adapter and mapper represent null JSON properties during testing.

## 10. Length and truncation

The database package applies field-length limits documented in `docs/logging-contract.md`.

The parent integration should:

- keep `summary` concise;
- avoid using `errorMessage` as an uncontrolled stack-trace store;
- place only approved large content in the CLOB payload properties;
- test values near the documented limits;
- verify whether the package truncates or rejects oversized values.

## 11. Mapping validation checklist

- [ ] `integrationKey` exists and is active.
- [ ] `attr1Value` is populated for create operations.
- [ ] Attribute positions match the selected integration configuration.
- [ ] `oicInstanceId` is captured.
- [ ] `transactionStatus` is populated.
- [ ] Status updates include a sufficiently selective identifier combination.
- [ ] Successful events do not contain error values.
- [ ] Error messages are sanitized.
- [ ] Payloads remain null unless retention is approved.
- [ ] Embedded JSON is escaped correctly.
- [ ] The serialized document is valid JSON.
- [ ] The Database Adapter receives the complete JSON text in `P_PAYLOAD`.

## 12. Related documentation

- [OIO logging contract](../docs/logging-contract.md)
- [Fault-handler pattern](fault-handler-pattern.md)
- [Implementation pattern](implementation-pattern.md)
- [Flat JSON examples](../contracts/examples/README.md)

## 13. Official Oracle reference

- [Global fault-handling functions in Oracle Integration](https://docs.oracle.com/en/cloud/paas/application-integration/integrations-user/add-global-faults-orchestrated-integrations.html)
