CREATE OR REPLACE PACKAGE audit_pkg AS
    TYPE t_change_rec IS RECORD (
        table_name  audit_log.table_name%TYPE,
        column_name audit_log.column_name%TYPE,
        pk_value    audit_log.pk_value%TYPE,
        old_value   audit_log.old_value%TYPE,
        new_value   audit_log.new_value%TYPE,
        action_type audit_log.action_type%TYPE
    );

    TYPE t_change_tab IS TABLE OF t_change_rec INDEX BY PLS_INTEGER;

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

    PROCEDURE flush_changes (
        p_changes IN t_change_tab
    );
END audit_pkg;
/
