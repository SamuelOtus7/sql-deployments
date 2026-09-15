-- ============================================================
-- BASELINE: dbo.vw_financeiro_complementar_km_coopmetro_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_complementar_km_coopmetro_off]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_financeiro_complementar_km_coopmetro_off]
as
select
	*
from
	vw_financeiro_complementar_km
where
	IdTransportadora = 1070423464
GO
