-- Revert climat-guardian:esp from pg

BEGIN;

    -- set the data table back to the old state
    alter table api.data add column ip varchar(15);
    update api.data data set ip = esp.ip from api.esp esp where data.esp_id = esp.id;
    alter table api.data drop column esp_id;

    -- drop the esp table
    drop table api.esp;

COMMIT;
