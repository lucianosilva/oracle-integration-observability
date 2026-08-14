prompt ======================================================================
prompt Oracle Integration Observability (OIO) - Recent Payload Demo Seed
prompt ======================================================================
prompt Purpose:
prompt   Insert 10 payload records for the most recent eligible trace events
prompt   already loaded in OIO_TRACE / OIO_TRACE_EVENT.
prompt
prompt Behavior:
prompt   - Uses the 10 most recent final events (COMPLETED or ERROR)
prompt   - Skips events that already have a payload
prompt   - Inserts a mix of JSON, XML, plain text, request-only and response-only
prompt   - Does not modify OIO_TRACE or OIO_TRACE_EVENT
prompt   - Intended for NON-PRODUCTION / APEX testing only
prompt ======================================================================

set define off
set verify off
set feedback on
set timing on
set serveroutput on

whenever sqlerror exit failure rollback

prompt ======================================================================
prompt 1. Preview the 10 events that will receive payloads
prompt ======================================================================

with candidates as (
    select
        e.trace_detail_id,
        e.trace_id,
        t.integration_key,
        t.transaction_id1,
        t.log_ref_id,
        e.oic_instance_id,
        e.event_type,
        e.transaction_status,
        e.creation_date,
        row_number() over (
            order by e.creation_date desc,
                     e.trace_detail_id desc
        ) as rn
    from oio_trace_event e
    join oio_trace t
      on t.trace_id = e.trace_id
    where e.event_type in ('COMPLETED', 'ERROR')
      and e.step_name = 'TARGET_PROCESSING'
      and not exists (
            select 1
            from oio_trace_payload p
            where p.trace_detail_id = e.trace_detail_id
      )
)
select
    rn,
    trace_detail_id,
    trace_id,
    integration_key,
    transaction_id1,
    event_type,
    transaction_status,
    creation_date
from candidates
where rn <= 10
order by rn;

prompt ======================================================================
prompt 2. Insert 10 recent payload records
prompt ======================================================================

insert into oio_trace_payload (
    trace_detail_id,
    request,
    response,
    creation_date
)
with candidates as (
    select
        e.trace_detail_id,
        e.trace_id,
        t.integration_key,
        t.transaction_id1,
        t.log_ref_id,
        e.oic_instance_id,
        e.event_type,
        e.transaction_status,
        e.error_code,
        e.error_message,
        e.creation_date,
        row_number() over (
            order by e.creation_date desc,
                     e.trace_detail_id desc
        ) as rn
    from oio_trace_event e
    join oio_trace t
      on t.trace_id = e.trace_id
    where e.event_type in ('COMPLETED', 'ERROR')
      and e.step_name = 'TARGET_PROCESSING'
      and not exists (
            select 1
            from oio_trace_payload p
            where p.trace_detail_id = e.trace_detail_id
      )
),
selected as (
    select *
    from candidates
    where rn <= 10
)
select
    trace_detail_id,

    case rn
        when 1 then
            to_clob('{"integrationKey":"')
            || integration_key
            || '","transactionId":"'
            || transaction_id1
            || '","correlationId":"'
            || log_ref_id
            || '","oicInstanceId":"'
            || oic_instance_id
            || '","operation":"CREATE","amount":1250.75,"currency":"BRL"}'

        when 2 then
            to_clob('{"integrationKey":"')
            || integration_key
            || '","transactionId":"'
            || transaction_id1
            || '","customer":{"account":"CUST-10027","country":"BR"},'
            || '"source":"CRM","target":"ORACLE_FUSION_ERP"}'

        when 3 then
            to_clob('{"integrationKey":"')
            || integration_key
            || '","transactionId":"'
            || transaction_id1
            || '","supplier":{"number":"SUP-2088","site":"BR_SP"},'
            || '"businessUnit":"Brazil BU"}'

        when 4 then
            to_clob('{"integrationKey":"')
            || integration_key
            || '","transactionId":"'
            || transaction_id1
            || '","items":[{"item":"ITEM-1001","quantity":10},'
            || '{"item":"ITEM-1002","quantity":5}],'
            || '"warehouse":"BR-SP-01"}'

        when 5 then
            to_clob(
                '<request>'
                || '<integrationKey>' || integration_key || '</integrationKey>'
                || '<transactionId>' || transaction_id1 || '</transactionId>'
                || '<correlationId>' || log_ref_id || '</correlationId>'
                || '<documentType>PurchaseOrder</documentType>'
                || '<documentNumber>PO-TEST-1005</documentNumber>'
                || '</request>'
            )

        when 6 then
            to_clob(
                '<InvoiceRequest>'
                || '<IntegrationKey>' || integration_key || '</IntegrationKey>'
                || '<TransactionId>' || transaction_id1 || '</TransactionId>'
                || '<BusinessUnit>Brazil BU</BusinessUnit>'
                || '<InvoiceNumber>INV-TEST-1006</InvoiceNumber>'
                || '<Currency>USD</Currency>'
                || '</InvoiceRequest>'
            )

        when 7 then
            to_clob(
                '<InventoryTransaction>'
                || '<IntegrationKey>' || integration_key || '</IntegrationKey>'
                || '<TransactionId>' || transaction_id1 || '</TransactionId>'
                || '<Organization>BR01</Organization>'
                || '<Item>ITEM-7001</Item>'
                || '<Quantity>25</Quantity>'
                || '</InventoryTransaction>'
            )

        when 8 then
            to_clob(
                'Integration=' || integration_key
                || chr(10)
                || 'Transaction=' || transaction_id1
                || chr(10)
                || 'CorrelationId=' || log_ref_id
                || chr(10)
                || 'Message=Sample plain-text request payload for APEX validation.'
            )

        when 9 then
            to_clob('{"integrationKey":"')
            || integration_key
            || '","transactionId":"'
            || transaction_id1
            || '","mode":"REQUEST_ONLY","note":"No response payload persisted."}'

        when 10 then
            null
    end as request,

    case rn
        when 1 then
            to_clob('{"status":"SUCCESS","transactionId":"')
            || transaction_id1
            || '","message":"Transaction processed successfully."}'

        when 2 then
            to_clob('{"status":"')
            || case when event_type = 'ERROR' then 'ERROR' else 'SUCCESS' end
            || '","transactionId":"'
            || transaction_id1
            || '","errorCode":"'
            || nvl(error_code, 'NONE')
            || '","message":"'
            || replace(
                   nvl(error_message, 'Transaction processed successfully.'),
                   '"',
                   '\"'
               )
            || '"}'

        when 3 then
            to_clob(
                '{"status":"SUCCESS","supplierNumber":"SUP-2088","transactionId":"'
            )
            || transaction_id1
            || '"}'

        when 4 then
            to_clob(
                '{"status":"SUCCESS","processedItems":2,"transactionId":"'
            )
            || transaction_id1
            || '"}'

        when 5 then
            to_clob(
                '<response>'
                || '<status>SUCCESS</status>'
                || '<transactionId>' || transaction_id1 || '</transactionId>'
                || '<message>Purchase order processed successfully.</message>'
                || '</response>'
            )

        when 6 then
            to_clob(
                '<InvoiceResponse>'
                || '<Status>'
                || case when event_type = 'ERROR' then 'ERROR' else 'SUCCESS' end
                || '</Status>'
                || '<TransactionId>' || transaction_id1 || '</TransactionId>'
                || '<ErrorCode>' || nvl(error_code, 'NONE') || '</ErrorCode>'
                || '</InvoiceResponse>'
            )

        when 7 then
            to_clob(
                '<InventoryResponse>'
                || '<Status>SUCCESS</Status>'
                || '<TransactionId>' || transaction_id1 || '</TransactionId>'
                || '<ProcessedQuantity>25</ProcessedQuantity>'
                || '</InventoryResponse>'
            )

        when 8 then
            to_clob(
                'STATUS='
                || case when event_type = 'ERROR' then 'ERROR' else 'SUCCESS' end
                || chr(10)
                || 'TRANSACTION=' || transaction_id1
                || chr(10)
                || 'ERROR_CODE=' || nvl(error_code, 'NONE')
                || chr(10)
                || 'MESSAGE='
                || nvl(error_message, 'Transaction processed successfully.')
            )

        when 9 then
            null

        when 10 then
            to_clob('{"status":"SUCCESS","transactionId":"')
            || transaction_id1
            || '","mode":"RESPONSE_ONLY","note":"No request payload persisted."}'
    end as response,

    creation_date
from selected;

commit;

prompt ======================================================================
prompt 3. Validation
prompt ======================================================================

select
    p.trace_lob_id,
    p.trace_detail_id,
    t.trace_id,
    t.integration_key,
    t.transaction_id1,
    e.event_type,
    e.transaction_status,
    e.creation_date as event_timestamp,
    case when p.request is not null then 'Y' else 'N' end as has_request,
    case when p.response is not null then 'Y' else 'N' end as has_response
from oio_trace_payload p
join oio_trace_event e
  on e.trace_detail_id = p.trace_detail_id
join oio_trace t
  on t.trace_id = e.trace_id
order by p.creation_date desc,
         p.trace_lob_id desc
fetch first 10 rows only;

prompt ======================================================================
prompt Recent payload demo seed completed.
prompt ======================================================================
