CREATE TABLE audit_log (
    audit_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_name      VARCHAR2(30),
    column_name     VARCHAR2(30),
    pk_value        VARCHAR2(100),
    old_value       VARCHAR2(4000),
    new_value       VARCHAR2(4000),
    json_payload    CLOB,
    action_type     VARCHAR2(10),
    changed_by      VARCHAR2(30),
    changed_at      DATE DEFAULT SYSDATE
);
