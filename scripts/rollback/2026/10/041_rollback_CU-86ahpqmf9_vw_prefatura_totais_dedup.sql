/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahpqmf9
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-09
  Descricao    : Reverte o dedup de vw_fin_prefatura_totais (script 041),
                 voltando ao LEFT JOIN original do deploy 038.
                 ATENCAO: o rollback reintroduz o fan-out para transportadoras
                 com mais de um registro em tb_clientes.
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
    LEFT JOIN dbo.tb_clientes c WITH (NOLOCK)
        ON c.cli_id_logistics = t.IdTransportadora
    ');

    PRINT 'View dbo.vw_fin_prefatura_totais revertida ao join original.';
    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO (rollback): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO
