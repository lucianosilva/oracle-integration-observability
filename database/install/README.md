# Oracle Integration Observability - Database installation

This folder contains the v1 database installation artifacts. `OIO_OWNER` creates and maintains the OIO database objects. `OIO_RUNTIME` is optional and is intended exclusively for the Oracle Integration connection.

## Installation order

1. `00_oio_owner_creation.sql` — execute as DBA or privileged administrator in the target PDB.
2. `01_oio_integration_cfg.sql` — execute connected as `OIO_OWNER`.
3. `02_oio_trace.sql`
4. `03_oio_trace_event.sql`
5. `04_oio_trace_payload.sql`
6. `05_oio_v_trace_payload.sql`
7. `05_oio_v_trace_status_history.sql`
8. `06_oio_v_trace_current.sql`
9. `oio_trace_api_pks.sql`
10. `oio_trace_api_pkb.sql`
11. Optional: `00_oio_runtime_creation.sql` — execute as DBA after the package compiles.

## Security model

- `OIO_OWNER` owns `OIO_INTEGRATION_CFG`, `OIO_TRACE`, `OIO_TRACE_EVENT`, `OIO_TRACE_PAYLOAD`, `OIO_V_TRACE_PAYLOAD`, `OIO_V_TRACE_STATUS_HISTORY`, `OIO_V_TRACE_CURRENT`, and `OIO_TRACE_API`.
- `OIO_RUNTIME` is the OIC connection user. It receives only `CREATE SESSION` and `EXECUTE` on `OIO_OWNER.OIO_TRACE_API`.
- No direct privileges on tables are granted to `OIO_RUNTIME`.

## Public API

- `OIO_TRACE_API.PR_CREATE_TRACE_LOG`
- `OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS`
- `OIO_TRACE_API.REGISTER_EVENT_JSON`

All named constraints and indexes use the `OIO_` prefix and remain below Oracle's 30-character identifier limit. The interval partitions use the neutral name `P_INITIAL`, removing legacy table-based partition names.

## Test scripts

After completing the installation, use `sample_data_oio.sql` and `validation_queries_oio.sql` to load and validate sample data.
