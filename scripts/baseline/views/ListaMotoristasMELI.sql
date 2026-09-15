-- ============================================================
-- BASELINE: dbo.ListaMotoristasMELI
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[ListaMotoristasMELI]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[ListaMotoristasMELI] AS 

SELECT * from vw_Dados_motoristas_ml where idtransportadora  = 11
GO
