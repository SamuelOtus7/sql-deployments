-- ============================================================
-- BASELINE: dbo.vw_InfoRotaGuidId
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_InfoRotaGuidId]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_InfoRotaGuidId] as 
  
select 
	rotas.DataReferencia, 
	rotas.DataHoraInicio, 
	rotas.ServiceCenter, 
	rotas.OrigemSaida, 
	rotas.NomeMotorista, 
	rotas.TipoVeiculo,
	rotas.TotalPacotes,
	fin.FaixaPreFatura  as FaixaPreFatura,
	kmRota.opcaoKmPreFatura,
	cast(rotas.IdRota as varchar(50)) as IdRota

from vw_rotas as rotas
left join vw_resultado_financeiro as fin
on cast(rotas.IdRota as varchar(50)) = fin.IdRota
left join tb_ml_processamento_km_rotas as kmRota
on cast(rotas.IdRota as varchar(50)) = cast(kmRota.idRota as varchar(50))


		union all

select 
	rotas.DataReferencia, 
	rotas.DataHoraInicio, 
	rotas.nomehub, 
	rotas.nomehub, 
	rotas.motorista, 
	rotas.TipoVeiculo,
	rotas.TotalPacotes,
	fin.FaixaPreFatura  as FaixaPreFatura,
	kmRota.opcaoKmPreFatura,
	cast(rotas.codigorota as varchar(50)) as IdRota


from vw_rotas_spe_v4 as rotas

left join vw_resultado_financeiro as fin
on cast(rotas.codigorota as varchar(50)) = fin.IdRota

left join tb_processamento_km_rotas as kmRota
on cast(rotas.codigorota as varchar(50)) = cast(kmRota.idRota as varchar(50))

GO
