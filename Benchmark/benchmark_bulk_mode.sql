SET SERVEROUTPUT ON

DEFINE row_count = '&1'

PROMPT === Benchmark: bulk_mode N vs Y ===
PROMPT rows = &&row_count

DECLARE
    v_exists            NUMBER;
    v_row_count         PLS_INTEGER := TO_NUMBER('&&row_count');
    v_start_cs          NUMBER;
    v_elapsed_cs        NUMBER;
    v_before_audit      NUMBER;
    v_after_audit       NUMBER;
    v_audit_rows_added  NUMBER;

    PROCEDURE ensure_employees_table IS
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
    END ensure_employees_table;

    PROCEDURE seed_data IS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE employees';

        FOR i IN 1 .. v_row_count LOOP
            INSERT INTO employees (emp_id, emp_name, salary, department)
            VALUES (i, 'EMP_' || TO_CHAR(i), 50000 + i, 'D' || TO_CHAR(MOD(i, 10)));
        END LOOP;

        COMMIT;
    END seed_data;

    PROCEDURE reset_workload_baseline IS
    BEGIN
        UPDATE employees
        SET salary = 50000 + emp_id,
            department = 'D' || TO_CHAR(MOD(emp_id, 10));
        COMMIT;
    END reset_workload_baseline;

    PROCEDURE run_case(
        p_bulk_mode IN CHAR,
        p_label     IN VARCHAR2
    ) IS
    BEGIN
        pkg_audit_generator.generate_trigger(
            p_table_name         => 'EMPLOYEES',
            p_include_insert_row => 'Y',
            p_include_delete_row => 'Y',
            p_bulk_mode          => p_bulk_mode,
            p_json_mode          => 'N'
        );

        reset_workload_baseline;
        DELETE FROM audit_log WHERE table_name = 'EMPLOYEES';
        COMMIT;

        SELECT COUNT(*)
        INTO v_before_audit
        FROM audit_log
        WHERE table_name = 'EMPLOYEES';

        v_start_cs := DBMS_UTILITY.GET_TIME;

        UPDATE employees
        SET salary = salary + 100,
            department = 'DX' || TO_CHAR(MOD(emp_id, 10));
        COMMIT;

        v_elapsed_cs := DBMS_UTILITY.GET_TIME - v_start_cs;

        SELECT COUNT(*)
        INTO v_after_audit
        FROM audit_log
        WHERE table_name = 'EMPLOYEES';

        v_audit_rows_added := v_after_audit - v_before_audit;

        DBMS_OUTPUT.PUT_LINE(
            RPAD(p_label, 15)
            || ' elapsed_ms=' || TO_CHAR(v_elapsed_cs * 10)
            || ' audit_rows=' || TO_CHAR(v_audit_rows_added)
        );
    END run_case;
BEGIN
    ensure_employees_table;

    audit_pkg.enable_audit(
        p_table_name => 'EMPLOYEES',
        p_ins        => 'Y',
        p_upd        => 'Y',
        p_del        => 'Y'
    );

    seed_data;

    run_case(p_bulk_mode => 'N', p_label => 'bulk_mode=N');
    run_case(p_bulk_mode => 'Y', p_label => 'bulk_mode=Y');
END;
/

