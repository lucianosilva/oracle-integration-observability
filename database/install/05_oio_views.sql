prompt ============================================================
prompt Oracle Integration Observability (OIO) - Support Views
prompt ============================================================
prompt Execute as the application schema owner, for example OIO_OWNER.
prompt ============================================================

set define off

CREATE OR REPLACE FORCE EDITIONABLE VIEW oio_v_trace_status_history AS 
  with latest_status as (
    select trace_id,
           transaction_status,
           row_number() over (
               partition by trace_id
               order by creation_date desc, trace_detail_id desc
           ) rn
      from oio_trace_event
)
select l.trace_id,
       d.trace_detail_id,
       l.integration_key,
       l.transaction_id1,
       l.transaction_id2,
       l.transaction_id3,
       s.transaction_status as current_status,
       d.creation_date as event_timestamp,
       d.event_type,
       d.step_name,
       d.oic_instance_id,
       d.user_name,
       d.log_level,
       d.transaction_status as history_status,
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
       l.creation_date as master_creation_date,
       l.last_update_date as master_last_update_date
  from oio_trace l
  join oio_trace_event d
    on d.trace_id = l.trace_id
  left join latest_status s
    on s.trace_id = l.trace_id
   and s.rn = 1
 where 1=1
;





