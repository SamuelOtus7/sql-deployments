-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaPendentes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaPendentes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspSPEAtualizaPendentes]
as
begin

exec UspSPEAtualizaPacotesPendentes
exec UspSPEAtualizaRotasPendentes 

end 
GO
