-- Fix RLS policies to allow INSERT/UPDATE (add WITH CHECK)

-- budget_data
DROP POLICY IF EXISTS "Admin can manage budget" ON public.budget_data;
CREATE POLICY "Admin can manage budget" ON public.budget_data FOR ALL
  USING (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  WITH CHECK (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- actual_data
DROP POLICY IF EXISTS "Branch can insert/update own actual" ON public.actual_data;
CREATE POLICY "Branch can insert/update own actual" ON public.actual_data FOR ALL
  USING (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  WITH CHECK (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- collection_data
DROP POLICY IF EXISTS "Branch can manage own collection" ON public.collection_data;
CREATE POLICY "Branch can manage own collection" ON public.collection_data FOR ALL
  USING (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  WITH CHECK (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- departments
DROP POLICY IF EXISTS "Admin can manage departments" ON public.departments;
CREATE POLICY "Admin can manage departments" ON public.departments FOR ALL
  USING (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  WITH CHECK (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- fields
DROP POLICY IF EXISTS "Admin can manage fields" ON public.fields;
CREATE POLICY "Admin can manage fields" ON public.fields FOR ALL
  USING (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  WITH CHECK (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));
