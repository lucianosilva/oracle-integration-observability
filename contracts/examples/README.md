# OIO flat JSON examples

These anonymized examples follow the canonical flat JSON contract parsed by `OIO_TRACE_API`.

For required fields, field limits, matching rules, payload handling, and procedure behavior, use the [logging contract](../../docs/logging-contract.md) as the source of truth.

## Create trace examples

Use with `OIO_TRACE_API.PR_CREATE_TRACE_LOG` or the compatibility wrapper `OIO_TRACE_API.REGISTER_EVENT_JSON`:

- `01_create_success.json`
- `02_create_business_error.json`
- `03_create_technical_error.json`
- `04_create_po_sync_success.json`

## Status update examples

Use with `OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS`:

- `05_update_status_resolved.json`
- `06_update_status_in_progress.json`

## Notes

- The integration keys used by the examples match the sample configuration included in the repository.
- Attribute positions remain metadata-driven through `OIO_INTEGRATION_CFG`.
- Replace sample identifiers and payload content with values appropriate to the target environment; do not use production-sensitive data in repository artifacts.
