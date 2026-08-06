# OIO Oracle Database connection setup

## 1. Purpose

This document covers only the Oracle Database Adapter connection used by `OIO_LOG_EVENT`.

The database ownership and runtime model is defined in the [architecture document](../docs/architecture.md). The expected model is:

- `OIO_OWNER` owns the OIO objects;
- `OIO_RUNTIME` is the optional OIC runtime account;
- the runtime account receives package execution privileges without direct table access.

## 2. Recommended connection

| Property | Recommended value |
|---|---|
| Connection name | `OIO_DB` |
| Identifier | `OIO_DB` |
| Adapter | Oracle Database Adapter |
| Usage | Invoke |
| Runtime user | `OIO_RUNTIME` |
| Owner schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Connectivity | Environment-specific |

Do not commit database credentials, wallets, certificates, or private endpoint details.

## 3. Database prerequisites

Before configuring OIC:

1. Install the OIO database objects as `OIO_OWNER`.
2. Confirm that `OIO_OWNER.OIO_TRACE_API` is `VALID`.
3. Create `OIO_RUNTIME` when using the separate runtime model.
4. Grant `CREATE SESSION` to `OIO_RUNTIME`.
5. Grant `EXECUTE` on `OIO_OWNER.OIO_TRACE_API` directly to `OIO_RUNTIME`.
6. Confirm that the runtime account has no direct table privileges.
7. Test package execution from SQL before configuring OIC.

The OIC implementation uses:

```text
OIO_TRACE_API.PR_CREATE_TRACE_LOG
OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS
```

## 4. Connectivity

The database and Oracle Integration instance must have an approved network path.

The selected architecture may use a public endpoint with approved controls, private connectivity, or an agent-based connection. Validate routing, DNS, TLS, firewall rules, certificates, and service accessibility for the target environment.

This repository does not prescribe a universal network design.

## 5. Create the connection

In Oracle Integration:

1. Create an Oracle Database Adapter connection.
2. Set the name and identifier to `OIO_DB`.
3. Configure the environment-specific endpoint and security policy.
4. Authenticate with `OIO_RUNTIME`.
5. Test the connection.
6. Keep all secrets outside repository artifacts.

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

### Update transaction status

| Setting | Value |
|---|---|
| Invoke name | `UpdateOIOStatus` |
| Operation | Invoke a stored procedure |
| Schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Procedure | `PR_UPDATE_TRANSACTION_STATUS` |
| Input | `P_PAYLOAD` CLOB |

Field-level serialization is documented in the [mapping reference](mapping-reference.md).

## 7. Metadata discovery

The least-privilege design assumes that the adapter can discover and invoke `OIO_OWNER.OIO_TRACE_API` while connected as `OIO_RUNTIME`.

If the package is not visible:

1. Confirm that `EXECUTE` was granted directly to `OIO_RUNTIME`.
2. Confirm the owner, package, and procedure names.
3. Re-test the connection.
4. Review adapter and database logs.
5. Evaluate an approved synonym or wrapper only when required.
6. Do not grant broad table privileges merely to solve metadata discovery.

Document any deviation from the repository security model.

## 8. Validation checklist

- [ ] `OIO_TRACE_API` is valid.
- [ ] `OIO_RUNTIME` can create a session.
- [ ] `OIO_RUNTIME` can execute the package.
- [ ] `OIO_RUNTIME` cannot directly access OIO tables.
- [ ] The `OIO_DB` connection test succeeds.
- [ ] Both procedures are visible to the adapter.
- [ ] A create call generates the expected database rows.
- [ ] A status update appends the expected event.
- [ ] No secrets appear in screenshots or exports.

## 9. Related documentation

- [Database installation](../database/install/README.md)
- [Implementation pattern](implementation-pattern.md)
- [Mapping reference](mapping-reference.md)
- [Security considerations](../README.md#security-considerations)

## 10. Official Oracle references

- [Oracle Database Adapter stored-procedure invocation](https://docs.oracle.com/en/cloud/paas/application-integration/database-adapter/invoke-stored-procedure-page.html)
- [Add the Oracle Database Adapter connection to an integration](https://docs.oracle.com/en/cloud/paas/integration-cloud/database-adapter/add-oracle-database-adapter-connection-integration.html)
