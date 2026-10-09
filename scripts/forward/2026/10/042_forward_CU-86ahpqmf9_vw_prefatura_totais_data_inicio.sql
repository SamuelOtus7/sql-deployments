/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Inclui DataInicioPrefatura em dbo.vw_fin_prefatura_totais.
                 O dump do portal (tb_fin_prefatura_upload) nao traz data de
                 inicio — so o rotulo 'YYYYMMQn'. A data e derivada do periodo:
                 quinzena 1 -> dia 01; quinzena 2 -> dia 16.
                 (MIN(tb_fin_prefatura.DataInicio) NAO serve: e a data da
                 primeira rota itemizada e pode comecar antes da quinzena.)
  Rollback     : scripts/rollback/2026/10/042_rollback_CU-86ahpqmf9_vw_prefatura_totais_data_inicio.sql
  Objetos      : dbo.vw_fin_prefatura_totais (ALTER VIEW)
  Dependencias : deploy 038 (tabela + view) e 041 (dedup cliente)
  ==============================================================================*/

SET NOCOUNT ON;
GO

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_fin_prefatura_totais'))
        THROW 50043, 'View dbo.vw_fin_prefatura_totais nao encontrada (aplicar 038/041 antes).', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

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
        DATEFROMPARTS(t.Ano, t.Mes, CASE t.Quinzena WHEN 1 THEN 1 ELSE 16 END) AS DataInicioPrefatura,
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

    PRINT 'View dbo.vw_fin_prefatura_totais alterada (+DataInicioPrefatura).';
    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (alter view): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
