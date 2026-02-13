CREATE OR REPLACE TRIGGER trg_audit_employees
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
    v_enabled audit_config.audit_enabled%TYPE;
BEGIN
    SELECT audit_enabled
    INTO v_enabled
    FROM audit_config
    WHERE table_name = 'EMPLOYEES';

    IF v_enabled = 'Y' THEN

        IF INSERTING THEN
            audit_pkg.log_change(
                'EMPLOYEES', NULL, :NEW.emp_id,
                NULL, NULL, 'INSERT'
            );
        END IF;

        IF UPDATING THEN
            IF NVL(:OLD.salary,0) <> NVL(:NEW.salary,0) THEN
                audit_pkg.log_change(
                    'EMPLOYEES', 'SALARY', :OLD.emp_id,
                    :OLD.salary, :NEW.salary, 'UPDATE'
                );
            END IF;
        END IF;

        IF DELETING THEN
            audit_pkg.log_change(
                'EMPLOYEES', NULL, :OLD.emp_id,
                NULL, NULL, 'DELETE'
            );
        END IF;

    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
END;
/
