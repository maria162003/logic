-- Agregar columna payment_method a la tabla proposals
ALTER TABLE proposals 
ADD COLUMN IF NOT EXISTS payment_method TEXT CHECK (payment_method IN ('full', 'split', 'result', 'installments'));

-- Comentario de la columna
COMMENT ON COLUMN proposals.payment_method IS 'Método de pago acordado: full (pago único al inicio), split (dos pagos), result (pago por resultado), installments (pagos divididos durante el proceso)';
