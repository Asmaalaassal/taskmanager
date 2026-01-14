-- Add USER role to users table
ALTER TABLE users MODIFY COLUMN role ENUM('ADMIN', 'AGENT', 'USER') NOT NULL;

