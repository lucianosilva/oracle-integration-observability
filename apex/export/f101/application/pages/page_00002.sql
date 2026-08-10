prompt --application/pages/page_00002
begin
--   Manifest
--     PAGE: 00002
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
 p_id=>2
,p_name=>'Transaction Search'
,p_alias=>'TRANSACTION-SEARCH'
,p_step_title=>'Transaction Search'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>To find data enter a search term into the search dialog, or click on the column headings to limit the records returned.</p>',
'',
'<p>You can perform numerous functions by clicking the <strong>Actions</strong> button. This includes selecting the columns that are displayed / hidden and their display sequence, plus numerous data and format functions.  You can also define additiona'
||'l views of the data using the chart, group by, and pivot options.</p>',
'',
'<p>If you want to save your customizations select report, or click download to unload the data. Enter you email address and time frame under subscription to be sent the data on a regular basis.<p>',
'',
'<p>For additional information click Help at the bottom of the Actions menu.</p> ',
'',
'<p>Click the <strong>Reset</strong> button to reset the interactive report back to the default settings.</p>'))
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15892641671683399)
,p_plug_name=>'Transactions'
,p_title=>'Transactions Search'
,p_region_name=>'transactions'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P2_PERIOD',
'',
'            when ''H1'' then',
'                cast(',
'                    systimestamp - interval ''1'' hour',
'                    as timestamp',
'                )',
'',
'            when ''H6'' then',
'                cast(',
'                    systimestamp - interval ''6'' hour',
'                    as timestamp',
'                )',
'',
'            when ''H24'' then',
'                cast(',
'                    systimestamp - interval ''24'' hour',
'                    as timestamp',
'                )',
'',
'            when ''D7'' then',
'                cast(',
'                    systimestamp - interval ''7'' day',
'                    as timestamp',
'                )',
'',
'            when ''D30'' then',
'                cast(',
'                    systimestamp - interval ''30'' day',
'                    as timestamp',
'                )',
'',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(',
'                    ''P2_DATE_FROM''',
'                )',
'',
'        end as date_from,',
'',
'        case',
'            when :P2_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(',
'                    ''P2_DATE_TO''',
'                ) + interval ''1'' day',
'',
'            else',
'                cast(',
'                    systimestamp + interval ''1'' second',
'                    as timestamp',
'                )',
'        end as date_to',
'',
'    from dual',
')',
'select',
'    v.trace_id,',
'    v.creation_date,',
'    v.integration_key,',
'    v.integration_description,',
'    v.source_system,',
'    v.target_system,',
'    v.outcome,',
'    v.current_status,',
'    v.transaction_id1,',
'    v.log_ref_id,',
'    v.oic_instance_id,',
'    v.summary,',
'    v.error_code,',
'    v.last_update_date,',
'    case v.outcome',
'    when ''SUCCESS'' then ''success''',
'    when ''ERROR''   then ''danger''',
'    else ''normal''',
'end as outcome_badge_state,',
'case v.current_status',
'    when ''COMPLETED''   then ''success''',
'    when ''FAILED''      then ''danger''',
'    when ''IN_PROGRESS'' then ''warning''',
'    when ''RECEIVED''    then ''info''',
'    else ''normal''',
'end as status_badge_state',
'from oio_owner.oio_v_trace_current v',
'cross join period_filter p',
'where v.creation_date >= p.date_from',
'  and v.creation_date <  p.date_to',
'',
'  and (',
'        :P2_INTEGRATION_KEY is null',
'        or v.integration_key = :P2_INTEGRATION_KEY',
'      )',
'',
'  and (',
'        :P2_OUTCOME is null',
'        or v.outcome = :P2_OUTCOME',
'      )',
'',
'  and (',
'        :P2_STATUS is null',
'        or v.current_status = :P2_STATUS',
'      )',
'',
'  and (',
'        :P2_SOURCE_SYSTEM is null',
'        or v.source_system = :P2_SOURCE_SYSTEM',
'      )',
'',
'  and (',
'        :P2_TARGET_SYSTEM is null',
'        or v.target_system = :P2_TARGET_SYSTEM',
'      )',
'',
'order by v.creation_date desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_ajax_items_to_submit=>'P2_PERIOD,P2_INTEGRATION_KEY,P2_OUTCOME,P2_STATUS,P2_SOURCE_SYSTEM,P2_TARGET_SYSTEM,P2_DATE_FROM,P2_DATE_TO'
,p_prn_page_header=>'Interactive Report'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(15892750901683399)
,p_name=>'Interactive Report'
,p_max_row_count_message=>'The maximum row count for this report is #MAX_ROW_COUNT# rows.  Please apply a filter to reduce the number of records in your query.'
,p_no_data_found_message=>'No transactions found for the selected period and filters.'
,p_allow_save_rpt_public=>'Y'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:XLSX'
,p_enable_mail_download=>'Y'
,p_csv_output_separator=>';'
,p_csv_output_enclosed_by=>'"'
,p_owner=>'OIO_APEX'
,p_internal_uid=>15892750901683399
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15893493329683410)
,p_db_column_name=>'TRACE_ID'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Trace Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15893823568683412)
,p_db_column_name=>'CREATION_DATE'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Created'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY HH24:MI:SS'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15894287123683413)
,p_db_column_name=>'INTEGRATION_KEY'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Integration'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15894637908683413)
,p_db_column_name=>'INTEGRATION_DESCRIPTION'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Description'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15895068969683414)
,p_db_column_name=>'SOURCE_SYSTEM'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Source'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15895499442683415)
,p_db_column_name=>'TARGET_SYSTEM'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Target'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15895888985683416)
,p_db_column_name=>'OUTCOME'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Outcome'
,p_allow_sorting=>'N'
,p_allow_filtering=>'N'
,p_allow_highlighting=>'N'
,p_allow_ctrl_breaks=>'N'
,p_allow_aggregations=>'N'
,p_allow_computations=>'N'
,p_allow_charting=>'N'
,p_allow_group_by=>'N'
,p_allow_pivot=>'N'
,p_column_type=>'STRING'
,p_display_text_as=>'TMPL_THEME_42$BADGE'
,p_heading_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'LABEL', 'Outcome',
  'LABEL_DISPLAY', 'N',
  'STATE', 'OUTCOME_BADGE_STATE',
  'VALUE', 'OUTCOME')).to_clob
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15896269625683417)
,p_db_column_name=>'CURRENT_STATUS'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Status'
,p_allow_sorting=>'N'
,p_allow_filtering=>'N'
,p_allow_highlighting=>'N'
,p_allow_ctrl_breaks=>'N'
,p_allow_aggregations=>'N'
,p_allow_computations=>'N'
,p_allow_charting=>'N'
,p_allow_group_by=>'N'
,p_allow_pivot=>'N'
,p_column_type=>'STRING'
,p_display_text_as=>'TMPL_THEME_42$BADGE'
,p_heading_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'LABEL', 'Status',
  'LABEL_DISPLAY', 'N',
  'STATE', 'STATUS_BADGE_STATE',
  'VALUE', 'CURRENT_STATUS')).to_clob
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15896691519683417)
,p_db_column_name=>'TRANSACTION_ID1'
,p_display_order=>9
,p_column_identifier=>'I'
,p_column_label=>'Transaction ID'
,p_column_link=>'javascript:apex.item("P2_TRACE_ID").setValue("#TRACE_ID#");apex.item("P2_TRANSACTION_ID").setValue("#TRANSACTION_ID1!JS#");apex.region("event_history").refresh();'
,p_column_linktext=>'#TRANSACTION_ID1#'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15897010848683418)
,p_db_column_name=>'LOG_REF_ID'
,p_display_order=>10
,p_column_identifier=>'J'
,p_column_label=>'Correlation ID'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15897488692683419)
,p_db_column_name=>'OIC_INSTANCE_ID'
,p_display_order=>11
,p_column_identifier=>'K'
,p_column_label=>'OIC Instance ID'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15897811262683420)
,p_db_column_name=>'SUMMARY'
,p_display_order=>12
,p_column_identifier=>'L'
,p_column_label=>'Summary'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15898210261683421)
,p_db_column_name=>'ERROR_CODE'
,p_display_order=>13
,p_column_identifier=>'M'
,p_column_label=>'Error Code'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(15898694071683422)
,p_db_column_name=>'LAST_UPDATE_DATE'
,p_display_order=>14
,p_column_identifier=>'N'
,p_column_label=>'Last Update'
,p_column_type=>'DATE'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(17087560519380913)
,p_db_column_name=>'OUTCOME_BADGE_STATE'
,p_display_order=>24
,p_column_identifier=>'O'
,p_column_label=>'Outcome Badge State'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(17087677856380914)
,p_db_column_name=>'STATUS_BADGE_STATE'
,p_display_order=>34
,p_column_identifier=>'P'
,p_column_label=>'Status Badge State'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(15903858024706634)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'159039'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TRACE_ID:CREATION_DATE:INTEGRATION_KEY:INTEGRATION_DESCRIPTION:SOURCE_SYSTEM:TARGET_SYSTEM:OUTCOME:CURRENT_STATUS:TRANSACTION_ID1:LOG_REF_ID:OIC_INSTANCE_ID:SUMMARY:ERROR_CODE:LAST_UPDATE_DATE'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15899712248683426)
,p_plug_name=>'Breadcrumb'
,p_title=>'Transaction Search'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(15878391117683269)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(15907823231777702)
,p_name=>'Event History'
,p_title=>'Event History '
,p_region_name=>'event_history'
,p_template=>4072358936313175081
,p_display_sequence=>50
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    h.trace_detail_id,',
'    h.transaction_id1,',
'    h.event_timestamp,',
'    h.event_type,',
'    h.step_name,',
'',
'    h.history_status,',
'',
'    case h.history_status',
'        when ''COMPLETED''   then ''Completed''',
'        when ''FAILED''      then ''Failed''',
'        when ''IN_PROGRESS'' then ''In Progress''',
'        when ''RECEIVED''    then ''Received''',
'        else initcap(replace(h.history_status, ''_'', '' ''))',
'    end as status_display,',
'',
'    case h.history_status',
'        when ''COMPLETED''   then ''success''',
'        when ''FAILED''      then ''danger''',
'        when ''IN_PROGRESS'' then ''warning''',
'        when ''RECEIVED''    then ''info''',
'        else ''normal''',
'    end as status_badge_state,',
'',
'    h.log_level,',
'',
'    case h.log_level',
'        when ''I'' then ''Info''',
'        when ''E'' then ''Error''',
'        else h.log_level',
'    end as level_display,',
'',
'    case h.log_level',
'        when ''I'' then ''info''',
'        when ''E'' then ''danger''',
'        else ''normal''',
'    end as level_badge_state,',
'',
'    h.oic_instance_id,',
'    h.user_name,',
'    h.summary,',
'    h.error_code,',
'    h.error_message,',
'',
'    (',
'        select max(p.trace_lob_id)',
'               keep (',
'                   dense_rank last',
'                   order by p.payload_creation_date',
'               )',
'        from oio_owner.oio_v_trace_payload p',
'        where p.trace_detail_id = h.trace_detail_id',
'    ) as trace_lob_id,',
'',
'    case',
'        when exists (',
'            select 1',
'            from oio_owner.oio_v_trace_payload p',
'            where p.trace_detail_id = h.trace_detail_id',
'        )',
'        then ''View Payload''',
'    end as payload_action',
'',
'from oio_owner.oio_v_trace_status_history h',
'where h.trace_id = :P2_TRACE_ID',
'order by',
'    h.event_timestamp desc,',
'    h.trace_detail_id desc'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P2_TRACE_ID,P2_TRANSACTION_ID'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'Select a transaction to view its event history.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15907987974777703)
,p_query_column_id=>1
,p_column_alias=>'TRACE_DETAIL_ID'
,p_column_display_sequence=>10
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15912415246777748)
,p_query_column_id=>2
,p_column_alias=>'TRANSACTION_ID1'
,p_column_display_sequence=>140
,p_column_heading=>'Transaction Id1'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908041255777704)
,p_query_column_id=>3
,p_column_alias=>'EVENT_TIMESTAMP'
,p_column_display_sequence=>20
,p_column_heading=>'Timestamp'
,p_column_format=>'DD/MM/YYYY HH24:MI:SS'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908144918777705)
,p_query_column_id=>4
,p_column_alias=>'EVENT_TYPE'
,p_column_display_sequence=>30
,p_column_heading=>'Event'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908219498777706)
,p_query_column_id=>5
,p_column_alias=>'STEP_NAME'
,p_column_display_sequence=>40
,p_column_heading=>'Step'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908366908777707)
,p_query_column_id=>6
,p_column_alias=>'HISTORY_STATUS'
,p_column_display_sequence=>60
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17087862094380916)
,p_query_column_id=>7
,p_column_alias=>'STATUS_DISPLAY'
,p_column_display_sequence=>50
,p_column_heading=>'Status'
,p_column_html_expression=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{with/}',
'LABEL:=Status',
'VALUE:=#STATUS_DISPLAY#',
'STATE:=#STATUS_BADGE_STATE#',
'LABEL_DISPLAY:=N',
'STYLE:=t-Badge--subtle',
'SHAPE:=t-Badge--square',
'{apply THEME$BADGE/}'))
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17087909815380917)
,p_query_column_id=>8
,p_column_alias=>'STATUS_BADGE_STATE'
,p_column_display_sequence=>180
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908468587777708)
,p_query_column_id=>9
,p_column_alias=>'LOG_LEVEL'
,p_column_display_sequence=>70
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17088038946380918)
,p_query_column_id=>10
,p_column_alias=>'LEVEL_DISPLAY'
,p_column_display_sequence=>80
,p_column_heading=>'Level'
,p_column_html_expression=>wwv_flow_string.join(wwv_flow_t_varchar2(
'{with/}',
'LABEL:=Level',
'VALUE:=#LEVEL_DISPLAY#',
'STATE:=#LEVEL_BADGE_STATE#',
'LABEL_DISPLAY:=N',
'STYLE:=t-Badge--subtle',
'SHAPE:=t-Badge--square',
'{apply THEME$BADGE/}'))
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(17088114058380919)
,p_query_column_id=>11
,p_column_alias=>'LEVEL_BADGE_STATE'
,p_column_display_sequence=>190
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908502122777709)
,p_query_column_id=>12
,p_column_alias=>'OIC_INSTANCE_ID'
,p_column_display_sequence=>90
,p_column_heading=>'OIC Instance'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908609535777710)
,p_query_column_id=>13
,p_column_alias=>'USER_NAME'
,p_column_display_sequence=>100
,p_column_heading=>'User'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908785358777711)
,p_query_column_id=>14
,p_column_alias=>'SUMMARY'
,p_column_display_sequence=>110
,p_column_heading=>'Summary'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908859169777712)
,p_query_column_id=>15
,p_column_alias=>'ERROR_CODE'
,p_column_display_sequence=>120
,p_column_heading=>'Error Code'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15908944511777713)
,p_query_column_id=>16
,p_column_alias=>'ERROR_MESSAGE'
,p_column_display_sequence=>130
,p_column_heading=>'Error Message'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15912517204777749)
,p_query_column_id=>17
,p_column_alias=>'TRACE_LOB_ID'
,p_column_display_sequence=>150
,p_hidden_column=>'Y'
,p_derived_column=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(15912686778777750)
,p_query_column_id=>18
,p_column_alias=>'PAYLOAD_ACTION'
,p_column_display_sequence=>160
,p_column_heading=>'Payload'
,p_column_link=>'f?p=&APP_ID.:3:&SESSION.::&DEBUG.:3:P3_TRACE_LOB_ID,P3_TRANSACTION_ID:#TRACE_LOB_ID#,#TRANSACTION_ID1#'
,p_column_linktext=>'#PAYLOAD_ACTION#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15909319155777717)
,p_plug_name=>'SelectedTransaction'
,p_title=>'Transaction: -'
,p_region_name=>'selected_transaction'
,p_parent_plug_id=>wwv_flow_imp.id(15907823231777702)
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15909808352777722)
,p_plug_name=>'Search Filters'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15911818795777742)
,p_button_sequence=>90
,p_button_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_button_name=>'ClearButton'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Clear Filters'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'N'
,p_grid_new_column=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15899019134683423)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(15892641671683399)
,p_button_name=>'RESET_REPORT'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Reset'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:2:&APP_SESSION.::&DEBUG.:RR::'
,p_icon_css_classes=>'fa-undo-alt'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15907728187777701)
,p_name=>'P2_TRACE_ID'
,p_item_sequence=>30
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15909226880777716)
,p_name=>'P2_TRANSACTION_ID'
,p_item_sequence=>40
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15909918151777723)
,p_name=>'P2_PERIOD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_item_default=>'H24'
,p_prompt=>'Period'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Last hour;H1,Last 6 hours;H6,Last 24 hours;H24,Last 7 days;D7,Last 30 days;D30,Custom range;RANGE'
,p_cHeight=>1
,p_colspan=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910060742777724)
,p_name=>'P2_INTEGRATION_KEY'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'Integration'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select integration_key d,',
'       integration_key r',
'from oio_owner.oio_v_trace_current',
'group by integration_key',
'order by integration_key'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All Integrations'
,p_cHeight=>1
,p_colspan=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910426865777728)
,p_name=>'P2_OUTCOME'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'Outcome'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Success;SUCCESS,Error;ERROR'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All Outcomes'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_colspan=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910533285777729)
,p_name=>'P2_STATUS'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'Status'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select distinct',
'       current_status d,',
'       current_status r',
'from oio_owner.oio_v_trace_current',
'where current_status is not null',
'order by 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All Statuses'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_colspan=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910617306777730)
,p_name=>'P2_SOURCE_SYSTEM'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'Source'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select distinct',
'       source_system d,',
'       source_system r',
'from oio_owner.oio_v_trace_current',
'where source_system is not null',
'order by 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All Sources'
,p_cHeight=>1
,p_colspan=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910790073777731)
,p_name=>'P2_TARGET_SYSTEM'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'Target'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select distinct',
'       target_system d,',
'       target_system r',
'from oio_owner.oio_v_trace_current',
'where target_system is not null',
'order by 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All Targets'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_colspan=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910816199777732)
,p_name=>'P2_DATE_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'From'
,p_format_mask=>'DD/MM/YYYY'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>12
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15910975081777733)
,p_name=>'P2_DATE_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(15909808352777722)
,p_prompt=>'To'
,p_format_mask=>'DD/MM/YYYY'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>12
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15909080238777714)
,p_name=>'Scroll to Event History'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(15907823231777702)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterrefresh'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15909197577777715)
,p_event_id=>wwv_flow_imp.id(15909080238777714)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'const traceId =',
'    apex.item("P2_TRACE_ID").getValue();',
'',
'const transactionId =',
'    apex.item("P2_TRANSACTION_ID").getValue();',
'',
'if (!traceId) {',
'    return;',
'}',
'',
'const title =',
'    document.querySelector(',
'        "#selected_transaction .t-Region-title"',
'    );',
'',
'if (title) {',
'    title.textContent =',
'        "Transaction: " + transactionId;',
'}',
'',
'const eventHistory =',
'    document.getElementById("event_history");',
'',
'if (eventHistory) {',
'    eventHistory.scrollIntoView({',
'        behavior: "smooth",',
'        block: "start"',
'    });',
'}'))
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15909502149777719)
,p_name=>'Toggle Selected Transaction'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P2_TRACE_ID'
,p_condition_element=>'P2_TRACE_ID'
,p_triggering_condition_type=>'NOT_NULL'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15909677714777720)
,p_event_id=>wwv_flow_imp.id(15909502149777719)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(15909319155777717)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15909791361777721)
,p_event_id=>wwv_flow_imp.id(15909502149777719)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(15909319155777717)
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15910109718777725)
,p_name=>'Refresh Transactions'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P2_PERIOD,P2_INTEGRATION_KEY,P2_OUTCOME,P2_STATUS,P2_SOURCE_SYSTEM,P2_TARGET_SYSTEM'
,p_condition_element=>'P2_PERIOD'
,p_triggering_condition_type=>'NOT_EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15910202374777726)
,p_event_id=>wwv_flow_imp.id(15910109718777725)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(15892641671683399)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15910316979777727)
,p_event_id=>wwv_flow_imp.id(15910109718777725)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.item("P2_TRACE_ID").setValue("");',
'apex.item("P2_TRANSACTION_ID").setValue("");',
'apex.region("event_history").refresh();'))
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15911051763777734)
,p_name=>'Toggle Custom Range'
,p_event_sequence=>40
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P2_PERIOD'
,p_condition_element=>'P2_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15911176389777735)
,p_event_id=>wwv_flow_imp.id(15911051763777734)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P2_DATE_FROM,P2_DATE_TO'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15911443352777738)
,p_event_id=>wwv_flow_imp.id(15911051763777734)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.item("P2_DATE_FROM").setValue("");',
'apex.item("P2_DATE_TO").setValue("");',
'apex.message.clearErrors();'))
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15911387404777737)
,p_event_id=>wwv_flow_imp.id(15911051763777734)
,p_event_result=>'FALSE'
,p_action_sequence=>30
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P2_DATE_FROM,P2_DATE_TO'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15911689855777740)
,p_name=>'Validate Custom Range'
,p_event_sequence=>50
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P2_DATE_FROM,P2_DATE_TO'
,p_condition_element=>'P2_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15911738331777741)
,p_event_id=>wwv_flow_imp.id(15911689855777740)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'Validate and Refresh Range'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.message.clearErrors();',
'',
'const fromValue = apex.item("P2_DATE_FROM").getValue();',
'const toValue   = apex.item("P2_DATE_TO").getValue();',
'',
'if (!fromValue || !toValue) {',
'    return;',
'}',
'',
'const fromDate = apex.date.parse(fromValue, "DD/MM/YYYY");',
'const toDate   = apex.date.parse(toValue, "DD/MM/YYYY");',
'',
'if (toDate < fromDate) {',
'    apex.message.showErrors([{',
'        type: "error",',
'        location: ["inline"],',
'        pageItem: "P2_DATE_TO",',
'        message: "To date must be greater than or equal to From date.",',
'        unsafe: false',
'    }]);',
'    return;',
'}',
'',
'const millisecondsPerDay = 86400000;',
'',
'const days =',
'    Math.floor((toDate - fromDate) / millisecondsPerDay) + 1;',
'',
'if (days > 90) {',
'    apex.message.showErrors([{',
'        type: "error",',
'        location: ["inline"],',
'        pageItem: "P2_DATE_TO",',
'        message: "The custom date range cannot exceed 90 days.",',
'        unsafe: false',
'    }]);',
'    return;',
'}',
'',
'apex.item("P2_TRACE_ID").setValue("");',
'apex.item("P2_TRANSACTION_ID").setValue("");',
'',
'apex.region("event_history").refresh();',
'apex.region("transactions").refresh();'))
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15912199229777745)
,p_name=>'Clear Search Filters'
,p_event_sequence=>60
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(15911818795777742)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15912210331777746)
,p_event_id=>wwv_flow_imp.id(15912199229777745)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.item("P2_PERIOD").setValue("H24");',
'',
'apex.item("P2_INTEGRATION_KEY").setValue("");',
'apex.item("P2_OUTCOME").setValue("");',
'apex.item("P2_STATUS").setValue("");',
'apex.item("P2_SOURCE_SYSTEM").setValue("");',
'apex.item("P2_TARGET_SYSTEM").setValue("");',
'',
'apex.item("P2_DATE_FROM").setValue("");',
'apex.item("P2_DATE_TO").setValue("");',
'',
'apex.item("P2_TRACE_ID").setValue("");',
'apex.item("P2_TRANSACTION_ID").setValue("");',
'',
'apex.message.clearErrors();',
'',
'apex.region("event_history").refresh();',
'apex.region("transactions").refresh();'))
);
wwv_flow_imp.component_end;
end;
/
