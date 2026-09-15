-- ============================================================
-- BASELINE: dbo.vw_monitor_pgto_espelhos_erros
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitor_pgto_espelhos_erros]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_monitor_pgto_espelhos_erros]
AS
SELECT
    pee_id,
    pee_cd_motorista,
    pee_base,
    pee_cd_periodo,
    pee_ds_erro,
    pee_dh_criacao
FROM dbo.tb_pag_espelhos_erros;
GO
