-- Add problem_type and is_public to tickets
ALTER TABLE tickets 
ADD COLUMN problem_type_id BIGINT NULL,
ADD COLUMN is_public BOOLEAN DEFAULT TRUE NOT NULL,
ADD FOREIGN KEY (problem_type_id) REFERENCES problem_types(id) ON DELETE SET NULL;

-- Update existing tickets to have a default problem type (GENERAL)
UPDATE tickets SET problem_type_id = (SELECT id FROM problem_types WHERE name = 'GENERAL' LIMIT 1) WHERE problem_type_id IS NULL;

