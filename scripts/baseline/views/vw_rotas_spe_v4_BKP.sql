-- ============================================================
-- BASELINE: dbo.vw_rotas_spe_v4_BKP
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_spe_v4_BKP]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[vw_rotas_spe_v4_BKP]
as

select 
	rotas.Id IdInterno,
	rotas.CodigoRota,
	rotas.IdStation,
	station.NomeStation NomeHub,
	station.CodigoStation Hub,
	rotas.IdTransportadora,
	motoristas.IdMotorista,
	motoristas.NomeMotorista Motorista,
	rotas.DataReferencia,
	rotas.TotalPacotes,
	rotas.PacotesEntregues,
	rotas.PacotesNaoEntregue,
	rotas.PacotesPendentes,
	case when rotas.TotalPacotes = PacotesEntregues + PacotesNaoEntregue then 1 else 0 end RotaFinalizada,
	rotas.DataUltimaEntrega,
	rotas.KmColetado,
	rotas.LinkMapa,
	rotas.TipoVeiculo,
	DataHoraInicio,
    case
    when DATEPART(HOUR,rotas.DataHoraCarga) between 0 and 11 
    then '0h - 11h'
    when DATEPART(HOUR,rotas.DataHoraCarga) between 12 and 15 
    then '12h - 15hs'
    when DATEPART(HOUR,rotas.DataHoraCarga) between 16 and 17 
    then '16hs - 17hs'
    when DATEPART(HOUR,rotas.DataHoraCarga) between 18 and 23 
    then '18hs - 23hs'
    end FiltroCarregamento,
    Paradas,
    CidadeReferencia,
    DistanciaTotal,
	case when tlm_cd_risco_ajudante = 'risco' then 'Sim' else 'Não' end as LancRisco,
	UsuarioIrisys



	-- case when datepart(HOUR, DataHoraInicio) >= 12 then 'PM' ELSE 'AM' end  CicloPM

from
	tb_spe_rotas_v4 rotas with(nolock)
	LEFT join tb_spe_motoristas motoristas with(nolock) on rotas.IdMotorista = motoristas.IdMotorista and rotas.IdTransportadora = motoristas.IdTransportadora
	left join tb_spe_station station with(nolock) on rotas.IdStation = station.IdStation
	left join (
				select 
					a.tlm_cd_rota
					,a.tlm_cd_risco_ajudante

				from tb_lancamentos_manuais as a
				inner join (
					select 
					tlm_cd_lancamento_manual	
					,tlm_cd_rota
					,ROW_NUMBER() over(partition by tlm_cd_rota order by tlm_cd_lancamento_manual desc) ordem
					from tb_lancamentos_manuais
					where tlm_cd_cliente = 27
					and tlm_cd_risco_ajudante = 'Risco'
					--and tlm_cd_rota = 'AT202405131ORMZ'
				) as b
				on a.tlm_cd_lancamento_manual = b.tlm_cd_lancamento_manual
				and b.ordem = 1
	) as lanc
	on cast(rotas.CodigoRota as varchar(50)) = lanc.tlm_cd_rota


where 1=1
	and rotas.Excluido = 0
	and (rotas.TotalPacotes > 0 or (rotas.IdTransportadora in (20230008) and rotas.CodigoRota like 'to%' ))
	--AND codigorota = 'AT2024060722LRC'
	--and rotas.DataReferencia = '2024-06-18'
	
	--select * from tb_spe_rotas_v4 where CodigoRota = 'AT2024060520ZJ6'

	--select * from tb_spe_motoristas where IdMotorista = 90895

GO
