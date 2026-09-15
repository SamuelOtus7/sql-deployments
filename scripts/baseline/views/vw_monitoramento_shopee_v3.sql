-- ============================================================
-- BASELINE: dbo.vw_monitoramento_shopee_v3
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_shopee_v3]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_monitoramento_shopee_v3]

as

select top 10000
	   stations.*,
	   rotas.QtdeColetasRotas,
	   rotas.PrimeiraColetaRota,
	   rotas.UltimaColetaRota,
	   rotas.TempoSemColetaRota,
	   rotas.RotaMaisAtrasada,
	   rotas.TempoRotaMaisAtrasada
from (
		select cli.cli_ds_nome as Cliente,
			   st.IdStation,
			   st.NomeStation as Station,
			   workers.DataHoraUltimaExecucao,
			   workers.Usuario,
			   count(*) as QtdeColetas,
			   min(dateadd(hour,-3,dac_dh_coleta)) as PrimeiraColeta,
			   max(dateadd(hour,-3,dac_dh_coleta)) as UltimaColeta,
			   format(dateadd(second, datediff(second,max(dateadd(hour,-3,dac_dh_coleta)), getdate()), 0),'HH:mm:ss') as TempoSemColeta
		from db_Irisys_Json.dbo.tb_dra_coleta as dac with(nolock)
			join tb_clientes as cli with(nolock) on dac.dac_cd_transportadora = cli.cli_id_shopee
			join tb_spe_station st with(nolock) on dac.dac_ds_contexto = st.IdStation
			inner join vw_cadastro_workers as workers with(nolock)
			on cli.cli_ds_nome = workers.Cliente
			and st.IdStation = workers.Stationid
		where dac_ds_tipo_coleta = 'SPE4_ROUTES'
			  and cast(dateadd(hour,-3,dac_dh_coleta) as date) = cast(getdate() as date)
		group by cli.cli_ds_nome,
				 st.NomeStation,
				 st.IdStation,
				 workers.DataHoraUltimaExecucao,
			     workers.Usuario
	) as Stations
	left join (
				select  Cliente,
						Station,
						count(distinct Rota) as Rotas,
						sum(QtdeColetasRotas) as QtdeColetasRotas,
						min(PrimeiraColetaRota) as PrimeiraColetaRota,
						min(UltimaColetaRota) as RotaMaisAtrasada,
						max(UltimaColetaRota) as UltimaColetaRota,
						min(TempoSemColetaRota) as TempoSemColetaRota,
						max(TempoSemColetaRota) as TempoRotaMaisAtrasada
				from (
						select cli.cli_ds_nome as Cliente,
								st.NomeStation as Station,
								dac_ds_contexto as Rota,
								count(*) as QtdeColetasRotas,
								min(dateadd(hour,-3,dac_dh_coleta)) as PrimeiraColetaRota,
								max(dateadd(hour,-3,dac_dh_coleta)) as UltimaColetaRota,
								format(dateadd(second, datediff(second,max(dateadd(hour,-3,dac_dh_coleta)), getdate()), 0),'HH:mm:ss') as TempoSemColetaRota
						from db_Irisys_Json.dbo.tb_dra_coleta as dac with(nolock)
							join tb_clientes as cli with(nolock) on dac.dac_cd_transportadora = cli.cli_id_shopee
							join tb_spe_rotas_v4 as rotas with(nolock) on dac.dac_ds_contexto = rotas.CodigoRota
							join tb_spe_station st with(nolock) on rotas.IdStation = st.IdStation
						where dac_ds_tipo_coleta = 'SPE4_PACKAGES'
								and cast(dateadd(hour,-3,dac_dh_coleta) as date) = cast(getdate() as date)
						group by cli.cli_ds_nome,
								 st.NomeStation,
								 dac_ds_contexto
					 ) as coletas
				group by Cliente,
						 Station
	) as rotas
	on stations.Cliente = rotas.Cliente 
	and stations.Station = rotas.Station
order by stations.Cliente,
	     stations.TempoSemColeta desc

GO
