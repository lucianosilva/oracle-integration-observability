prompt ============================================================
prompt Oracle Integration Observability (OIO) - Support Views
prompt ============================================================
prompt Execute as the application schema owner, for example OIO_OWNER.
prompt ============================================================

set define off

CREATE OR REPLACE FORCE EDITIONABLE VIEW OIO_V_TRACE_PAYLOAD AS 
select
    p.trace_lob_id,
    p.trace_detail_id,
    e.trace_id,
    t.integration_key,
    t.transaction_id1,
    t.log_ref_id,
    e.event_type,
    e.step_name,
    e.transaction_status,
    e.oic_instance_id,
    p.request,
    p.response,
    p.creation_date as payload_creation_date
from oio_trace_payload p
join oio_trace_event e
  on e.trace_detail_id = p.trace_detail_id
join oio_trace t
  on t.trace_id = e.trace_id
;





