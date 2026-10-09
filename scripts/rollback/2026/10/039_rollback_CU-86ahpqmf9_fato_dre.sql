/*==============================================================================
  ROLLBACK SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Remove o modelo estrela da Fato DRE criado pelo forward 039:
                 triggers de auditoria, procedure, view, fato, tabelas de apoio
                 e dimensoes novas. Nao toca nas fontes (tb_fin_prefatura*,
                 tb_pag_espelhos, DimData, tb_clientes, tb_bases) nem em
                 tb_fin_cadastro_impostos (apenas remove a trigger de auditoria).
  Forward      : scripts/forward/2026/10/039_forward_CU-86ahpqmf9_fato_dre.sql
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fato_dre'))
        PRINT 'Aviso: tb_fato_dre nao existe — rollback parcial.';
    PRINT 'Pre-checks OK.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. TRIGGERS DE AUDITORIA
--============================================================================
IF OBJECT_ID('dbo.trg_aud_fato_dre_orcado', 'TR')      IS NOT NULL DROP TRIGGER dbo.trg_aud_fato_dre_orcado;
IF OBJECT_ID('dbo.trg_aud_cadastro_impostos', 'TR')    IS NOT NULL DROP TRIGGER dbo.trg_aud_cadastro_impostos;
IF OBJECT_ID('dbo.trg_aud_dim_visao', 'TR')            IS NOT NULL DROP TRIGGER dbo.trg_aud_dim_visao;
IF OBJECT_ID('dbo.trg_aud_dim_origem', 'TR')           IS NOT NULL DROP TRIGGER dbo.trg_aud_dim_origem;
IF OBJECT_ID('dbo.trg_aud_dim_marketplace', 'TR')      IS NOT NULL DROP TRIGGER dbo.trg_aud_dim_marketplace;
IF OBJECT_ID('dbo.trg_aud_dim_dre_estrutura', 'TR')    IS NOT NULL DROP TRIGGER dbo.trg_aud_dim_dre_estrutura;
IF OBJECT_ID('dbo.trg_aud_dim_dre_indicador', 'TR')    IS NOT NULL DROP TRIGGER dbo.trg_aud_dim_dre_indicador;
IF OBJECT_ID('dbo.trg_aud_dim_plano_contas', 'TR')     IS NOT NULL DROP TRIGGER dbo.trg_aud_dim_plano_contas;
GO

--============================================================================
-- 3. PROCEDURE E VIEW
--============================================================================
IF OBJECT_ID('dbo.sp_fin_dre_carga', 'P') IS NOT NULL DROP PROCEDURE dbo.sp_fin_dre_carga;
IF OBJECT_ID('dbo.vw_fin_fato_dre', 'V') IS NOT NULL DROP VIEW dbo.vw_fin_fato_dre;
GO

--============================================================================
-- 4. FATO + APOIO + DIMENSOES (ordem inversa de dependencia)
--============================================================================
IF OBJECT_ID('dbo.tb_fato_dre', 'U')              IS NOT NULL DROP TABLE dbo.tb_fato_dre;
IF OBJECT_ID('dbo.tb_fin_dre_carga_log', 'U')     IS NOT NULL DROP TABLE dbo.tb_fin_dre_carga_log;
IF OBJECT_ID('dbo.tb_fin_dre_processamento', 'U') IS NOT NULL DROP TABLE dbo.tb_fin_dre_processamento;
IF OBJECT_ID('dbo.tb_aud_dre', 'U')               IS NOT NULL DROP TABLE dbo.tb_aud_dre;
IF OBJECT_ID('dbo.tb_dim_dre_estrutura', 'U')     IS NOT NULL DROP TABLE dbo.tb_dim_dre_estrutura;
IF OBJECT_ID('dbo.tb_dim_plano_contas', 'U')      IS NOT NULL DROP TABLE dbo.tb_dim_plano_contas;
IF OBJECT_ID('dbo.tb_dim_dre_indicador', 'U')     IS NOT NULL DROP TABLE dbo.tb_dim_dre_indicador;
IF OBJECT_ID('dbo.tb_dim_marketplace', 'U')       IS NOT NULL DROP TABLE dbo.tb_dim_marketplace;
IF OBJECT_ID('dbo.tb_dim_origem', 'U')            IS NOT NULL DROP TABLE dbo.tb_dim_origem;
IF OBJECT_ID('dbo.tb_dim_visao', 'U')             IS NOT NULL DROP TABLE dbo.tb_dim_visao;
GO

--============================================================================
-- 5. POS-CHECKS
--============================================================================
BEGIN TRY
    IF EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_fato_dre'))
        THROW 50020, 'tb_fato_dre ainda existe.', 1;
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.sp_fin_dre_carga'))
        THROW 50021, 'sp_fin_dre_carga ainda existe.', 1;
    PRINT 'Rollback concluido.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
