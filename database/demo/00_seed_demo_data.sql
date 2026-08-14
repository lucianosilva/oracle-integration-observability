prompt ======================================================================
prompt Oracle Integration Observability (OIO) - High Volume Demo Data Seed
prompt ======================================================================
prompt Purpose:
prompt   Generate a realistic, deterministic dataset for APEX/dashboard testing.
prompt
prompt Scope:
prompt   - 20 integration configurations
prompt   - 100,000 OIO_TRACE rows per month
prompt   - January 2026 through August 7, 2026
prompt   - 800,000 master transactions in total
prompt   - ~1.84M event-history rows
prompt   - Payloads only for a controlled subset of events
prompt
prompt IMPORTANT:
prompt   - Intended for NON-PRODUCTION environments only.
prompt   - The script is optimized for bulk loading using set-based INSERT SELECT.
prompt   - It does not call OIO_TRACE_API row by row because the goal is test-data
prompt     generation, not API functional validation.
prompt   - Re-running the script is blocked when SEED26 data already exists.
prompt ======================================================================

set define on
set verify off
set feedback on
set timing on
set serveroutput on
set sqlblanklines on

whenever sqlerror exit failure rollback

define ROWS_PER_MONTH = 100000

alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';
alter session set nls_timestamp_format = 'YYYY-MM-DD HH24:MI:SS.FF6';

prompt ======================================================================
prompt 0. Safety check
prompt ======================================================================

declare
    l_count number;
begin
    select count(*)
      into l_count
      from oio_trace
     where log_ref_id like 'SEED26-%';

    if l_count > 0 then
        raise_application_error(
            -20999,
            'SEED26 demo data already exists (' || l_count ||
            ' rows). Remove it before running this script again.'
        );
    end if;
end;
/

prompt ======================================================================
prompt 1. Seed 20 integration configurations
prompt ======================================================================

merge into oio_integration_cfg c
using (
    select 'AP_INVOICE_IMPORT' integration_key,
           'Import supplier invoices into Oracle Fusion Payables' description,
           'SCHEDULED' integration_type,
           'EXTERNAL_AP' source_system,
           'ORACLE_FUSION_ERP' target_system,
           'Supplier Invoice Import' process_name,
           'AP' scope_name,
           'Invoice Number' transaction_id1_name,
           'Supplier Number' transaction_id2_name,
           'Load Request ID' transaction_id3_name,
           'Invoice Number' attr1_name,
           'Business Unit' attr2_name,
           'Supplier Number' attr3_name,
           'Amount' attr4_name,
           'Currency' attr5_name
      from dual
    union all
    select 'AP_PAYMENT_STATUS','Synchronize supplier payment status','EVENT_DRIVEN',
           'ORACLE_FUSION_ERP','BANK_PLATFORM','Supplier Payment Status','AP',
           'Payment Number','Supplier Number','Payment Process Request',
           'Payment Number','Business Unit','Supplier Number','Amount','Currency'
      from dual
    union all
    select 'AR_INVOICE_IMPORT','Import customer invoices into Oracle Fusion Receivables','SCHEDULED',
           'BILLING_PLATFORM','ORACLE_FUSION_ERP','Customer Invoice Import','AR',
           'Transaction Number','Customer Account','Load Request ID',
           'Transaction Number','Business Unit','Customer Account','Amount','Currency'
      from dual
    union all
    select 'AR_RECEIPT_SYNC','Synchronize customer receipts from banking platform','EVENT_DRIVEN',
           'BANK_PLATFORM','ORACLE_FUSION_ERP','Customer Receipt Synchronization','AR',
           'Receipt Number','Customer Account','Bank Reference',
           'Receipt Number','Business Unit','Customer Account','Amount','Currency'
      from dual
    union all
    select 'PO_CREATE_ORDER','Create purchase orders from procurement requests','APP_DRIVEN',
           'PROCUREMENT_PORTAL','ORACLE_FUSION_ERP','Purchase Order Creation','PO',
           'Purchase Order','Supplier Number','Requisition Number',
           'Purchase Order','Business Unit','Supplier Number','Amount','Currency'
      from dual
    union all
    select 'PO_ORDER_CHANGE','Publish purchase-order changes to supplier network','EVENT_DRIVEN',
           'ORACLE_FUSION_ERP','SUPPLIER_NETWORK','Purchase Order Change','PO',
           'Purchase Order','Supplier Number','Change Order Number',
           'Purchase Order','Business Unit','Supplier Number','Amount','Currency'
      from dual
    union all
    select 'SCM_SHIPMENT_SYNC','Synchronize shipment updates between WMS and Fusion SCM','EVENT_DRIVEN',
           'WMS','ORACLE_FUSION_SCM','Shipment Synchronization','SCM',
           'Shipment Number','Order Number','Delivery Number',
           'Shipment Number','Organization','Order Number','Quantity','UOM'
      from dual
    union all
    select 'SCM_ORDER_ORCHESTRATION','Synchronize sales-order orchestration events','EVENT_DRIVEN',
           'CRM','ORACLE_FUSION_SCM','Order Orchestration','SCM',
           'Order Number','Customer Account','Fulfillment Line',
           'Order Number','Business Unit','Customer Account','Amount','Currency'
      from dual
    union all
    select 'CUSTOMER_MASTER_SYNC','Synchronize customer master records from CRM','EVENT_DRIVEN',
           'CRM','ORACLE_FUSION_ERP','Customer Master Synchronization','CUSTOMERS',
           'Customer Account','Party Number','Source Reference',
           'Customer Account','Business Unit','Party Number','Country','Customer Type'
      from dual
    union all
    select 'CUSTOMER_ACCOUNT_UPDATE','Publish Fusion customer-account updates to CRM','EVENT_DRIVEN',
           'ORACLE_FUSION_ERP','CRM','Customer Account Update','CUSTOMERS',
           'Customer Account','Party Number','Account Site',
           'Customer Account','Business Unit','Party Number','Country','Customer Type'
      from dual
    union all
    select 'SUPPLIER_MASTER_SYNC','Synchronize supplier master records','EVENT_DRIVEN',
           'SUPPLIER_PORTAL','ORACLE_FUSION_ERP','Supplier Master Synchronization','SUPPLIERS',
           'Supplier Number','Tax Registration','Source Reference',
           'Supplier Number','Procurement BU','Tax Registration','Country','Supplier Type'
      from dual
    union all
    select 'SUPPLIER_SITE_UPDATE','Publish supplier-site updates','EVENT_DRIVEN',
           'ORACLE_FUSION_ERP','SUPPLIER_PORTAL','Supplier Site Update','SUPPLIERS',
           'Supplier Number','Supplier Site','Address Name',
           'Supplier Number','Procurement BU','Supplier Site','Country','Site Purpose'
      from dual
    union all
    select 'GL_JOURNAL_IMPORT','Import journals into Oracle Fusion General Ledger','SCHEDULED',
           'LEGACY_GL','ORACLE_FUSION_ERP','Journal Import','GL',
           'Journal Batch','Journal Name','Load Request ID',
           'Journal Batch','Ledger','Journal Name','Amount','Currency'
      from dual
    union all
    select 'GL_BALANCE_EXPORT','Export Fusion GL balances to the enterprise data platform','SCHEDULED',
           'ORACLE_FUSION_ERP','DATA_LAKE','Balance Export','GL',
           'Ledger Period','Ledger','Extract Request',
           'Ledger Period','Ledger','Account','Amount','Currency'
      from dual
    union all
    select 'INVENTORY_TXN_IMPORT','Import material transactions from WMS','SCHEDULED',
           'WMS','ORACLE_FUSION_SCM','Inventory Transaction Import','INVENTORY',
           'Transaction Reference','Organization','Item Number',
           'Transaction Reference','Organization','Item Number','Quantity','UOM'
      from dual
    union all
    select 'INVENTORY_ONHAND_SYNC','Publish Fusion on-hand balances to WMS','SCHEDULED',
           'ORACLE_FUSION_SCM','WMS','Inventory On-Hand Synchronization','INVENTORY',
           'Item Number','Organization','Subinventory',
           'Item Number','Organization','Subinventory','Quantity','UOM'
      from dual
    union all
    select 'PROC_REQUISITION_IMPORT','Import procurement requisitions','APP_DRIVEN',
           'PROCUREMENT_PORTAL','ORACLE_FUSION_ERP','Requisition Import','PROCUREMENT',
           'Requisition Number','Requester','Source Reference',
           'Requisition Number','Business Unit','Requester','Amount','Currency'
      from dual
    union all
    select 'PROC_AWARD_SYNC','Synchronize sourcing award results','EVENT_DRIVEN',
           'SOURCING_PLATFORM','ORACLE_FUSION_ERP','Sourcing Award Synchronization','PROCUREMENT',
           'Negotiation Number','Supplier Number','Award Reference',
           'Negotiation Number','Procurement BU','Supplier Number','Amount','Currency'
      from dual
    union all
    select 'PROJECT_COST_IMPORT','Import project costs from time and expense platform','SCHEDULED',
           'TIME_EXPENSE','ORACLE_FUSION_PPM','Project Cost Import','PROJECTS',
           'Project Number','Expenditure Item','Load Request ID',
           'Project Number','Business Unit','Expenditure Type','Amount','Currency'
      from dual
    union all
    select 'CASH_BANK_STMT_IMPORT','Import bank statements into Fusion Cash Management','SCHEDULED',
           'BANK_PLATFORM','ORACLE_FUSION_ERP','Bank Statement Import','CASH_MANAGEMENT',
           'Statement Number','Bank Account','Load Request ID',
           'Statement Number','Business Unit','Bank Account','Amount','Currency'
      from dual
) s
on (c.integration_key = s.integration_key)
when matched then update set
    c.description          = s.description,
    c.active_flag          = 'Y',
    c.integration_type     = s.integration_type,
    c.source_system        = s.source_system,
    c.target_system        = s.target_system,
    c.process_name         = s.process_name,
    c.scope_name           = s.scope_name,
    c.transaction_id1_name = s.transaction_id1_name,
    c.transaction_id2_name = s.transaction_id2_name,
    c.transaction_id3_name = s.transaction_id3_name,
    c.attr1_name           = s.attr1_name,
    c.attr2_name           = s.attr2_name,
    c.attr3_name           = s.attr3_name,
    c.attr4_name           = s.attr4_name,
    c.attr5_name           = s.attr5_name,
    c.last_update_date     = systimestamp
when not matched then insert (
    integration_key, description, active_flag, integration_type,
    source_system, target_system, process_name, scope_name,
    transaction_id1_name, transaction_id2_name, transaction_id3_name,
    attr1_name, attr2_name, attr3_name, attr4_name, attr5_name,
    creation_date
) values (
    s.integration_key, s.description, 'Y', s.integration_type,
    s.source_system, s.target_system, s.process_name, s.scope_name,
    s.transaction_id1_name, s.transaction_id2_name, s.transaction_id3_name,
    s.attr1_name, s.attr2_name, s.attr3_name, s.attr4_name, s.attr5_name,
    timestamp '2026-01-01 00:00:00'
);

commit;

prompt ======================================================================
prompt 2. Bulk load OIO_TRACE - 100,000 transactions per month
prompt ======================================================================

insert /*+ append */ into oio_trace (
    integration_key, log_ref_id, oic_instance_id, user_name, log_level,
    summary, error_code, error_message,
    attr1_value, attr2_value, attr3_value, attr4_value, attr5_value,
    attr6_value, attr7_value, attr8_value, attr9_value, attr10_value,
    transaction_id1, transaction_id2, transaction_id3,
    creation_date, last_update_date
)
with
months (month_no, month_start, month_end) as (
    select 1, date '2026-01-01', date '2026-02-01' from dual union all
    select 2, date '2026-02-01', date '2026-03-01' from dual union all
    select 3, date '2026-03-01', date '2026-04-01' from dual union all
    select 4, date '2026-04-01', date '2026-05-01' from dual union all
    select 5, date '2026-05-01', date '2026-06-01' from dual union all
    select 6, date '2026-06-01', date '2026-07-01' from dual union all
    select 7, date '2026-07-01', date '2026-08-01' from dual union all
    select 8, date '2026-08-01', date '2026-08-08' from dual
),
integration_seed (integration_id, integration_key, txn_prefix, error_pct) as (
    select  1, 'AP_INVOICE_IMPORT',        'API',  9 from dual union all
    select  2, 'AP_PAYMENT_STATUS',        'PAY',  7 from dual union all
    select  3, 'AR_INVOICE_IMPORT',        'ARI', 10 from dual union all
    select  4, 'AR_RECEIPT_SYNC',          'RCT',  6 from dual union all
    select  5, 'PO_CREATE_ORDER',          'PO',   8 from dual union all
    select  6, 'PO_ORDER_CHANGE',          'POC',  7 from dual union all
    select  7, 'SCM_SHIPMENT_SYNC',        'SHP', 13 from dual union all
    select  8, 'SCM_ORDER_ORCHESTRATION',  'ORD', 11 from dual union all
    select  9, 'CUSTOMER_MASTER_SYNC',     'CUS',  5 from dual union all
    select 10, 'CUSTOMER_ACCOUNT_UPDATE',  'CUA',  6 from dual union all
    select 11, 'SUPPLIER_MASTER_SYNC',     'SUP',  8 from dual union all
    select 12, 'SUPPLIER_SITE_UPDATE',     'SPS',  7 from dual union all
    select 13, 'GL_JOURNAL_IMPORT',        'JRN', 12 from dual union all
    select 14, 'GL_BALANCE_EXPORT',        'BAL',  4 from dual union all
    select 15, 'INVENTORY_TXN_IMPORT',     'INV', 14 from dual union all
    select 16, 'INVENTORY_ONHAND_SYNC',    'ONH',  8 from dual union all
    select 17, 'PROC_REQUISITION_IMPORT',  'REQ',  9 from dual union all
    select 18, 'PROC_AWARD_SYNC',          'AWD',  6 from dual union all
    select 19, 'PROJECT_COST_IMPORT',       'PJC', 10 from dual union all
    select 20, 'CASH_BANK_STMT_IMPORT',    'BST', 11 from dual
),
nums as (
    select level n from dual connect by level <= &&ROWS_PER_MONTH
),
base as (
    select
        m.month_no, m.month_start, m.month_end, n.n,
        mod(n.n - 1, 20) + 1 as integration_id,
        trunc((m.month_end - m.month_start) * 86400) as period_seconds
    from months m
    cross join nums n
),
generated as (
    select
        b.month_no, b.month_start, b.n, b.integration_id,
        i.integration_key, i.txn_prefix, i.error_pct,
        cast(b.month_start as timestamp)
            + numtodsinterval(
                mod((b.n - 1) * 7919 + b.month_no * 101,
                    b.period_seconds - 7200),
                'SECOND'
              ) as creation_ts,
        case
            when mod(
                     ora_hash(
                         to_char(b.month_no)
                         || ':'
                         || to_char(b.integration_id)
                         || ':'
                         || to_char(b.n)
                     ),
                     100
                 ) < i.error_pct
            then 'E'
            else 'I'
        end as final_level
    from base b
    join integration_seed i
      on i.integration_id = b.integration_id
)
select
    g.integration_key,
    'SEED26-' || to_char(g.month_start, 'YYYYMM') || '-' || lpad(g.n, 6, '0'),
    'OIC-' || to_char(g.month_start, 'YYYYMM') || '-' || lpad(g.n, 8, '0'),
    'OIO_SEED_GENERATOR',
    g.final_level,
    case g.final_level
        when 'E' then 'Integration transaction completed with an error.'
        else 'Integration transaction completed successfully.'
    end,
    case
        when g.final_level = 'I' then null
        when mod(g.n, 4) = 0 then 'HTTP-500'
        when mod(g.n, 4) = 1 then 'FUSION-VALIDATION-001'
        when mod(g.n, 4) = 2 then 'TIMEOUT-001'
        else 'BUSINESS-VALIDATION-001'
    end,
    case
        when g.final_level = 'I' then null
        when mod(g.n, 4) = 0 then 'Target service returned an internal server error.'
        when mod(g.n, 4) = 1 then 'Oracle Fusion rejected the transaction during validation.'
        when mod(g.n, 4) = 2 then 'Target operation exceeded the configured timeout.'
        else 'Business validation failed for the submitted transaction.'
    end,
    g.txn_prefix || '-' || to_char(g.month_start, 'YYYYMM') || '-' || lpad(g.n, 6, '0'),
    case mod(g.n, 5)
        when 0 then 'Brazil BU'
        when 1 then 'US BU'
        when 2 then 'Mexico BU'
        when 3 then 'EMEA BU'
        else 'Global BU'
    end,
    'SRC-' || lpad(mod(g.n * 17, 1000000), 6, '0'),
    to_char(100 + mod(g.n * 7919, 5000000) / 100,
            'FM99999990D00',
            'NLS_NUMERIC_CHARACTERS=''.,'''),
    case mod(g.n, 4)
        when 0 then 'BRL'
        when 1 then 'USD'
        when 2 then 'MXN'
        else 'EUR'
    end,
    case mod(g.n, 4)
        when 0 then 'BR'
        when 1 then 'US'
        when 2 then 'MX'
        else 'DE'
    end,
    case mod(g.n, 3)
        when 0 then 'HIGH'
        when 1 then 'NORMAL'
        else 'LOW'
    end,
    null, null, null,
    g.txn_prefix || '-' || to_char(g.month_start, 'YYYYMM') || '-' || lpad(g.n, 6, '0'),
    'BATCH-' || to_char(g.month_start, 'YYYYMM') || '-' || lpad(ceil(g.n / 500), 4, '0'),
    'REQ-' || to_char(g.month_start, 'YYYYMM') || '-' || lpad(mod(g.n * 97, 999999), 6, '0'),
    g.creation_ts,
    g.creation_ts + numtodsinterval(300 + mod(g.n * 17, 3300), 'SECOND')
from generated g;

commit;

prompt ======================================================================
prompt 3. Bulk load initial RECEIVED event - one per transaction
prompt ======================================================================

insert /*+ append */ into oio_trace_event (
    trace_id, event_type, step_name, oic_instance_id, user_name, log_level,
    summary, error_code, error_message, transaction_status,
    creation_date, last_update_date
)
select
    t.trace_id, 'CREATED', 'RECEIVE', t.oic_instance_id, t.user_name, 'I',
    'Transaction received for integration processing.',
    null, null, 'RECEIVED', t.creation_date, t.creation_date
from oio_trace t
where t.log_ref_id like 'SEED26-%';

commit;

prompt ======================================================================
prompt 4. Bulk load IN_PROGRESS event for ~30 percent of transactions
prompt ======================================================================

insert /*+ append */ into oio_trace_event (
    trace_id, event_type, step_name, oic_instance_id, user_name, log_level,
    summary, error_code, error_message, transaction_status,
    creation_date, last_update_date
)
select
    t.trace_id, 'STATUS_UPDATE', 'PROCESSING', t.oic_instance_id, t.user_name, 'I',
    'Transaction is being processed.',
    null, null, 'IN_PROGRESS',
    t.creation_date + numtodsinterval(30 + mod(t.trace_id, 240), 'SECOND'),
    t.creation_date + numtodsinterval(30 + mod(t.trace_id, 240), 'SECOND')
from oio_trace t
where t.log_ref_id like 'SEED26-%'
  and mod(t.trace_id, 10) < 3;

commit;

prompt ======================================================================
prompt 5. Bulk load final event - one per transaction
prompt ======================================================================

insert /*+ append */ into oio_trace_event (
    trace_id, event_type, step_name, oic_instance_id, user_name, log_level,
    summary, error_code, error_message, transaction_status,
    creation_date, last_update_date
)
select
    t.trace_id,
    case when t.log_level = 'E' then 'ERROR' else 'COMPLETED' end,
    'TARGET_PROCESSING',
    t.oic_instance_id,
    t.user_name,
    t.log_level,
    t.summary,
    t.error_code,
    t.error_message,
    case when t.log_level = 'E' then 'FAILED' else 'COMPLETED' end,
    t.last_update_date,
    t.last_update_date
from oio_trace t
where t.log_ref_id like 'SEED26-%';

commit;

prompt ======================================================================
prompt 6. Bulk load optional payloads
prompt ======================================================================

insert /*+ append */ into oio_trace_payload (
    trace_detail_id, request, response, creation_date
)
select
    e.trace_detail_id,
    to_clob('{"seedData":true,"integrationKey":"')
      || t.integration_key
      || '","transactionId":"'
      || t.transaction_id1
      || '","correlationId":"'
      || t.log_ref_id
      || '","businessUnit":"'
      || t.attr2_value
      || '"}',
    case
        when t.log_level = 'E' then
            to_clob('{"status":"ERROR","errorCode":"')
              || t.error_code
              || '","message":"'
              || replace(t.error_message, '"', '\"')
              || '"}'
        else
            to_clob('{"status":"SUCCESS","transactionId":"')
              || t.transaction_id1
              || '"}'
    end,
    e.creation_date
from oio_trace t
join oio_trace_event e
  on e.trace_id = t.trace_id
 and e.creation_date = t.last_update_date
 and e.event_type in ('ERROR', 'COMPLETED')
where t.log_ref_id like 'SEED26-%'
  and (
        (t.log_level = 'E' and mod(t.trace_id, 4) = 0)
        or
        (t.log_level = 'I' and mod(t.trace_id, 50) = 0)
      );

commit;

prompt ======================================================================
prompt 7. Gather optimizer statistics
prompt ======================================================================

begin
    dbms_stats.gather_table_stats(
        ownname => user, tabname => 'OIO_INTEGRATION_CFG',
        estimate_percent => dbms_stats.auto_sample_size,
        cascade => true, degree => 4
    );
    dbms_stats.gather_table_stats(
        ownname => user, tabname => 'OIO_TRACE',
        estimate_percent => dbms_stats.auto_sample_size,
        cascade => true, degree => 4, granularity => 'AUTO'
    );
    dbms_stats.gather_table_stats(
        ownname => user, tabname => 'OIO_TRACE_EVENT',
        estimate_percent => dbms_stats.auto_sample_size,
        cascade => true, degree => 4, granularity => 'AUTO'
    );
    dbms_stats.gather_table_stats(
        ownname => user, tabname => 'OIO_TRACE_PAYLOAD',
        estimate_percent => dbms_stats.auto_sample_size,
        cascade => true, degree => 4, granularity => 'AUTO'
    );
end;
/

prompt ======================================================================
prompt 8. Validation summary
prompt ======================================================================

prompt Transactions per month - expected 100000 for every month
select
    to_char(creation_date, 'YYYY-MM') as month_key,
    count(*) as trace_count,
    sum(case when log_level = 'E' then 1 else 0 end) as error_count,
    round(100 * sum(case when log_level = 'E' then 1 else 0 end) / count(*), 2) as error_pct
from oio_trace
where log_ref_id like 'SEED26-%'
group by to_char(creation_date, 'YYYY-MM')
order by month_key;

prompt Distribution by integration
select
    integration_key,
    count(*) as trace_count,
    sum(case when log_level = 'E' then 1 else 0 end) as error_count,
    round(100 * sum(case when log_level = 'E' then 1 else 0 end) / count(*), 2) as error_pct
from oio_trace
where log_ref_id like 'SEED26-%'
group by integration_key
order by integration_key;

prompt Event distribution
select
    e.event_type,
    e.transaction_status,
    count(*) as event_count
from oio_trace_event e
join oio_trace t on t.trace_id = e.trace_id
where t.log_ref_id like 'SEED26-%'
group by e.event_type, e.transaction_status
order by e.event_type, e.transaction_status;

prompt Payload count
select count(*) as payload_count
from oio_trace_payload p
join oio_trace_event e on e.trace_detail_id = p.trace_detail_id
join oio_trace t on t.trace_id = e.trace_id
where t.log_ref_id like 'SEED26-%';

prompt Total row counts
select 'OIO_TRACE' object_name, count(*) row_count
from oio_trace
where log_ref_id like 'SEED26-%'
union all
select 'OIO_TRACE_EVENT', count(*)
from oio_trace_event e
join oio_trace t on t.trace_id = e.trace_id
where t.log_ref_id like 'SEED26-%'
union all
select 'OIO_TRACE_PAYLOAD', count(*)
from oio_trace_payload p
join oio_trace_event e on e.trace_detail_id = p.trace_detail_id
join oio_trace t on t.trace_id = e.trace_id
where t.log_ref_id like 'SEED26-%';

prompt ======================================================================
prompt Seed completed successfully.
prompt ======================================================================
prompt Expected:
prompt   OIO_TRACE         = 800,000 rows
prompt   OIO_TRACE_EVENT   = approximately 1,840,000 rows
prompt   OIO_TRACE_PAYLOAD = controlled subset for payload-viewer testing
prompt ======================================================================
