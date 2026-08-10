prompt --application/shared_components/navigation/lists/page_navigation
begin
--   Manifest
--     LIST: Page Navigation
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
 p_id=>wwv_flow_imp.id(15900604050683440)
,p_name=>'Page Navigation'
,p_list_status=>'PUBLIC'
,p_version_scn=>47039289585382
);
wwv_flow_imp_shared.create_list_item(
 p_id=>wwv_flow_imp.id(15901089053683441)
,p_list_item_display_sequence=>20
,p_list_item_link_text=>'Interactive Report'
,p_list_item_link_target=>'f?p=&APP_ID.:2:&APP_SESSION.::&DEBUG.:::'
,p_list_item_icon=>'fa-table'
,p_list_item_current_type=>'TARGET_PAGE'
);
wwv_flow_imp.component_end;
end;
/
