CREATE TABLE replies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    ticket_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_ticket_id (ticket_id),
    INDEX idx_user_id (user_id)
);

