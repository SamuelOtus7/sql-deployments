-- ============================================================
-- BASELINE: dbo.sp_temp_teste_execucao_rotinas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_temp_teste_execucao_rotinas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_temp_teste_execucao_rotinas] as
begin
	insert into tb_temp_teste_execucao_rotinas values (getdate())
end
GO
