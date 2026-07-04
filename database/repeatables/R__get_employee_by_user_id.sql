CREATE OR REPLACE FUNCTION public.get_employee_by_user_id(
    p_user_id UUID
)
RETURNS TABLE (
    user_id UUID,
    username TEXT,
    email TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.user_id,
        e.username,
        'forward',
        e.created_at,
    FROM public.employee e
    WHERE e.user_id = p_user_id;
END;
$$;