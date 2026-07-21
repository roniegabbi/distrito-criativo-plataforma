# Plataforma Distrito Criativo Centro-Gare — Backend Supabase + Deploy Vercel

Guia para colocar a plataforma no ar com **Supabase** (banco, autenticação e storage) e **Vercel** (hospedagem do front-end).

---

## 1. Criar o projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) → **New project**.
2. Escolha a região **South America (São Paulo)** para menor latência.
3. Guarde a senha do banco.
4. Após criar, anote em **Project Settings → API**:
   - `Project URL` (ex.: `https://xxxx.supabase.co`)
   - `anon public key`
   - `service_role key` (secreta — nunca vai para o front-end)

## 2. Rodar o schema

No painel do Supabase → **SQL Editor** → **New query**, cole e execute na ordem:

1. `schema.sql`  — cria tipos, tabelas, relacionamentos, triggers e políticas de segurança (RLS).
2. `seed.sql`    — popula dimensões, instituições, pessoas, comitês, um projeto e os eventos.

> Alternativa via CLI: `supabase db push` (com os arquivos em `supabase/migrations/`).

## 3. Autenticação e papéis

- **Auth → Providers**: habilite **Email** (e, se quiser, Google/SSO institucional).
- Ao criar o primeiro usuário, um `profile` é gerado automaticamente com papel `leitura`.
- Promova-o a administrador:

  ```sql
  update profile set role = 'admin'
  where id = (select id from auth.users where email = 'voce@dominio.com');
  ```

- Papéis disponíveis (`user_role`): `admin`, `coordenacao`, `gestor`, `comite`, `leitura`.
  Escrita (criar/editar) é liberada para `admin`, `coordenacao` e `gestor` — ver função `can_edit()` no schema.

## 4. Storage (imagens)

Crie os buckets em **Storage**:

| Bucket        | Acesso   | Uso                                             |
|---------------|----------|-------------------------------------------------|
| `marca`       | público  | logotipos e identidade visual                   |
| `galeria`     | público  | fotos da Vitrine                                |
| `mapas`       | público  | mapas do território (fundo do hero)             |
| `pessoas`     | privado  | fotos das pessoas do cadastro                   |

As colunas `logo_url`, `foto_url`, `logo_url` guardam as URLs públicas geradas pelo Storage.

## 5. Conectar o front-end (Vercel)

1. Suba o projeto do front-end para um repositório (GitHub/GitLab).
2. Em [vercel.com](https://vercel.com) → **Import Project**.
3. Configure as **Environment Variables**:

   ```
   NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=xxxxxxxx
   ```

   > Use **apenas** a `anon key` no front-end. A `service_role key` só em funções server-side/Edge.

4. Deploy. A cada `git push`, a Vercel publica automaticamente.

## 6. Mapa de dados (protótipo → tabelas)

| Tela do protótipo            | Tabela(s) principal(is)                                  |
|------------------------------|----------------------------------------------------------|
| Planejamento Estratégico     | `dimensao`, `objetivo_estrategico`                       |
| Pessoas                      | `pessoa` (+ `instituicao`, `pessoa_comite`)              |
| Instituições                 | `instituicao`                                            |
| Projetos & Processos         | `projeto`, `projeto_equipe`, `acao`, `indicador`, `fonte_recurso` |
| Indicadores                  | `indicador`                                              |
| Orçamento & Fontes           | `fonte_recurso`                                          |
| Eventos & Iniciativas        | `evento`, `evento_organizador`                           |
| Agenda & Atas                | `reuniao`, `reuniao_pauta`, `reuniao_participante`, `ata`|
| Estrutura de Governança      | `comite`, `pessoa_comite`                                |
| Vitrine → Participe          | `contribuicao_cidadao`                                   |

## 7. Geração de ata por IA

No protótipo a ata é montada por template. Em produção, crie uma **Edge Function** (`supabase/functions/gerar-ata`) que:

1. recebe `reuniao_id`;
2. lê pauta + participantes;
3. chama um provedor de LLM (chave guardada em *secret* do Supabase, nunca no front);
4. grava em `ata.conteudo` com `gerada_por_ia = true`.

---

### Estrutura sugerida do repositório

```
/ (front-end: Next.js na Vercel)
  /app ...
  /lib/supabaseClient.ts
/supabase
  schema.sql
  seed.sql
  /functions/gerar-ata/index.ts
```
