-- Verify climat-guardian:esp on pg

BEGIN;

    -- test esp table
    select * from api.esp;
    INSERT INTO api.esp (name, ip) VALUES ('ESP1', '192.168.1.10');
    UPDATE api.esp SET (x,y) = (4,5) WHERE name = 'ESP1';
    SELECT ip FROM api.esp WHERE name = 'ESP1';

    -- test data table
    select * from api.data;
    INSERT INTO api.data (temperature, humidity, timestamp, esp_id) VALUES (25.5, 50.5, '2021-01-01 00:00:00', (SELECT id FROM api.esp WHERE name = 'ESP1'));

    -- test data_view and avg_date
    select * from api.data_view where name = 'ESP1';
    select * from api.avg_date('day') where name = 'ESP1';

    -- test insert_data
    delete from api.data where esp_id = (SELECT id FROM api.esp WHERE name = 'ESP1');
    select api.insert_data(25.5, 50.5, '192.168.1.10', 1609459200);
    select * from api.data where esp_id = (SELECT id FROM api.esp WHERE name = 'ESP1');

ROLLBACK;
