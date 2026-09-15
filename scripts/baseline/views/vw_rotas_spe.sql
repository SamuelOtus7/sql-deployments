-- ============================================================
-- BASELINE: dbo.vw_rotas_spe
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_spe]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_rotas_spe]
as
select
	rotas.Id IdInterno,
	rotas.IdStation,
	station.NomeStation NomeHub,
	station.CodigoStation Hub,
	rotas.IdTransportadora,
	motoristas.NomeMotorista Motorista,
	rotas.DataReferencia,
	rotas.TotalPacotes,
	rotas.PacotesEntregues,
	rotas.PacotesNaoEntregue,
	rotas.PacotesPendentes,
	case when rotas.TotalPacotes = PacotesEntregues + PacotesNaoEntregue then 1 else 0 end RotaFinalizada,
	rotas.DataUltimaEntrega
from
	tb_spe_rotas rotas with(nolock)
	join tb_spe_motoristas motoristas with(nolock) on rotas.IdMotorista = motoristas.IdMotorista
	left join tb_spe_station station with(nolock) on rotas.IdStation = station.IdStation
where
	(motoristas.Ativo = 1 or rotas.DataReferencia < motoristas.DataInativo)

GO
