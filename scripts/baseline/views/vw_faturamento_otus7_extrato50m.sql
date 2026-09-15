-- ============================================================
-- BASELINE: dbo.vw_faturamento_otus7_extrato50m
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_faturamento_otus7_extrato50m]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_faturamento_otus7_extrato50m]

as

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
	   case when count(distinct data) < 3 then 0 when datediff(day,min(Data),max(Data)) +  1 < 7 then 0.5 else 1 end as Licencas,
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
				select 
					p.IdRota,
					p.DataReferencia
				from 
					tb_ml_pacotes p with(nolock) 
				where 
					p.IdTransportadora = 1726310024
					and p.DataReferencia between dateadd(day,1,eomonth(getdate(),-2)) and eomonth(getdate(),-1)
					and p.Excluido = 0
					and p.StatusEntrega = 'delivered'
			) as p
		 on r.IdRota = p.IdRota
			and r.DataReferencia = p.DataReferencia
	where
		r.Excluido = 0
		and r.DataReferencia between dateadd(day,1,eomonth(getdate(),-2)) and eomonth(getdate(),-1)
		and r.NomeMotorista <> '-'
		and r.NomeMotorista <> ''
		and r.IdTransportadora = 1726310024
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
		'Shopee' MarketPlace,
		NomeMotorista,
		dt.data,
		max(stations.NomeStation) as Base
	from
		tb_spe_rotas_v4 r with(nolock)
		join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
		join DimData dt with(nolock) on r.DataReferencia = dt.Data
		join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
		inner join (
						select 
							IdMotorista,
							DataReferencia
						from 
							tb_spe_pacotes_v4 p with(nolock) 
						where 
							p.IdTransportadora = 20230007
							and p.DataReferencia between dateadd(day,1,eomonth(getdate(),-2)) and eomonth(getdate(),-1)
							and p.IdTransportadora = p.IdTransportadora
							and p.StatusEntrega = 'Delivered'
					) p
		on r.IdMotorista = p.IdMotorista
		   and r.DataReferencia = p.DataReferencia
		left join tb_spe_station as stations on r.IdStation = stations.IdStation
	where
		r.Excluido = 0
		and r.DataReferencia between dateadd(day,1,eomonth(getdate(),-2)) and eomonth(getdate(),-1)
		and m.NomeMotorista <> '-'
		and m.NomeMotorista <> ''
		and r.IdTransportadora = 20230007
		
	group by
		dt.MesAno,
		t.tpr_nome_transportadora,
		NomeMotorista,
		dt.data
	) as base
group by NomeMotorista
--) as base
GO
