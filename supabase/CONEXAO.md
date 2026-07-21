# Conexão — Projeto Supabase (Distrito Criativo Centro-Gare)

Banco criado e populado com sucesso ✅

| Item                | Valor                                                        |
|---------------------|-------------------------------------------------------------|
| Organização         | Gabbi Consultorias                                          |
| Projeto             | `distrito-criativo-centro-gare` *(reaproveitou o projeto vazio existente)* |
| Ref do projeto      | `phnthshtuyvchhwhihfh`                                       |
| Região              | ca-central-1 (Canadá) — migrar para São Paulo é opcional    |
| **API URL**         | `https://phnthshtuyvchhwhihfh.supabase.co`                  |
| **Publishable key** | `sb_publishable_8T6ibUn0rIagthojKeoM-A_uVz64h2a`            |

> A *publishable key* é pública e pode ir no front-end. A `service_role` (secreta) fica só em funções server-side — pegue no painel em **Settings → API** quando precisar.

## Variáveis de ambiente (Vercel)

```
NEXT_PUBLIC_SUPABASE_URL=https://phnthshtuyvchhwhihfh.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=sb_publishable_8T6ibUn0rIagthojKeoM-A_uVz64h2a
```

## O que já está no banco

- 19 tabelas + RLS (segurança por papel) + triggers
- 4 dimensões · 14 instituições · 5 pessoas · 7 comitês
- 1 projeto (Clube dos Ferroviários) com 3 fontes de recurso
- 5 eventos (Festival do Xis, Calourada Segura, Santa Summit, Mapeando Memórias, Incubadora Social)

## Próximo passo para virar usuário administrador

1. No painel do Supabase → **Authentication → Users → Add user** (crie com seu e-mail).
2. No **SQL Editor**, rode:

   ```sql
   update profile set role = 'admin'
   where id = (select id from auth.users where email = 'seu-email@dominio.com');
   ```

Pronto — esse usuário passa a ter permissão de escrita em toda a plataforma.
