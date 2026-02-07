CREATE OR REPLACE VIEW vw_audit_history AS
SELECT
    table_name,
    column_name,
    pk_value,
    old_value,
    new_value,
    action_type,
    changed_by,
    changed_at
FROM audit_log
ORDER BY changed_at DESC;
