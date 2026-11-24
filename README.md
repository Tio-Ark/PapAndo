# Pap&ando

Rede social gastronômica local — demonstração acadêmica em React + Vite.

## Executar localmente
1. Instale Node.js 20 ou superior.
2. Extraia o projeto e execute `npm install`.
3. Execute `npm run dev`.
4. Abra o endereço local informado pelo Vite.

## Build / Netlify
- Build command: `npm run build`
- Publish directory: `dist`
- O `netlify.toml` contém o fallback SPA para as rotas do frontend.

## O que funciona nesta demonstração
- Navegação entre Início, Explorar, detalhes, Rankings, Mensagens, Perfil, Painel do proprietário, Administração e Configurações.
- Pesquisa e filtros de estabelecimentos.
- Visualização de produtos e preços ilustrativos.
- Avaliação interativa com seis critérios e opção de anonimato (registro apenas local).
- Inclusão local de produtos no painel do proprietário.
- Alternância de tema claro/escuro.
- Feed com curtidas locais.
- Layout responsivo para desktop e celular.

Os dados apresentados no frontend são fictícios e estão identificados como demonstração. Alterações feitas na interface não são persistidas em um servidor.

## Integração Supabase
1. Crie um projeto Supabase.
2. Copie `.env.example` para `.env.local` e preencha `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`.
3. Revise e execute `database/schema.sql` no SQL Editor.
4. Crie usuários exclusivamente pelo Supabase Auth e associe perfis por fluxo seguro.
5. Revise as políticas RLS antes de habilitar dados reais. O schema inclui uma base inicial de tabelas e políticas, não uma auditoria de segurança final.
6. Configure buckets privados para documentos e políticas de Storage. Nunca exponha documentos legais por URL pública.

## Limitações conscientes
- Login, recuperação de senha, upload real, chat em tempo real, moderação persistente, notificações e auditoria ainda dependem de backend/serviços configurados.
- O seletor de perfil é apenas uma prévia de telas, não uma autenticação nem controle de autorização.
- Não use dados pessoais reais na apresentação.
- A aplicação não implementa checkout ou pagamentos.

## Estrutura
- `src/`: aplicação React e estilos.
- `public/`: manifesto PWA e ícone.
- `database/schema.sql`: estrutura PostgreSQL inicial.
- `database/seed.sql`: registros de demonstração seguros (sem credenciais).

## PWA
O manifesto e o ícone estão configurados. Para uso offline completo, adicione estratégia de cache/service worker testada; esta entrega não declara suporte offline completo.
