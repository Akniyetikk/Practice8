#2
CREATE OR REPLACE PROCEDURE upsert_contact(p_name VARCHAR, p_phone VARCHAR) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.phonebook WHERE first_name = p_name) THEN
        UPDATE public.phonebook SET phone_number = p_phone WHERE first_name = p_name;
    ELSE
        INSERT INTO public.phonebook (first_name, phone_number) VALUES (p_name, p_phone);
    END IF;
END;
$$ LANGUAGE plpgsql;

#3
CREATE OR REPLACE PROCEDURE bulk_insert_with_errors(
    IN p_names TEXT[], 
    IN p_phones TEXT[], 
    OUT failed_names TEXT[], 
    OUT failed_phones TEXT[]
) AS $$
DECLARE
    i INT;
BEGIN
    failed_names := '{}';
    failed_phones := '{}';
    FOR i IN 1..array_length(p_names, 1) LOOP
        IF p_phones[i] ~ '^[0-9]{10,15}$' THEN
            INSERT INTO public.phonebook (first_name, phone_number)
            VALUES (p_names[i], p_phones[i])
            ON CONFLICT (phone_number) DO NOTHING;
        ELSE
            failed_names := array_append(failed_names, p_names[i]);
            failed_phones := array_append(failed_phones, p_phones[i]);
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

#5
CREATE OR REPLACE PROCEDURE delete_contact(p_target VARCHAR) AS $$
BEGIN
    DELETE FROM public.phonebook 
    WHERE first_name = p_target OR phone_number = p_target;
END;
$$ LANGUAGE plpgsql;
