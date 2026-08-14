prompt --application/shared_components/globalization/messages
begin
--   Manifest
--     MESSAGES: 101
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.16'
,p_default_workspace_id=>15869608976564234
,p_default_application_id=>101
,p_default_id_offset=>0
,p_default_owner=>'OIO_APEX'
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18285849422174163)
,p_name=>'OIO_TECH_ERRORS_DESC'
,p_message_text=>'Transactions with errors in the selected period'
,p_version_scn=>47039818529438
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18286071042174166)
,p_name=>'OIO_TECH_ERRORS_DESC'
,p_message_language=>'pt-br'
,p_message_text=>unistr('Transa\00E7\00F5es com erros no per\00EDodo selecionado')
,p_version_scn=>47039818529578
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18285400076047216)
,p_name=>'OIO_TECH_ERRORS_TITLE'
,p_message_text=>'Errors'
,p_version_scn=>47039816906323
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18285674932052925)
,p_name=>'OIO_TECH_ERRORS_TITLE'
,p_message_language=>'pt-br'
,p_message_text=>'Erros'
,p_version_scn=>47039816971645
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18290730975194316)
,p_name=>'OIO_TECH_ERROR_RATE_DESC'
,p_message_text=>'Percentage of transactions with errors'
,p_version_scn=>47039818849721
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18291010496194317)
,p_name=>'OIO_TECH_ERROR_RATE_DESC'
,p_message_language=>'pt-br'
,p_message_text=>unistr('Percentual de transa\00E7\00F5es com erros')
,p_version_scn=>47039818849723
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18290220525194313)
,p_name=>'OIO_TECH_ERROR_RATE_TITLE'
,p_message_text=>'Error Rate'
,p_version_scn=>47039818849631
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18290479383194314)
,p_name=>'OIO_TECH_ERROR_RATE_TITLE'
,p_message_language=>'pt-br'
,p_message_text=>'Taxa de Erros'
,p_version_scn=>47039818849680
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18289784597188671)
,p_name=>'OIO_TECH_STUCK_DESC'
,p_message_text=>'Potentially Stuck'
,p_version_scn=>47039818777940
);
wwv_flow_imp_shared.create_message(
 p_id=>wwv_flow_imp.id(18289995516188672)
,p_name=>'OIO_TECH_STUCK_DESC'
,p_message_language=>'pt-br'
,p_message_text=>'Potencialmente Travadas'
,p_version_scn=>47039818777949
);
wwv_flow_imp.component_end;
end;
/
