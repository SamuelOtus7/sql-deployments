/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Reverte a inclusao de DataInicioPrefatura (script 042),
                 voltando a view ao estado do script 041 (com dedup de cliente).
  Objetos      : dbo.vw_fin_prefatura_totais (ALTER VIEW)
  ==============================================================================*/

SET NOCOUNT ON;
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

    PRINT 'View dbo.vw_fin_prefatura_totais revertida (sem DataInicioPrefatura).';
    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (rollback): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
