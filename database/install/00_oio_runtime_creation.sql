prompt ============================================================
prompt Oracle Integration Observability (OIO) - Runtime User Creation
prompt ============================================================
prompt Execute as ADMIN, SYS, or an authorized DBA after OIO_OWNER
prompt and OIO_OWNER.OIO_TRACE_API have been created successfully.
prompt
prompt OIO_RUNTIME is intended for the Oracle Integration Database
prompt Adapter runtime connection.
prompt
prompt Security model:
prompt   - CREATE SESSION only
prompt   - EXECUTE on OIO_OWNER.OIO_TRACE_API only
prompt   - No direct SELECT/INSERT/UPDATE/DELETE on OIO tables or views
prompt   - No CREATE SYNONYM privilege is required
prompt
prompt Review the constants below before execution.
prompt ============================================================

whenever sqlerror exit sql.sqlcode rollback

set define on
set verify off

define OIO_RUNTIME_USER     = 'OIO_RUNTIME'
define OIO_RUNTIME_PASSWORD = 'Change_This_Runtime_Password_#2026'
define OIO_OWNER            = 'OIO_OWNER'

prompt
prompt ============================================================
prompt Configuration constants
prompt ============================================================
prompt OIO_RUNTIME_USER = &&OIO_RUNTIME_USER
prompt OIO_OWNER        = &&OIO_OWNER
prompt
prompt Password is defined in OIO_RUNTIME_PASSWORD and must be changed
prompt before executing this script in a customer environment.
prompt ============================================================

prompt
prompt Creating runtime user &&OIO_RUNTIME_USER ...
prompt

create user &&OIO_RUNTIME_USER
    identified by "&&OIO_RUNTIME_PASSWORD"
    account unlock;

prompt
prompt Granting minimum runtime privileges ...
prompt

grant create session
    to &&OIO_RUNTIME_USER;

grant execute on &&OIO_OWNER..OIO_TRACE_API
    to &&OIO_RUNTIME_USER;

prompt
prompt ============================================================
prompt Runtime user created successfully.
prompt ============================================================
prompt User: &&OIO_RUNTIME_USER
prompt
prompt Granted:
prompt   - CREATE SESSION
prompt   - EXECUTE on &&OIO_OWNER..OIO_TRACE_API
prompt
prompt Not granted:
prompt   - Direct access to OIO tables or views
prompt   - CREATE SYNONYM
prompt   - CREATE TABLE / VIEW / PROCEDURE / SEQUENCE / TRIGGER
prompt
prompt The Oracle Integration Database Adapter should invoke the public
prompt procedures exposed by &&OIO_OWNER..OIO_TRACE_API.
prompt ============================================================

set verify on
