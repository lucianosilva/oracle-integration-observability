prompt ============================================================
prompt Oracle Integration Observability - APEX Read Grants
prompt ============================================================
prompt Execute as OIO_OWNER or an authorized DBA.
prompt ============================================================

grant select on OIO_V_TRACE_CURRENT
    to OIO_APEX;

grant select on OIO_V_TRACE_STATUS_HISTORY
    to OIO_APEX;

grant select on OIO_V_TRACE_PAYLOAD
    to OIO_APEX;

grant select on OIO_INTEGRATION_CFG
    to OIO_APEX;

prompt ============================================================
prompt OIO_APEX read privileges granted.
prompt ============================================================