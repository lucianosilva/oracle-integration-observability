prompt ============================================================
prompt Oracle Integration Observability (OIO) - Optional Runtime User
prompt ============================================================
prompt Execute as a DBA after the OIO_OWNER schema and OIO_TRACE_API
prompt package have been created successfully.
prompt OIO_RUNTIME is the OIC database connection user. It has no direct
prompt access to OIO tables, views, sequences, or other database objects.
prompt ============================================================

set define on
set verify off

define OIO_RUNTIME_USER = 'OIO_RUNTIME'
define OIO_RUNTIME_PASSWORD = 'Change_This_Runtime_Password_#2026'
define OIO_OWNER = 'OIO_OWNER'

create user &&OIO_RUNTIME_USER
    identified by "&&OIO_RUNTIME_PASSWORD"
    account unlock;

grant create session to &&OIO_RUNTIME_USER;
grant execute on &&OIO_OWNER..OIO_TRACE_API to &&OIO_RUNTIME_USER;

prompt OIO_RUNTIME was created with CREATE SESSION and EXECUTE only.
prompt No direct table access has been granted.

set verify on


