prompt ============================================================
prompt oio_integration_cfg 2.0 - table, constraints, indexes and comments
prompt ============================================================
prompt Execute as the application schema owner, for example OIO_OWNER.
prompt This script is intended as standalone DDL for review.
prompt ============================================================

set define off

create table oio_integration_cfg (
    integration_key       varchar2(250 byte) not null,
    description           varchar2(4000 byte),
    active_flag           char(1 byte) default 'Y',
    integration_type      varchar2(50 byte),
    source_system         varchar2(250 byte),
    target_system         varchar2(250 byte),
    process_name          varchar2(250 byte),
    scope_name            varchar2(250 byte),
    transaction_id1_name  varchar2(4000 byte),
    transaction_id2_name  varchar2(4000 byte),
    transaction_id3_name  varchar2(4000 byte),
    attr1_name            varchar2(4000 byte) not null,
    attr2_name            varchar2(4000 byte),
    attr3_name            varchar2(4000 byte),
    attr4_name            varchar2(4000 byte),
    attr5_name            varchar2(4000 byte),
    attr6_name            varchar2(4000 byte),
    attr7_name            varchar2(4000 byte),
    attr8_name            varchar2(4000 byte),
    attr9_name            varchar2(4000 byte),
    attr10_name           varchar2(4000 byte),
    creation_date         timestamp(6) default systimestamp,
    last_update_date      timestamp(6),
    constraint oio_integration_cfg_pk primary key (integration_key),
    constraint oio_integration_active_ck check (active_flag in ('Y','N'))
);

prompt No standalone sequence or trigger is required for oio_integration_cfg.
prompt Primary key index oio_integration_cfg_PK is created by the primary key constraint.

create index oio_integration_active_ix on oio_integration_cfg (active_flag);
create index oio_integration_systems_ix on oio_integration_cfg (source_system, target_system);

comment on table oio_integration_cfg is
    'Mandatory integration traceability configuration. Each integrationKey used by OIC must exist and be active in this table before trace events are accepted.';
comment on column oio_integration_cfg.integration_key is
    'Unique integration identifier and primary key. Used by OIC as the required integrationKey payload field.';
comment on column oio_integration_cfg.description is
    'Functional description of the configured integration.';
comment on column oio_integration_cfg.active_flag is
    'Indicates whether the integration configuration is active. Expected values are Y or N.';
comment on column oio_integration_cfg.integration_type is
    'Integration type or technical category.';
comment on column oio_integration_cfg.source_system is
    'Configured source system for the integration. This value is derived from configuration and is not expected in the OIC logging payload.';
comment on column oio_integration_cfg.target_system is
    'Configured target system for the integration. This value is derived from configuration and is not expected in the OIC logging payload.';
comment on column oio_integration_cfg.process_name is
    'Business or integration process name.';
comment on column oio_integration_cfg.scope_name is
    'Scope, domain, or logical grouping for the integration.';
comment on column oio_integration_cfg.transaction_id1_name is
    'Business-defined label for oio_trace.TRANSACTION_ID1.';
comment on column oio_integration_cfg.transaction_id2_name is
    'Business-defined label for oio_trace.TRANSACTION_ID2.';
comment on column oio_integration_cfg.transaction_id3_name is
    'Business-defined label for oio_trace.TRANSACTION_ID3.';
comment on column oio_integration_cfg.attr1_name is
    'Business-defined label for oio_trace.ATTR1_VALUE. Mandatory because ATTR1_VALUE is mandatory.';
comment on column oio_integration_cfg.attr2_name is
    'Business-defined label for oio_trace.ATTR2_VALUE.';
comment on column oio_integration_cfg.attr3_name is
    'Business-defined label for oio_trace.ATTR3_VALUE.';
comment on column oio_integration_cfg.attr4_name is
    'Business-defined label for oio_trace.ATTR4_VALUE.';
comment on column oio_integration_cfg.attr5_name is
    'Business-defined label for oio_trace.ATTR5_VALUE.';
comment on column oio_integration_cfg.attr6_name is
    'Business-defined label for oio_trace.ATTR6_VALUE.';
comment on column oio_integration_cfg.attr7_name is
    'Business-defined label for oio_trace.ATTR7_VALUE.';
comment on column oio_integration_cfg.attr8_name is
    'Business-defined label for oio_trace.ATTR8_VALUE.';
comment on column oio_integration_cfg.attr9_name is
    'Business-defined label for oio_trace.ATTR9_VALUE.';
comment on column oio_integration_cfg.attr10_name is
    'Business-defined label for oio_trace.ATTR10_VALUE.';
comment on column oio_integration_cfg.creation_date is
    'Record creation timestamp.';
comment on column oio_integration_cfg.last_update_date is
    'Record last update timestamp.';




