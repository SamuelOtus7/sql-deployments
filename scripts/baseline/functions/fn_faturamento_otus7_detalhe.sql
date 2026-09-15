-- ============================================================
-- BASELINE: dbo.fn_faturamento_otus7_detalhe
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_faturamento_otus7_detalhe]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE function [dbo].[fn_faturamento_otus7_detalhe] (
	@Competencia date,
	@Transportadora varchar(150)
)

returns table
as return

select NomeMotorista,
	   @Competencia as Competencia,
	   @Transportadora as Cliente, 
	   count(distinct data) as Data,
	   max(MarketPlace) as MarketPlace,
	   min(Data) as PrimeiraData,
	   max(Data) as UltimaData,
	   datediff(day,min(Data),max(Data)) +  1 as Dias,
	   case 
			when @Transportadora = '50 Mais'
			then case when count(distinct data) < 3 then 0 when datediff(day,min(Data),max(Data)) +  1 < 7 then 0.5 else 1 end 
			else count(distinct data)
	   end as Licencas,
	   min(case when MarketPlace = 'Shopee' and len(base) < 5 then null else base end) as Base
from (
	select
		dt.MesAno Competencia,
		'Mercado Livre' MarketPlace,
		NomeMotorista,
		dt.data,
		max(r.ServiceCenter) as base
	from
		tb_ml_rotas r with(nolock)
		join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
		join DimData dt with(nolock) on r.DataReferencia = dt.Data
				join (
			select distinct IdRota,
					IdTransportadora,
					DataReferencia
			from 
				tb_ml_pacotes p with(nolock) 
			where 
				p.Excluido = 0
				and p.DataReferencia between @Competencia and eomonth(@Competencia)
				--and p.StatusEntrega = 'delivered'
	) as p on r.IdRota = p.IdRota
	      and r.IdTransportadora = p.IdTransportadora
	      and r.DataReferencia = p.DataReferencia	
	where
		r.Excluido = 0
		and r.DataReferencia between @Competencia and eomonth(@Competencia)
		and r.NomeMotorista <> '-'
		and r.NomeMotorista <> ''
	    and t.tpr_nome_transportadora = @Transportadora
	group by
		dt.MesAno,
		r.DataReferencia,
		dt.data,
		NomeMotorista
	
	union all

	select
		@Competencia Competencia,
		'Shopee' MarketPlace,
		r.Motorista,
		dt.data,
		max(stations.NomeStation) as Base
	from
		tb_spe_rotas_v5 r with(nolock)
		join tb_clientes t with(nolock) on r.IdTransportadora = t.cli_id_shopee
		join DimData dt with(nolock) on r.DataReferencia = dt.Data
		--left join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
		left join tb_spe_station stations with(nolock) on r.IdStation = stations.IdStation
	where
		r.Excluido = 0
		and r.DataReferencia between @Competencia and eomonth(@Competencia)
		and r.Motorista <> '-'
		and r.Motorista <> ''
		and t.cli_ds_nome = @Transportadora
		and exists (select 
						1 
					from 
						tb_spe_pacotes_v5 p with(nolock) 
					where 
						r.CodigoRota = p.CodigoRota
						and r.IdTransportadora = p.IdTransportadora
						--and r.DataReferencia = p.DataReferencia
						and p.StatusEntrega = 'Delivered'
					)
	group by
		dt.MesAno,
		Motorista,
		dt.data
	) as base
group by NomeMotorista
--) as base
GO
