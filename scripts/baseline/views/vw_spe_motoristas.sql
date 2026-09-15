-- ============================================================
-- BASELINE: dbo.vw_spe_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_spe_motoristas]
as
select
	m.IdMotorista, m.Nome
from
	tb_spe_motoristas m
	join (
		select	
			Nome,
			count(1) Qtde
		from
			tb_spe_motoristas
		group by
			Nome
		having
			count(1) = 1
	) m2 on m.Nome = m2.Nome
where
	m.IdTransportadora is null
	and m.Nome <> ''
GO
