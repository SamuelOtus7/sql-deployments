-- ============================================================
-- BASELINE: dbo.vw_rotas_coopmetro_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_coopmetro_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO











CREATE view [dbo].[vw_rotas_coopmetro_off]
as
select 
	r.*
from
	vw_rotas r
where
	r.IdTransportadora = 1070423464
	and r.DataReferencia = (
		select
			max(DataReferencia)
		from
			vw_rotas r2
		where
			r2.IdTransportadora  = 1070423464
			and r2.IdRota = r.IdRota
			--and r2.DataReferencia >= dateadd(month,-3,getdate())
	)
GO
