-- Default admin credentials:
-- Email: admin@ticketmanager.com
-- Password: admin123
-- Password is BCrypt hashed: $2a$12$Zm6oEsE4onkjoC0r7oTA4ej/c8zxQgBYmEVlMZXJs8zrVWyKxSDay
-- Use INSERT IGNORE to prevent errors if admin already exists
INSERT IGNORE INTO users (name, email, password, role) 
VALUES ('Admin User', 'admin@ticketmanager.com', '$2a$12$Zm6oEsE4onkjoC0r7oTA4ej/c8zxQgBYmEVlMZXJs8zrVWyKxSDay', 'ADMIN');

