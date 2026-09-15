-- ============================================================
-- BASELINE: dbo.UspDeleteReport
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspDeleteReport]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[UspDeleteReport]
(
	@relatorio int
)
as
declare @controller int = (select rel_cd_controller from tb_relatorios where rel_cd_relatorio = @relatorio)
delete from tb_relatorio_logs where rel_cd_relatorio = @relatorio
delete from tb_relatorios where rel_cd_relatorio = @relatorio
exec UspDeleteController @controller
GO
