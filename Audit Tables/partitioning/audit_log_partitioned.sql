-- Use this table definition for high-volume/new deployments
-- when you want monthly interval partitioning by changed_at.
CREATE TABLE audit_log (
    audit_id        NUMBER GENERATED ALWAYS AS IDENTITY,
    table_name      VARCHAR2(30),
    column_name     VARCHAR2(30),
    pk_value        VARCHAR2(100),
    old_value       VARCHAR2(4000),
    new_value       VARCHAR2(4000),
    json_payload    CLOB,
    action_type     VARCHAR2(10),
    changed_by      VARCHAR2(30),
    changed_at      DATE DEFAULT SYSDATE,
    CONSTRAINT pk_audit_log PRIMARY KEY (audit_id)
)
PARTITION BY RANGE (changed_at)
INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION p_audit_log_seed VALUES LESS THAN (DATE '2026-01-01')
);

CREATE INDEX idx_audit_log_tbl_changed_at ON audit_log (table_name, changed_at) LOCAL;
CREATE INDEX idx_audit_log_tbl_pk_changed_at ON audit_log (table_name, pk_value, changed_at) LOCAL;
CREATE INDEX idx_audit_log_changed_by_at ON audit_log (changed_by, changed_at) LOCAL;

