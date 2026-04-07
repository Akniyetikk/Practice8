#1
CREATE OR REPLACE FUNCTION search_contacts(p_pattern TEXT)
RETURNS TABLE(contact_id INT, first_name VARCHAR, phone_number VARCHAR) AS $$
BEGIN
    RETURN QUERY 
    SELECT p.contact_id, p.first_name, p.phone_number 
    FROM public.phonebook p
    WHERE p.first_name ILIKE '%' || p_pattern || '%' 
       OR p.phone_number LIKE '%' || p_pattern || '%';
END;
$$ LANGUAGE plpgsql;

#4
CREATE OR REPLACE FUNCTION get_contacts_paginated(p_limit INT, p_offset INT)
RETURNS TABLE(contact_id INT, first_name VARCHAR, phone_number VARCHAR) AS $$
BEGIN
    RETURN QUERY 
    SELECT p.contact_id, p.first_name, p.phone_number 
    FROM public.phonebook p
    ORDER BY p.contact_id 
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;
