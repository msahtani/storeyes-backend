UPDATE supplier_orders
SET status = CASE status
    WHEN 'DRAFT' THEN 'PENDING'
    WHEN 'SENT' THEN 'VALID'
    WHEN 'CONVERTED' THEN 'VALID'
    ELSE status
END
WHERE status IN ('DRAFT', 'SENT', 'CONVERTED');
