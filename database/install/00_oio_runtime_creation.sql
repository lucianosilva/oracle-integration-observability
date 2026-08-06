prompt ============================================================
prompt Oracle Integration Observability (OIO) - Runtime Privileges
prompt ============================================================
prompt Execute as ADMIN, SYS, or an authorized DBA.
prompt The OIO_RUNTIME user must already exist.
prompt ============================================================

whenever sqlerror exit sql.sqlcode rollback

set define on
set verify off

define OIO_RUNTIME_USER = 'OIO_RUNTIME'
define OIO_OWNER = 'OIO_OWNER'

grant create session to &&OIO_RUNTIME_USER;

grant execute on &&OIO_OWNER..OIO_TRACE_API
    to &&OIO_RUNTIME_USER;

prompt Required runtime privileges were granted successfully.

set verify on