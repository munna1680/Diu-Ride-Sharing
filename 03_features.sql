-- =========================================
-- DIU Ride Sharing Project
-- Trigger + View + Procedure Script
-- =========================================

USE ridesharing_db;

-- =========================================
-- TRIGGERS
-- =========================================

DELIMITER $$

-- Trigger 1: Empty message block + sent_at auto set
DROP TRIGGER IF EXISTS trg_before_insert_chat_messages $$
CREATE TRIGGER trg_before_insert_chat_messages
BEFORE INSERT ON chat_messages
FOR EACH ROW
BEGIN
    IF NEW.message IS NULL OR TRIM(NEW.message) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Message cannot be empty';
    END IF;

    IF NEW.sent_at IS NULL THEN
        SET NEW.sent_at = NOW();
    END IF;
END $$

-- Trigger 2: Negative fare block + default status/request_time
DROP TRIGGER IF EXISTS trg_before_insert_rides $$
CREATE TRIGGER trg_before_insert_rides
BEFORE INSERT ON rides
FOR EACH ROW
BEGIN
    IF NEW.fare < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fare cannot be negative';
    END IF;

    IF NEW.status IS NULL THEN
        SET NEW.status = 'OFFERED';
    END IF;

    IF NEW.request_time IS NULL THEN
        SET NEW.request_time = NOW();
    END IF;
END $$

-- Trigger 3: On complete/cancel set end_time
DROP TRIGGER IF EXISTS trg_before_update_rides $$
CREATE TRIGGER trg_before_update_rides
BEFORE UPDATE ON rides
FOR EACH ROW
BEGIN
    IF NEW.fare < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fare cannot be negative';
    END IF;

    IF NEW.status = 'COMPLETED' AND NEW.end_time IS NULL THEN
        SET NEW.end_time = NOW();
    END IF;

    IF NEW.status = 'CANCELLED' AND NEW.end_time IS NULL THEN
        SET NEW.end_time = NOW();
    END IF;
END $$

DELIMITER ;

-- =========================================
-- VIEWS
-- =========================================

-- View 1: Active rides
DROP VIEW IF EXISTS vw_active_rides;
CREATE VIEW vw_active_rides AS
SELECT
    r.id,
    r.pickup_location,
    r.dropoff_location,
    r.fare,
    r.status,
    r.request_time,
    r.start_time,
    d.id    AS driver_id,
    d.name  AS driver_name,
    d.email AS driver_email,
    d.phone AS driver_phone,
    rr.id    AS rider_id,
    rr.name  AS rider_name,
    rr.email AS rider_email,
    rr.phone AS rider_phone
FROM rides r
LEFT JOIN users d ON r.driver_id = d.id
LEFT JOIN users rr ON r.rider_id = rr.id
WHERE r.status IN ('OFFERED', 'BOOKED', 'IN_PROGRESS');


-- View 2: Ride details with driver and rider
DROP VIEW IF EXISTS vw_ride_details;
CREATE VIEW vw_ride_details AS
SELECT
    r.id AS ride_id,
    r.pickup_location,
    r.dropoff_location,
    r.fare,
    r.status,
    r.request_time,
    r.start_time,
    r.end_time,
    d.id AS driver_id,
    d.name AS driver_name,
    d.email AS driver_email,
    d.phone AS driver_phone,
    rr.id AS rider_id,
    rr.name AS rider_name,
    rr.email AS rider_email,
    rr.phone AS rider_phone
FROM rides r
LEFT JOIN users d ON r.driver_id = d.id
LEFT JOIN users rr ON r.rider_id = rr.id;


-- View 3: Chat history with sender info
DROP VIEW IF EXISTS vw_chat_history;
CREATE VIEW vw_chat_history AS
SELECT
    c.id AS chat_id,
    c.ride_id,
    c.sender_id,
    u.name AS sender_name,
    u.email AS sender_email,
    c.sender_role,
    c.message,
    c.sent_at
FROM chat_messages c
LEFT JOIN users u ON c.sender_id = u.id;


-- =========================================
-- STORED PROCEDURES
-- =========================================

DELIMITER $$

-- Procedure 1: Get all users
DROP PROCEDURE IF EXISTS GetAllUsers $$
CREATE PROCEDURE GetAllUsers()
BEGIN
    SELECT
        id,
        name,
        email,
        role,
        status,
        student_id,
        department,
        phone,
        user_type
    FROM users;
END $$

-- Procedure 2: Get rides by status
DROP PROCEDURE IF EXISTS GetRideDetailsByStatus $$
CREATE PROCEDURE GetRideDetailsByStatus(IN p_status VARCHAR(30))
BEGIN
    SELECT
        r.id,
        r.pickup_location,
        r.dropoff_location,
        r.fare,
        r.status,
        r.request_time,
        r.start_time,
        r.end_time,
        d.name AS driver_name,
        rr.name AS rider_name
    FROM rides r
    LEFT JOIN users d ON r.driver_id = d.id
    LEFT JOIN users rr ON r.rider_id = rr.id
    WHERE r.status = p_status;
END $$

-- Procedure 3: Insert chat message
DROP PROCEDURE IF EXISTS InsertChatMessage $$
CREATE PROCEDURE InsertChatMessage(
    IN p_ride_id BIGINT,
    IN p_sender_id BIGINT,
    IN p_sender_role VARCHAR(20),
    IN p_message TEXT
)
BEGIN
    INSERT INTO chat_messages (ride_id, sender_id, sender_role, message, sent_at)
    VALUES (p_ride_id, p_sender_id, p_sender_role, p_message, NOW());
END $$

-- Procedure 4: Cancel ride
DROP PROCEDURE IF EXISTS CancelRide $$
CREATE PROCEDURE CancelRide(
    IN p_ride_id BIGINT,
    IN p_last_action_by VARCHAR(20)
)
BEGIN
    UPDATE rides
    SET
        status = 'CANCELLED',
        end_time = NOW(),
        last_action_by = p_last_action_by
    WHERE id = p_ride_id;
END $$

-- Procedure 5: Complete ride
DROP PROCEDURE IF EXISTS CompleteRide $$
CREATE PROCEDURE CompleteRide(
    IN p_ride_id BIGINT,
    IN p_last_action_by VARCHAR(20)
)
BEGIN
    UPDATE rides
    SET
        status = 'COMPLETED',
        end_time = NOW(),
        last_action_by = p_last_action_by
    WHERE id = p_ride_id;
END $$

DELIMITER ;