CREATE OR REPLACE PACKAGE pkg_audit_generator AS
    PROCEDURE generate_trigger(
        p_table_name         IN VARCHAR2,
        p_trigger_name       IN VARCHAR2 DEFAULT NULL,
        p_include_insert_row IN CHAR DEFAULT 'Y',
        p_include_delete_row IN CHAR DEFAULT 'Y'
    );

    PROCEDURE drop_trigger(
        p_table_name   IN VARCHAR2,
        p_trigger_name IN VARCHAR2 DEFAULT NULL
    );
END pkg_audit_generator;
/

