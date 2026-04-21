-- =========================================
-- DIU Ride Sharing Project - SQL Queries
-- =========================================

USE ridesharing_db;

-- =========================================
-- Query 1: Show all users
-- =========================================
SELECT * FROM users;


-- =========================================
-- Query 2: Show all active rides
-- =========================================
SELECT *
FROM rides
WHERE status IN ('OFFERED', 'BOOKED', 'IN_PROGRESS');


-- =========================================
-- Query 3: Show completed rides
-- =========================================
SELECT *
FROM rides
WHERE status = 'COMPLETED';


-- =========================================
-- Query 4: Ride with driver info (JOIN)
-- =========================================
SELECT
    r.id,
    r.pickup_location,
    r.dropoff_location,
    r.fare,
    r.status,
    u.name  AS driver_name,
    u.email AS driver_email,
    u.phone AS driver_phone
FROM rides r
JOIN users u ON r.driver_id = u.id;


-- =========================================
-- Query 5: Ride with rider info (JOIN)
-- =========================================
SELECT
    r.id,
    r.pickup_location,
    r.dropoff_location,
    r.status,
    u.name  AS rider_name,
    u.email AS rider_email,
    u.phone AS rider_phone
FROM rides r
JOIN users u ON r.rider_id = u.id;


-- =========================================
-- Query 6: Count rides per driver (GROUP BY)
-- =========================================
SELECT driver_id, COUNT(*) AS total_rides
FROM rides
GROUP BY driver_id;


-- =========================================
-- Query 7: Average ride fare
-- =========================================
SELECT AVG(fare) AS average_fare
FROM rides;


-- =========================================
-- Query 8: Drivers with more than 2 rides (HAVING)
-- =========================================
SELECT driver_id, COUNT(*) AS total_rides
FROM rides
GROUP BY driver_id
HAVING COUNT(*) > 2;


-- =========================================
-- Query 9: Rides that have chat messages
-- =========================================
SELECT DISTINCT ride_id
FROM chat_messages;


-- =========================================
-- Query 10: Chat history with sender info (JOIN)
-- =========================================
SELECT
    c.id,
    c.ride_id,
    u.name AS sender_name,
    c.sender_role,
    c.message,
    c.sent_at
FROM chat_messages c
JOIN users u ON c.sender_id = u.id;


-- =========================================
-- Query 11: Subquery - rides above average fare
-- =========================================
SELECT *
FROM rides
WHERE fare > (SELECT AVG(fare) FROM rides);


-- =========================================
-- Query 12: View usage (vw_ride_details)
-- =========================================
SELECT * FROM vw_ride_details;


-- =========================================
-- Analysis Query: Most Active Driver
-- =========================================
SELECT
    driver_id,
    COUNT(*) AS total_rides
FROM rides
GROUP BY driver_id
ORDER BY total_rides DESC;
