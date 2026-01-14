-- Default admin credentials:
-- Email: admin@ticketmanager.com
-- Password: admin123
-- Password is BCrypt hashed: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
INSERT INTO users (name, email, password, role) 
VALUES ('Admin User', 'admin@ticketmanager.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN');

