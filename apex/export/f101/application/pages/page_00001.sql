prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'Monitoring Dashboard'
,p_alias=>'MONITOR'
,p_step_title=>'Monitoring Dashboard'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'13'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15891329538683391)
,p_plug_name=>'Monitoring Dashboard'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2674017834225413037
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_location=>null
,p_plug_query_num_rows=>15
,p_region_image=>'#APP_FILES#icons/app-icon-512.png'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17088226424380920)
,p_plug_name=>'Dashboard Filters'
,p_title=>'Dashboard Filters'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17088888274380926)
,p_plug_name=>'Dashboard KPIs'
,p_title=>'Dashboard KPIs'
,p_region_name=>'Dashboard_KPIs'
,p_region_template_options=>'#DEFAULT#:t-CardsRegion--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2072724515482255512
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P1_PERIOD',
'            when ''H1'' then',
'                cast(systimestamp - interval ''1'' hour as timestamp)',
'',
'            when ''H6'' then',
'                cast(systimestamp - interval ''6'' hour as timestamp)',
'',
'            when ''H24'' then',
'                cast(systimestamp - interval ''24'' hour as timestamp)',
'',
'            when ''D7'' then',
'                cast(systimestamp - interval ''7'' day as timestamp)',
'',
'            when ''D30'' then',
'                cast(systimestamp - interval ''30'' day as timestamp)',
'',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_FROM'')',
'        end as date_from,',
'',
'        case',
'            when :P1_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
'),',
'filtered as (',
'    select',
'        v.outcome,',
'        v.current_status',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date <  p.date_to',
')',
'select',
'    ''Transactions'' as title,',
'    to_char(count(*), ''FM999G999G999'') as value,',
'    ''Total transactions in the selected period'' as description,',
'    ''u-info-text'' as value_class,',
'    1 as display_order',
'from filtered',
'',
'union all',
'',
'select',
'    ''Errors'',',
'    to_char(',
'        sum(case when outcome = ''ERROR'' then 1 else 0 end),',
'        ''FM999G999G999''',
'    ),',
'    ''Transactions with errors in the selected period'',',
'    ''u-danger-text'',',
'    2',
'from filtered',
'',
'union all',
'',
'select',
'    ''Success Rate'',',
'    case',
'        when count(*) = 0 then ''0%''',
'        else',
'            to_char(',
'                100 *',
'                sum(case when outcome = ''SUCCESS'' then 1 else 0 end)',
'                / count(*),',
'                ''FM990D0''',
'            ) || ''%''',
'    end,',
'    ''Successful transactions in the selected period'',',
'    ''u-success-text'',',
'    3',
'from filtered',
'',
'order by display_order'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_CARDS'
,p_ajax_items_to_submit=>'P1_PERIOD,P1_DATE_FROM,P1_DATE_TO'
,p_plug_query_num_rows_type=>'SCROLL'
,p_show_total_row_count=>false
);
wwv_flow_imp_page.create_card(
 p_id=>wwv_flow_imp.id(17088909451380927)
,p_region_id=>wwv_flow_imp.id(17088888274380926)
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
 p_id=>wwv_flow_imp.id(17089689076380934)
,p_plug_name=>'Dashboard Donuts'
,p_title=>'Success vs Error'
,p_region_name=>'Dashboard_Donuts'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(17089792426380935)
,p_region_id=>wwv_flow_imp.id(17089689076380934)
,p_chart_type=>'donut'
,p_height=>'400'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hide_and_show_behavior=>'withRescale'
,p_hover_behavior=>'dim'
,p_value_format_type=>'decimal'
,p_value_decimal_places=>0
,p_value_format_scaling=>'none'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_value=>true
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
,p_pie_other_threshold=>0
,p_pie_selection_effect=>'highlight'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(17089889578380936)
,p_chart_id=>wwv_flow_imp.id(17089792426380935)
,p_seq=>10
,p_name=>'Serie1'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P1_PERIOD',
'            when ''H1''  then cast(systimestamp - interval ''1'' hour  as timestamp)',
'            when ''H6''  then cast(systimestamp - interval ''6'' hour  as timestamp)',
'            when ''H24'' then cast(systimestamp - interval ''24'' hour as timestamp)',
'            when ''D7''  then cast(systimestamp - interval ''7'' day   as timestamp)',
'            when ''D30'' then cast(systimestamp - interval ''30'' day  as timestamp)',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_FROM'')',
'        end as date_from,',
'',
'        case',
'            when :P1_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
'),',
'counts as (',
'    select',
'        v.outcome,',
'        count(*) as total',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date < p.date_to',
'    group by v.outcome',
')',
'select',
'    initcap(lower(outcome))',
'        || '' - ''',
'        || to_char(total, ''FM999G999G999'')',
'        || '' (''',
'        || to_char(',
'            100 * ratio_to_report(total) over (),',
'            ''FM990D0''',
'        )',
'        || ''%)'' as label,',
'',
'    total as value,',
'',
'    case outcome',
'        when ''ERROR''   then ''#C74634''',
'        when ''SUCCESS'' then ''#3A7D44''',
'        else ''#6B7785''',
'    end as color',
'',
'from counts',
'order by outcome'))
,p_ajax_items_to_submit=>'P1_PERIOD,P1_DATE_FROM,P1_DATE_TO'
,p_items_value_column_name=>'VALUE'
,p_items_label_column_name=>'LABEL'
,p_color=>'&COLOR.'
,p_items_label_rendered=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(17090153546380939)
,p_plug_name=>'Transaction Volume'
,p_title=>'Transaction Volume'
,p_region_name=>'Transaction_Volume'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_plug_new_grid_row=>false
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(17090222853380940)
,p_region_id=>wwv_flow_imp.id(17090153546380939)
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
 p_id=>wwv_flow_imp.id(17090384081380941)
,p_chart_id=>wwv_flow_imp.id(17090222853380940)
,p_seq=>10
,p_name=>'Transaction Volume'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P1_PERIOD',
'            when ''H1'' then',
'                cast(systimestamp - interval ''1'' hour as timestamp)',
'',
'            when ''H6'' then',
'                cast(systimestamp - interval ''6'' hour as timestamp)',
'',
'            when ''H24'' then',
'                cast(systimestamp - interval ''24'' hour as timestamp)',
'',
'            when ''D7'' then',
'                cast(systimestamp - interval ''7'' day as timestamp)',
'',
'            when ''D30'' then',
'                cast(systimestamp - interval ''30'' day as timestamp)',
'',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_FROM'')',
'        end as date_from,',
'',
'        case',
'            when :P1_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
'),',
'base as (',
'    select',
'        cast(v.creation_date as date) as creation_date',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date <  p.date_to',
'),',
'bucketed as (',
'    select',
'        case',
'            -- Last hour: 5-minute buckets',
'            when :P1_PERIOD = ''H1'' then',
'                trunc(creation_date, ''HH24'')',
'                + floor(',
'                    to_number(to_char(creation_date, ''MI'')) / 5',
'                  ) * 5 / 1440',
'',
'            -- Last 6 hours: 15-minute buckets',
'            when :P1_PERIOD = ''H6'' then',
'                trunc(creation_date, ''HH24'')',
'                + floor(',
'                    to_number(to_char(creation_date, ''MI'')) / 15',
'                  ) * 15 / 1440',
'',
'            -- Last 24 hours: hourly',
'            when :P1_PERIOD = ''H24'' then',
'                trunc(creation_date, ''HH24'')',
'',
'            -- Last 7 days: 6-hour buckets',
'            when :P1_PERIOD = ''D7'' then',
'                trunc(creation_date)',
'                + floor(',
'                    to_number(to_char(creation_date, ''HH24'')) / 6',
'                  ) * 6 / 24',
'',
'            -- Last 30 days / Custom range: daily',
'            else',
'                trunc(creation_date)',
'        end as time_bucket',
'    from base',
')',
'select',
'    time_bucket,',
'',
'    case',
'        when :P1_PERIOD in (''H1'', ''H6'') then',
'            to_char(time_bucket, ''HH24:MI'')',
'',
'        when :P1_PERIOD in (''H24'', ''D7'') then',
'            to_char(time_bucket, ''DD/MM HH24:MI'')',
'',
'        when :P1_PERIOD in (''D30'', ''RANGE'') then',
'            to_char(time_bucket, ''DD/MM/YYYY'')',
'',
'        else',
'            to_char(time_bucket, ''DD/MM/YYYY HH24:MI'')',
'    end as time_label,',
'',
'    count(*) as transaction_count',
'',
'from bucketed',
'group by time_bucket',
'order by time_bucket'))
,p_ajax_items_to_submit=>'P1_PERIOD,P1_DATE_FROM,P1_DATE_TO'
,p_items_value_column_name=>'TRANSACTION_COUNT'
,p_items_label_column_name=>'TIME_LABEL'
,p_line_style=>'solid'
,p_line_type=>'curved'
,p_marker_rendered=>'auto'
,p_marker_shape=>'auto'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>false
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17090649772380944)
,p_chart_id=>wwv_flow_imp.id(17090222853380940)
,p_axis=>'y2'
,p_is_rendered=>'off'
,p_format_scaling=>'auto'
,p_scaling=>'linear'
,p_baseline_scaling=>'zero'
,p_position=>'auto'
,p_major_tick_rendered=>'on'
,p_minor_tick_rendered=>'off'
,p_tick_label_rendered=>'on'
,p_split_dual_y=>'auto'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17090465319380942)
,p_chart_id=>wwv_flow_imp.id(17090222853380940)
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
 p_id=>wwv_flow_imp.id(17090567316380943)
,p_chart_id=>wwv_flow_imp.id(17090222853380940)
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
 p_id=>wwv_flow_imp.id(17090733919380945)
,p_plug_name=>'Top Integrations by Error'
,p_region_name=>'Top_Integrations'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>80
,p_location=>null
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(17090875938380946)
,p_region_id=>wwv_flow_imp.id(17090733919380945)
,p_chart_type=>'bar'
,p_height=>'400'
,p_animation_on_display=>'auto'
,p_animation_on_data_change=>'auto'
,p_orientation=>'vertical'
,p_data_cursor=>'auto'
,p_data_cursor_behavior=>'auto'
,p_hover_behavior=>'dim'
,p_stack=>'on'
,p_stack_label=>'on'
,p_connect_nulls=>'Y'
,p_sorting=>'value-desc'
,p_fill_multi_series_gaps=>true
,p_zoom_and_scroll=>'off'
,p_tooltip_rendered=>'Y'
,p_show_series_name=>true
,p_show_group_name=>true
,p_show_value=>true
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(17090900488380947)
,p_chart_id=>wwv_flow_imp.id(17090875938380946)
,p_seq=>10
,p_name=>'New'
,p_data_source_type=>'SQL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'with period_filter as (',
'    select',
'        case :P1_PERIOD',
'            when ''H1'' then',
'                cast(systimestamp - interval ''1'' hour as timestamp)',
'',
'            when ''H6'' then',
'                cast(systimestamp - interval ''6'' hour as timestamp)',
'',
'            when ''H24'' then',
'                cast(systimestamp - interval ''24'' hour as timestamp)',
'',
'            when ''D7'' then',
'                cast(systimestamp - interval ''7'' day as timestamp)',
'',
'            when ''D30'' then',
'                cast(systimestamp - interval ''30'' day as timestamp)',
'',
'            when ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_FROM'')',
'        end as date_from,',
'',
'        case',
'            when :P1_PERIOD = ''RANGE'' then',
'                apex_session_state.get_timestamp(''P1_DATE_TO'')',
'                    + interval ''1'' day',
'            else',
'                cast(systimestamp as timestamp)',
'        end as date_to',
'    from dual',
'),',
'errors_by_integration as (',
'    select',
'        v.integration_key,',
'        count(*) as error_count',
'    from oio_owner.oio_v_trace_current v',
'    cross join period_filter p',
'    where v.creation_date >= p.date_from',
'      and v.creation_date <  p.date_to',
'      and v.outcome = ''ERROR''',
'    group by v.integration_key',
')',
'select',
'    integration_key as label,',
'    error_count     as value',
'from (',
'    select',
'        integration_key,',
'        error_count',
'    from errors_by_integration',
'    order by error_count desc',
')',
'fetch first 10 rows only'))
,p_ajax_items_to_submit=>'P1_PERIOD,P1_DATE_FROM,P1_DATE_TO'
,p_items_value_column_name=>'VALUE'
,p_items_label_column_name=>'LABEL'
,p_color=>'#c74634'
,p_assigned_to_y2=>'off'
,p_items_label_rendered=>false
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(17091001546380948)
,p_chart_id=>wwv_flow_imp.id(17090875938380946)
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
 p_id=>wwv_flow_imp.id(17091113530380949)
,p_chart_id=>wwv_flow_imp.id(17090875938380946)
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17088351016380921)
,p_name=>'P1_PERIOD'
,p_is_required=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(17088226424380920)
,p_item_default=>'H24'
,p_prompt=>'Period'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Last hour;H1,Last 6 hours;H6,Last 24 hours;H24,Last 7 days;D7,Last 30 days;D30,Custom range;RANGE'
,p_cHeight=>1
,p_colspan=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17088442756380922)
,p_name=>'P1_DATE_FROM'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(17088226424380920)
,p_prompt=>'From'
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
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(17088576014380923)
,p_name=>'P1_DATE_TO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(17088226424380920)
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
 p_id=>wwv_flow_imp.id(17089097093380928)
,p_name=>'Toggle Custom Range'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P1_PERIOD'
,p_condition_element=>'P1_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17089181369380929)
,p_event_id=>wwv_flow_imp.id(17089097093380928)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_name=>'Show Range Fields'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P1_DATE_FROM,P1_DATE_TO'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17089200728380930)
,p_event_id=>wwv_flow_imp.id(17089097093380928)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.item("P1_DATE_FROM").setValue("");',
'apex.item("P1_DATE_TO").setValue("");',
'apex.message.clearErrors();'))
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17089347427380931)
,p_event_id=>wwv_flow_imp.id(17089097093380928)
,p_event_result=>'FALSE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_name=>'Hide Range Fields'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P1_DATE_FROM,P1_DATE_TO'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(17089423237380932)
,p_name=>'Refresh Transactions'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P1_DATE_FROM,P1_DATE_TO,P1_PERIOD'
,p_condition_element=>'P1_PERIOD'
,p_triggering_condition_type=>'NOT_EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17089507125380933)
,p_event_id=>wwv_flow_imp.id(17089423237380932)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'Refresh KPIs'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17088888274380926)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17674087489037405)
,p_event_id=>wwv_flow_imp.id(17089423237380932)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Donuts'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17089689076380934)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17674184610037406)
,p_event_id=>wwv_flow_imp.id(17089423237380932)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Transactions Donuts'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17090153546380939)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17674278189037407)
,p_event_id=>wwv_flow_imp.id(17089423237380932)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_name=>'Refresh Top Errors'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(17090733919380945)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(17673873131037403)
,p_name=>'Validate Custom Range'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P1_DATE_FROM,P1_DATE_TO'
,p_condition_element=>'P1_PERIOD'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'RANGE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(17673985683037404)
,p_event_id=>wwv_flow_imp.id(17673873131037403)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'Validate and Refresh Range'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex.message.clearErrors();',
'',
'const fromValue = apex.item("P1_DATE_FROM").getValue();',
'const toValue   = apex.item("P1_DATE_TO").getValue();',
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
'        pageItem: "P1_DATE_TO",',
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
'        pageItem: "P1_DATE_TO",',
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
wwv_flow_imp.component_end;
end;
/
