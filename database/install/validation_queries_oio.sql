prompt ============================================================
prompt Oracle Integration Observability (OIO) - Sample Data Validation Queries
prompt ============================================================

set define off

prompt 1) Master rows by integration and current status from latest detail
with latest_status as (
    select trace_id,
           transaction_status,
           row_number() over (
               partition by trace_id
               order by creation_date desc, trace_detail_id desc
           ) rn
      from oio_trace_event
)
select l.integration_key,
       c.description,
       s.transaction_status as current_status,
       count(*) as master_rows
  from oio_trace l
  join oio_integration_cfg c
    on c.integration_key = l.integration_key
  left join latest_status s
    on s.trace_id = l.trace_id
   and s.rn = 1
 where l.integration_key in (
       'FIN_AP_PAYMENT_FLOW',
       'SCM_PO_SYNC',
       'FIN_AR_SYSTEM_A',
       'FIN_AR_SYSTEM_B'
 )
 group by l.integration_key,
          c.description,
          s.transaction_status
 order by l.integration_key,
          s.transaction_status;

prompt 2) Payables master/detail status history
with latest_status as (
    select trace_id,
           transaction_status,
           row_number() over (
               partition by trace_id
               order by creation_date desc, trace_detail_id desc
           ) rn
      from oio_trace_event
)
select l.transaction_id1 as ap_invoice_number,
       s.transaction_status as current_status,
       d.creation_date,
       d.event_type,
       d.step_name,
       d.log_level,
       d.transaction_status as history_status,
       d.error_code,
       d.summary
  from oio_trace l
  join oio_trace_event d
    on d.trace_id = l.trace_id
  left join latest_status s
    on s.trace_id = l.trace_id
   and s.rn = 1
 where l.integration_key = 'FIN_AP_PAYMENT_FLOW'
 order by l.transaction_id1,
          d.creation_date;

prompt 3) SCM simple success transactions
with latest_status as (
    select trace_id,
           transaction_status,
           row_number() over (
               partition by trace_id
               order by creation_date desc, trace_detail_id desc
           ) rn
      from oio_trace_event
)
select l.transaction_id1 as po_number,
       l.transaction_id2 as acknowledgement_number,
       s.transaction_status as current_status,
       count(d.trace_detail_id) as detail_rows
  from oio_trace l
  join oio_trace_event d
    on d.trace_id = l.trace_id
  left join latest_status s
    on s.trace_id = l.trace_id
   and s.rn = 1
 where l.integration_key = 'SCM_PO_SYNC'
 group by l.transaction_id1,
          l.transaction_id2,
          s.transaction_status
 order by l.transaction_id1;

prompt 4) Receivables same transaction sent to multiple systems
with latest_status as (
    select trace_id,
           transaction_status,
           row_number() over (
               partition by trace_id
               order by creation_date desc, trace_detail_id desc
           ) rn
      from oio_trace_event
)
select l.transaction_id1 as receivables_transaction,
       l.integration_key,
       c.target_system,
       l.transaction_id2 as target_document_id,
       s.transaction_status as current_status,
       count(d.trace_detail_id) as status_history_rows,
       min(d.creation_date) as first_event,
       max(d.creation_date) as last_event
  from oio_trace l
  join oio_integration_cfg c
    on c.integration_key = l.integration_key
  join oio_trace_event d
    on d.trace_id = l.trace_id
  left join latest_status s
    on s.trace_id = l.trace_id
   and s.rn = 1
 where l.integration_key in ('FIN_AR_SYSTEM_A', 'FIN_AR_SYSTEM_B')
 group by l.transaction_id1,
          l.integration_key,
          c.target_system,
          l.transaction_id2,
          s.transaction_status
 order by l.transaction_id1,
          c.target_system;

prompt 5) Payload LOB records by master/detail
select l.integration_key,
       l.transaction_id1,
       d.step_name,
       d.transaction_status,
       dbms_lob.getlength(lb.request) as request_size,
       dbms_lob.getlength(lb.response) as response_size,
       lb.creation_date
  from oio_trace_payload lb
  join oio_trace_event d
    on d.trace_detail_id = lb.trace_detail_id
  join oio_trace l
    on l.trace_id = d.trace_id
 order by lb.creation_date;




