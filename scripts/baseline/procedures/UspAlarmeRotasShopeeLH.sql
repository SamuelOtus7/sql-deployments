-- ============================================================
-- BASELINE: dbo.UspAlarmeRotasShopeeLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAlarmeRotasShopeeLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[UspAlarmeRotasShopeeLH] as
IF NOT EXISTS (
    SELECT 1
    FROM tb_spe_rotas_v5
    WHERE DataReferencia = CAST(GETDATE() AS date)
)
BEGIN
    SELECT '? Nenhum registro encontrado para a data atual' AS Alerta;
END
GO
