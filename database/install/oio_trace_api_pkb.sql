create or replace package body oio_trace_api as
    g_status_success CONSTANT VARCHAR2(30) := 'SUCCESS';
    g_status_error   CONSTANT VARCHAR2(30) := 'SUCCESS';
    subtype t_payload_key is varchar2(128);

    type t_trace_id_tab is table of oio_trace.trace_id%type;

    type t_event_rec is record (
        integration_key     oio_trace.integration_key%type,
        log_ref_id          oio_trace.log_ref_id%type,
        oic_instance_id     oio_trace.oic_instance_id%type,
        user_name           oio_trace.user_name%type,
        log_level           oio_trace.log_level%type,
        summary             oio_trace.summary%type,
        error_code          oio_trace.error_code%type,
        error_message       oio_trace.error_message%type,
        attr1_value         oio_trace.attr1_value%type,
        attr2_value         oio_trace.attr2_value%type,
        attr3_value         oio_trace.attr3_value%type,
        attr4_value         oio_trace.attr4_value%type,
        attr5_value         oio_trace.attr5_value%type,
        attr6_value         oio_trace.attr6_value%type,
        attr7_value         oio_trace.attr7_value%type,
        attr8_value         oio_trace.attr8_value%type,
        attr9_value         oio_trace.attr9_value%type,
        attr10_value        oio_trace.attr10_value%type,
        transaction_id1     oio_trace.transaction_id1%type,
        transaction_id2     oio_trace.transaction_id2%type,
        transaction_id3     oio_trace.transaction_id3%type,
        transaction_status  oio_trace_event.transaction_status%type,
        request_payload     clob,
        response_payload    clob
    );

    function trim_vc(
        p_value  in varchar2,
        p_length in pls_integer
    ) return varchar2 is
        l_value varchar2(32767);
    begin
        l_value := trim(p_value);

        if l_value is null then
            return null;
        end if;

        return substr(l_value, 1, p_length);
    end trim_vc;

    function clob_has_value(
        p_value in clob
    ) return boolean is
    begin
        return p_value is not null and dbms_lob.getlength(p_value) > 0;
    exception
        when others then
            return false;
    end clob_has_value;

    function is_xml_payload(
        p_payload in clob
    ) return boolean is
        l_prefix varchar2(100);
    begin
        l_prefix := ltrim(dbms_lob.substr(p_payload, 100, 1));
        return substr(l_prefix, 1, 1) = '<';
    exception
        when others then
            return false;
    end is_xml_payload;

    function xml_varchar(
        p_payload in clob,
        p_key     in t_payload_key,
        p_length  in pls_integer
    ) return varchar2 is
        l_xml  xmltype;
        l_node xmltype;
    begin
        l_xml := xmltype(p_payload);
        l_node := l_xml.extract(
            '/*[local-name()="request-wrapper"]/*[local-name()="' || p_key || '"]/text()'
        );

        if l_node is null then
            return null;
        end if;

        return trim_vc(l_node.getstringval(), p_length);
    exception
        when others then
            return null;
    end xml_varchar;

    function xml_clob(
        p_payload in clob,
        p_key     in t_payload_key
    ) return clob is
        l_xml  xmltype;
        l_node xmltype;
    begin
        l_xml := xmltype(p_payload);
        l_node := l_xml.extract(
            '/*[local-name()="request-wrapper"]/*[local-name()="' || p_key || '"]/text()'
        );

        if l_node is null then
            return null;
        end if;

        return l_node.getclobval();
    exception
        when others then
            return null;
    end xml_clob;

    function json_varchar(
        p_values in apex_json.t_values,
        p_key    in t_payload_key,
        p_length in pls_integer
    ) return varchar2 is
    begin
        return trim_vc(
            apex_json.get_varchar2(
                p_path   => p_key,
                p_values => p_values
            ),
            p_length
        );
    exception
        when others then
            return null;
    end json_varchar;

    function json_clob(
        p_values in apex_json.t_values,
        p_key    in t_payload_key
    ) return clob is
    begin
        return apex_json.get_clob(
            p_path   => p_key,
            p_values => p_values
        );
    exception
        when others then
            return null;
    end json_clob;

    function event_type_for(
        p_log_level          in oio_trace.log_level%type,
        p_error_code         in oio_trace.error_code%type,
        p_error_message      in oio_trace.error_message%type,
        p_transaction_status in oio_trace_event.transaction_status%type
    ) return oio_trace_event.event_type%type is
    begin
        if p_log_level = 'E'
           or p_error_code is not null
           or p_error_message is not null then
            return 'ERROR';
        end if;

        if p_transaction_status is not null then
            return 'STATUS_EVENT';
        end if;

        return 'INFO';
    end event_type_for;

    function load_event(
        p_payload in clob
    ) return t_event_rec is
        l_event  t_event_rec;
        l_values apex_json.t_values;
        l_is_xml boolean;
    begin
        l_is_xml := is_xml_payload(p_payload);

        if not l_is_xml then
            apex_json.parse(
                p_values => l_values,
                p_source => p_payload
            );
        end if;

        if l_is_xml then
            l_event.integration_key := xml_varchar(p_payload, 'integrationKey', 250);
            l_event.log_ref_id := xml_varchar(p_payload, 'correlationId', 250);
            l_event.oic_instance_id := xml_varchar(p_payload, 'oicInstanceId', 250);
            l_event.user_name := xml_varchar(p_payload, 'userName', 250);
            l_event.log_level := upper(xml_varchar(p_payload, 'logLevel', 1));
            l_event.summary := xml_varchar(p_payload, 'summary', 4000);
            l_event.error_code := xml_varchar(p_payload, 'errorCode', 250);
            l_event.error_message := xml_varchar(p_payload, 'errorMessage', 4000);
            l_event.attr1_value := xml_varchar(p_payload, 'attr1Value', 4000);
            l_event.attr2_value := xml_varchar(p_payload, 'attr2Value', 4000);
            l_event.attr3_value := xml_varchar(p_payload, 'attr3Value', 4000);
            l_event.attr4_value := xml_varchar(p_payload, 'attr4Value', 4000);
            l_event.attr5_value := xml_varchar(p_payload, 'attr5Value', 4000);
            l_event.attr6_value := xml_varchar(p_payload, 'attr6Value', 4000);
            l_event.attr7_value := xml_varchar(p_payload, 'attr7Value', 4000);
            l_event.attr8_value := xml_varchar(p_payload, 'attr8Value', 4000);
            l_event.attr9_value := xml_varchar(p_payload, 'attr9Value', 4000);
            l_event.attr10_value := xml_varchar(p_payload, 'attr10Value', 4000);
            l_event.transaction_id1 := xml_varchar(p_payload, 'transactionId1', 250);
            l_event.transaction_id2 := xml_varchar(p_payload, 'transactionId2', 250);
            l_event.transaction_id3 := xml_varchar(p_payload, 'transactionId3', 250);
            l_event.transaction_status := xml_varchar(p_payload, 'transactionStatus', 250);
            l_event.request_payload := xml_clob(p_payload, 'requestPayload');
            l_event.response_payload := xml_clob(p_payload, 'responsePayload');
        else
            l_event.integration_key := json_varchar(l_values, 'integrationKey', 250);
            l_event.log_ref_id := json_varchar(l_values, 'correlationId', 250);
            l_event.oic_instance_id := json_varchar(l_values, 'oicInstanceId', 250);
            l_event.user_name := json_varchar(l_values, 'userName', 250);
            l_event.log_level := upper(json_varchar(l_values, 'logLevel', 1));
            l_event.summary := json_varchar(l_values, 'summary', 4000);
            l_event.error_code := json_varchar(l_values, 'errorCode', 250);
            l_event.error_message := json_varchar(l_values, 'errorMessage', 4000);
            l_event.attr1_value := json_varchar(l_values, 'attr1Value', 4000);
            l_event.attr2_value := json_varchar(l_values, 'attr2Value', 4000);
            l_event.attr3_value := json_varchar(l_values, 'attr3Value', 4000);
            l_event.attr4_value := json_varchar(l_values, 'attr4Value', 4000);
            l_event.attr5_value := json_varchar(l_values, 'attr5Value', 4000);
            l_event.attr6_value := json_varchar(l_values, 'attr6Value', 4000);
            l_event.attr7_value := json_varchar(l_values, 'attr7Value', 4000);
            l_event.attr8_value := json_varchar(l_values, 'attr8Value', 4000);
            l_event.attr9_value := json_varchar(l_values, 'attr9Value', 4000);
            l_event.attr10_value := json_varchar(l_values, 'attr10Value', 4000);
            l_event.transaction_id1 := json_varchar(l_values, 'transactionId1', 250);
            l_event.transaction_id2 := json_varchar(l_values, 'transactionId2', 250);
            l_event.transaction_id3 := json_varchar(l_values, 'transactionId3', 250);
            l_event.transaction_status := json_varchar(l_values, 'transactionStatus', 250);
            l_event.request_payload := json_clob(l_values, 'requestPayload');
            l_event.response_payload := json_clob(l_values, 'responsePayload');
        end if;

        l_event.user_name := coalesce(l_event.user_name, 'OIC');

        return l_event;
    exception
        when others then
            raise_application_error(-20000, 'Invalid traceability payload. ' || sqlerrm);
    end load_event;

    procedure validate_integration(
        p_integration_key in oio_integration_cfg.integration_key%type
    ) is
        l_count number;
    begin
        if p_integration_key is null then
            raise_application_error(-20001, 'integrationKey is required.');
        end if;

        select count(*)
          into l_count
          from oio_integration_cfg
         where integration_key = p_integration_key
           and nvl(active_flag, 'Y') = 'Y';

        if l_count = 0 then
            raise_application_error(-20002, 'integrationKey does not exist or is inactive in oio_integration_cfg.');
        end if;
    end validate_integration;

    procedure validate_create_event(
        p_event in t_event_rec
    ) is
    begin
        validate_integration(p_event.integration_key);

        if p_event.oic_instance_id is null then
            raise_application_error(-20003, 'oicInstanceId is required.');
        end if;

        if p_event.log_level not in ('I', 'E') then
            raise_application_error(-20004, 'logLevel must be I or E.');
        end if;

        if p_event.summary is null then
            raise_application_error(-20005, 'summary is required.');
        end if;

        if p_event.attr1_value is null then
            raise_application_error(-20006, 'attr1Value is required.');
        end if;

        if p_event.transaction_status is null then
            raise_application_error(-20007, 'transactionStatus is required.');
        end if;
    end validate_create_event;

    procedure validate_status_update(
        p_event in t_event_rec
    ) is
    begin
        validate_integration(p_event.integration_key);

        if p_event.transaction_id1 is null
           and p_event.transaction_id2 is null
           and p_event.transaction_id3 is null then
            raise_application_error(-20008, 'At least one transaction identifier is required.');
        end if;

        if p_event.transaction_status is null then
            raise_application_error(-20009, 'transactionStatus is required.');
        end if;
    end validate_status_update;

    procedure insert_detail_event(
        p_trace_id        in oio_trace.trace_id%type,
        p_event_type      in oio_trace_event.event_type%type,
        p_event           in t_event_rec,
        o_trace_detail_id out oio_trace_event.trace_detail_id%type
    ) is
    begin
        insert into oio_trace_event (
            trace_id,
            event_type,
            step_name,
            oic_instance_id,
            user_name,
            log_level,
            summary,
            error_code,
            error_message,
            transaction_status,
            creation_date,
            last_update_date
        ) values (
            p_trace_id,
            p_event_type,
            null,
            p_event.oic_instance_id,
            p_event.user_name,
            p_event.log_level,
            p_event.summary,
            p_event.error_code,
            p_event.error_message,
            p_event.transaction_status,
            systimestamp,
            systimestamp
        )
        returning trace_detail_id into o_trace_detail_id;
    end insert_detail_event;

    procedure insert_lob_event(
        p_trace_detail_id in oio_trace_event.trace_detail_id%type,
        p_event           in t_event_rec
    ) is
    begin
        if clob_has_value(p_event.request_payload)
           or clob_has_value(p_event.response_payload) then
            insert into oio_trace_payload (
                trace_detail_id,
                request,
                response,
                creation_date
            ) values (
                p_trace_detail_id,
                p_event.request_payload,
                p_event.response_payload,
                systimestamp
            );
        end if;
    end insert_lob_event;

    procedure create_trace_event(
        p_payload         in clob,
        o_trace_id        out oio_trace.trace_id%type,
        o_trace_detail_id out oio_trace_event.trace_detail_id%type
    ) is
        l_event      t_event_rec;
        l_event_type oio_trace_event.event_type%type;
    begin
        l_event := load_event(p_payload);
        validate_create_event(l_event);

        insert into oio_trace (
            integration_key,
            log_ref_id,
            oic_instance_id,
            user_name,
            log_level,
            summary,
            error_code,
            error_message,
            attr1_value,
            attr2_value,
            attr3_value,
            attr4_value,
            attr5_value,
            attr6_value,
            attr7_value,
            attr8_value,
            attr9_value,
            attr10_value,
            transaction_id1,
            transaction_id2,
            transaction_id3,
            creation_date,
            last_update_date
        ) values (
            l_event.integration_key,
            l_event.log_ref_id,
            l_event.oic_instance_id,
            l_event.user_name,
            l_event.log_level,
            l_event.summary,
            l_event.error_code,
            l_event.error_message,
            l_event.attr1_value,
            l_event.attr2_value,
            l_event.attr3_value,
            l_event.attr4_value,
            l_event.attr5_value,
            l_event.attr6_value,
            l_event.attr7_value,
            l_event.attr8_value,
            l_event.attr9_value,
            l_event.attr10_value,
            l_event.transaction_id1,
            l_event.transaction_id2,
            l_event.transaction_id3,
            systimestamp,
            systimestamp
        )
        returning trace_id into o_trace_id;

        l_event_type := event_type_for(
            p_log_level          => l_event.log_level,
            p_error_code         => l_event.error_code,
            p_error_message      => l_event.error_message,
            p_transaction_status => l_event.transaction_status
        );

        insert_detail_event(
            p_trace_id        => o_trace_id,
            p_event_type      => l_event_type,
            p_event           => l_event,
            o_trace_detail_id => o_trace_detail_id
        );

        insert_lob_event(
            p_trace_detail_id => o_trace_detail_id,
            p_event           => l_event
        );
    end create_trace_event;

    procedure pr_create_trace_log(
        p_payload in clob,
        o_status  OUT VARCHAR2,
        o_message OUT VARCHAR2
    ) is
        pragma autonomous_transaction;

        l_trace_id        oio_trace.trace_id%type;
        l_trace_detail_id oio_trace_event.trace_detail_id%type;
        l_message         VARCHAR2(4000) := 'Record was created with success';
    begin
        create_trace_event(
            p_payload         => p_payload,
            o_trace_id        => l_trace_id,
            o_trace_detail_id => l_trace_detail_id
        );

        commit;
        o_status := g_status_success;
        o_message := l_message;
    exception
        when others then
            rollback;
            o_status := g_status_error;
            o_message := SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 0, 4000);
    end pr_create_trace_log;

    procedure pr_update_transaction_status(
        p_payload in clob,
        o_status  OUT VARCHAR2,
        o_message OUT VARCHAR2
    ) is
      pragma autonomous_transaction;
      l_event           t_event_rec;
      l_trace_ids       t_trace_id_tab;
      l_trace_detail_id oio_trace_event.trace_detail_id%type;
      l_message         VARCHAR2(4000) := 'Record was created with success';
    begin
      l_event := load_event(p_payload);
      validate_status_update(l_event);

        select trace_id
        bulk collect into l_trace_ids
        from oio_trace
        where integration_key = l_event.integration_key
        and (l_event.transaction_id1 is null or transaction_id1 = l_event.transaction_id1)
        and (l_event.transaction_id2 is null or transaction_id2 = l_event.transaction_id2)
        and (l_event.transaction_id3 is null or transaction_id3 = l_event.transaction_id3);

        if l_trace_ids.count = 0 then
            raise_application_error(
                -20010,
                'No oio_trace rows were found for the provided transaction identifiers.'
            );
        end if;

        for i in 1 .. l_trace_ids.count loop
            update oio_trace
            set log_ref_id      = coalesce(l_event.log_ref_id, log_ref_id),
                oic_instance_id = coalesce(l_event.oic_instance_id, oic_instance_id),
                user_name       = coalesce(l_event.user_name, user_name),
                log_level       = coalesce(l_event.log_level, log_level),
                summary         = coalesce(l_event.summary, summary),
                error_code      = coalesce(l_event.error_code, error_code),
                error_message   = coalesce(l_event.error_message, error_message),
                attr1_value     = coalesce(l_event.attr1_value, attr1_value),
                attr2_value     = coalesce(l_event.attr2_value, attr2_value),
                attr3_value     = coalesce(l_event.attr3_value, attr3_value),
                attr4_value     = coalesce(l_event.attr4_value, attr4_value),
                attr5_value     = coalesce(l_event.attr5_value, attr5_value),
                attr6_value     = coalesce(l_event.attr6_value, attr6_value),
                attr7_value     = coalesce(l_event.attr7_value, attr7_value),
                attr8_value     = coalesce(l_event.attr8_value, attr8_value),
                attr9_value     = coalesce(l_event.attr9_value, attr9_value),
                attr10_value    = coalesce(l_event.attr10_value, attr10_value),
                transaction_id1 = coalesce(l_event.transaction_id1, transaction_id1),
                transaction_id2 = coalesce(l_event.transaction_id2, transaction_id2),
                transaction_id3 = coalesce(l_event.transaction_id3, transaction_id3),
                last_update_date = systimestamp
            where trace_id = l_trace_ids(i);

            insert_detail_event(
                p_trace_id        => l_trace_ids(i),
                p_event_type      => 'STATUS_UPDATE',
                p_event           => l_event,
                o_trace_detail_id => l_trace_detail_id
            );

            insert_lob_event(
                p_trace_detail_id => l_trace_detail_id,
                p_event           => l_event
            );
        end loop;

        commit;
        o_status := g_status_success;
        o_message := l_message;
    exception
    when others then
        rollback;
        o_status := g_status_error;
        o_message := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    end pr_update_transaction_status;

    procedure register_event_json(
        p_payload  in clob,
        o_status   out varchar2,
        o_trace_id out number,
        o_message  out varchar2
    ) is
        pragma autonomous_transaction;

        l_trace_detail_id oio_trace_event.trace_detail_id%type;
    begin
        o_status := null;
        o_trace_id := null;
        o_message := null;

        create_trace_event(
            p_payload         => p_payload,
            o_trace_id        => o_trace_id,
            o_trace_detail_id => l_trace_detail_id
        );

        o_status := 'OK';
        o_message := 'Trace log registered successfully.';

        commit;
    exception
        when others then
            rollback;
            o_status := 'ERROR';
            o_trace_id := null;
            o_message := trim_vc(sqlerrm, 4000);
            raise;
    end register_event_json;

end oio_trace_api;
/



