-- ============================================================
-- BASELINE: dbo.vw_pgto_periodo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_periodo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_pgto_periodo] AS
SELECT
    pgp_cd_periodo,
    pgp_nm_periodo,
    pgp_dt_inicio,
    pgp_dt_fim,
    pgp_cd_status,
    pgp_dt_pagamento,
    pgp_dt_limite_reanalise,
    pgp_cd_cliente,
    pgp_cd_tipo_contratos,
    CAST(
        CASE
            WHEN pgp_dt_inicio >= DATEADD(DAY, -60, CAST(GETDATE() AS DATE))
            THEN CAST(GETDATE() AS DATE)
            ELSE pgp_dt_inicio
        END AS DATETIME
    ) AS DataAtualizacaoControlePowerBI,
    ttc_nm_tipo,
    lt.lst_ds_valor AS ClienteTransportadora
FROM dbo.tb_pgto_periodo AS a
LEFT JOIN dbo.tb_lista AS lt
    ON lt.lst_cd_lista = a.pgp_cd_cliente_transportadora
LEFT JOIN dbo.tb_tipo_contrato AS b
    ON a.pgp_cd_tipo_contratos = b.ttc_cd_tipo_contrato
WHERE pgp_in_excluido = 0
  AND pgp_cd_periodo > 370;
GO
