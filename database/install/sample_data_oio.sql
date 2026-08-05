prompt ============================================================
prompt Oracle Integration Observability (OIO) - Sample Data
prompt ============================================================
prompt Compatible with the revised V2 model:
prompt - oio_trace stores master transaction metadata only.
prompt - oio_trace_event stores transaction status history.
prompt - oio_trace_payload stores optional request/response CLOBs by detail event.
prompt ============================================================

set define off
set serveroutput on

prompt Cleaning previous sample data...

delete from oio_trace_payload
 where trace_detail_id in (
       select d.trace_detail_id
         from oio_trace_event d
         join oio_trace l
           on l.trace_id = d.trace_id
        where l.integration_key in (
              'FIN_AP_PAYMENT_FLOW',
              'SCM_PO_SYNC',
              'FIN_AR_SYSTEM_A',
              'FIN_AR_SYSTEM_B'
        )
 );

delete from oio_trace_event
 where trace_id in (
       select trace_id
         from oio_trace
        where integration_key in (
              'FIN_AP_PAYMENT_FLOW',
              'SCM_PO_SYNC',
              'FIN_AR_SYSTEM_A',
              'FIN_AR_SYSTEM_B'
        )
 );

delete from oio_trace
 where integration_key in (
       'FIN_AP_PAYMENT_FLOW',
       'SCM_PO_SYNC',
       'FIN_AR_SYSTEM_A',
       'FIN_AR_SYSTEM_B'
 );

prompt Creating sample oio_integration_cfg rows...

merge into oio_integration_cfg t
using (
    select 'FIN_AP_PAYMENT_FLOW' integration_key,
           'Financial Payables invoice payment traceability flow' description,
           'Y' active_flag,
           'ASYNC' integration_type,
           'Payables' source_system,
           'ERP Financials' target_system,
           'Accounts Payable' process_name,
           'FIN' scope_name,
           'AP Invoice Number' transaction_id1_name,
           'Payment Document Number' transaction_id2_name,
           'Payment Batch ID' transaction_id3_name,
           'Invoice Number' attr1_name,
           'Supplier Number' attr2_name,
           'Business Unit' attr3_name,
           'Currency' attr4_name,
           'Amount' attr5_name,
           'Payment Method' attr6_name,
           'Due Date' attr7_name,
           'Batch ID' attr8_name,
           'Ledger' attr9_name,
           'Source Event' attr10_name
      from dual
) s
on (t.integration_key = s.integration_key)
when not matched then
    insert (
        integration_key, description, active_flag, integration_type,
        source_system, target_system, process_name, scope_name,
        transaction_id1_name, transaction_id2_name, transaction_id3_name,
        attr1_name, attr2_name, attr3_name, attr4_name, attr5_name,
        attr6_name, attr7_name, attr8_name, attr9_name, attr10_name,
        creation_date, last_update_date
    )
    values (
        s.integration_key, s.description, s.active_flag, s.integration_type,
        s.source_system, s.target_system, s.process_name, s.scope_name,
        s.transaction_id1_name, s.transaction_id2_name, s.transaction_id3_name,
        s.attr1_name, s.attr2_name, s.attr3_name, s.attr4_name, s.attr5_name,
        s.attr6_name, s.attr7_name, s.attr8_name, s.attr9_name, s.attr10_name,
        systimestamp, systimestamp
    );

merge into oio_integration_cfg t
using (
    select 'SCM_PO_SYNC' integration_key,
           'SCM purchase order synchronization traceability flow' description,
           'Y' active_flag,
           'ASYNC' integration_type,
           'Procurement' source_system,
           'Supplier Portal' target_system,
           'Purchase Order' process_name,
           'SCM' scope_name,
           'Purchase Order Number' transaction_id1_name,
           'Supplier Acknowledgement Number' transaction_id2_name,
           'PO Batch ID' transaction_id3_name,
           'Purchase Order Number' attr1_name,
           'Supplier Number' attr2_name,
           'Buyer' attr3_name,
           'Business Unit' attr4_name,
           'Currency' attr5_name,
           'Amount' attr6_name,
           'Inventory Organization' attr7_name,
           'Approval Group' attr8_name,
           'Source Event' attr9_name,
           'Batch ID' attr10_name
      from dual
) s
on (t.integration_key = s.integration_key)
when not matched then
    insert (
        integration_key, description, active_flag, integration_type,
        source_system, target_system, process_name, scope_name,
        transaction_id1_name, transaction_id2_name, transaction_id3_name,
        attr1_name, attr2_name, attr3_name, attr4_name, attr5_name,
        attr6_name, attr7_name, attr8_name, attr9_name, attr10_name,
        creation_date, last_update_date
    )
    values (
        s.integration_key, s.description, s.active_flag, s.integration_type,
        s.source_system, s.target_system, s.process_name, s.scope_name,
        s.transaction_id1_name, s.transaction_id2_name, s.transaction_id3_name,
        s.attr1_name, s.attr2_name, s.attr3_name, s.attr4_name, s.attr5_name,
        s.attr6_name, s.attr7_name, s.attr8_name, s.attr9_name, s.attr10_name,
        systimestamp, systimestamp
    );

merge into oio_integration_cfg t
using (
    select 'FIN_AR_SYSTEM_A' integration_key,
           'Receivables transaction delivery to System A' description,
           'Y' active_flag,
           'ASYNC' integration_type,
           'Receivables' source_system,
           'System A' target_system,
           'Receivables Transaction Delivery' process_name,
           'FIN' scope_name,
           'Receivables Transaction Number' transaction_id1_name,
           'System A Document ID' transaction_id2_name,
           'Receivables Transmission Batch ID' transaction_id3_name,
           'Transaction Number' attr1_name,
           'Customer Account' attr2_name,
           'Business Unit' attr3_name,
           'Currency' attr4_name,
           'Amount' attr5_name,
           'Ledger' attr6_name,
           'Receipt Method' attr7_name,
           'System Reference' attr8_name,
           'Batch ID' attr9_name,
           'Channel' attr10_name
      from dual
) s
on (t.integration_key = s.integration_key)
when not matched then
    insert (
        integration_key, description, active_flag, integration_type,
        source_system, target_system, process_name, scope_name,
        transaction_id1_name, transaction_id2_name, transaction_id3_name,
        attr1_name, attr2_name, attr3_name, attr4_name, attr5_name,
        attr6_name, attr7_name, attr8_name, attr9_name, attr10_name,
        creation_date, last_update_date
    )
    values (
        s.integration_key, s.description, s.active_flag, s.integration_type,
        s.source_system, s.target_system, s.process_name, s.scope_name,
        s.transaction_id1_name, s.transaction_id2_name, s.transaction_id3_name,
        s.attr1_name, s.attr2_name, s.attr3_name, s.attr4_name, s.attr5_name,
        s.attr6_name, s.attr7_name, s.attr8_name, s.attr9_name, s.attr10_name,
        systimestamp, systimestamp
    );

merge into oio_integration_cfg t
using (
    select 'FIN_AR_SYSTEM_B' integration_key,
           'Receivables transaction delivery to System B' description,
           'Y' active_flag,
           'ASYNC' integration_type,
           'Receivables' source_system,
           'System B' target_system,
           'Receivables Transaction Delivery' process_name,
           'FIN' scope_name,
           'Receivables Transaction Number' transaction_id1_name,
           'System B Document ID' transaction_id2_name,
           'Receivables Transmission Batch ID' transaction_id3_name,
           'Transaction Number' attr1_name,
           'Customer Account' attr2_name,
           'Business Unit' attr3_name,
           'Currency' attr4_name,
           'Amount' attr5_name,
           'Ledger' attr6_name,
           'Receipt Method' attr7_name,
           'System Reference' attr8_name,
           'Batch ID' attr9_name,
           'Channel' attr10_name
      from dual
) s
on (t.integration_key = s.integration_key)
when not matched then
    insert (
        integration_key, description, active_flag, integration_type,
        source_system, target_system, process_name, scope_name,
        transaction_id1_name, transaction_id2_name, transaction_id3_name,
        attr1_name, attr2_name, attr3_name, attr4_name, attr5_name,
        attr6_name, attr7_name, attr8_name, attr9_name, attr10_name,
        creation_date, last_update_date
    )
    values (
        s.integration_key, s.description, s.active_flag, s.integration_type,
        s.source_system, s.target_system, s.process_name, s.scope_name,
        s.transaction_id1_name, s.transaction_id2_name, s.transaction_id3_name,
        s.attr1_name, s.attr2_name, s.attr3_name, s.attr4_name, s.attr5_name,
        s.attr6_name, s.attr7_name, s.attr8_name, s.attr9_name, s.attr10_name,
        systimestamp, systimestamp
    );

prompt Creating sample master/detail/lob rows...

declare
    l_base       timestamp := systimestamp - interval '6' hour;
    l_trace_id   oio_trace.trace_id%type;
    l_detail_id  oio_trace_event.trace_detail_id%type;

    procedure add_master(
        p_integration_key in oio_trace.integration_key%type,
        p_log_ref_id      in oio_trace.log_ref_id%type,
        p_oic_instance_id in oio_trace.oic_instance_id%type,
        p_user_name       in oio_trace.user_name%type,
        p_log_level       in oio_trace.log_level%type,
        p_summary         in oio_trace.summary%type,
        p_error_code      in oio_trace.error_code%type,
        p_error_message   in oio_trace.error_message%type,
        p_attr1_value     in oio_trace.attr1_value%type,
        p_attr2_value     in oio_trace.attr2_value%type,
        p_attr3_value     in oio_trace.attr3_value%type,
        p_attr4_value     in oio_trace.attr4_value%type,
        p_attr5_value     in oio_trace.attr5_value%type,
        p_attr6_value     in oio_trace.attr6_value%type,
        p_attr7_value     in oio_trace.attr7_value%type,
        p_attr8_value     in oio_trace.attr8_value%type,
        p_attr9_value     in oio_trace.attr9_value%type,
        p_attr10_value    in oio_trace.attr10_value%type,
        p_transaction_id1 in oio_trace.transaction_id1%type,
        p_transaction_id2 in oio_trace.transaction_id2%type,
        p_transaction_id3 in oio_trace.transaction_id3%type,
        p_offset_minutes  in number,
        p_trace_id        out oio_trace.trace_id%type
    ) is
        l_event_ts timestamp := l_base + numtodsinterval(p_offset_minutes, 'MINUTE');
    begin
        insert into oio_trace (
            integration_key, log_ref_id, oic_instance_id, user_name,
            log_level, summary, error_code, error_message,
            attr1_value, attr2_value, attr3_value, attr4_value, attr5_value,
            attr6_value, attr7_value, attr8_value, attr9_value, attr10_value,
            transaction_id1, transaction_id2, transaction_id3,
            creation_date, last_update_date
        ) values (
            p_integration_key, p_log_ref_id, p_oic_instance_id, p_user_name,
            p_log_level, p_summary, p_error_code, p_error_message,
            p_attr1_value, p_attr2_value, p_attr3_value, p_attr4_value, p_attr5_value,
            p_attr6_value, p_attr7_value, p_attr8_value, p_attr9_value, p_attr10_value,
            p_transaction_id1, p_transaction_id2, p_transaction_id3,
            l_event_ts, l_event_ts
        )
        returning trace_id into p_trace_id;
    end add_master;

    procedure add_detail(
        p_trace_id           in oio_trace_event.trace_id%type,
        p_event_type         in oio_trace_event.event_type%type,
        p_step_name          in oio_trace_event.step_name%type,
        p_oic_instance_id    in oio_trace_event.oic_instance_id%type,
        p_user_name          in oio_trace_event.user_name%type,
        p_log_level          in oio_trace_event.log_level%type,
        p_summary            in oio_trace_event.summary%type,
        p_error_code         in oio_trace_event.error_code%type,
        p_error_message      in oio_trace_event.error_message%type,
        p_transaction_status in oio_trace_event.transaction_status%type,
        p_offset_minutes     in number,
        p_trace_detail_id    out oio_trace_event.trace_detail_id%type
    ) is
        l_event_ts timestamp := l_base + numtodsinterval(p_offset_minutes, 'MINUTE');
    begin
        insert into oio_trace_event (
            trace_id, event_type, step_name, oic_instance_id, user_name,
            log_level, summary, error_code, error_message, transaction_status,
            creation_date, last_update_date
        ) values (
            p_trace_id, p_event_type, p_step_name, p_oic_instance_id, p_user_name,
            p_log_level, p_summary, p_error_code, p_error_message, p_transaction_status,
            l_event_ts, l_event_ts
        )
        returning trace_detail_id into p_trace_detail_id;
    end add_detail;

    procedure add_lob(
        p_trace_detail_id in oio_trace_payload.trace_detail_id%type,
        p_request         in clob,
        p_response        in clob,
        p_offset_minutes  in number
    ) is
        l_event_ts timestamp := l_base + numtodsinterval(p_offset_minutes, 'MINUTE');
    begin
        if p_request is not null or p_response is not null then
            insert into oio_trace_payload (
                trace_detail_id, request, response, creation_date
            ) values (
                p_trace_detail_id, p_request, p_response, l_event_ts
            );
        end if;
    end add_lob;
begin
    ----------------------------------------------------------------
    -- FIN Payables: 1 integration key, 3 transactions.
    ----------------------------------------------------------------
    add_master('FIN_AP_PAYMENT_FLOW', 'AP-CORR-1001', 'OIC-AP-1001', 'OIC', 'I',
        'AP invoice payment completed successfully', null, null,
        'AP-INV-1001', 'SUP-100', 'BR Operations', 'BRL', '12500.75',
        'EFT', '2026-05-28', 'AP-BATCH-20260519-01', 'BR_PRIMARY', 'PAYMENT_REQUEST',
        'AP-INV-1001', 'PAY-9001001', 'AP-BATCH-20260519-01', 0, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'Invoice received', 'OIC-AP-1001', 'OIC', 'I', 'Invoice received by traceability flow', null, null, 'RECEIVED', 0, l_detail_id);
    add_lob(l_detail_id, to_clob(q'~{"invoiceNumber":"AP-INV-1001","supplier":"SUP-100","amount":12500.75}~'), to_clob(q'~{"status":"RECEIVED"}~'), 0);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'Invoice validation', 'OIC-AP-1001', 'OIC', 'I', 'Invoice validated successfully', null, null, 'VALIDATED', 3, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'Payment approval', 'OIC-AP-1001', 'OIC', 'I', 'Payment approved', null, null, 'APPROVED', 6, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'Payment execution', 'OIC-AP-1001', 'OIC', 'I', 'Payment completed in ERP Financials', null, null, 'PAID', 10, l_detail_id);
    add_lob(l_detail_id, null, to_clob(q'~{"paymentDocument":"PAY-9001001","paymentStatus":"PAID"}~'), 10);

    add_master('FIN_AP_PAYMENT_FLOW', 'AP-CORR-1002', 'OIC-AP-1002', 'OIC', 'E',
        'AP invoice rejected during validation', 'AP-VAL-002', 'Supplier payment site is missing',
        'AP-INV-1002', 'SUP-200', 'BR Operations', 'BRL', '8450.00',
        'EFT', '2026-05-30', 'AP-BATCH-20260519-01', 'BR_PRIMARY', 'PAYMENT_REQUEST',
        'AP-INV-1002', null, 'AP-BATCH-20260519-01', 20, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'Invoice received', 'OIC-AP-1002', 'OIC', 'I', 'Invoice received by traceability flow', null, null, 'RECEIVED', 20, l_detail_id);
    add_detail(l_trace_id, 'ERROR', 'Invoice validation', 'OIC-AP-1002', 'OIC', 'E', 'Invoice rejected due to missing supplier payment site', 'AP-VAL-002', 'Supplier payment site is missing', 'REJECTED', 24, l_detail_id);
    add_lob(l_detail_id, to_clob(q'~{"invoiceNumber":"AP-INV-1002","supplier":"SUP-200"}~'), to_clob(q'~{"errorCode":"AP-VAL-002","message":"Supplier payment site is missing"}~'), 24);

    add_master('FIN_AP_PAYMENT_FLOW', 'AP-CORR-1003', 'OIC-AP-1003', 'OIC', 'I',
        'AP invoice paid after retry', null, null,
        'AP-INV-1003', 'SUP-300', 'BR Services', 'USD', '2210.40',
        'WIRE', '2026-06-03', 'AP-BATCH-20260519-02', 'US_PRIMARY', 'PAYMENT_REQUEST',
        'AP-INV-1003', 'PAY-9001003', 'AP-BATCH-20260519-02', 35, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'Invoice received', 'OIC-AP-1003', 'OIC', 'I', 'Invoice received by traceability flow', null, null, 'RECEIVED', 35, l_detail_id);
    add_detail(l_trace_id, 'ERROR', 'Payment execution', 'OIC-AP-1003', 'OIC', 'E', 'Temporary bank gateway timeout', 'BANK-504', 'Payment gateway timeout', 'PAYMENT_ERROR', 39, l_detail_id);
    add_lob(l_detail_id, null, to_clob(q'~{"errorCode":"BANK-504","message":"Payment gateway timeout"}~'), 39);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'Retry scheduled', 'OIC-AP-1003', 'OIC', 'I', 'Payment retry scheduled', null, null, 'RETRY_SCHEDULED', 43, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'Payment execution retry', 'OIC-AP-1003', 'OIC', 'I', 'Payment completed after retry', null, null, 'PAID', 49, l_detail_id);

    ----------------------------------------------------------------
    -- SCM Purchase Order: 1 integration key, 2 simple success transactions.
    ----------------------------------------------------------------
    add_master('SCM_PO_SYNC', 'PO-CORR-450001', 'OIC-SCM-450001', 'OIC', 'I',
        'Purchase order synchronized successfully', null, null,
        'PO-450001', 'SUP-880', 'Ana Buyer', 'BR Operations', 'BRL',
        '35100.00', 'INV-BR-01', 'STD_APPROVAL', 'PO_APPROVED', 'SCM-BATCH-20260519-01',
        'PO-450001', 'ACK-450001', 'SCM-BATCH-20260519-01', 70, l_trace_id);
    add_detail(l_trace_id, 'SUCCESS', 'Supplier portal acknowledgement', 'OIC-SCM-450001', 'OIC', 'I', 'Purchase order accepted by supplier portal', null, null, 'SUCCESS', 70, l_detail_id);

    add_master('SCM_PO_SYNC', 'PO-CORR-450002', 'OIC-SCM-450002', 'OIC', 'I',
        'Purchase order synchronized successfully', null, null,
        'PO-450002', 'SUP-881', 'Carlos Buyer', 'BR Operations', 'USD',
        '18800.00', 'INV-BR-02', 'STD_APPROVAL', 'PO_APPROVED', 'SCM-BATCH-20260519-01',
        'PO-450002', 'ACK-450002', 'SCM-BATCH-20260519-01', 76, l_trace_id);
    add_detail(l_trace_id, 'SUCCESS', 'Supplier portal acknowledgement', 'OIC-SCM-450002', 'OIC', 'I', 'Purchase order accepted by supplier portal', null, null, 'SUCCESS', 76, l_detail_id);

    ----------------------------------------------------------------
    -- FIN Receivables: same transaction sent to System A and System B.
    ----------------------------------------------------------------
    add_master('FIN_AR_SYSTEM_A', 'AR-CORR-9001-A', 'OIC-AR-9001-A', 'OIC', 'I',
        'Receivables transaction accepted by System A', null, null,
        'AR-INV-9001', 'CUST-1001', 'BR Operations', 'BRL', '9800.00',
        'BR_PRIMARY', 'BANK_TRANSFER', 'SYS-A-REF-9001', 'AR-BATCH-20260519-01', 'B2B',
        'AR-INV-9001', 'SYS-A-DOC-9001', 'AR-BATCH-20260519-01', 100, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'AR transaction received', 'OIC-AR-9001-A', 'OIC', 'I', 'Transaction received for System A delivery', null, null, 'RECEIVED', 100, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'System A transformation', 'OIC-AR-9001-A', 'OIC', 'I', 'Payload transformed for System A', null, null, 'TRANSFORMED', 104, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'System A delivery', 'OIC-AR-9001-A', 'OIC', 'I', 'Transaction accepted by System A', null, null, 'ACCEPTED', 108, l_detail_id);

    add_master('FIN_AR_SYSTEM_B', 'AR-CORR-9001-B', 'OIC-AR-9001-B', 'OIC', 'I',
        'Receivables transaction accepted by System B', null, null,
        'AR-INV-9001', 'CUST-1001', 'BR Operations', 'BRL', '9800.00',
        'BR_PRIMARY', 'BANK_TRANSFER', 'SYS-B-REF-9001', 'AR-BATCH-20260519-01', 'B2B',
        'AR-INV-9001', 'SYS-B-DOC-9001', 'AR-BATCH-20260519-01', 110, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'AR transaction received', 'OIC-AR-9001-B', 'OIC', 'I', 'Transaction received for System B delivery', null, null, 'RECEIVED', 110, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'System B enrichment', 'OIC-AR-9001-B', 'OIC', 'I', 'Customer reference enriched for System B', null, null, 'ENRICHED', 113, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'System B delivery', 'OIC-AR-9001-B', 'OIC', 'I', 'Transaction accepted by System B', null, null, 'ACCEPTED', 118, l_detail_id);

    add_master('FIN_AR_SYSTEM_A', 'AR-CORR-9002-A', 'OIC-AR-9002-A', 'OIC', 'I',
        'Receivables transaction accepted by System A', null, null,
        'AR-INV-9002', 'CUST-1002', 'BR Operations', 'BRL', '14250.90',
        'BR_PRIMARY', 'PIX', 'SYS-A-REF-9002', 'AR-BATCH-20260519-01', 'B2C',
        'AR-INV-9002', 'SYS-A-DOC-9002', 'AR-BATCH-20260519-01', 130, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'AR transaction received', 'OIC-AR-9002-A', 'OIC', 'I', 'Transaction received for System A delivery', null, null, 'RECEIVED', 130, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'System A delivery', 'OIC-AR-9002-A', 'OIC', 'I', 'Transaction accepted by System A', null, null, 'ACCEPTED', 134, l_detail_id);

    add_master('FIN_AR_SYSTEM_B', 'AR-CORR-9002-B', 'OIC-AR-9002-B', 'OIC', 'I',
        'Receivables transaction accepted by System B after retry', null, null,
        'AR-INV-9002', 'CUST-1002', 'BR Operations', 'BRL', '14250.90',
        'BR_PRIMARY', 'PIX', 'SYS-B-REF-9002', 'AR-BATCH-20260519-01', 'B2C',
        'AR-INV-9002', 'SYS-B-DOC-9002', 'AR-BATCH-20260519-01', 136, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'AR transaction received', 'OIC-AR-9002-B', 'OIC', 'I', 'Transaction received for System B delivery', null, null, 'RECEIVED', 136, l_detail_id);
    add_detail(l_trace_id, 'ERROR', 'System B delivery', 'OIC-AR-9002-B', 'OIC', 'E', 'System B returned a temporary service error', 'SYSB-503', 'Service temporarily unavailable', 'DELIVERY_ERROR', 140, l_detail_id);
    add_lob(l_detail_id, to_clob(q'~{"transactionNumber":"AR-INV-9002","targetSystem":"System B"}~'), to_clob(q'~{"errorCode":"SYSB-503","message":"Service temporarily unavailable"}~'), 140);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'System B retry', 'OIC-AR-9002-B', 'OIC', 'I', 'Retry accepted by System B', null, null, 'ACCEPTED', 148, l_detail_id);

    add_master('FIN_AR_SYSTEM_A', 'AR-CORR-9003-A', 'OIC-AR-9003-A', 'OIC', 'E',
        'Receivables transaction rejected by System A', 'SYSA-422', 'Invalid tax classification',
        'AR-INV-9003', 'CUST-1003', 'BR Services', 'USD', '7300.00',
        'US_PRIMARY', 'WIRE', 'SYS-A-REF-9003', 'AR-BATCH-20260519-02', 'B2B',
        'AR-INV-9003', null, 'AR-BATCH-20260519-02', 160, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'AR transaction received', 'OIC-AR-9003-A', 'OIC', 'I', 'Transaction received for System A delivery', null, null, 'RECEIVED', 160, l_detail_id);
    add_detail(l_trace_id, 'ERROR', 'System A validation', 'OIC-AR-9003-A', 'OIC', 'E', 'System A rejected the transaction due to tax classification', 'SYSA-422', 'Invalid tax classification', 'REJECTED', 166, l_detail_id);
    add_lob(l_detail_id, to_clob(q'~{"transactionNumber":"AR-INV-9003","taxClassification":"UNKNOWN"}~'), to_clob(q'~{"errorCode":"SYSA-422","message":"Invalid tax classification"}~'), 166);

    add_master('FIN_AR_SYSTEM_B', 'AR-CORR-9003-B', 'OIC-AR-9003-B', 'OIC', 'I',
        'Receivables transaction blocked waiting System A correction', null, null,
        'AR-INV-9003', 'CUST-1003', 'BR Services', 'USD', '7300.00',
        'US_PRIMARY', 'WIRE', 'SYS-B-REF-9003', 'AR-BATCH-20260519-02', 'B2B',
        'AR-INV-9003', null, 'AR-BATCH-20260519-02', 168, l_trace_id);
    add_detail(l_trace_id, 'CREATED', 'AR transaction received', 'OIC-AR-9003-B', 'OIC', 'I', 'Transaction received for System B delivery', null, null, 'RECEIVED', 168, l_detail_id);
    add_detail(l_trace_id, 'STATUS_UPDATE', 'Dependency check', 'OIC-AR-9003-B', 'OIC', 'I', 'System B delivery blocked until System A correction is completed', null, null, 'BLOCKED', 172, l_detail_id);

    dbms_output.put_line('Oracle Integration Observability (OIO) sample data loaded successfully.');
end;
/

commit;

prompt Sample data loaded.




