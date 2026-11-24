-- Dados de demonstração inteiramente fictícios. IDs fixos para facilitar testes locais.
insert into public.establishments(id,name,description,city,state,category,status) values
('10000000-0000-4000-8000-000000000001','Brasa & Pão','Hambúrguer artesanal na brasa.','Belo Horizonte','MG','Hamburgueria','approved'),
('10000000-0000-4000-8000-000000000002','Cantina da Praça','Receitas afetivas e lanches.','Belo Horizonte','MG','Lanches','approved'),
('10000000-0000-4000-8000-000000000003','Doce Encontro','Cafés especiais e bolos artesanais.','Belo Horizonte','MG','Cafeteria','pending');
insert into public.products(establishment_id,name,description,category,price,stock) values
('10000000-0000-4000-8000-000000000001','Smash da Casa','Dois discos smash e cheddar.','Hambúrguer',32.90,20),
('10000000-0000-4000-8000-000000000001','Batata Brasa','Batata com páprica.','Acompanhamento',18,30),
('10000000-0000-4000-8000-000000000002','Misto da Praça','Pão na chapa e queijo.','Sanduíche',19.50,15),
('10000000-0000-4000-8000-000000000003','Cappuccino Cremoso','Espresso e leite vaporizado.','Café',14,10);
-- Usuários de demonstração devem ser criados via Supabase Auth antes de inserir profiles.
-- Não há senhas nem credenciais fictícias neste seed.
