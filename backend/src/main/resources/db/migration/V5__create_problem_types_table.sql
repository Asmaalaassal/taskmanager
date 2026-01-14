CREATE TABLE problem_types (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default problem types
INSERT INTO problem_types (name, description) VALUES
('TECHNICAL', 'Technical issues and bugs'),
('BILLING', 'Billing and payment issues'),
('ACCOUNT', 'Account management issues'),
('FEATURE_REQUEST', 'Feature requests and suggestions'),
('GENERAL', 'General inquiries');

