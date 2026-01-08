-- Add document_number field to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS document_number TEXT;

-- Add biometric_enabled field to profiles table for security settings
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS biometric_enabled BOOLEAN DEFAULT false;