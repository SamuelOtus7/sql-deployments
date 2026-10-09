/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Corrige fan-out em dbo.vw_fin_prefatura_totais.
                 O join t.IdTransportadora = c.cli_id_logistics multiplicava
                 linhas quando a transportadora tinha MAIS DE UM registro em
                 tb_clientes (detectado no deploy PROD do script 038:
                 IdTransportadora 2087146923 mapeia ALC Transportes [inativo]
                 + Otus7 [ativo] -> view retornava 611 linhas vs 561 da tabela).
                 Nao da para filtrar cli_in_ativo=1: 18 transportadoras so tem
                 cadastro inativo e perderiam CodCliente/Cliente.
                 Solucao: OUTER APPLY TOP 1 por transportadora, preferindo
                 cliente ativo (cli_in_ativo DESC) e menor codigo como
                 desempate determinístico.
  Rollback     : scripts/rollback/2026/10/041_rollback_CU-86ahpqmf9_vw_prefatura_totais_dedup.sql
  Objetos      : dbo.vw_fin_prefatura_totais (ALTER VIEW)
  Dependencias : dbo.tb_fin_prefatura_totais, dbo.tb_clientes (deploy 038)
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECK
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_fin_prefatura_totais'))
        THROW 50041, 'View dbo.vw_fin_prefatura_totais nao encontrada (aplicar 038 antes).', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. ALTER VIEW - um cliente por transportadora (prefere ativo)
--============================================================================
BEGIN TRY
    EXEC('
    ALTER VIEW dbo.vw_fin_prefatura_totais AS
    SELECT
        t.IdTransportadora,
        c.cli_cd_codigo_cliente AS CodCliente,
        c.cli_ds_nome           AS Cliente,
        t.Ano,
        t.Mes,
        t.Quinzena,
        CONCAT(t.Ano, RIGHT(''0'' + CONVERT(varchar(2), t.Mes), 2), ''Q'', t.Quinzena) AS PeriodoML,
        t.IDPrefatura,
        t.SubtotalServicos,
        t.SubtotalAdicionais,
        t.SubtotalPrefatura,
        t.GlosaPrefatura,
        t.AdicionaisPortal,
        t.PenLost,
        t.PenPnr,
        t.PenNotVisited,
        t.TotalPenalidades,
        t.TotalPrefatura,
        t.TotalComCTE,
        t.DataCarga
    FROM dbo.tb_fin_prefatura_totais t
    OUTER APPLY
    (
        SELECT TOP 1 c2.cli_cd_codigo_cliente, c2.cli_ds_nome
        FROM dbo.tb_clientes c2 WITH (NOLOCK)
        WHERE c2.cli_id_logistics = t.IdTransportadora
        ORDER BY c2.cli_in_ativo DESC, c2.cli_cd_codigo_cliente
    ) c
    ');

    PRINT 'View dbo.vw_fin_prefatura_totais alterada (dedup por transportadora).';
END TRY
BEGIN CATCH
    PRINT 'ERRO (alter view): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 3. POS-CHECK - view nao pode retornar mais linhas que a tabela
--============================================================================
BEGIN TRY
    DECLARE @t INT = (SELECT COUNT(*) FROM dbo.tb_fin_prefatura_totais WITH (NOLOCK));
    DECLARE @v INT = (SELECT COUNT(*) FROM dbo.vw_fin_prefatura_totais);
    IF @v <> @t
        THROW 50042, 'Pos-check: view continua divergindo da tabela.', 1;
    PRINT 'Pos-check OK: view = tabela = ' + CAST(@v AS varchar) + ' linhas.';
    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (pos-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
