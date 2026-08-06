# OIO Oracle Database connection setup

## 1. Purpose

This document defines the intended Oracle Integration connection used by `OIO_LOG_EVENT` to invoke the OIO PL/SQL API.

The repository security model separates object ownership from runtime access:

- `OIO_OWNER` owns the tables, view, and `OIO_TRACE_API`.
- `OIO_RUNTIME` is the optional runtime account intended for the Oracle Integration connection.
- `OIO_RUNTIME` should not receive direct table privileges.

The connection and metadata-discovery behavior must be validated in the target Oracle Integration and Oracle Database environment before the setup is identified as tested.

## 2. Recommended connection

| Property | Recommended value |
|---|---|
| Connection name | `OIO_DB` |
| Identifier | `OIO_DB` |
| Adapter | Oracle Database Adapter |
| Usage | Invoke |
| Runtime database user | `OIO_RUNTIME` |
| Owner schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Connectivity | Environment-specific |
| Security policy | Environment-specific and approved by the implementing organization |

Do not store connection passwords, wallets, certificates, or private endpoints in this repository.

## 3. Database prerequisites

Before creating the OIC connection:

1. Install the OIO database objects as `OIO_OWNER`.
2. Compile `OIO_OWNER.OIO_TRACE_API`.
3. Confirm that the package specification and body are `VALID`.
4. Create `OIO_RUNTIME` when the separate runtime model is being used.
5. Grant `CREATE SESSION` to `OIO_RUNTIME`.
6. Grant `EXECUTE` on `OIO_OWNER.OIO_TRACE_API` directly to `OIO_RUNTIME`.
7. Confirm that no direct table grants were added to the runtime account.
8. Test package execution from a controlled SQL session before configuring OIC.

The current public package procedures are:

```text
OIO_TRACE_API.PR_CREATE_TRACE_LOG
OIO_TRACE_API.PR_UPDATE_TRANSACTION_STATUS
OIO_TRACE_API.REGISTER_EVENT_JSON
```

The initial OIC pattern uses:

```text
PR_CREATE_TRACE_LOG
PR_UPDATE_TRANSACTION_STATUS
```

`REGISTER_EVENT_JSON` remains available for compatibility and direct testing but is not the default operation documented for the new OIC flows.

## 4. Network and connectivity decision

The database endpoint and OIC instance must have an approved connectivity path.

The exact configuration depends on the target architecture, such as:

- a publicly reachable database endpoint protected by approved security controls;
- a private endpoint accessible from the OIC environment;
- an agent-based connection where required by the network topology.

This repository does not prescribe a universal network model. The project team must validate routing, name resolution, TLS, firewall rules, certificates, and private-network requirements for the implementation context.

## 5. Create the connection

In Oracle Integration:

1. Create a new Oracle Database Adapter connection.
2. Set the name and identifier to `OIO_DB`.
3. Configure the database endpoint using project-approved values.
4. Configure the runtime credentials for `OIO_RUNTIME`.
5. Upload or reference only the security material required by the selected connection mode.
6. Test the connection.
7. Do not publish screenshots that reveal host names, service names, wallet details, or credentials.

## 6. Configure the stored-procedure invokes

Inside `OIO_LOG_EVENT`, add two Oracle Database Adapter invokes.

### 6.1 Create trace invoke

Suggested invoke name:

```text
CreateOIOTrace
```

Configuration:

| Setting | Value |
|---|---|
| Operation | Invoke a stored procedure |
| Schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Procedure | `PR_CREATE_TRACE_LOG` |
| Input | `P_PAYLOAD` CLOB |

### 6.2 Update status invoke

Suggested invoke name:

```text
UpdateOIOStatus
```

Configuration:

| Setting | Value |
|---|---|
| Operation | Invoke a stored procedure |
| Schema | `OIO_OWNER` |
| Package | `OIO_TRACE_API` |
| Procedure | `PR_UPDATE_TRANSACTION_STATUS` |
| Input | `P_PAYLOAD` CLOB |

The adapter mapping must pass the complete canonical flat payload as serialized JSON text to `P_PAYLOAD`.

## 7. Metadata-discovery validation

The intended least-privilege model assumes that the Database Adapter can discover and invoke `OIO_OWNER.OIO_TRACE_API` while authenticated as `OIO_RUNTIME`, based on the direct `EXECUTE` grant.

Validate this behavior in the target environment.

If the package is not visible during adapter metadata discovery:

1. Confirm that the grant was issued directly to `OIO_RUNTIME`, not only through a role.
2. Confirm the selected schema and package names.
3. Re-test the database connection.
4. Review database and adapter logs.
5. Evaluate an approved wrapper or synonym strategy if required by the environment.
6. Do not grant broad table privileges merely to work around metadata discovery.
7. Document any deviation from the repository security model.

## 8. Connection test checklist

- [ ] `OIO_OWNER.OIO_TRACE_API` is valid.
- [ ] `OIO_RUNTIME` can create a database session.
- [ ] `OIO_RUNTIME` can execute the package.
- [ ] `OIO_RUNTIME` cannot directly select from or modify OIO tables.
- [ ] OIC successfully tests the `OIO_DB` connection.
- [ ] `PR_CREATE_TRACE_LOG` is visible to the adapter.
- [ ] `PR_UPDATE_TRANSACTION_STATUS` is visible to the adapter.
- [ ] A test create operation inserts the expected master and event rows.
- [ ] A test status operation appends the expected event row.
- [ ] No credentials or environment-specific secrets are present in repository artifacts.

## 9. Security considerations

Use a dedicated credential and rotate it according to the implementing organization's security policy.

Apply the following controls:

- least privilege;
- encrypted transport;
- controlled secret storage;
- credential rotation;
- restricted administrative access;
- auditing appropriate to the environment;
- non-production credentials for repository demonstrations;
- no direct table access for the OIC runtime user unless a documented exception is approved.

The OIC connection controls access to the persistence API. It does not, by itself, determine whether payload content is legally or operationally appropriate to retain. Payload persistence must follow the repository security guidance and the project's privacy, compliance, and data-retention decisions.

## 10. Official Oracle reference

- [Oracle Database Adapter stored-procedure invocation](https://docs.oracle.com/en/cloud/paas/application-integration/database-adapter/invoke-stored-procedure-page.html)
- [Add the Oracle Database Adapter connection to an integration](https://docs.oracle.com/en/cloud/paas/integration-cloud/database-adapter/add-oracle-database-adapter-connection-integration.html)
