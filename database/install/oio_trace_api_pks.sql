create or replace package oio_trace_api authid definer as
    /*
        Oracle Integration Observability (OIO) package.

        Public procedure names were preserved for compatibility with the OIC
        database adapter mappings already discussed for the traceability asset.

        PR_CREATE_TRACE_LOG:
          Registers a trace event from the POST payload. The package creates the
          oio_trace master row, the first oio_trace_event history row, and the
          optional oio_trace_payload payload row.

        PR_UPDATE_TRANSACTION_STATUS:
          Registers a transaction status update from the PATCH payload. The
          package resolves the oio_trace master row by integrationKey and the
          provided transaction identifiers, then appends a oio_trace_event row.

        REGISTER_EVENT_JSON:
          Compatibility wrapper for existing callers that expect status outputs.
    */

    procedure pr_create_trace_log(
        p_payload in clob
    );

    procedure pr_update_transaction_status(
        p_payload in clob
    );

    procedure register_event_json(
        p_payload  in clob,
        o_status   out varchar2,
        o_trace_id out number,
        o_message  out varchar2
    );
end oio_trace_api;
/



