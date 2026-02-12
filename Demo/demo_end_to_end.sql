SET SERVEROUTPUT ON

PROMPT === Demo: Generic Audit & Change Tracking Framework ===

-- Create sample table if not already present.
DECLARE
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_exists
    FROM user_tables
    WHERE table_name = 'EMPLOYEES';

    IF v_exists = 0 THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE employees (
                emp_id      NUMBER PRIMARY KEY,
                emp_name    VARCHAR2(100),
                salary      NUMBER,
                department  VARCHAR2(50)
            )';
    END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE employees';
END;
/

DELETE FROM audit_log WHERE table_name = 'EMPLOYEES';
COMMIT;

BEGIN
    audit_pkg.enable_audit(
        p_table_name => 'EMPLOYEES',
        p_ins        => 'Y',
        p_upd        => 'Y',
        p_del        => 'Y'
    );

    pkg_audit_generator.generate_trigger(
        p_table_name         => 'EMPLOYEES',
        p_include_insert_row => 'Y',
        p_include_delete_row => 'Y',
        p_bulk_mode          => 'Y',
        p_json_mode          => 'Y'
    );
END;
/

INSERT INTO employees (emp_id, emp_name, salary, department)
VALUES (1, 'Alice', 70000, 'Engineering');

UPDATE employees
SET salary = 74000,
    department = 'Platform'
WHERE emp_id = 1;

DELETE FROM employees WHERE emp_id = 1;
COMMIT;

PROMPT === Recent audit rows for EMPLOYEES ===
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
WHERE table_name = 'EMPLOYEES'
ORDER BY audit_id DESC;

PROMPT === JSON audit rows (ROW_JSON) ===
SELECT
    table_name,
    column_name,
    pk_value,
    action_type,
    json_payload
FROM audit_log
WHERE table_name = 'EMPLOYEES'
  AND column_name = 'ROW_JSON'
ORDER BY audit_id DESC;

