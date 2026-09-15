-- ============================================================
-- BASELINE: dbo.vw_ml_fm_paradas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_fm_paradas]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_ml_fm_paradas]
as
select
	r.Id IdRotaInterno
	,p.*
from
	tb_ml_fm_paradas p with(nolock)
	join tb_ml_fm_rotas r with(nolock) on p.IdRota = r.IdRota 
									and p.IdTransportadora = r.IdTransportadora
									and p.DataReferencia = r.DataReferencia
									and r.Excluido = 0
where
	p.Excluido = 0
GO
