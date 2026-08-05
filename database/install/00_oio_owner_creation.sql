prompt ============================================================
prompt Oracle Integration Observability (OIO) - Schema/User Creation
prompt ============================================================
prompt Execute this script as a DBA or privileged administrator user
prompt connected to the target PDB where the asset will be installed.
prompt
prompt This script creates the application schema and grants only the
prompt privileges required to install and own the Traceability objects.
prompt
prompt Review the constants below before execution.
prompt ============================================================

set define on
set verify off

define TRACE_SCHEMA = 'OIO_OWNER'
define TRACE_PASSWORD = 'Change_This_Password_#2026'
define TRACE_TABLESPACE_PREFIX = 'OIO_OWNER'
define TRACE_DEFAULT_TABLESPACE = 'DATA'
define TRACE_TEMP_TABLESPACE = 'TEMP'
define TRACE_QUOTA = '2G'

prompt ============================================================
prompt Configuration constants
prompt ============================================================
prompt TRACE_SCHEMA             = &&TRACE_SCHEMA
prompt TRACE_DEFAULT_TABLESPACE = &&TRACE_DEFAULT_TABLESPACE
prompt TRACE_TEMP_TABLESPACE    = &&TRACE_TEMP_TABLESPACE
prompt TRACE_QUOTA              = &&TRACE_QUOTA
prompt
prompt Password is defined in TRACE_PASSWORD and should be changed by the DBA
prompt before executing this script in a customer environment.
prompt ============================================================

prompt
prompt Creating schema &&TRACE_SCHEMA ...
prompt

create user &&TRACE_SCHEMA
    identified by "&&TRACE_PASSWORD"
    default tablespace &&TRACE_DEFAULT_TABLESPACE
    temporary tablespace &&TRACE_TEMP_TABLESPACE
    quota &&TRACE_QUOTA on &&TRACE_DEFAULT_TABLESPACE
    account unlock;

prompt
prompt Granting minimum object owner privileges ...
prompt

grant create session to &&TRACE_SCHEMA;
grant create table to &&TRACE_SCHEMA;
grant create view to &&TRACE_SCHEMA;
grant create procedure to &&TRACE_SCHEMA;
grant create sequence to &&TRACE_SCHEMA;
grant create trigger to &&TRACE_SCHEMA;

prompt
prompt Optional privileges for future asset extensions.
prompt Review with the customer DBA before enabling.
prompt
prompt -- grant create type to &&TRACE_SCHEMA;
prompt -- grant create job to &&TRACE_SCHEMA;
prompt -- grant create synonym to &&TRACE_SCHEMA;

prompt
prompt Optional APEX_JSON grant note.
prompt oio_trace_api uses APEX_JSON for JSON payload parsing. In most APEX
prompt installations APEX_JSON is available through a public synonym/grant.
prompt If package compilation fails with missing APEX_JSON privileges, ask the
prompt DBA to grant EXECUTE on the installed APEX schema package, for example:
prompt
prompt -- grant execute on APEX_240200.APEX_JSON to &&TRACE_SCHEMA;
prompt
prompt Replace APEX_240200 with the actual APEX owner in the target database.
prompt

prompt Optional ORDS note.
prompt If this schema will expose REST endpoints later, enable the schema in
prompt ORDS using the customer's standard authentication and authorization
prompt model. Do not expose anonymous endpoints by default.
prompt
prompt Example only - execute according to customer ORDS standards:
prompt
prompt -- begin
prompt --     ords_admin.enable_schema(
prompt --         p_enabled             => true,
prompt --         p_schema              => upper('&&TRACE_SCHEMA'),
prompt --         p_url_mapping_type    => 'BASE_PATH',
prompt --         p_url_mapping_pattern => lower('&&TRACE_SCHEMA'),
prompt --         p_auto_rest_auth      => true
prompt --     );
prompt --     commit;
prompt -- end;
prompt -- /

prompt
prompt Schema &&TRACE_SCHEMA created and granted successfully.
prompt Next step: connect as &&TRACE_SCHEMA and execute the Traceability DDL scripts.
prompt ============================================================

set verify on



