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

    -- Change api.data to use a foreign key instead of a string
    alter table api.data add column esp_id integer;
    insert into api.esp (name, ip) select distinct 'unnamed', ip from api.data;
    update api.data set esp_id = esp.id from api.esp esp where api.data.ip = esp.ip;
    alter table api.data drop column ip;
    alter table api.data add constraint data_esp_fk foreign key (esp_id) references api.esp(id);

    -- Create a view to get the data with the esp name and ip
    create view api.data_view as
        select temperature, humidity, timestamp, ip, name
        from api.data
        join api.esp as e on e.id = data.esp_id;

COMMIT;
