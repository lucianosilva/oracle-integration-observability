prompt ============================================================
prompt Oracle Integration Observability - APEX Parsing Schema
prompt ============================================================
prompt Execute as ADMIN, SYS, or an authorized DBA.
prompt ============================================================

set define on
set verify off

define OIO_APEX_USER     = 'OIO_APEX'
define OIO_APEX_PASSWORD = 'Change_This_APEX_Password_#2026'

create user &&OIO_APEX_USER
    identified by "&&OIO_APEX_PASSWORD"
    account unlock;

grant create session
    to &&OIO_APEX_USER;

prompt ============================================================
prompt OIO_APEX created.
prompt
prompt Associate this database user with the target APEX workspace
prompt before importing the application.
prompt ============================================================