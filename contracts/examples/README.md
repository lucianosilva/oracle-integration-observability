# OIO flat JSON examples

These examples follow the flat payload currently parsed by `OIO_TRACE_API`.

## Create trace examples

Use with `OIO_TRACE_API.PR_CREATE_TRACE_LOG` or `OIO_TRACE_API.REGISTER_EVENT_JSON`:

- `01_create_success.json`
- `02_create_business_error.json`
- `03_create_technical_error.json`
- `04_create_po_sync_success.json`

Required fields for creation in the current package implementation:

- `integrationKey`
- `oicInstanceId`
- `logLevel` (`I` or `E`)
- `summary`
- `attr1Value`
- `transactionStatus`

## Status update examples

Use with `OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS`:

- `05_update_status_resolved.json`
- `06_update_status_in_progress.json`

Required fields for status updates in the current package implementation:

- `integrationKey`
- at least one of `transactionId1`, `transactionId2`, or `transactionId3`
- `transactionStatus`

## Notes

- The payload remains flat by design.
- `requestPayload` and `responsePayload` are represented as escaped JSON strings because they are stored as CLOB values.
- The `attr1Value` through `attr10Value` meanings are metadata-driven and depend on the matching row in `OIO_INTEGRATION_CFG`.
- The integration keys used here match the sample configuration data currently included in the repository scripts.
