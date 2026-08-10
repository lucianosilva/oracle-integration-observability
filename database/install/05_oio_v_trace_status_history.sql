prompt ============================================================
prompt Oracle Integration Observability (OIO) - Trace Status History View
prompt ============================================================
prompt Execute as the application schema owner, for example OIO_OWNER.
prompt
prompt Purpose:
prompt   Exposes the chronological event history of each OIO transaction,
prompt   together with the current transaction status and master identifiers.
prompt
prompt Intended use:
prompt   - APEX Transaction Search detail region
prompt   - Operational troubleshooting
prompt   - Transaction status timeline
prompt
prompt Notes:
prompt   - One row is returned for each OIO_TRACE_EVENT row.
prompt   - CURRENT_STATUS is derived from the latest event for the TRACE_ID.
prompt   - HISTORY_STATUS is the status recorded on the individual event.
prompt   - Payload CLOBs are intentionally not included.
prompt ============================================================

set define off

create or replace force editionable view oio_v_trace_status_history as
with latest_status as (
    select
        trace_id,
        transaction_status,
        row_number() over (
            partition by trace_id
            order by creation_date desc,
                     trace_detail_id desc
        ) as rn
    from oio_trace_event
)
select
    l.trace_id,
    d.trace_detail_id,
    l.integration_key,

    l.transaction_id1,
    l.transaction_id2,
    l.transaction_id3,

    s.transaction_status       as current_status,

    d.creation_date            as event_timestamp,
    d.event_type,
    d.step_name,
    d.oic_instance_id,
    d.user_name,
    d.log_level,
    d.transaction_status       as history_status,
    d.error_code,
    d.error_message,
    d.summary,

    l.log_ref_id,

    l.attr1_value,
    l.attr2_value,
    l.attr3_value,
    l.attr4_value,
    l.attr5_value,
    l.attr6_value,
    l.attr7_value,
    l.attr8_value,
    l.attr9_value,
    l.attr10_value,

    l.creation_date            as master_creation_date,
    l.last_update_date         as master_last_update_date

from oio_trace l

join oio_trace_event d
  on d.trace_id = l.trace_id

left join latest_status s
  on s.trace_id = l.trace_id
 and s.rn = 1
;

comment on table oio_v_trace_status_history is
    'Chronological OIO transaction event history. Returns one row per trace event and includes the current status derived from the latest event.';

prompt ============================================================
prompt Validation
prompt ============================================================

prompt Expected: VIEW_COUNT should match OIO_TRACE_EVENT count.
select
    (select count(*) from oio_trace_event) as event_count,
    (select count(*) from oio_v_trace_status_history) as view_count
from dual;

prompt Expected: one current status value per TRACE_ID in the result.
select
    trace_id,
    integration_key,
    current_status,
    history_status,
    event_type,
    step_name,
    event_timestamp
from (
    select
        trace_id,
        integration_key,
        current_status,
        history_status,
        event_type,
        step_name,
        event_timestamp
    from oio_v_trace_status_history
    order by event_timestamp desc,
             trace_detail_id desc
)
where rownum <= 20;

prompt ============================================================
prompt OIO_V_TRACE_STATUS_HISTORY created successfully.
prompt ============================================================
