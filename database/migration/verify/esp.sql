-- Verify climat-guardian:esp on pg

BEGIN;

    -- test esp table
    select * from api.esp;
    INSERT INTO api.esp (name, ip) VALUES ('ESP1', '192.168.1.10');
    UPDATE api.esp SET (x,y) = (4,5) WHERE name = 'ESP1';
    SELECT ip FROM api.esp WHERE name = 'ESP1';

ROLLBACK;
