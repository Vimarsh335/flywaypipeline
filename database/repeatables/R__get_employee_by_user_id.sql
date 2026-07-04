CREATE OR REPLACE FUNCTION public.get_employee_by_user_id(
    p_user_id UUID
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Fetching employee with user_id: %', p_user_id;
END;
$$;