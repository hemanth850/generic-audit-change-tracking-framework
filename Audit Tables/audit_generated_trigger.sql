CREATE TABLE audit_generated_trigger (
    table_name          VARCHAR2(30) PRIMARY KEY,
    trigger_name        VARCHAR2(30) NOT NULL,
    include_insert_row  CHAR(1) CHECK (include_insert_row IN ('Y', 'N')),
    include_delete_row  CHAR(1) CHECK (include_delete_row IN ('Y', 'N')),
    include_columns     VARCHAR2(4000),
    exclude_columns     VARCHAR2(4000),
    skip_datatypes      VARCHAR2(4000),
    include_lobs        CHAR(1) CHECK (include_lobs IN ('Y', 'N')),
    bulk_mode           CHAR(1) CHECK (bulk_mode IN ('Y', 'N')),
    json_mode           CHAR(1) CHECK (json_mode IN ('Y', 'N')),
    generated_by        VARCHAR2(30),
    generated_at        DATE DEFAULT SYSDATE
);

