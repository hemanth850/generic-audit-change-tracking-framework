CREATE OR REPLACE PACKAGE pkg_audit_generator AS
    PROCEDURE generate_trigger(
        p_table_name         IN VARCHAR2,
        p_trigger_name       IN VARCHAR2 DEFAULT NULL,
        p_include_insert_row IN CHAR DEFAULT 'Y',
        p_include_delete_row IN CHAR DEFAULT 'Y',
        p_include_columns    IN VARCHAR2 DEFAULT NULL,
        p_exclude_columns    IN VARCHAR2 DEFAULT NULL,
        p_skip_datatypes     IN VARCHAR2 DEFAULT NULL,
        p_include_lobs       IN CHAR DEFAULT 'N',
        p_bulk_mode          IN CHAR DEFAULT 'Y',
        p_json_mode          IN CHAR DEFAULT 'N'
    );

    PROCEDURE drop_trigger(
        p_table_name   IN VARCHAR2,
        p_trigger_name IN VARCHAR2 DEFAULT NULL
    );
END pkg_audit_generator;
/
