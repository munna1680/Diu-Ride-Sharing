USE ridesharing_db;

-- Basic table check
SELECT * FROM users;
SELECT * FROM rides;
SELECT * FROM chat_messages;

-- View test
SELECT * FROM vw_active_rides;
SELECT * FROM vw_ride_details;
SELECT * FROM vw_chat_history;

-- trigger test
SHOW TRIGGERS LIKE 'rides';
SHOW TRIGGERS LIKE 'chat_messages';

-- Procedure test
CALL GetAllUsers();
CALL GetRideDetailsByStatus('OFFERED');
CALL GetRideDetailsByStatus('COMPLETED');
CALL GetRideDetailsByStatus('CANCELLED');


