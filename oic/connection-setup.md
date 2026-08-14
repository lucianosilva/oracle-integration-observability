# OIO Oracle Database connection setup

## 1. Purpose

This document covers the Oracle Database Adapter connection used by `OIO_LOG_EVENT`.

The ownership and security boundaries are defined in the [architecture document](../docs/architecture.md):

- `OIO_OWNER` owns the OIO database objects;
- `OIO_RUNTIME` is the optional Oracle Integration runtime account;
- the runtime account receives package execution privileges without direct table access.

## 2. Reference connection

| Property | Reference value |
|---|---|
| Connection name | `OIO_TRACE_DB` |
| Identifier | `OIO_TRACE_DB` |
| Adapter | Oracle Database Adapter |
| Usage | Trigger and invoke |
| Runtime user | `OIO_RUNTIME` |
| Owner schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Connectivity | Environment-specific |

Do not commit database credentials, wallets, certificates, or private endpoint details.

## 3. Database prerequisites

Before configuring Oracle Integration:

1. Install the OIO database objects as `OIO_OWNER`.
2. Confirm that `OIO_OWNER.OIO_TRACE_API` is `VALID`.
3. Create `OIO_RUNTIME` when using the separate runtime model.
4. Grant `CREATE SESSION` to `OIO_RUNTIME`.
5. Grant `EXECUTE` on `OIO_OWNER.OIO_TRACE_API` directly to `OIO_RUNTIME`.
6. Confirm that `OIO_RUNTIME` has no direct privileges on OIO tables.
7. Test package execution from SQL before configuring the adapter.

The OIC implementation invokes:

```text
OIO_TRACE_API.PR_CREATE_TRACE_LOG
OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS
```

## 4. Connectivity

Oracle Integration and the database must have an approved network path. Validate routing, DNS, TLS, firewall rules, certificates, and service accessibility for the target environment.

This repository does not prescribe a universal public, private, or agent-based network design.

## 5. Create the connection

In Oracle Integration:

1. Create an Oracle Database Adapter connection.
2. Set the name and identifier to `OIO_TRACE_DB`.
3. Configure the environment-specific endpoint and security policy.
4. Authenticate with `OIO_RUNTIME` when using the reference runtime model.
5. Test the connection.

## 6. Configure the invokes

Create two Database Adapter invokes inside `OIO_LOG_EVENT`.

### Create trace

| Setting | Value |
|---|---|
| Invoke name | `CreateOIOTrace` |
| Operation | Invoke a stored procedure |
| Schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Procedure | `PR_CREATE_TRACE_LOG` |
| Input | `P_PAYLOAD` CLOB |
| Output | `O_STATUS` VARCHAR2 |
| Output | `O_MESSAGE` VARCHAR2 |

### Update transaction status

| Setting | Value |
|---|---|
| Invoke name | `UpdateOIOStatus` |
| Operation | Invoke a stored procedure |
| Schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Procedure | `PR_UPDATE_TRANSACTION_STATUS` |
| Input | `P_PAYLOAD` CLOB |
| Output | `O_STATUS` VARCHAR2 |
| Output | `O_MESSAGE` VARCHAR2 |

The adapter exposes the procedure OUT parameters to the child integration. Field serialization is defined in the [mapping reference](mapping-reference.md); post-invoke behavior is defined in the [implementation pattern](implementation-pattern.md).

## 7. Metadata discovery

If `OIO_TRACE_API` is not visible while connected as `OIO_RUNTIME`:

1. confirm the direct `EXECUTE` grant;
2. confirm the owner, package, and procedure names;
3. re-test the connection and review adapter/database logs;
4. evaluate an approved synonym or wrapper only when required by the target environment.

Do not grant broad table privileges merely to solve metadata discovery. Document any deviation from the reference security model.

## 8. Validation checklist

- [ ] `OIO_TRACE_API` is `VALID`.
- [ ] `OIO_RUNTIME` can create a session and execute the package.
- [ ] `OIO_RUNTIME` cannot directly access OIO tables.
- [ ] The `OIO_TRACE_DB` connection test succeeds.
- [ ] Both procedures are visible to the adapter.
- [ ] `P_PAYLOAD`, `O_STATUS`, and `O_MESSAGE` are exposed with the expected directions and types.
- [ ] No secrets or private endpoint details appear in exports or screenshots.

End-to-end asynchronous behavior is validated separately in the [implementation pattern](implementation-pattern.md).

## 9. Related documentation

- [Database installation](../database/install/README.md)
- [Implementation pattern](implementation-pattern.md)
- [Mapping reference](mapping-reference.md)
- [Security considerations](../README.md#security-considerations)

## 10. Official Oracle references

- [Oracle Database Adapter stored-procedure invocation](https://docs.oracle.com/en/cloud/paas/application-integration/database-adapter/invoke-stored-procedure-page.html)
- [Add the Oracle Database Adapter connection to an integration](https://docs.oracle.com/en/cloud/paas/application-integration/database-adapter/add-oracle-database-adapter-connection-integration.html)
