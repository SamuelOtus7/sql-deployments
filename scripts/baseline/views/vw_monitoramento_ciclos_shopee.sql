-- ============================================================
-- BASELINE: dbo.vw_monitoramento_ciclos_shopee
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_ciclos_shopee]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_monitoramento_ciclos_shopee]
as
select 
	base.*,
	hub.ColetasPorMinutoTotalizadores
from 
	(
	select 
		s.NomeStation Hub,
		t.tpr_nome_transportadora Transportadora,
		min(b.DataAtualizacao) as AtualizacaoRotaMaisAntiga,
		max(b.DataAtualizacao) as AtualizacaoRotaMaisRecente,
		min(a.DataAtualizacao) as AtualizacaoPacoteMaisAntiga,
		max(a.DataAtualizacao) as AtualizacaoPacoteMaisRecente,
		convert(varchar,dateadd(SECOND,datediff(second,min(b.DataAtualizacao),getdate()),0),108) as DuracaoCicloRota,
		convert(varchar,dateadd(SECOND,datediff(second,min(a.DataAtualizacao),getdate()),0),108) as DuracaoCicloPacote,
		count(distinct B.CodigoRota) as Rotas,
		count(distinct a.CodigoPacote) as Entregas,
		convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(b.DataAtualizacao),GETDATE()),0),108) as TempoSemColetaRota,
		convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(a.DataAtualizacao),GETDATE()),0),108) as TempoSemColetaPacote,
		sum(c.ColetasPorMinutoRotas) as ColetasPorMinutoRotas
	from 
		tb_spe_rotas_v4 b with(nolock) 
		left join tb_spe_pacotes_v4 a with(nolock) on a.CodigoRota = b.CodigoRota and a.DataReferencia = b.DataReferencia and a.IdTransportadora = b.IdTransportadora
		left join tb_dra_transportadora t on b.IdTransportadora = t.tpr_cd_transportadora
		join tb_spe_station s with(nolock) on b.IdStation = s.IdStation
		left join (
			select 
				dac_ds_contexto as CodigoRota,
				COUNT(*) as Coletas,
				MAX(dac_dh_escrita) as UltimaColeta,
				MIN(dac_dh_escrita) as PrimeiraColeta   ,
				case when DATEDIFF(second, MIN(dac_dh_escrita), MAX(dac_dh_escrita)) > 0 
					then CAST(COUNT(*) as float) / CAST(DATEDIFF(second, MIN(dac_dh_escrita), MAX(dac_dh_escrita)) as float) * 60.0
				else 1 end as ColetasPorMinutoRotas,
				convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(dac_dh_escrita),GETDATE()),0),108) as TempoDesdeAUltimaColeta,
				DATEDIFF(SECOND,MAX(dac_dh_escrita),GETDATE()) as SegundosDesdeAUltimaColeta
			from 
				db_Irisys_Json.dbo.tb_dra_coleta (nolock)
			where 
				dac_ds_tipo_coleta = 'SPE4_PACKAGES'
				and cast(dac_dh_escrita as date)= CAST(getdate() as date)
			group by 
				dac_ds_contexto
		) c on b.CodigoRota = c.CodigoRota
	where 
		b.DataReferencia = cast(getdate() as date)
		and b.Excluido = 0
	group by 
		s.NomeStation,
		t.tpr_nome_transportadora
	) as base
	left join (
		select 
			s.NomeStation as Hub,
			COUNT(*) as Coletas,
			MAX(c.dac_dh_escrita) as UltimaColeta,
			MIN(c.dac_dh_escrita) as PrimeiraColeta   ,
			case when DATEDIFF(second, MIN(c.dac_dh_escrita), MAX(c.dac_dh_escrita)) > 0 
				then CAST(COUNT(*) as float) / CAST(DATEDIFF(second, MIN(c.dac_dh_escrita), MAX(c.dac_dh_escrita)) as float)
			end * 60.0 as ColetasPorMinutoTotalizadores,
			convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(c.dac_dh_escrita),GETDATE()),0),108) as TempoDesdeAUltimaColeta,
			DATEDIFF(SECOND,MAX(c.dac_dh_escrita),GETDATE()) as SegundosDesdeAUltimaColeta
		from 
			db_Irisys_Json.dbo.tb_dra_coleta c with(nolock)
			join tb_spe_station s with(nolock) on c.dac_ds_contexto = s.IdStation
		where 
			c.dac_ds_tipo_coleta = 'SPE4_ROUTES'
			and cast(c.dac_dh_escrita as date) = CAST(getdate() as date)
		group by 
				s.NomeStation
	) hub on base.Hub = hub.Hub

GO
