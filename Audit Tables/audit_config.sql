CREATE TABLE audit_config (
    table_name      VARCHAR2(30) PRIMARY KEY,
    audit_enabled   CHAR(1) CHECK (audit_enabled IN ('Y','N')),
    audit_insert    CHAR(1) CHECK (audit_insert IN ('Y','N')),
    audit_update    CHAR(1) CHECK (audit_update IN ('Y','N')),
    audit_delete    CHAR(1) CHECK (audit_delete IN ('Y','N')),
    created_at      DATE DEFAULT SYSDATE
);