-- ============================================================
-- BASELINE: dbo.vw_motoristas_nao_atribuidos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_motoristas_nao_atribuidos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- dbo.NewView source

create view [dbo].[vw_motoristas_nao_atribuidos]

as 
select IdMotorista as IdShopee,
	   NomeMotorista,
	   stations.NomeStation,
	   stations.Cidade
from tb_spe_motoristas as motoristas
	left join tb_spe_station  as stations
	on motoristas.IdStation = stations.IdStation
where Transportadora is null
GO
