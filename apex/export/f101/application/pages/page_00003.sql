prompt --application/pages/page_00003
begin
--   Manifest
--     PAGE: 00003
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.16'
,p_default_workspace_id=>15869608976564234
,p_default_application_id=>101
,p_default_id_offset=>0
,p_default_owner=>'OIO_APEX'
);
wwv_flow_imp_page.create_page(
 p_id=>3
,p_name=>'Payload Viewer'
,p_alias=>'PAYLOAD-VIEWER'
,p_page_mode=>'MODAL'
,p_step_title=>'Payload Viewer'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'27'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17086307452380901)
,p_plug_name=>'Request'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17086456822380902)
,p_plug_name=>'Response'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17086981972380907)
,p_plug_name=>'PayloadContext'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    p.transaction_id1 as title,',
'',
'    ''Integration: '' || p.integration_key as description,',
'',
'    ''Event: '' || p.event_type',
unistr('        || ''  \2022  Step: '' || p.step_name'),
unistr('        || ''  \2022  Level: '''),
'        || case h.log_level',
'             when ''I'' then ''Info''',
'             when ''E'' then ''Error''',
'             else h.log_level',
'           end as misc,',
'',
'    p.transaction_status as badge_value,',
'',
'    case p.transaction_status',
'        when ''COMPLETED''   then ''success''',
'        when ''FAILED''      then ''danger''',
'        when ''IN_PROGRESS'' then ''warning''',
'        when ''RECEIVED''    then ''info''',
'        else ''normal''',
'    end as badge_state',
'',
'from oio_owner.oio_v_trace_payload p',
'',
'join oio_owner.oio_v_trace_status_history h',
'  on h.trace_detail_id = p.trace_detail_id',
'',
'where p.trace_lob_id = :P3_TRACE_LOB_ID'))
,p_template_component_type=>'REPORT'
,p_lazy_loading=>false
,p_plug_source_type=>'TMPL_THEME_42$CONTENT_ROW'
,p_plug_query_num_rows=>15
,p_plug_query_num_rows_type=>'SET'
,p_show_total_row_count=>false
,p_landmark_type=>'region'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'APPLY_THEME_COLORS', 'Y',
  'BADGE_COL_WIDTH', 't-ContentRow-badge--md',
  'BADGE_LABEL', '&BADGE_STATE.',
  'BADGE_LABEL_DISPLAY', 'N',
  'BADGE_STATE', 'BADGE_STATE',
  'BADGE_VALUE', 'BADGE_VALUE',
  'DESCRIPTION', '&DESCRIPTION.',
  'DISPLAY_AVATAR', 'N',
  'DISPLAY_BADGE', 'Y',
  'HIDE_BORDERS', 'N',
  'MISC', '&MISC.',
  'REMOVE_PADDING', 'N',
  'TITLE', '&TITLE.')).to_clob
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(17087002406380908)
,p_name=>'TITLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TITLE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(17087161771380909)
,p_name=>'DESCRIPTION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'DESCRIPTION'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(17087220618380910)
,p_name=>'MISC'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'MISC'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(17087334921380911)
,p_name=>'BADGE_VALUE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'BADGE_VALUE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(17087434386380912)
,p_name=>'BADGE_STATE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'BADGE_STATE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>50
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17086505060380903)
,p_name=>'P3_REQUEST'
,p_data_type=>'CLOB'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(17086307452380901)
,p_prompt=>'Request'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select request',
'from oio_owner.oio_v_trace_payload',
'where trace_lob_id = :P3_TRACE_LOB_ID'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17086652123380904)
,p_name=>'P3_RESPONSE'
,p_data_type=>'CLOB'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(17086456822380902)
,p_prompt=>'Request'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select response',
'from oio_owner.oio_v_trace_payload',
'where trace_lob_id = :P3_TRACE_LOB_ID'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17086795223380905)
,p_name=>'P3_TRACE_LOB_ID'
,p_item_sequence=>40
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17086867666380906)
,p_name=>'P3_TRANSACTION_ID'
,p_item_sequence=>50
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp.component_end;
end;
/
