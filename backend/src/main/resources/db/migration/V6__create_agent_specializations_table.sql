CREATE TABLE agent_specializations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    agent_id BIGINT NOT NULL,
    problem_type_id BIGINT NOT NULL,
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (problem_type_id) REFERENCES problem_types(id) ON DELETE CASCADE,
    UNIQUE KEY unique_agent_specialization (agent_id, problem_type_id)
);

