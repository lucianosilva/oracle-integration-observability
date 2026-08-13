prompt --application/shared_components/navigation/lists/navigation_menu
begin
--   Manifest
--     LIST: Navigation Menu
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.16'
,p_default_workspace_id=>15869608976564234
,p_default_application_id=>101
,p_default_id_offset=>0
,p_default_owner=>'OIO_APEX'
);
wwv_flow_imp_shared.create_list(
 p_id=>wwv_flow_imp.id(15878862362683273)
,p_name=>'Navigation Menu'
,p_list_status=>'PUBLIC'
,p_version_scn=>47039727259092
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(15890456339683385)
,p_list_item_display_sequence=>10
,p_list_item_link_text=>'Monitoring Dashboard'
,p_list_item_link_target=>'f?p=&APP_ID.:1:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-dashboard'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(15891925987683394)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Transaction Search'
,p_list_item_link_target=>'f?p=&APP_ID.:2:&SESSION.::&DEBUG.::::'
,p_list_item_icon=>'fa-search'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(17870668018991630)
,p_list_item_display_sequence=>30
,p_list_item_link_text=>'Technical Operations'
,p_list_item_link_target=>'f?p=&APP_ID.:4:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-wrench'
,p_list_item_current_type=>'COLON_DELIMITED_PAGE_LIST'
,p_list_item_current_for_pages=>'4'
);
wwv_flow_imp.component_end;
end;
/
