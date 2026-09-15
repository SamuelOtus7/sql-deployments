-- ============================================================
-- BASELINE: dbo.vw_monitor_pgto_rotas_erros
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitor_pgto_rotas_erros]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_monitor_pgto_rotas_erros]
AS
SELECT
    pre_id,
    pre_cd_rota,
    pre_base,
    pre_cd_periodo,
    pre_ds_erro,
    pre_dh_criacao
FROM dbo.tb_pgto_periodo_rota_erro;
GO
