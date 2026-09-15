-- ============================================================
-- BASELINE: dbo.vw_rotas_nikkey_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_nikkey_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_rotas_nikkey_off]
as
select 
	r.*
from
	vw_rotas r
where
	r.IdTransportadora = 2144088496
GO
