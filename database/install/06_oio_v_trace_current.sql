prompt ============================================================
prompt Oracle Integration Observability (OIO) - Current Trace View
prompt ============================================================
prompt Execute as the application schema owner, for example OIO_OWNER.
prompt
prompt Purpose:
prompt   Provides one row per transaction for operational search and APEX.
prompt   The current master state comes from OIO_TRACE.
prompt   The current transaction status and latest event metadata come from
prompt   the most recent OIO_TRACE_EVENT row for each TRACE_ID.
prompt
prompt Design:
prompt   - One row per OIO_TRACE record.
prompt   - No payload CLOBs are exposed.
prompt   - Integration metadata and metadata-driven labels are included.
prompt   - OUTER APPLY preserves traces even if no event exists.
prompt   - Latest event is determined by CREATION_DATE DESC,
prompt     TRACE_DETAIL_ID DESC, matching OIO_V_TRACE_STATUS_HISTORY semantics.
prompt ============================================================

set define off

create or replace force editionable view oio_v_trace_current as
select
    /* ------------------------------------------------------------------
       Master transaction
       ------------------------------------------------------------------ */
    t.trace_id,
    t.integration_key,

    /* ------------------------------------------------------------------
       Integration configuration
       ------------------------------------------------------------------ */
    c.description          as integration_description,
    c.integration_type,
    c.source_system,
    c.target_system,
    c.process_name,
    c.scope_name,

    /* ------------------------------------------------------------------
       Correlation and execution
       ------------------------------------------------------------------ */
    t.log_ref_id,
    t.oic_instance_id,
    t.user_name,

    /* ------------------------------------------------------------------
       Current master state
       ------------------------------------------------------------------ */
    t.log_level,
    case t.log_level
        when 'E' then 'ERROR'
        when 'I' then 'SUCCESS'
        else 'UNKNOWN'
    end                    as outcome,
    le.transaction_status  as current_status,
    t.summary,
    t.error_code,
    t.error_message,

    /* ------------------------------------------------------------------
       Business transaction identifiers and labels
       ------------------------------------------------------------------ */
    t.transaction_id1,
    c.transaction_id1_name,

    t.transaction_id2,
    c.transaction_id2_name,

    t.transaction_id3,
    c.transaction_id3_name,

    /* ------------------------------------------------------------------
       Metadata-driven attributes and labels
       ------------------------------------------------------------------ */
    t.attr1_value,
    c.attr1_name,

    t.attr2_value,
    c.attr2_name,

    t.attr3_value,
    c.attr3_name,

    t.attr4_value,
    c.attr4_name,

    t.attr5_value,
    c.attr5_name,

    t.attr6_value,
    c.attr6_name,

    t.attr7_value,
    c.attr7_name,

    t.attr8_value,
    c.attr8_name,

    t.attr9_value,
    c.attr9_name,

    t.attr10_value,
    c.attr10_name,

    /* ------------------------------------------------------------------
       Latest event
       ------------------------------------------------------------------ */
    le.trace_detail_id     as latest_trace_detail_id,
    le.event_type          as latest_event_type,
    le.step_name           as latest_step_name,
    le.oic_instance_id     as latest_oic_instance_id,
    le.user_name           as latest_event_user_name,
    le.log_level           as latest_event_log_level,
    le.creation_date       as latest_event_timestamp,

    /* ------------------------------------------------------------------
       Master audit dates
       ------------------------------------------------------------------ */
    t.creation_date,
    t.last_update_date

from oio_trace t

join oio_integration_cfg c
  on c.integration_key = t.integration_key

outer apply (
    select
        e.trace_detail_id,
        e.event_type,
        e.step_name,
        e.oic_instance_id,
        e.user_name,
        e.log_level,
        e.transaction_status,
        e.creation_date
    from oio_trace_event e
    where e.trace_id = t.trace_id
    order by
        e.creation_date desc,
        e.trace_detail_id desc
    fetch first 1 row only
) le

with read only
;

comment on table oio_v_trace_current is
    'Current operational transaction view for OIO. Returns one row per trace, integration metadata, current master state, metadata-driven labels, and the latest event/status. Payload CLOBs are intentionally excluded.';

prompt ============================================================
prompt Validation
prompt ============================================================

prompt Expected: same number of rows as OIO_TRACE.
select
    (select count(*) from oio_trace) as trace_count,
    (select count(*) from oio_v_trace_current) as view_count
from dual;

prompt Expected: zero duplicate TRACE_ID values.
select count(*) as duplicate_trace_ids
from (
    select trace_id
    from oio_v_trace_current
    group by trace_id
    having count(*) > 1
);

prompt Sample current transactions.
select *
from (
    select
        trace_id,
        integration_key,
        source_system,
        target_system,
        outcome,
        current_status,
        transaction_id1,
        log_ref_id,
        oic_instance_id,
        latest_event_type,
        latest_event_timestamp,
        creation_date,
        last_update_date
    from oio_v_trace_current
    order by creation_date desc
)
where rownum <= 20;

prompt Error distribution by integration.
select
    integration_key,
    count(*) as transaction_count,
    sum(case when log_level = 'E' then 1 else 0 end) as error_count,
    round(
        100 * sum(case when log_level = 'E' then 1 else 0 end) / count(*),
        2
    ) as error_pct
from oio_v_trace_current
group by integration_key
order by error_count desc;

prompt ============================================================
prompt OIO_V_TRACE_CURRENT created successfully.
prompt ============================================================
