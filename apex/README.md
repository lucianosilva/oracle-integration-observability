# Oracle Integration Observability - APEX Operational Console

This directory contains the Oracle APEX operational console for the **Oracle Integration Observability (OIO)** reference implementation.

The application provides a read-only operational interface for monitoring integration activity, investigating failed or potentially stalled transactions, reviewing transaction event history, and inspecting persisted request and response payloads when available.

> This application is an independent technical reference implementation and is not official Oracle documentation.

## Overview

The APEX console complements the OIO database and Oracle Integration layers with an operational UI focused on monitoring, troubleshooting, and transaction analysis.

The v1 console includes three primary operational areas:

```text
Monitoring Dashboard
        |
        | identify operational patterns
        v
Technical Operations
        |
        | investigate errors or potentially stuck transactions
        v
Transaction Search
        |
        | select transaction
        v
Event History
        |
        | payload available
        v
Payload Viewer
   |           |
 Request    Response
```

Key capabilities include:

- Monitoring dashboard with transaction, error, and success-rate KPIs
- Success-versus-error distribution
- Transaction volume trend analysis
- Top integrations by error count
- Transaction search with bounded time filtering
- Filtering by integration, outcome, status, source, and target
- Custom date-range searches limited to 90 calendar days
- Inline transaction event-history drill-down
- Technical operations dashboard for incident investigation
- Error trend and top error-code analysis
- Detection of potentially stuck transactions using an operational heuristic
- Recent error-event investigation
- Navigation from technical reports directly to Transaction Search
- Modal request/response payload viewer
- Redwood-compatible semantic styling for status, outcome, severity, and KPIs
- English and Brazilian Portuguese application languages
- Read-only access to the OIO observability model

## Architecture

The reference deployment uses a dedicated APEX parsing schema.

```text
                         Oracle Integration
                                |
                                v
                           OIO_OWNER
                     observability data model
                                |
               +----------------+----------------+
               |                                 |
               | SELECT on views                 | SELECT on configuration
               v                                 v
        OIO read-only views              OIO_INTEGRATION_CFG
               |                                 |
               +----------------+----------------+
                                |
                                v
                           OIO_APEX
                        parsing schema
                                |
                                v
                     Oracle APEX Application
```

`OIO_OWNER` owns the observability persistence model and PL/SQL API.

`OIO_APEX` is an optional consumer schema used as the parsing schema for the APEX operational console. It requires only the read privileges needed by the UI.

The application currently consumes:

- `OIO_V_TRACE_CURRENT`
- `OIO_V_TRACE_STATUS_HISTORY`
- `OIO_V_TRACE_PAYLOAD`
- `OIO_INTEGRATION_CFG`

`OIO_INTEGRATION_CFG` is used by integration list-of-values components and filters.

### Security Model

The APEX console is intentionally read-only.

The reference grants are:

```sql
grant select on OIO_OWNER.OIO_V_TRACE_CURRENT
    to OIO_APEX;

grant select on OIO_OWNER.OIO_V_TRACE_STATUS_HISTORY
    to OIO_APEX;

grant select on OIO_OWNER.OIO_V_TRACE_PAYLOAD
    to OIO_APEX;

grant select on OIO_OWNER.OIO_INTEGRATION_CFG
    to OIO_APEX;
```

If direct database login to the parsing schema is required for administration or deployment tasks, the reference setup also grants:

```sql
grant create session to OIO_APEX;
```

The APEX schema does **not** require:

- direct DML access to OIO trace tables
- `EXECUTE` on `OIO_TRACE_API`
- `SELECT ANY TABLE`
- `EXECUTE ANY PROCEDURE`
- other broad database privileges

This separation keeps the operational UI independent from the runtime logging API used by Oracle Integration.

## Monitoring Dashboard

The **Monitoring Dashboard** provides a high-level operational view of integration activity for a selected period.

Supported periods include:

- Last hour
- Last 6 hours
- Last 24 hours
- Last 7 days
- Last 30 days
- Custom range

Custom date ranges are bounded to a maximum of 90 calendar days.

The dashboard includes:

### KPI Cards

- **Transactions** - total transactions in the selected period
- **Errors** - transactions with an error outcome
- **Success Rate** - percentage of successful transactions

The KPI values use semantic Universal Theme / Redwood-compatible styling while keeping presentation logic separate from the persisted transaction data.

### Success vs Error

A donut chart presents the distribution of successful and failed transactions for the selected period.

### Transaction Volume

A time-series chart shows transaction volume over time. The aggregation level is adjusted according to the selected period so that short and long periods remain readable.

### Top Integrations by Error

A bar chart highlights integrations generating the highest number of transaction errors during the selected period.

## Transaction Search

The **Transaction Search** page is designed for business support, operational support, and detailed transaction investigation.

It provides:

- mandatory bounded time filtering
- integration filtering
- outcome filtering
- transaction-status filtering
- source-system filtering
- target-system filtering
- custom date ranges limited to 90 calendar days
- Interactive Report capabilities for additional end-user sorting and filtering

A selected transaction is maintained as transient UI state and its Event History is refreshed without requiring a complete page reload.

The transaction identifier is presented as a navigation point from other operational pages, while the internal `TRACE_ID` is used as the technical identity for the selected trace.

## Event History

The **Event History** region presents the lifecycle of the selected transaction.

Depending on the available data, it exposes information such as:

- Event Timestamp
- Event Type
- Processing Step
- Transaction Status
- Severity / Log Level
- OIC Instance ID
- User
- Summary
- Error Code
- Error Message
- Transaction ID

Technical severity values can be translated in the presentation layer for easier operational interpretation.

```text
I -> Info
E -> Error
```

Status and severity are rendered using semantic Redwood-compatible styling without changing the underlying persisted values.

## Technical Operations

The **Technical Operations** page is intended for integration support and IT operations teams investigating errors and abnormal transaction behavior.

It complements the functional-oriented Transaction Search page by emphasizing operational signals and troubleshooting information.

### Filters

The page supports:

- bounded period selection
- integration filtering
- custom date range

The same bounded-period principle used by the other console pages is maintained to avoid unbounded operational queries.

### Technical KPI Cards

The page includes:

- **Errors** - error transactions in the selected period
- **Error Rate** - percentage of transactions with errors
- **Potentially Stuck** - transactions matching the current inactivity heuristic
- **Affected Integrations** - integrations with errors in the selected period

### Potentially Stuck Heuristic

A transaction is considered **potentially stuck** when:

```text
Current Status = RECEIVED or IN_PROGRESS
AND
No new event has been recorded for more than 30 minutes
```

This is an operational heuristic and must not be interpreted as authoritative proof that an Oracle Integration instance is stuck.

Different implementations may require different inactivity thresholds depending on expected process duration and integration behavior.

### Error Trend

A time-series chart shows error activity over the selected period, helping operators identify spikes or unusual error patterns.

### Top Error Codes

A bar chart summarizes the most frequent error codes in the selected period and helps identify recurring failure categories.

### Potentially Stuck Transactions

An Interactive Report exposes candidate transactions together with information such as:

- Integration
- Transaction ID
- Current Status
- Latest Step
- Latest Event Timestamp
- Idle Minutes
- OIC Instance ID
- Summary

The Transaction ID links directly to **Transaction Search**, where the complete transaction history can be investigated.

### Recent Error Events

An Interactive Report provides recent error events with operational details including:

- Event Timestamp
- Integration
- Transaction ID
- Event
- Step
- Status
- OIC Instance ID
- Error Code
- Error Message
- Summary

Transaction links allow operators to move from the technical error view to the full transaction history without manually repeating the search.

## Payload Viewer

If an event has a persisted payload, the Event History exposes a **View Payload** action.

The modal displays contextual information for the selected event together with:

- Transaction ID
- Integration
- Event
- Step
- Status
- Severity
- Request Payload
- Response Payload

Payload persistence is optional.

Request and response content may contain personal, financial, confidential, or regulated information. Each implementation should define appropriate security, privacy, masking, retention, access, and deletion controls before enabling payload storage.

Payload collection should be omitted when it is not required for the relevant operational or troubleshooting use case.

## Internationalization

The reference application uses English as its primary application language and includes Brazilian Portuguese as a translated language.

Reference application IDs:

```text
Primary application:    101
Translated application: 10002
Language:               pt-br
```

The translation workflow follows the standard Oracle APEX application translation process:

```text
Primary Application
       |
       v
Seed Translatable Text
       |
       v
Export / Maintain XLIFF
       |
       v
Apply Translation
       |
       v
Publish Translated Application
```

Component text such as page titles, region titles, labels, and declarative UI messages is maintained through the APEX translation repository and XLIFF.

Text generated directly by SQL should use APEX Text Messages instead of hard-coded language-specific literals. This allows SQL-generated card titles and descriptions to follow the current application language.

During active development, changes should be validated first against the primary application. After a development checkpoint, translations should be reseeded, updated, applied, and republished so that the translated application remains synchronized with the primary application.

## Global Application Styling

Shared OIO-specific styling is maintained as an APEX Static Application File and loaded at application level rather than duplicated as page-level inline CSS.

The reference CSS file is:

```text
css/oio.css
```

It is referenced at application level using:

```text
#APP_FILES#css/oio.css
```

This file contains reusable presentation rules such as KPI value formatting, while semantic status colors continue to use Universal Theme / Redwood-compatible utility classes where appropriate.

## APEX Export

The application export is stored under:

```text
apex/export/f101/
```

The repository uses the **split application export** format so that pages and shared components can be reviewed and versioned independently.

```text
f101/
├── install.sql
└── application/
    ├── create_application.sql
    ├── pages/
    ├── shared_components/
    └── ...
```

The reference application ID is:

```text
101
```

After significant application changes, regenerate the split export so that page definitions, shared components, application static files, navigation changes, and other application metadata remain synchronized with the repository.

## Translation Artifact

The Brazilian Portuguese XLIFF translation can be versioned under:

```text
apex/translations/
```

For example:

```text
apex/translations/f101_10002_en_pt-br.xlf
```

Keeping the XLIFF artifact in source control makes translation changes reviewable independently from the application export.

## Installation

### Prerequisites

Before importing the application:

1. Install the OIO database objects under `OIO_OWNER`.
2. Create or identify an APEX workspace.
3. Create or identify the APEX parsing schema.
4. Associate the parsing schema with the target APEX workspace.
5. Grant the parsing schema access to the required OIO objects.
6. Import the APEX application.
7. Configure and publish translations when required.

### Reference Parsing Schema

The reference environment uses:

```text
OIO_APEX
```

The repository keeps APEX-specific database setup separate from the core OIO database installation.

Reference setup scripts are stored under:

```text
apex/install/
```

Suggested structure:

```text
apex/install/
├── 00_oio_apex_creation.sql
└── 01_oio_apex_grants.sql
```

`00_oio_apex_creation.sql` creates the reference parsing schema and the minimal database login privilege used by the reference environment.

`01_oio_apex_grants.sql` grants read-only access to the OIO objects consumed by the application.

A different parsing schema can be selected during import as long as equivalent privileges are granted.

The current application contains SQL references to the `OIO_OWNER` schema. If the observability objects are deployed under a different owner, review those references after import.

### Importing the Split Export

The split export can be installed using:

```text
apex/export/f101/install.sql
```

The application can also be imported through Oracle APEX App Builder.

## Screenshots

### Transaction Search

![Transaction Search](screenshots/transaction-search_01.png)

![Transaction Search - Custom Range](screenshots/transaction-search_02.png)

### Event History

![Transaction Event History](screenshots/transaction-search_event_history_01.png)

![Transaction Event History - Status Styling](screenshots/transaction-search_event_history_02.png)

### Payload Viewer

![Payload Viewer](screenshots/transaction-event-history-payload_01.png)

Additional screenshots of the Monitoring Dashboard and Technical Operations pages can be added to this section as the v1 repository artifacts are finalized.

## Repository Structure

```text
apex/
├── README.md
├── install/
│   ├── 00_oio_apex_creation.sql
│   └── 01_oio_apex_grants.sql
├── export/
│   └── f101/
│       ├── install.sql
│       └── application/
├── translations/
│   └── f101_10002_en_pt-br.xlf
└── screenshots/
    ├── transaction-event-history-payload_01.png
    ├── transaction-search_01.png
    ├── transaction-search_02.png
    ├── transaction-search_event_history_01.png
    └── transaction-search_event_history_02.png
```

## v1 Scope and Future Evolution

The v1 APEX console establishes the operational UI layer for the OIO reference implementation.

The following items are intentionally considered future enhancements rather than v1 requirements:

- role-based application authorization profiles
- richer JSON/XML payload formatting
- configurable potentially-stuck thresholds
- schema-independent SQL references
- additional operational drill-downs
- enhanced accessibility and visual refinements
- external observability access through the broader ORDS / Grafana extension of the OIO project

These enhancements should preserve the current design principles of bounded operational queries, least privilege, read-only observability access, and separation between business processing and monitoring concerns.

## Related Components

The APEX console is one layer of the broader Oracle Integration Observability reference implementation.

- [`../README.md`](../README.md) - project overview
- [`../docs/architecture.md`](../docs/architecture.md) - architecture
- [`../docs/logging-contract.md`](../docs/logging-contract.md) - logging contract
- [`../database/install/`](../database/install/) - database objects and PL/SQL API
- [`../oic/`](../oic/) - Oracle Integration implementation

## License

This project is licensed under the Apache License 2.0. See [`../LICENSE`](../LICENSE).
