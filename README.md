# Plataforma Distrito Criativo Centro-Gare (web)

Site estático conectado ao **Supabase** (login real + dados do banco), pronto para publicar na **Vercel**.

## Estrutura
```
plataforma-web/
  index.html        ← a plataforma (Vitrine + Governança) já conectada ao Supabase
  assets/           ← logo, mapa e fotos
  vercel.json       ← configuração de cache/rotas
```

O Supabase já está embutido no `index.html`:
- URL: `https://phnthshtuyvchhwhihfh.supabase.co`
- Chave pública (publishable): segura para o front-end (a segurança real está nas políticas RLS do banco).

## Publicar na Vercel (via GitHub) — passo a passo

1. **Criar o repositório no GitHub**
   - Crie um repositório novo (ex.: `distrito-criativo-plataforma`).
   - Envie o conteúdo desta pasta (`plataforma-web/`) para a raiz do repositório.
   - Sem terminal? Use o botão **"uploading an existing file"** na página do repositório novo e arraste os arquivos.

2. **Importar na Vercel**
   - Acesse [vercel.com](https://vercel.com) e faça login com o GitHub.
   - **Add New… → Project** → selecione o repositório.
   - Framework Preset: **Other** (é um site estático, não precisa de build).
   - Root Directory: a raiz (onde está o `index.html`).
   - Clique em **Deploy**.

3. **Pronto**
   - Em ~30s a Vercel te dá uma URL pública (ex.: `distrito-criativo.vercel.app`).
   - A cada novo commit no GitHub, a Vercel republica sozinha.

## Como testar depois de publicado
- **Vitrine** (pública): abre direto; a seção "Acontece no Distrito" carrega os eventos do Supabase.
- **Área de Governança**: clique em "Área de Governança" e entre com:
  - e-mail: `ronie.gabbi74@gmail.com`
  - senha: a que você definiu (temporária: `Distrito@2026` — troque no Supabase).
- Dentro, os dados de Pessoas, Instituições, Projetos e Orçamento vêm do banco; criar um novo registro grava no Supabase de verdade.

## Domínio próprio (opcional)
Na Vercel → **Settings → Domains**, é possível apontar um domínio como `distrito.santamaria.rs.gov.br`.
