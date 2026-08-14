prompt --application/pages/page_00004
begin
--   Manifest
--     PAGE: 00004
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
 p_id=>4
,p_name=>'Technical Operations'
,p_alias=>'TECHNICAL-OPERATIONS'
,p_step_title=>'Technical Operations'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'23'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17674357759037408)
,p_plug_name=>'Dashboard Filters'
,p_title=>'Dashboard Filters'
,p_region_name=>'P4_Dashboard_Filters'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17674817963037413)
,p_plug_name=>'Technical KPIs'
,p_title=>'Technical KPIs'
,p_region_name=>'P4_Technical_KPIs'
,p_region_template_options=>'#DEFAULT#:t-CardsRegion--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2072724515482255512
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P4_PERIOD',
'            when ''H1''  then cast(systimestamp - interval ''1'' hour as timestamp)',
'            when ''H6''  then cast(systimestamp - interval ''6'' hour as timestamp)',
'            when ''H24'' then cast(systimestamp - interval ''24'' hour as timestamp)',
'            when ''D7''  then cast(systimestamp - interval ''7'' day as timestamp)',
'            when ''D30'' then cast(systimestamp - interval ''30'' day as timestamp)',
'            when ''RANGE'' then apex_session_state.get_timestamp(''P4_DATE_FROM'')',
'        end as date_from,',
'        case',
'            when :P4_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
'),',
'filtered as (',
'    select',
'        v.*',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date <  p.date_to',
'      and (',
'       :P4_INTEGRATION_KEY is null',
'       or v.integration_key = :P4_INTEGRATION_KEY',
'    )',
')',
'select',
'    ''Errors'' as title,',
'    to_char(',
'        sum(case when outcome = ''ERROR'' then 1 else 0 end),',
'        ''FM999G999G999''',
'    ) as value,',
'    ''Transactions with errors in the selected period'' as description,',
'    ''u-danger-text'' as value_class,',
'    1 as display_order',
'from filtered',
'union all',
'select',
'    ''Error Rate'',',
'    case',
'        when count(*) = 0 then ''0%''',
'        else',
'            to_char(',
'                100 *',
'                sum(case when outcome = ''ERROR'' then 1 else 0 end)',
'                / count(*),',
'                ''FM990D0''',
'            ) || ''%''',
'    end,',
'    ''Percentage of transactions with errors'',',
'    ''u-danger-text'',',
'    2',
'from filtered',
'union all',
'select',
'    ''Potentially Stuck'',',
'    to_char(',
'        sum(',
'            case',
'                when current_status in (''RECEIVED'', ''IN_PROGRESS'')',
'                 and latest_event_timestamp <',
'                     systimestamp - interval ''30'' minute',
'                then 1',
'                else 0',
'            end',
'        ),',
'        ''FM999G999G999''',
'    ),',
'    ''No event activity for more than 30 minutes'',',
'    ''u-warning-text'',',
'    3',
'from filtered',
'union all',
'select',
'    ''Affected Integrations'',',
'    to_char(',
'        count(',
'            distinct case',
'                when outcome = ''ERROR''',
'                then integration_key',
'            end',
'        ),',
'        ''FM999G999G999''',
'    ),',
'    ''Integrations with errors in the selected period'',',
'    ''u-info-text'',',
'    4',
'from filtered',
'',
'order by display_order'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_CARDS'
,p_ajax_items_to_submit=>'P4_PERIOD,P4_DATE_FROM,P4_DATE_TO,P4_INTEGRATION_KEY'
,p_plug_query_num_rows_type=>'SCROLL'
,p_show_total_row_count=>false
);
wwv_flow_imp_page.create_card(
 p_id=>wwv_flow_imp.id(17674902973037414)
,p_region_id=>wwv_flow_imp.id(17674817963037413)
,p_layout_type=>'GRID'
,p_title_adv_formatting=>false
,p_title_column_name=>'TITLE'
,p_sub_title_adv_formatting=>false
,p_body_adv_formatting=>true
,p_body_html_expr=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<div class="oio-kpi-value &VALUE_CLASS.">',
'    &VALUE.',
'</div>'))
,p_second_body_adv_formatting=>false
,p_second_body_column_name=>'DESCRIPTION'
,p_media_adv_formatting=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17676621730037431)
,p_plug_name=>'Error Trend'
,p_title=>'Error Trend'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(17676745737037432)
,p_region_id=>wwv_flow_imp.id(17676621730037431)
,p_chart_type=>'line'
,p_height=>'400'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_orientation=>'vertical'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_connect_nulls=>'Y'
,p_sorting=>'label-asc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(17676828919037433)
,p_chart_id=>wwv_flow_imp.id(17676745737037432)
,p_seq=>10
,p_name=>'New'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P4_PERIOD',
'            when ''H1''  then cast(systimestamp - interval ''1'' hour as timestamp)',
'            when ''H6''  then cast(systimestamp - interval ''6'' hour as timestamp)',
'            when ''H24'' then cast(systimestamp - interval ''24'' hour as timestamp)',
'            when ''D7''  then cast(systimestamp - interval ''7'' day as timestamp)',
'            when ''D30'' then cast(systimestamp - interval ''30'' day as timestamp)',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_FROM'')',
'        end date_from,',
'',
'        case',
'            when :P4_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end date_to',
'    from dual',
'),',
'base as (',
'    select',
'        cast(v.creation_date as date) creation_date',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date < p.date_to',
'      and v.outcome = ''ERROR''',
'      and (',
'            :P4_INTEGRATION_KEY is null',
'            or v.integration_key = :P4_INTEGRATION_KEY',
'          )',
'),',
'bucketed as (',
'    select',
'        case',
'            when :P4_PERIOD = ''H1'' then',
'                trunc(creation_date,''HH24'')',
'                + floor(to_number(to_char(creation_date,''MI'')) / 5) * 5 / 1440',
'',
'            when :P4_PERIOD = ''H6'' then',
'                trunc(creation_date,''HH24'')',
'                + floor(to_number(to_char(creation_date,''MI'')) / 15) * 15 / 1440',
'',
'            when :P4_PERIOD = ''H24'' then',
'                trunc(creation_date,''HH24'')',
'',
'            when :P4_PERIOD = ''D7'' then',
'                trunc(creation_date)',
'                + floor(to_number(to_char(creation_date,''HH24'')) / 6) * 6 / 24',
'',
'            else',
'                trunc(creation_date)',
'        end time_bucket',
'    from base',
')',
'select',
'    case',
'        when :P4_PERIOD in (''H1'',''H6'') then',
'            to_char(time_bucket,''HH24:MI'')',
'        when :P4_PERIOD in (''H24'',''D7'') then',
'            to_char(time_bucket,''DD/MM HH24:MI'')',
'        else',
'            to_char(time_bucket,''DD/MM/YYYY'')',
'    end as time_label,',
'',
'    count(*) as error_count',
'',
'from bucketed',
'group by time_bucket',
'order by time_bucket'))
,p_ajax_items_to_submit=>'P4_PERIOD,P4_INTEGRATION_KEY,P4_DATE_FROM,P4_DATE_TO'
,p_items_value_column_name=>'ERROR_COUNT'
,p_items_label_column_name=>'TIME_LABEL'
,p_color=>'#c74634'
,p_line_style=>'solid'
,p_line_type=>'auto'
,p_marker_rendered=>'auto'
,p_marker_shape=>'auto'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>false
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17676979356037434)
,p_chart_id=>wwv_flow_imp.id(17676745737037432)
,p_axis=>'x'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_tick_label_rotation=>'auto'
,p_tick_label_position=>'outside'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17677039104037435)
,p_chart_id=>wwv_flow_imp.id(17676745737037432)
,p_axis=>'y'
,p_is_rendered=>'on'
,p_format_type=>'decimal'
,p_decimal_places=>0
,p_format_scaling=>'none'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17677394281037438)
,p_plug_name=>'Top Error Codes'
,p_title=>'Top Error Codes'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(17677488965037439)
,p_region_id=>wwv_flow_imp.id(17677394281037438)
,p_chart_type=>'bar'
,p_height=>'400'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_orientation=>'vertical'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hover_behavior=>'dim'
,p_stack=>'off'
,p_connect_nulls=>'Y'
,p_sorting=>'label-asc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(17677587823037440)
,p_chart_id=>wwv_flow_imp.id(17677488965037439)
,p_seq=>10
,p_name=>'Top Errors'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P4_PERIOD',
'            when ''H1''  then cast(systimestamp - interval ''1'' hour as timestamp)',
'            when ''H6''  then cast(systimestamp - interval ''6'' hour as timestamp)',
'            when ''H24'' then cast(systimestamp - interval ''24'' hour as timestamp)',
'            when ''D7''  then cast(systimestamp - interval ''7'' day as timestamp)',
'            when ''D30'' then cast(systimestamp - interval ''30'' day as timestamp)',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_FROM'')',
'        end date_from,',
'',
'        case',
'            when :P4_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end date_to',
'    from dual',
')',
'select',
'    error_code label,',
'    error_count value',
'from (',
'    select',
'        nvl(v.error_code, ''UNCLASSIFIED'') error_code,',
'        count(*) error_count',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date < p.date_to',
'      and v.outcome = ''ERROR''',
'      and (',
'            :P4_INTEGRATION_KEY is null',
'            or v.integration_key = :P4_INTEGRATION_KEY',
'          )',
'    group by nvl(v.error_code, ''UNCLASSIFIED'')',
'    order by error_count desc',
')',
'fetch first 10 rows only'))
,p_ajax_items_to_submit=>'P4_PERIOD,P4_INTEGRATION_KEY,P4_DATE_FROM,P4_DATE_TO'
,p_items_value_column_name=>'VALUE'
,p_items_label_column_name=>'LABEL'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>false
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17677610084037441)
,p_chart_id=>wwv_flow_imp.id(17677488965037439)
,p_axis=>'x'
,p_is_rendered=>'on'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_tick_label_rotation=>'auto'
,p_tick_label_position=>'outside'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17677732300037442)
,p_chart_id=>wwv_flow_imp.id(17677488965037439)
,p_axis=>'y'
,p_is_rendered=>'on'
,p_format_type=>'decimal'
,p_decimal_places=>0
,p_format_scaling=>'none'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17678226511037447)
,p_plug_name=>'Potentially Stuck Transactions'
,p_title=>'Potentially Stuck Transactions'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P4_PERIOD',
'            when ''H1''  then cast(systimestamp - interval ''1'' hour as timestamp)',
'            when ''H6''  then cast(systimestamp - interval ''6'' hour as timestamp)',
'            when ''H24'' then cast(systimestamp - interval ''24'' hour as timestamp)',
'            when ''D7''  then cast(systimestamp - interval ''7'' day as timestamp)',
'            when ''D30'' then cast(systimestamp - interval ''30'' day as timestamp)',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_FROM'')',
'        end as date_from,',
'',
'        case',
'            when :P4_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
')',
'select',
'    v.trace_id,',
'    v.integration_key,',
'    v.transaction_id1                         as transaction_id,',
'    v.current_status,',
'    case v.current_status',
'      when ''RECEIVED''    then ''info''',
'      when ''IN_PROGRESS'' then ''warning''',
'      when ''COMPLETED''   then ''success''',
'      when ''FAILED''      then ''danger''',
'      else ''normal''',
'    end as badge_state,',
'    v.latest_step_name                        as latest_step,',
'    v.latest_event_timestamp,',
'    round(',
'        (cast(systimestamp as date)',
'         - cast(v.latest_event_timestamp as date)) * 1440',
'    )                                         as idle_minutes,',
'    nvl(',
'        v.latest_oic_instance_id,',
'        v.oic_instance_id',
'    )                                         as oic_instance_id,',
'    v.summary',
'from oio_owner.oio_v_trace_current v',
'cross join period_filter p',
'where v.creation_date >= p.date_from',
'  and v.creation_date <  p.date_to',
'  and (',
'        :P4_INTEGRATION_KEY is null',
'        or v.integration_key = :P4_INTEGRATION_KEY',
'      )',
'  and v.current_status in (''RECEIVED'', ''IN_PROGRESS'')',
'  and v.latest_event_timestamp is not null',
'  and v.latest_event_timestamp <',
'      cast(systimestamp - interval ''30'' minute as timestamp)',
'order by v.latest_event_timestamp'))
,p_plug_source_type=>'NATIVE_IR'
,p_ajax_items_to_submit=>'P4_PERIOD,P4_INTEGRATION_KEY,P4_DATE_FROM,P4_DATE_TO'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header=>'Potentially Stuck Transactions'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(17678318240037448)
,p_alias=>'STUCK'
,p_max_row_count=>'1000000'
,p_max_rows_per_page=>'15'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_rows_per_page=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:XLSX'
,p_enable_mail_download=>'Y'
,p_owner=>'OIO_APEX'
,p_internal_uid=>17678318240037448
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(17678446795037449)
,p_db_column_name=>'TRACE_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Trace Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(17678552697037450)
,p_db_column_name=>'INTEGRATION_KEY'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Integration'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18094451533790501)
,p_db_column_name=>'TRANSACTION_ID'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Transaction Id'
,p_column_link=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:2:P2_TRACE_ID,P2_TRANSACTION_ID:#TRACE_ID#,#TRANSACTION_ID#'
,p_column_linktext=>'#TRANSACTION_ID#'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18094526889790502)
,p_db_column_name=>'CURRENT_STATUS'
,p_display_order=>40
,p_column_identifier=>'D'
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
  'STATE', 'BADGE_STATE',
  'VALUE', 'CURRENT_STATUS')).to_clob
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18094657746790503)
,p_db_column_name=>'LATEST_STEP'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Latest Step'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18094708474790504)
,p_db_column_name=>'LATEST_EVENT_TIMESTAMP'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Latest Event Timestamp'
,p_column_type=>'DATE'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_tz_dependent=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18094898833790505)
,p_db_column_name=>'IDLE_MINUTES'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Idle Minutes'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18094924939790506)
,p_db_column_name=>'OIC_INSTANCE_ID'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Oic Instance Id'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095059762790507)
,p_db_column_name=>'SUMMARY'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Summary'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18096763884790524)
,p_db_column_name=>'BADGE_STATE'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Badge State'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(18102960787802806)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'181030'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TRACE_ID:INTEGRATION_KEY:TRANSACTION_ID:CURRENT_STATUS:LATEST_STEP:LATEST_EVENT_TIMESTAMP:IDLE_MINUTES:OIC_INSTANCE_ID:SUMMARY'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17871063539991642)
,p_plug_name=>'Technical Operations'
,p_title=>'Technical Operations'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_menu_id=>wwv_flow_imp.id(15878391117683269)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(18095153661790508)
,p_plug_name=>'Recent Error Events'
,p_title=>'Recent Error Events'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P4_PERIOD',
'            when ''H1''  then cast(systimestamp - interval ''1'' hour as timestamp)',
'            when ''H6''  then cast(systimestamp - interval ''6'' hour as timestamp)',
'            when ''H24'' then cast(systimestamp - interval ''24'' hour as timestamp)',
'            when ''D7''  then cast(systimestamp - interval ''7'' day as timestamp)',
'            when ''D30'' then cast(systimestamp - interval ''30'' day as timestamp)',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_FROM'')',
'        end as date_from,',
'',
'        case',
'            when :P4_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P4_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
')',
'select',
'    h.trace_id,',
'    h.event_timestamp,',
'    h.integration_key,',
'    h.transaction_id1                 as transaction_id,',
'    h.event_type,',
'    h.step_name,',
'    h.history_status                  as event_status,',
'    case h.history_status',
'    when ''COMPLETED''   then ''success''',
'    when ''FAILED''      then ''danger''',
'    when ''IN_PROGRESS'' then ''warning''',
'    when ''RECEIVED''    then ''info''',
'    else ''normal''',
'end as badge_state,',
'    h.oic_instance_id,',
'    h.error_code,',
'    h.error_message,',
'    h.summary',
'from oio_owner.oio_v_trace_status_history h',
'cross join period_filter p',
'where h.event_timestamp >= p.date_from',
'  and h.event_timestamp <  p.date_to',
'  and h.log_level = ''E''',
'  and (',
'        :P4_INTEGRATION_KEY is null',
'        or h.integration_key = :P4_INTEGRATION_KEY',
'      )',
'order by',
'    h.event_timestamp desc,',
'    h.trace_detail_id desc'))
,p_plug_source_type=>'NATIVE_IR'
,p_ajax_items_to_submit=>'P4_PERIOD,P4_INTEGRATION_KEY,P4_DATE_FROM,P4_DATE_TO'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'INCHES'
,p_prn_paper_size=>'LETTER'
,p_prn_width=>11
,p_prn_height=>8.5
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header=>'Recent Error Events'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(18095247975790509)
,p_max_row_count=>'1000000'
,p_max_rows_per_page=>'15'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_rows_per_page=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:XLSX'
,p_enable_mail_download=>'N'
,p_owner=>'OIO_APEX'
,p_internal_uid=>18095247975790509
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095305345790510)
,p_db_column_name=>'TRACE_ID'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Trace Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095405227790511)
,p_db_column_name=>'EVENT_TIMESTAMP'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Timestamp'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY HH24:MI:SS'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095535904790512)
,p_db_column_name=>'INTEGRATION_KEY'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Integration'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095659233790513)
,p_db_column_name=>'TRANSACTION_ID'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Transaction ID'
,p_column_link=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.:2:P2_TRACE_ID,P2_TRANSACTION_ID:#TRACE_ID#,#TRANSACTION_ID#'
,p_column_linktext=>'#TRANSACTION_ID#'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095761203790514)
,p_db_column_name=>'EVENT_TYPE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Event'
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
  'LABEL', 'Event',
  'LABEL_DISPLAY', 'N',
  'STATE', 'BADGE_STATE',
  'VALUE', 'EVENT_STATUS')).to_clob
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095871004790515)
,p_db_column_name=>'STEP_NAME'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Step'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18095997227790516)
,p_db_column_name=>'EVENT_STATUS'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Status'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18096042470790517)
,p_db_column_name=>'OIC_INSTANCE_ID'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'OIC Instance'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18096142716790518)
,p_db_column_name=>'ERROR_CODE'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Error Code'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18096208779790519)
,p_db_column_name=>'ERROR_MESSAGE'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Error Message'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18096393443790520)
,p_db_column_name=>'SUMMARY'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Summary'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(18096818978790525)
,p_db_column_name=>'BADGE_STATE'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Badge State'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(18107522925852401)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'181076'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'TRACE_ID:EVENT_TIMESTAMP:INTEGRATION_KEY:TRANSACTION_ID:EVENT_TYPE:STEP_NAME:EVENT_STATUS:OIC_INSTANCE_ID:ERROR_CODE:ERROR_MESSAGE:SUMMARY'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(17676156162037426)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(17674357759037408)
,p_button_name=>'P4_BUTTON_APPLY'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Apply Filter'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'N'
,p_grid_new_column=>'Y'
,p_grid_column_span=>2
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17674477209037409)
,p_name=>'P4_PERIOD'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(17674357759037408)
,p_item_default=>'H24'
,p_prompt=>'Period'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Last hour;H1,Last 6 hours;H6,Last 24 hours;H24,Last 7 days;D7,Last 30 days;D30,Custom range;RANGE'
,p_cHeight=>1
,p_colspan=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17674558230037410)
,p_name=>'P4_INTEGRATION_KEY'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(17674357759037408)
,p_prompt=>'Integration'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    integration_key d,',
'    integration_key r',
'from oio_owner.oio_integration_cfg',
'where active_flag = ''Y''',
'AND ( integration_key IS NOT NULL AND integration_key IS NOT NULL)',
'order by integration_key'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'All integrations'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_colspan=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17674658206037411)
,p_name=>'P4_DATE_FROM'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(17674357759037408)
,p_prompt=>'From'
,p_format_mask=>'DD/MM/YYYY'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>15
,p_colspan=>2
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
 p_id=>wwv_flow_imp.id(17674752345037412)
,p_name=>'P4_DATE_TO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(17674357759037408)
,p_prompt=>'To'
,p_format_mask=>'DD/MM/YYYY'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>15
,p_begin_on_new_line=>'N'
,p_colspan=>2
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
 p_id=>wwv_flow_imp.id(17675275040037417)
,p_name=>'Toggle Custom Range'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P4_PERIOD'
,p_condition_element=>'P4_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17675388234037418)
,p_event_id=>wwv_flow_imp.id(17675275040037417)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_name=>'Show Range Fields'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P4_DATE_FROM,P4_DATE_TO'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17675733902037422)
,p_event_id=>wwv_flow_imp.id(17675275040037417)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_name=>'Hide Range Fields'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P4_DATE_FROM,P4_DATE_TO'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17676252790037427)
,p_event_id=>wwv_flow_imp.id(17675275040037417)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_name=>'Show Button'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'BUTTON'
,p_affected_button_id=>wwv_flow_imp.id(17676156162037426)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17676393263037428)
,p_event_id=>wwv_flow_imp.id(17675275040037417)
,p_event_result=>'FALSE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_name=>'Hide Button'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'BUTTON'
,p_affected_button_id=>wwv_flow_imp.id(17676156162037426)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17677239319037437)
,p_event_id=>wwv_flow_imp.id(17675275040037417)
,p_event_result=>'FALSE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_name=>'Clear Range Date'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.item("P4_DATE_FROM").setValue("");',
'apex.item("P4_DATE_TO").setValue("");'))
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(17888633950271099)
,p_name=>'Validate Custom Range'
,p_event_sequence=>40
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P4_DATE_FROM,P4_DATE_TO,P4_PERIOD'
,p_condition_element=>'P4_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17889092991271100)
,p_event_id=>wwv_flow_imp.id(17888633950271099)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'Validate and Refresh Range'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.message.clearErrors();',
'',
'const fromValue = apex.item("P4_DATE_FROM").getValue();',
'const toValue   = apex.item("P4_DATE_TO").getValue();',
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
'        pageItem: "P4_DATE_TO",',
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
'        pageItem: "P4_DATE_TO",',
'        message: "The custom date range cannot exceed 90 days.",',
'        unsafe: false',
'    }]);',
'    return;',
'}',
'',
'apex.region("Dashboard_KPIs").refresh();',
'apex.region("Dashboard_Donuts").refresh();',
'apex.region("Transaction_Volume").refresh();',
'apex.region("Top_Integrations").refresh();'))
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(17675831129037423)
,p_name=>'Refresh Dashboards'
,p_event_sequence=>50
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P4_PERIOD,P4_DATE_FROM,P4_DATE_TO,P4_INTEGRATION_KEY'
,p_condition_element=>'P4_PERIOD'
,p_triggering_condition_type=>'NOT_EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17675993729037424)
,p_event_id=>wwv_flow_imp.id(17675831129037423)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Tech KPIs'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17674817963037413)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17677123078037436)
,p_event_id=>wwv_flow_imp.id(17675831129037423)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Error Trend'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17676621730037431)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17677824764037443)
,p_event_id=>wwv_flow_imp.id(17675831129037423)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Top Errors'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17677394281037438)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(18096592674790522)
,p_event_id=>wwv_flow_imp.id(17675831129037423)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Stuck Transactions'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17678226511037447)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(18096644961790523)
,p_event_id=>wwv_flow_imp.id(17675831129037423)
,p_event_result=>'TRUE'
,p_action_sequence=>50
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Error Events'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(18095153661790508)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(17676421156037429)
,p_name=>'ClickApplyFilter'
,p_event_sequence=>60
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(17676156162037426)
,p_condition_element=>'P4_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17676587747037430)
,p_event_id=>wwv_flow_imp.id(17676421156037429)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17674817963037413)
,p_attribute_01=>'N'
);
wwv_flow_imp.component_end;
end;
/
