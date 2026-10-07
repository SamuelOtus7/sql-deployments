/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-SEM-TASK (dimensoes dos relatorios web)
  Autor        : Devin
  Data         : 2026-09-22
  Descrição    : Cria as dimensoes de filtro usadas pelos relatorios HTML web
                 (padrao template-relatorio-padrao, ex.: pgto-vs-recebimento).

                 vw_dim_base        : cadastro de bases/service centers a partir
                                      de tb_bases (1 linha por base cadastrada).
                                      Grao de join da fato: bss_ds_sigla +
                                      bss_cd_idtransportadora (mesmo join de
                                      vw_ml_rotas_financeiro). bss_cod_cliente
                                      alimenta a cascata Tenant -> Base
                                      (pgp_cd_cliente = bss_cod_cliente).

                 vw_dim_cidade_ibge : cidades normalizadas via IBGE, a partir de
                                      tb_codigos_cidades JOIN tb_estados_ibge
                                      (cid_cd_estado = tb_estados_ibge.ibge).
                                      Grao: nome da cidade (a fato so carrega
                                      o nome, sem UF). cidade_uf traz o rotulo
                                      "Cidade - UF" ou "Cidade - UF1/UF2"
                                      quando o nome existe em mais de um estado.

                 Sao VIEWS (nao tabelas fisicas) porque os cadastros de origem
                 mudam com o tempo — a view reflete sempre o cadastro atual e
                 nao precisa de rotina de refresh/ETL. O login de servico dos
                 relatorios (usr_relatorio_web, db_datareader) le views
                 normalmente.

                 Uso previsto:
                   - /api/filtros carrega as opcoes dos selects a partir destas
                     views quando a tela abre (tenant, base, cidade);
                   - o WHERE da fato continua filtrando pelo VALOR
                     (f.Base = @base / f.cidade = @cidade), parametrizado;
                   - Faixa de km e Tipo de veiculo NAO mudam (seguem vindos da
                     fato, como hoje).

                 NOTA: CREATE OR ALTER VIEW exige ser o primeiro statement do
                 batch — por isso as views ficam fora do TRY/CATCH, separadas
                 por GO, e os checks ficam em batches proprios.
  Rollback     : scripts/rollback/2026/09/008_rollback_dim_relatorios_web.sql
  Objetos      : VIEW dbo.vw_dim_base, VIEW dbo.vw_dim_cidade_ibge
  Dependências : dbo.tb_bases, dbo.tb_codigos_cidades, dbo.tb_estados_ibge
  ==============================================================================*/

SET NOCOUNT ON;

--==========================================================================
-- 1. PRE-CHECKS — tabelas de origem existem
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_bases') AND type = 'U')
        THROW 50008, 'Tabela dbo.tb_bases nao encontrada', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_codigos_cidades') AND type = 'U')
        THROW 50008, 'Tabela dbo.tb_codigos_cidades nao encontrada', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.tb_estados_ibge') AND type = 'U')
        THROW 50008, 'Tabela dbo.tb_estados_ibge nao encontrada', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO no pre-check: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--==========================================================================
-- 2. DIM BASE / SERVICE CENTER  (fonte: tb_bases)
--==========================================================================
-- Grao: 1 linha por base cadastrada (bss_cd_base).
-- Atencao: bss_ds_sigla NAO e unica — a mesma sigla se repete por
-- transportadora (ex.: SMG8 existe em 13 transportadoras). A unicidade real
-- e (bss_cd_idtransportadora, bss_ds_sigla), mesmo criterio do join da rota.
-- Filtro: bss_in_status = 1 AND bss_in_excluido = 0 — mesmo criterio de
-- tb_ml_service_center, que e a ponte rota -> base usada na fato.
--==========================================================================
CREATE OR ALTER VIEW dbo.vw_dim_base
AS
SELECT
    bss_cd_base             AS id_base,
    bss_ds_sigla            AS base,                -- valor do WHERE (f.Base = @base)
    bss_ds_label            AS base_label,
    bss_ds_nome_amigavel    AS base_nome_amigavel,
    bss_cd_idtransportadora AS id_transportadora,   -- chave real do join com a rota
    bss_cod_cliente         AS id_cliente,          -- cascata Tenant (pgp_cd_cliente)
    bss_ds_cidade           AS cidade,
    bss_ds_estado           AS uf,
    bss_ds_regiao           AS regiao,
    bss_ds_marketplace      AS marketplace
FROM dbo.tb_bases WITH (NOLOCK)  -- NOLOCK intencional: dim de filtro, dirty read aceitavel (padrao das views do banco)
WHERE bss_in_status   = 1
  AND bss_in_excluido = 0;
GO

--==========================================================================
-- 3. DIM CIDADE NORMALIZADA  (tb_codigos_cidades + tb_estados_ibge)
--==========================================================================
-- Grao: 1 linha por nome de cidade (a fato so tem o nome, sem UF).
-- Join estado validado: cid_cd_estado = tb_estados_ibge.ibge
--   (5.575 linhas, 0 orfas em 22/09/2026).
-- uf_lista/cidade_uf: quando o nome existe em mais de uma UF, o rotulo
-- mostra todas ("Agua Boa - MG/MT") — o WHERE continua casando pelo nome.
--==========================================================================
CREATE OR ALTER VIEW dbo.vw_dim_cidade_ibge
AS
WITH mun AS (
    SELECT DISTINCT
        LTRIM(RTRIM(c.cid_ds_cidade)) AS cidade,
        e.sigla                     AS uf
    FROM dbo.tb_codigos_cidades c WITH (NOLOCK)  -- NOLOCK intencional: dim de filtro, dirty read aceitavel
    JOIN dbo.tb_estados_ibge    e WITH (NOLOCK)  -- NOLOCK intencional: dim de filtro, dirty read aceitavel
        ON c.cid_cd_estado = e.ibge
    WHERE c.cid_ds_cidade IS NOT NULL
      AND LTRIM(RTRIM(c.cid_ds_cidade)) <> ''
)
SELECT
    cidade,
    MIN(uf)    AS uf,          -- UF principal (quando ha so uma, e a UF)
    COUNT(*)   AS qtd_ufs,     -- >1: nome de cidade repetido entre UFs
    STRING_AGG(uf, '/') WITHIN GROUP (ORDER BY uf)                 AS uf_lista,
    cidade + ' - ' + STRING_AGG(uf, '/') WITHIN GROUP (ORDER BY uf) AS cidade_uf
FROM mun
GROUP BY cidade;
GO

--==========================================================================
-- 4. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.vw_dim_base')        AND type = 'V')
        THROW 50008, 'View dbo.vw_dim_base nao foi criada', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID('dbo.vw_dim_cidade_ibge') AND type = 'V')
        THROW 50008, 'View dbo.vw_dim_cidade_ibge nao foi criada', 1;

    PRINT 'SUCESSO: vw_dim_base e vw_dim_cidade_ibge criadas.';
END TRY
BEGIN CATCH
    PRINT 'ERRO no pos-check: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
