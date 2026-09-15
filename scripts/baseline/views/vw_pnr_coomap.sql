-- ============================================================
-- BASELINE: dbo.vw_pnr_coomap
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pnr_coomap]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_pnr_coomap] AS
SELECT 
     IdRota
    , SUM([Vehicle Daily Not])        AS Vehicle
    , SUM([Pnr Packages Penalty:])    AS PNR
    , SUM([Lost Packages Penalty:])   AS Lost
FROM (
    SELECT 
        pnr.IdTransportadora,
        cli.cli_cd_codigo_cliente     AS TenantId,
        pnr.Ano,
        pnr.Mes,
        pnr.Quinzena,
        pnr.IdRota,
        pnr.DataReferencia,
        SUBSTRING(
            pnr.Descricao,
            1,
            CHARINDEX(
                ' ',
                pnr.Descricao + ' ',
                CHARINDEX(
                    ' ',
                    pnr.Descricao + ' ',
                    CHARINDEX(' ', pnr.Descricao + ' ') + 1
                ) + 1
            ) - 1
        ) AS Descricao,
        pnr.Total
    FROM tb_fin_prefatura_descontos pnr
    INNER JOIN tb_clientes cli
        ON pnr.IdTransportadora = cli.cli_id_logistics
    WHERE cli.cli_cd_codigo_cliente = 63
) AS src
PIVOT (
    SUM(Total)
    FOR Descricao IN (
        [Vehicle Daily Not],
        [Pnr Packages Penalty:],
        [Lost Packages Penalty:]
    )
) AS pvt
GROUP BY 
    IdRota;
GO
