-- Revert climat-guardian:esp from pg

BEGIN;

    -- drop the view
    drop view api.data_view;

    -- set the data table back to the old state
    alter table api.data add column ip varchar(15);
    update api.data data set ip = esp.ip from api.esp esp where data.esp_id = esp.id;
    alter table api.data drop column esp_id;

    -- drop the esp table
    drop table api.esp;

    -- use the old functions bback
    drop function api.avg_date;
    create function api.avg_date(
        delta varchar
    )
    returns table(
        avg_temperature double precision, 
        avg_humidity double precision, 
        date timestamp,
        ip character varying(15),
        count bigint
    ) as $$
    begin
        return query select 
            avg(temperature) as avg_temperature, 
            avg(humidity) as avg_humidity,
            date_trunc(delta, timestamp) as date,
            data.ip,
            count(*) as count
        from api.data
        group by date, data.ip
        order by date;
    end;
    $$ language plpgsql;

COMMIT;
