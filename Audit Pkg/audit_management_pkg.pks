CREATE OR REPLACE PACKAGE audit_pkg AS
    PROCEDURE enable_audit (
        p_table_name IN VARCHAR2,
        p_ins        IN CHAR DEFAULT 'Y',
        p_upd        IN CHAR DEFAULT 'Y',
        p_del        IN CHAR DEFAULT 'Y'
    );

    PROCEDURE disable_audit (
        p_table_name IN VARCHAR2
    );

    PROCEDURE log_change (
        p_table_name  IN VARCHAR2,
        p_column_name IN VARCHAR2,
        p_pk_value    IN VARCHAR2,
        p_old_value   IN VARCHAR2,
        p_new_value   IN VARCHAR2,
        p_action      IN VARCHAR2
    );
END audit_pkg;
/
