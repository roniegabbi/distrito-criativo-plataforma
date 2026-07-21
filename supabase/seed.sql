-- =====================================================================
--  SEED · DISTRITO CRIATIVO CENTRO-GARE
--  Rodar DEPOIS de schema.sql
-- =====================================================================

-- ---- Dimensões ----
insert into dimensao (slug,nome,cor,descricao,ordem) values
 ('amb','Ambiente Natural e Construído','#82BA26','Espaços naturais, patrimônio, mobilidade, iluminação e revitalização urbana.',1),
 ('gov','Governança e Políticas Públicas','#1A9BD7','Participação pública, segurança, engajamento, investimentos e desburocratização.',2),
 ('eco','Economia Criativa','#DD0079','Empreendedorismo, gastronomia, turismo, empregabilidade e talentos.',3),
 ('ide','Identidade e Recursos Culturais','#EFA81C','Memória ferroviária e belga, pertencimento, inclusão e cultura local.',4);

-- ---- Instituições ----
insert into instituicao (nome,sigla,tipo,email,telefone,is_fonte_recurso) values
 ('Prefeitura Municipal de Santa Maria','PMSM','publica','gabinete@santamaria.rs.gov.br','(55) 3921-7000',true),
 ('Sec. de Desenvolvimento Econômico e Inovação','SMDEI','publica','economico@santamaria.rs.gov.br','(55) 3921-7000',true),
 ('Secretaria de Município de Cultura','SMC','publica','cultura@santamaria.rs.gov.br','(55) 3921-7000',true),
 ('Universidade Federal de Santa Maria','UFSM','ensino','reitoria@ufsm.br','(55) 3220-8000',false),
 ('VIA Estação Conhecimento (UFSC)','VIA/UFSC','ensino','contato@via.ufsc.br',null,false),
 ('Sebrae RS','Sebrae','privada','atendimento@sebrae-rs.com.br','0800 570 0800',true),
 ('Ministério Público do RS','MPRS','publica',null,null,true),
 ('Banco Regional de Desenvolvimento do Extremo Sul','BRDE','publica',null,null,true),
 ('Sicredi','Sicredi','privada',null,null,true),
 ('Agência de Desenvolvimento de Santa Maria','Adesm','terceiro','contato@adesm.org.br',null,false),
 ('Instituto Caldeira','Caldeira','terceiro',null,null,false),
 ('Arquium Construções e Restauro','Arquium','privada',null,null,false),
 ('Tempo Arquitetos','Tempo','privada',null,null,false),
 ('Coletivo Memória Ativa','Mem. Ativa','coletivo',null,null,false);

-- ---- Pessoas ----
insert into pessoa (nome,email,telefone,instituicao_id,cargo,dimensao_id,papel,competencias) values
 ('Rose Carneiro','rose.carneiro@santamaria.rs.gov.br','(55) 99000-0001',(select id from instituicao where sigla='SMC'),'Secretária de Cultura',(select id from dimensao where slug='gov'),'coordenacao','{Gestão cultural,Patrimônio,Captação}'),
 ('Rodrigo Décimo','gabinete@santamaria.rs.gov.br',null,(select id from instituicao where sigla='PMSM'),'Prefeito de Santa Maria',(select id from dimensao where slug='gov'),'gestor','{Liderança institucional}'),
 ('Maico Fernandes','maico@santamaria.rs.gov.br',null,(select id from instituicao where sigla='SMDEI'),'Coord. de Economia Criativa',(select id from dimensao where slug='eco'),'lider','{Economia criativa,Empreendedorismo}'),
 ('Clarissa Stefani Teixeira','clarissa@via.ufsc.br',null,(select id from instituicao where sigla='VIA/UFSC'),'Coordenação metodológica',(select id from dimensao where slug='gov'),'membro','{Metodologia,Distritos criativos,Pesquisa}'),
 ('Cristiane Thies',null,null,(select id from instituicao where sigla='Arquium'),'Arquiteta responsável',(select id from dimensao where slug='amb'),'gt','{Arquitetura,Restauro,Projetos técnicos}');

-- ---- Comitês ----
insert into comite (tipo,nome,dimensao_id) values
 ('assembleia','Assembleia Colegiada',null),
 ('gestor','Comitê Gestor',null),
 ('coordenacao','Coordenação Executiva',null),
 ('executivo','Comitê Executivo — Ambiente Natural e Construído',(select id from dimensao where slug='amb')),
 ('executivo','Comitê Executivo — Governança e Políticas Públicas',(select id from dimensao where slug='gov')),
 ('executivo','Comitê Executivo — Economia Criativa',(select id from dimensao where slug='eco')),
 ('executivo','Comitê Executivo — Identidade e Recursos Culturais',(select id from dimensao where slug='ide'));

-- ---- Projeto exemplo: Clube dos Ferroviários ----
with p as (
  insert into projeto (nome,dimensao_id,status,progresso,descricao,lider_id,inicio,fim,prazo,orcamento)
  values ('Revitalização do Clube dos Ferroviários (AEVF)',
    (select id from dimensao where slug='amb'),'em_execucao',8,
    'Restauro do antigo Clube dos Ferroviários para o Centro de Inovação e Economia Criativa e nova sede da Emaet. Projeto "Túnel do Tempo" (Iconicidades).',
    (select id from pessoa where nome='Rose Carneiro'),'14/07/2026','~07/2028','720 dias (24 meses)',14779656.58)
  returning id)
insert into fonte_recurso (projeto_id,instituicao_id,natureza,nome,valor)
 select p.id,(select id from instituicao where sigla='MPRS'),'publica'::natureza_recurso,'FRBL — Ministério Público (MPRS)',10000000 from p
 union all select p.id,(select id from instituicao where sigla='BRDE'),'publica'::natureza_recurso,'Programa Pró-Cidades / BRDE',3000000 from p
 union all select p.id,(select id from instituicao where sigla='PMSM'),'publica'::natureza_recurso,'Contrapartida do Município',1779656.58 from p;

-- ---- Eventos (os 5 eixos) ----
insert into evento (nome,eixo,status,resumo,local,quando,publico_txt,publico_num,orcamento,destaque) values
 ('Festival do Xis','gastro','realizado','Festival gastronômico-cultural que celebra Santa Maria como "Cidade do Xis".','Gare da Viação Férrea','Novembro · anual','35.000',35000,520000,'+35 mil pessoas'),
 ('Calourada Segura','univ','recorrente','Recepção oficial dos calouros universitários na Gare, com estrutura de segurança.','Gare da Viação Férrea','Março e agosto · semestral','5.600–16.000',16000,300000,'Até 16 mil universitários'),
 ('Santa Summit','inova','recorrente','Maior evento de inovação e empreendedorismo da região central, com batalha de startups.','Mercado da Vila Belga / UFSM','Set–Nov · anual','Milhares',5000,800000,'5 pilares'),
 ('Mapeando Memórias','memoria','continuo','Resgate da memória ferroviária e histórias orais do território.','Centro Histórico Ferroviário','Contínuo','Comunidade',0,120000,'Histórias orais'),
 ('Incubadora Social da UFSM · Hub IS','social','continuo','Incubação de empreendimentos de economia solidária; Hub IS conecta universidade, poder público e comunidade.','Território / CRAS / Vila Belga','Contínuo (desde 2012)','Empreendimentos solidários',0,200000,'Economia solidária');

-- =====================================================================
--  Após criar seu primeiro usuário no Auth, promova-o a admin:
--  update profile set role = 'admin' where id = (select id from auth.users where email = 'voce@dominio.com');
-- =====================================================================
