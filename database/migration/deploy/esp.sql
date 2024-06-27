-- Deploy climat-guardian:esp to pg

BEGIN;

    create table api.esp (
        id   serial primary key,
        name character varying(20) not null,
        ip   character varying(15) NOT NULL unique,
        x    integer,
        y    integer
    );
    grant all on api.esp to web_user;
    grant usage, select on sequence api.esp_id_seq to web_user;

COMMIT;
