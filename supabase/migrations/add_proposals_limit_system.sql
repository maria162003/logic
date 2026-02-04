-- Migration: Add proposals limit system to marketplace_cases
-- Description: Adds max_proposals and current_proposals_count columns to implement proposal limits per case
-- Date: 2026-02-03

-- Add columns to marketplace_cases table
ALTER TABLE marketplace_cases
ADD COLUMN IF NOT EXISTS max_proposals INTEGER DEFAULT 5 NOT NULL,
ADD COLUMN IF NOT EXISTS current_proposals_count INTEGER DEFAULT 0 NOT NULL;

-- Add check constraint to ensure current count doesn't exceed max
ALTER TABLE marketplace_cases
ADD CONSTRAINT current_proposals_check 
CHECK (current_proposals_count >= 0 AND current_proposals_count <= max_proposals);

-- Add comment for documentation
COMMENT ON COLUMN marketplace_cases.max_proposals IS 'Maximum number of proposals allowed for this case (default: 5)';
COMMENT ON COLUMN marketplace_cases.current_proposals_count IS 'Current number of active proposals for this case';

-- Update existing cases to set default values
UPDATE marketplace_cases
SET max_proposals = 5,
    current_proposals_count = 0
WHERE max_proposals IS NULL OR current_proposals_count IS NULL;

-- Initialize current_proposals_count for existing cases based on actual proposals
-- This counts only 'pending' proposals, not 'accepted', 'rejected', or 'withdrawn' ones
UPDATE marketplace_cases mc
SET current_proposals_count = (
  SELECT COUNT(*)
  FROM proposals p
  WHERE p.case_id = mc.id
  AND p.status = 'pending'
);

-- Create index for performance on proposals count queries
CREATE INDEX IF NOT EXISTS idx_marketplace_cases_proposals_count 
ON marketplace_cases(current_proposals_count);

CREATE INDEX IF NOT EXISTS idx_marketplace_cases_status_proposals 
ON marketplace_cases(status, current_proposals_count);

-- Add index on proposals for faster counting
CREATE INDEX IF NOT EXISTS idx_proposals_case_status 
ON proposals(case_id, status);

-- Create a function to automatically update proposal count (optional, for future use with triggers)
CREATE OR REPLACE FUNCTION update_proposals_count()
RETURNS TRIGGER AS $$
BEGIN
  -- Increment when a new proposal is created with 'pending' status
  IF TG_OP = 'INSERT' AND NEW.status = 'pending' THEN
    UPDATE marketplace_cases
    SET current_proposals_count = current_proposals_count + 1
    WHERE id = NEW.case_id;
  END IF;
  
  -- Decrement when a proposal is deleted or changed from 'pending' to another status
  IF TG_OP = 'DELETE' AND OLD.status = 'pending' THEN
    UPDATE marketplace_cases
    SET current_proposals_count = GREATEST(0, current_proposals_count - 1)
    WHERE id = OLD.case_id;
  END IF;
  
  -- Handle status changes
  IF TG_OP = 'UPDATE' THEN
    -- If changing from 'pending' to another status, decrement
    IF OLD.status = 'pending' AND NEW.status != 'pending' THEN
      UPDATE marketplace_cases
      SET current_proposals_count = GREATEST(0, current_proposals_count - 1)
      WHERE id = OLD.case_id;
    END IF;
    
    -- If changing from another status to 'pending', increment
    IF OLD.status != 'pending' AND NEW.status = 'pending' THEN
      UPDATE marketplace_cases
      SET current_proposals_count = current_proposals_count + 1
      WHERE id = NEW.case_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Note: Trigger is NOT created automatically to avoid conflicts with application logic
-- Uncomment below to enable automatic counting via database triggers
-- CREATE TRIGGER trigger_update_proposals_count
-- AFTER INSERT OR UPDATE OR DELETE ON proposals
-- FOR EACH ROW
-- EXECUTE FUNCTION update_proposals_count();

-- Update status to 'full' for cases that reached the limit
UPDATE marketplace_cases
SET status = 'full'
WHERE status = 'open'
AND current_proposals_count >= max_proposals;

