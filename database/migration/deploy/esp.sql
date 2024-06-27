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

    -- Replace the function to insert data to match the new data structure
    drop function api.insert_data;
    create function api.insert_data(
        temperature real,
        humidity real,
        ip varchar(15),
        unix_timestamp bigint
    ) 
    returns void as $$
    declare
        ip_address varchar(15):= ip;
    begin
        -- if the ip said in the token is not the same as the one in the request, then this means that the user is not who he pretends to be and we should throw an error
        if (current_setting('request.jwt.claims', true)::json->>'ip' != ip_address) then
            raise exception insufficient_privilege
            using hint = 'You are not who you pretend to be';
        end if;
        -- insert the data
        insert into api.data("temperature", "humidity", "timestamp", "esp_id") values (temperature, humidity, to_timestamp(unix_timestamp), (select id from api.esp where ip_address = esp.ip));
    end $$ language plpgsql;
    grant insert on api.data to esp32;

    -- Replace the function to get the averaged data to match the new data structure
    drop function api.avg_date;
    create function api.avg_date(
        delta varchar
    )
    returns table(
        avg_temperature double precision, 
        avg_humidity double precision, 
        date timestamp,
        ip character varying(15),
        name character varying(20),
        count bigint
    ) as $$
    begin
        return query select 
            avg(temperature) as avg_temperature, 
            avg(humidity) as avg_humidity,
            date_trunc(delta, timestamp) as date,
            esp.ip,
            esp.name,
            count(*) as count
        from api.data
        join api.esp on data.esp_id = esp.id
        group by date, esp.id
        order by date;
    end;
    $$ language plpgsql;

COMMIT;
