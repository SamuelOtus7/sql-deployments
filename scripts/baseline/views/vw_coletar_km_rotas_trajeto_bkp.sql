-- ============================================================
-- BASELINE: dbo.vw_coletar_km_rotas_trajeto_bkp
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_coletar_km_rotas_trajeto_bkp]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






create view [dbo].[vw_coletar_km_rotas_trajeto_bkp]
as
select top 100000000 *
from (
select
	IdRota,
	DataReferencia,
	ServiceCenter 'Parada',
	Latitude,
	Longitude,
	0 SequenciaParada
from
	vw_coletar_km_rotas

union all

select
	distinct
	r.IdRota,
	r.DataReferencia,
	p.EnderecoParada 'Parada',
	cast(p.LatitudeEnderecoParada as decimal(18, 9)) Latitude,
	cast(p.LongitudeEnderecoParada as decimal(18, 9)) Longitude,
	isnull(p.SequenciaParada,0) SequenciaParada
from
	vw_coletar_km_rotas r
	join tb_ml_pacotes p on r.IdRota = p.IdRota and r.DataReferencia = p.DataReferencia
where
	isnull(p.LatitudeEnderecoParada, '') <> ''
	and p.Excluido = 0
	and p.StatusEntrega in ('delivered', 'not_delivered')
	and isnull(p.SubStatus,'') <> 'transferred'
	--verifica qual é a latitude (considerando só a parte inteira) mais comum entre os pacotes e considera apenas ela
	and CEILING(p.LatitudeEnderecoParada) in (
												select 
													Latitude
												from
													(
														select
															IdRota,
															IdTransportadora,
															DataReferencia,
															CEILING(LatitudeEnderecoParada) Latitude,
															count(1) Qtde
														from
															tb_ml_pacotes
														where
															Excluido = 0
															and StatusEntrega in ('delivered', 'not_delivered')
															and isnull(SubStatus,'') <> 'transferred'
														group by 
															IdRota,
															IdTransportadora,
															DataReferencia,
															CEILING(LatitudeEnderecoParada)
													) b
												where
													Qtde = (
														select
															max(Qtde)
														from
															(
															select
																IdRota,
																IdTransportadora,
																DataReferencia,
																CEILING(LatitudeEnderecoParada) Latitude,
																count(1) Qtde
															from
																tb_ml_pacotes
															where
																Excluido = 0
																and StatusEntrega in ('delivered', 'not_delivered')
																and isnull(SubStatus,'') <> 'transferred'
															group by 
																IdRota,
																IdTransportadora,
																DataReferencia,
																CEILING(LatitudeEnderecoParada)
															) t
														where
															b.IdRota = t.IdRota
															and b.IdTransportadora = t.IdTransportadora
															and b.DataReferencia = t.DataReferencia
													)
													and b.IdRota = r.IdRota
													and b.IdTransportadora = r.IdTransportadora
													and b.DataReferencia = r.DataReferencia

									)
) as base
order by SequenciaParada

GO
