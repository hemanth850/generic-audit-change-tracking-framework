BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_audit_log_tbl_changed_at ON audit_log (table_name, changed_at)';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN
                RAISE;
            END IF;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_audit_log_tbl_pk_changed_at ON audit_log (table_name, pk_value, changed_at)';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN
                RAISE;
            END IF;
    END;

    BEGIN
        EXECUTE IMMEDIATE 'CREATE INDEX idx_audit_log_changed_by_at ON audit_log (changed_by, changed_at)';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -955 THEN
                RAISE;
            END IF;
    END;
END;
/

