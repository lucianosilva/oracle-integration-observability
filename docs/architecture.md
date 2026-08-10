# Oracle Integration Observability Architecture

## 1. Purpose

Oracle Integration Observability (OIO) is a reference implementation for capturing technical execution data together with business context from Oracle Integration.

The solution extends native integration monitoring by persisting a structured and searchable history outside Oracle Integration. Its primary goal is to help support and business teams answer questions such as:

- Which business transaction was processed?
- Which Oracle Integration instance handled it?
- What was the latest known transaction status?
- Which status changes occurred during the transaction lifecycle?
- Was the event informational or related to an error?
- Which request or response payload was retained for investigation?

This repository complements the article [From Fault Handling to Observability: Building a Monitoring Framework with Oracle Integration Cloud](https://medium.com/@lcarmo2701/from-fault-handling-to-observability-building-a-monitoring-framework-with-oracle-integration-cloud-407b34755cd0).

## 2. Scope

The current implementation includes:

- A metadata-driven integration registry.
- A flat JSON logging contract.
- A transaction-level trace record.
- A chronological event and status history.
- Optional CLOB storage for request and response payloads.
- A PL/SQL API used as the database entry point.
- A support view that exposes the current status together with the complete history.
- Separate owner and optional runtime database users.
- The asynchronous `OIO_LOG_EVENT` Oracle Integration component.
- An exported `OIO_SAMPLE_BUSINESS_FLOW` demonstration integration.
- A sanitized Oracle Integration export for `OIO_LOG_EVENT`.
- Native OIC fault generation when database persistence returns a non-success result.
- An Oracle APEX application export.

The current version does not include:

- ORDS endpoints.
- Grafana dashboards or alert rules.
- Automated deployment pipelines.
- A prescriptive retention or purge policy.

These items may be added in later repository versions.

## 3. Design principles

### 3.1 Business context is part of observability

An Oracle Integration instance identifier is useful for technical troubleshooting, but it is rarely sufficient for business support. OIO stores business transaction identifiers and configurable attributes alongside execution information.

### 3.2 The logging payload remains flat

The canonical JSON contract is intentionally flat. This reduces mapping complexity in Oracle Integration and keeps the normalization logic inside `OIO_TRACE_API`.

### 3.3 Integration-specific meaning is metadata-driven

The physical columns `ATTR1_VALUE` through `ATTR10_VALUE` and `TRANSACTION_ID1` through `TRANSACTION_ID3` are generic. Their business meaning is defined by the matching row in `OIO_INTEGRATION_CFG`.

### 3.4 Transaction data and history are separated

The model distinguishes between:

- The trace master record and stable identifiers.
- The chronological sequence of events and status changes.
- Optional large payloads associated with a specific event.

### 3.5 Payload storage is optional

Request and response payloads are stored only when provided. They are separated from the main trace tables to avoid making routine operational queries dependent on CLOB columns.

### 3.6 Database access follows least privilege

`OIO_OWNER` owns the database objects. The optional `OIO_RUNTIME` user is intended for the Oracle Integration database connection and receives only `CREATE SESSION` and `EXECUTE` on `OIO_TRACE_API`.

### 3.7 Observability persistence is asynchronous

The business integration does not call the database API directly. It dispatches the flat OIO event to `OIO_LOG_EVENT` using an asynchronous fire-and-forget invocation.

The parent process continues after Oracle Integration accepts the handoff. Database persistence, result evaluation, and any later logging failure occur in the child integration instance. This prevents observability storage from becoming part of the business response path while keeping failed logging instances visible through native OIC monitoring and error management.

## 4. Logical architecture

```mermaid
flowchart LR
    A[Business integration] -->|Asynchronous local invoke| B[OIO_LOG_EVENT]
    B --> C[Build / serialize flat OIO payload]
    C --> D[Oracle Database Adapter]
    D --> E[OIO_TRACE_API]

    E --> F[(OIO_INTEGRATION_CFG)]
    E --> G[(OIO_TRACE)]
    E --> H[(OIO_TRACE_EVENT)]
    E --> I[(OIO_TRACE_PAYLOAD)]

    E -->|O_STATUS / O_MESSAGE| B
    B -->|O_STATUS = SUCCESS| J[Child completes]
    B -->|O_STATUS != SUCCESS| K[Throw New Fault]
    K --> L[OIC native error management]

    G --> M[OIO_V_TRACE_STATUS_HISTORY]
    H --> M
    M --> N[SQL and support queries]
    M -. future .-> O[Oracle APEX]
    M -. future .-> P[ORDS and Grafana]
```

The asynchronous handoff isolates the business process from database persistence. A successful handoff means that the child request was accepted by Oracle Integration; it does not guarantee that the database write completed successfully.

## 5. Components

### 5.1 Business integration

The business integration is responsible for collecting the values required by the logging contract and dispatching the event asynchronously to `OIO_LOG_EVENT`.

Depending on the use case, the dispatch may occur from:

- The main orchestration flow.
- A scope fault handler.
- A global fault handler.
- A retry or reprocessing flow.
- A support operation that changes the business transaction status.

The business integration does not wait for the Database Adapter or PL/SQL package to complete. Field-level behavior is defined in the [logging contract](logging-contract.md), while OIC implementation details are maintained under [`oic/`](../oic/README.md).

### 5.2 `OIO_INTEGRATION_CFG`

This table is the mandatory registry of integrations allowed to write to OIO.

Each `integrationKey` must have a corresponding active configuration. The configuration provides:

- Integration description and type.
- Source and target systems.
- Process and scope information.
- Labels for up to three transaction identifiers.
- Labels for up to ten integration-specific attributes.

The configuration separates the physical logging contract from the business meaning of each generic field.

### 5.3 `OIO_TRACE`

This is the master record for a traced business transaction.

It stores:

- The configured integration key.
- Correlation and Oracle Integration instance identifiers.
- User or service account information.
- Log level, summary, and error information.
- Up to ten metadata-driven attribute values.
- Up to three business transaction identifiers.
- Creation and last-update timestamps.

A new row is created when a create operation is submitted to the API.

### 5.4 `OIO_TRACE_EVENT`

This table stores the chronological history associated with an `OIO_TRACE` record.

Each row may contain:

- Event classification.
- Integration step information.
- Oracle Integration instance identifier.
- User or service account.
- Log level and summary.
- Error code and message.
- Business-defined transaction status.
- Event timestamp.

The current transaction status is derived from the latest event rather than maintained as a separate status column in the master table.

### 5.5 `OIO_TRACE_PAYLOAD`

This table stores optional request and response payloads as CLOB values.

A payload row belongs to a specific `OIO_TRACE_EVENT`, not directly to the master trace. This preserves the relationship between the retained payload and the event that produced it.

Payload storage should be selective. Sensitive, regulated, or high-volume content should be sanitized or omitted according to the implementation's security and retention requirements.

### 5.6 `OIO_TRACE_API`

The package is the public database interface for the framework. It exposes:

- `PR_CREATE_TRACE_LOG`
- `PR_UPDATE_TRANSACTION_STATUS`
- `REGISTER_EVENT_JSON`

The package:

- Parses the flat payload.
- Validates the integration key.
- Applies mandatory-field rules.
- Creates the master trace and initial event.
- Appends transaction status events.
- Stores optional request and response payloads.
- Controls the autonomous database transaction used by each public operation.

`PR_CREATE_TRACE_LOG` and `PR_UPDATE_TRANSACTION_STATUS` return `O_STATUS` and `O_MESSAGE`. On success, the operation commits and returns `SUCCESS`. On an internal error, the operation rolls back and returns an error status and diagnostic message to `OIO_LOG_EVENT` for evaluation.

`REGISTER_EVENT_JSON` remains a compatibility wrapper with its own `OK` / `ERROR` behavior and generated trace identifier.

The package uses definer-rights execution so the runtime user does not require direct table privileges.

### 5.7 `OIO_LOG_EVENT`

`OIO_LOG_EVENT` is the reusable asynchronous Oracle Integration component that isolates the business flow from the database layer.

For each operation it:

1. Receives the flat OIO payload.
2. Serializes the payload for the PL/SQL CLOB input.
3. Invokes the corresponding `OIO_TRACE_API` procedure.
4. Evaluates `O_STATUS` returned by the procedure.
5. Completes normally when `O_STATUS = SUCCESS`.
6. Executes `Throw New Fault` when `O_STATUS != SUCCESS`, using `O_MESSAGE` as diagnostic context.

The generated fault belongs to the asynchronous child instance and is intentionally left to native OIC monitoring and error management. It does not propagate back to a parent business integration that has already continued.

### 5.8 `OIO_V_TRACE_STATUS_HISTORY`

The support view joins the trace master and event history. It exposes:

- Stable trace and transaction identifiers.
- The latest transaction status.
- Every historical status and event.
- Error information.
- Configurable attribute values.
- Master and event timestamps.

The view is intended as the initial access layer for support queries and future presentation components.

## 6. Main processing flows

### 6.1 Create a trace

```mermaid
sequenceDiagram
    participant Parent as Business integration
    participant Logger as OIO_LOG_EVENT
    participant API as OIO_TRACE_API
    participant CFG as OIO_INTEGRATION_CFG
    participant TRC as OIO_TRACE
    participant EVT as OIO_TRACE_EVENT
    participant PAY as OIO_TRACE_PAYLOAD
    participant EM as OIC error management

    Parent-)Logger: Asynchronous CreateTrace handoff
    Parent-->>Parent: Continue business processing
    Logger->>API: PR_CREATE_TRACE_LOG(P_PAYLOAD)
    API->>CFG: Validate active integrationKey
    CFG-->>API: Configuration found
    API->>TRC: Insert master trace
    API->>EVT: Insert initial event and status
    opt requestPayload or responsePayload provided
        API->>PAY: Insert payload linked to event
    end
    API-->>Logger: O_STATUS / O_MESSAGE
    alt O_STATUS = SUCCESS
        Logger-->>Logger: Complete child instance
    else O_STATUS != SUCCESS
        Logger->>Logger: Throw New Fault
        Logger-->>EM: Failed child instance
    end
```

A successful database operation creates one master row and one initial history row. A payload row is created only when at least one payload value is present.

### 6.2 Update transaction status

```mermaid
sequenceDiagram
    participant Parent as Business or support integration
    participant Logger as OIO_LOG_EVENT
    participant API as OIO_TRACE_API
    participant TRC as OIO_TRACE
    participant EVT as OIO_TRACE_EVENT
    participant PAY as OIO_TRACE_PAYLOAD
    participant EM as OIC error management

    Parent-)Logger: Asynchronous UpdateTransactionStatus handoff
    Parent-->>Parent: Continue processing
    Logger->>API: PR_UPDATE_TRANSACTION_STATUS(P_PAYLOAD)
    API->>TRC: Locate matching trace records
    API->>TRC: Update non-null master values
    API->>EVT: Append STATUS_UPDATE event
    opt requestPayload or responsePayload provided
        API->>PAY: Insert payload linked to event
    end
    API-->>Logger: O_STATUS / O_MESSAGE
    alt O_STATUS = SUCCESS
        Logger-->>Logger: Complete child instance
    else O_STATUS != SUCCESS
        Logger->>Logger: Throw New Fault
        Logger-->>EM: Failed child instance
    end
```

The current implementation locates records by `integrationKey` and the transaction identifiers provided in the payload. Null transaction identifiers are ignored during matching. If more than one trace satisfies the criteria, the master values are updated and a status event is appended to every matching trace.

## 7. Data relationships

```mermaid
erDiagram
    OIO_INTEGRATION_CFG ||--o{ OIO_TRACE : configures
    OIO_TRACE ||--|{ OIO_TRACE_EVENT : contains
    OIO_TRACE_EVENT ||--o| OIO_TRACE_PAYLOAD : may_have

    OIO_INTEGRATION_CFG {
        varchar2 integration_key PK
        char active_flag
        varchar2 source_system
        varchar2 target_system
        varchar2 transaction_id1_name
        varchar2 attr1_name
    }

    OIO_TRACE {
        number trace_id PK
        varchar2 integration_key FK
        varchar2 log_ref_id
        varchar2 oic_instance_id
        char log_level
        varchar2 transaction_id1
        timestamp creation_date
    }

    OIO_TRACE_EVENT {
        number trace_detail_id PK
        number trace_id FK
        varchar2 event_type
        varchar2 transaction_status
        timestamp creation_date
    }

    OIO_TRACE_PAYLOAD {
        number trace_lob_id PK
        number trace_detail_id FK
        clob request
        clob response
        timestamp creation_date
    }
```

## 8. Event classification

For trace creation, the package derives the event type using the submitted fields:

1. `ERROR` when `logLevel` is `E`, `errorCode` is populated, or `errorMessage` is populated.
2. `STATUS_EVENT` when a transaction status is populated and the event is not classified as an error.
3. `INFO` when neither of the previous conditions applies.

Because `transactionStatus` is mandatory in the current create operation, a non-error creation event is normally classified as `STATUS_EVENT`.

Status updates are recorded with the event type `STATUS_UPDATE`.

## 9. Transaction and failure behavior

The public persistence procedures use autonomous database transactions.

For `PR_CREATE_TRACE_LOG` and `PR_UPDATE_TRANSACTION_STATUS`:

- Successful processing commits independently from the caller and returns `O_STATUS = SUCCESS` with an informational `O_MESSAGE`.
- Internal processing errors roll back the OIO transaction and are converted into `O_STATUS` / `O_MESSAGE` output values.
- `OIO_LOG_EVENT` evaluates the returned status after the Database Adapter invoke.
- When the status differs from `SUCCESS`, the child integration executes `Throw New Fault` so the failed logger instance remains visible and manageable through native OIC error handling.

Because `OIO_LOG_EVENT` is invoked asynchronously, this failure is isolated from the parent business integration after the handoff has been accepted. The parent does not wait for the database result and does not receive `O_STATUS` or `O_MESSAGE`.

This creates two separate operational boundaries:

1. **Business-flow execution:** continues after the asynchronous handoff is accepted.
2. **Observability persistence:** completes or fails independently in the `OIO_LOG_EVENT` instance.

`REGISTER_EVENT_JSON` is a compatibility wrapper and is not the primary procedure used by the current OIC component. Its exception behavior differs from the two primary procedures and is documented in the [logging contract](logging-contract.md).

## 10. Security boundaries

### Owner schema

`OIO_OWNER` owns the tables, view, indexes, constraints, and package.

### Runtime schema

`OIO_RUNTIME` is optional. It is intended for the Oracle Integration connection and receives:

- `CREATE SESSION`
- `EXECUTE` on `OIO_OWNER.OIO_TRACE_API`

It does not receive direct table privileges.

### Data protection considerations

Implementations should:

- Avoid storing credentials, access tokens, authorization headers, or database secrets.
- Sanitize personal, financial, and regulated information before persistence.
- Store request and response payloads only when operationally justified.
- Restrict support access to payload data.
- Define retention and purge rules appropriate to data volume and compliance requirements.
- Use non-production or anonymized values in repository examples.

## 11. Scalability and retention

`OIO_TRACE`, `OIO_TRACE_EVENT`, and `OIO_TRACE_PAYLOAD` are range-partitioned by `CREATION_DATE` with monthly interval partitions.

This supports:

- Time-based operational queries.
- Partition-oriented retention strategies.
- Separation of recent operational data from older history.
- More predictable management of high-volume logging data.

No automatic purge job is included in the current release. Retention must be defined by each implementation according to its transaction volume, support requirements, and compliance obligations.

## 12. Repository structure

The relevant repository areas follow this structure:

```text
oracle-integration-observability/
├── oic
│   ├── screenshot
│   │   ├── OIO_TRACE_DB_connection.png
│   │   ├── OIO_SAMPLE_BUSINESS_FLOW.png
│   │   ├── OIO_LOG_EVENT_main.png
│   │   └── OIO_LOG_EVENT_global_handling.png
│   ├── mapping-reference.md
│   ├── implementation-pattern.md
│   ├── fault-handler-pattern.md
│   ├── export
│   │   ├── OIO_SAMPLE_BUSINESS_FLOW_01.00.0000.iar
│   │   └── OIO_LOG_EVENT_01.00.0000.iar
│   ├── connection-setup.md
│   └── README.md
├── docs
│   ├── logging-contract.md
│   └── architecture.md
├── database
│   └── install
│       ├── validation_queries_oio.sql
│       ├── sample_data_oio.sql
│       ├── oio_trace_api_pks.sql
│       ├── oio_trace_api_pkb.sql
│       ├── README.md
│       ├── 06_oio_v_trace_current.sql
│       ├── 05_oio_views.sql
│       ├── 05_oio_v_trace_status_history.sql
│       ├── 04_oio_trace_payload.sql
│       ├── 03_oio_trace_event.sql
│       ├── 02_oio_trace.sql
│       ├── 01_oio_integration_cfg.sql
│       ├── 00_oio_runtime_creation.sql
│       └── 00_oio_owner_creation.sql
├── contracts
│   └── examples
│       ├── README.md
│       ├── 06_update_status_in_progress.json
│       ├── 05_update_status_resolved.json
│       ├── 04_create_po_sync_success.json
│       ├── 03_create_technical_error.json
│       ├── 02_create_business_error.json
│       └── 01_create_success.json
├── apex
│   ├── screenshots
│   │   ├── transaction-search_event_history_02.png
│   │   ├── transaction-search_event_history_01.png
│   │   ├── transaction-search_02.png
│   │   ├── transaction-search_01.png
│   │   └── transaction-event_history-payload_01.png
│   ├── export
│   │   └── f101
│   │       ├── install.sql
│   │       └── application
│   │           ├── ** <HIDDEN>
│   └── README.md
├── README.md
└── LICENSE
```

## 13. Current limitations

- The database scripts and package should be validated in a clean target database before a tagged tested release.
- Transaction statuses are business-defined and are not restricted by a database check constraint.
- The physical attribute fields are generic and require configuration documentation for each integration.
- Status update matching can affect multiple traces when the provided identifiers are not unique.
- The PL/SQL implementation supports JSON as the canonical contract and also contains XML parsing compatibility logic.
- `OIO_LOG_EVENT` is included, but the demonstration `OIO_SAMPLE_BUSINESS_FLOW` is currently documented rather than exported.
- No user interface, reconciliation process, or external alerting component is included in the current release.

## 14. Planned evolution

Potential future increments include:

- An exported `OIO_SAMPLE_BUSINESS_FLOW` demonstration integration.
- Sanitized OIC implementation screenshots.
- APEX operational pages.
- ORDS APIs and OpenAPI definitions.
- Grafana dashboards and alerting examples.
- Automated installation and regression tests.
- Purge and retention utilities.
- CI/CD validation for SQL and documentation artifacts.
