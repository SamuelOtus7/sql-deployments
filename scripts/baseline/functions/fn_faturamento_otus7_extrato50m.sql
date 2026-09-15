-- ============================================================
-- BASELINE: dbo.fn_faturamento_otus7_extrato50m
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_faturamento_otus7_extrato50m]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_faturamento_otus7_extrato50m]
(
	@Mes date
)

returns table 
as return

--select
--	max(Competencia) as Competencia,
--	max(Transportadora) as Transportadora,
--	sum(case when MarketPlace = 'Mercado Livre' then case when Data = 1 then 0 when datediff(day,PrimeiraData,UltimaData) + 1 < 7 then 0.5 else 1 end else 0 end) as TotalMotoristasML,
--	sum(case when MarketPlace = 'Shopee' then case when Data = 1 then 0 when datediff(day,PrimeiraData,UltimaData) + 1 < 7 then 0.5 else 1 end else 0 end) as TotalMotoristasSP,
--	sum(case when Data = 1 then 0 when datediff(day,PrimeiraData,UltimaData) +  1 < 7 then 0.5 else 1 end) as TotaMotoristas
--from (
select NomeMotorista,
	   max(Competencia) as Competencia,
	   max(Transportadora) as Transportadora,
	   count(distinct data) as Data,
	   max(MarketPlace) as MarketPlace,
	   min(Data) as PrimeiraData,
	   max(Data) as UltimaData,
	   datediff(day,min(Data),max(Data)) +  1 as Dias,
	   case when count(distinct data) < 3 then 0 when count(distinct data) < 7 then 0.5 else 1 end as Licencas,
	   min(case when MarketPlace = 'Shopee' and len(base) < 5 then null else base end) as Base
from (
	select
		dt.MesAno Competencia,
		t.tpr_nome_transportadora Transportadora,
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
							and p.StatusEntrega = 'delivered'
							and p.DataReferencia between @Mes and eomonth(@Mes)
			) as p
			on r.IdRota = p.IdRota
				and r.IdTransportadora = p.IdTransportadora
				and r.DataReferencia = p.DataReferencia
	where
		r.Excluido = 0
		and r.DataReferencia between @Mes and eomonth(@Mes)
		and r.NomeMotorista <> '-'
		and r.NomeMotorista <> ''
	and r.IdTransportadora = 1726310024
	and r.StatusRota <> 'planned'
	group by
		dt.MesAno,
		r.DataReferencia,
		t.tpr_nome_transportadora,
		dt.data,
		NomeMotorista
	
	union all

	select
		dt.MesAno Competencia,
		t.tpr_nome_transportadora Transportadora,
		'Mercado Livre' MarketPlace,
		NomeMotorista,
		dt.data,
		max(r.ServiceCenterOrigem) as base
	from
		tb_ml_lh_rotas r with(nolock)
		join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
		join DimData dt with(nolock) on r.DataReferencia = dt.Data
		--join (
		--				select distinct IdRota,
		--					   IdTransportadora,
		--					   DataReferencia
		--				from 
		--					tb_ml_pacotes p with(nolock) 
		--				where 
		--					p.Excluido = 0
		--					and p.StatusEntrega = 'delivered'
		--					and p.DataReferencia between @Mes and eomonth(@Mes)
		--	) as p
		--	on r.IdRota = p.IdRota
		--		and r.IdTransportadora = p.IdTransportadora
		--		and r.DataReferencia = p.DataReferencia
	where
		r.Excluido = 0
		and r.DataReferencia between @Mes and eomonth(@Mes)
		and r.NomeMotorista <> '-'
		and r.NomeMotorista <> ''
	and r.IdTransportadora = 1726310024
	and r.UsuarioDA is not null
	group by
		dt.MesAno,
		r.DataReferencia,
		t.tpr_nome_transportadora,
		dt.data,
		NomeMotorista

	union all
	
	select
		dt.MesAno Competencia,
		t.tpr_nome_transportadora Transportadora,
		'Mercado Livre' MarketPlace,
		NomeMotorista,
		dt.data,
		max(r.OrigemSaida) as base
	from
		tb_ml_fm_rotas r with(nolock)
		join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
		join DimData dt with(nolock) on r.DataReferencia = dt.Data
		--join (
		--				select distinct IdRota,
		--					   IdTransportadora,
		--					   DataReferencia
		--				from 
		--					tb_ml_pacotes p with(nolock) 
		--				where 
		--					p.Excluido = 0
		--					and p.StatusEntrega = 'delivered'
		--					and p.DataReferencia between @Mes and eomonth(@Mes)
		--	) as p
		--	on r.IdRota = p.IdRota
		--		and r.IdTransportadora = p.IdTransportadora
		--		and r.DataReferencia = p.DataReferencia
	where
		r.Excluido = 0
		and r.DataReferencia between @Mes and eomonth(@Mes)
		and r.NomeMotorista <> '-'
		and r.NomeMotorista <> ''
		and r.UsuarioDA is not null
	and r.IdTransportadora = 1726310024
	group by
		dt.MesAno,
		r.DataReferencia,
		t.tpr_nome_transportadora,
		dt.data,
		NomeMotorista
	) as base
group by NomeMotorista
--) as base
GO
