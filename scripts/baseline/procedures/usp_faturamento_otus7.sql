-- ============================================================
-- BASELINE: dbo.usp_faturamento_otus7
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_faturamento_otus7]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_faturamento_otus7]
as
declare
	@Mes date = '2024-10-01'

--Faturamento padrão
select
	isnull(ml.Competencia,sp.Competencia) Competencia,
	isnull(ml.Transportadora,sp.Transportadora) Transportadora,
	isnull(ml.TotalMotorista,0) TotalMotoristasML,
	isnull(sp.TotalMotorista,0) TotalMotoristasSP,
	isnull(ml.TotalMotorista,0) + isnull(sp.TotalMotorista,0) TotaMotoristas
from
	(
		select
			dt.MesAno Competencia,
			t.tpr_nome_transportadora Transportadora,
			'Mercado Livre' MarketPlace,
			count(distinct NomeMotorista) TotalMotorista
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
							and p.DataReferencia between @Mes and eomonth(@Mes)
							and p.StatusEntrega = 'delivered'
			) as p
			on r.IdRota = p.IdRota
				and r.IdTransportadora = p.IdTransportadora
				and r.DataReferencia = p.DataReferencia		
		where
			r.Excluido = 0
			and r.DataReferencia between @Mes and eomonth(@Mes)
			and r.NomeMotorista <> '-'
			and r.NomeMotorista <> ''
			and r.IdTransportadora <> 1726310024
		group by
			dt.MesAno,
			t.tpr_nome_transportadora
	) ml
	full join
	(
		select
			Competencia,
			Transportadora,
			'Shopee' MarketPlace,
			count(distinct NomeMotorista) TotalMotorista
		from
		(	
			select dt.MesAno Competencia,
				   t.tpr_nome_transportadora Transportadora,
				   NomeMotorista
			from 
				tb_spe_rotas_v5 r with(nolock)
				join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
				join DimData dt with(nolock) on r.DataReferencia = dt.Data
				join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
				join (
							select distinct CodigoRota,
								   IdTransportadora,
								   DataReferencia
							from 
								tb_spe_pacotes_v5 p with(nolock) 
							where 
								p.Excluido = 0
								and p.DataReferencia between @Mes and eomonth(@Mes)
								and p.StatusEntrega = 'delivered'
				) as p
				on r.CodigoRota = p.CodigoRota
					and r.IdTransportadora = p.IdTransportadora
					and r.DataReferencia = p.DataReferencia	
			where
				r.Excluido = 0
				and r.DataReferencia between @Mes and eomonth(@Mes)
				and m.NomeMotorista <> '-'
				and m.NomeMotorista <> ''
				and r.IdTransportadora <> 20230007
				and (
						r.IdTransportadora <> 20230009 or 
						r.IdStation not in (
							select IdStation 
							from tb_spe_station 
							where NomeStation like '%XPT%'
							and IdTransportadora = 20230009
						)
					)
/*
				union all 

				select  dt.MesAno Competencia,
						t.tpr_nome_transportadora Transportadora,
						NomeMotorista
				from tb_spe_rotas r with (nolock)
					join DimData dt with(nolock) on r.DataReferencia = dt.Data
					join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
					join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
				where DataReferencia between @Mes and eomonth(@mes)
				
*/

			) as base
		group by
			Competencia,
			Transportadora
	) sp on ml.Competencia = sp.Competencia and ml.Transportadora = sp.Transportadora
	
union all

--Faturamento 50 Mais
select
	max(Competencia) as Competencia,
	max(Transportadora) as Transportadora,
	sum(case when MarketPlace = 'Mercado Livre' then Licencas else 0 end) as TotalMotoristasML,
	sum(case when MarketPlace = 'Shopee' then Licencas else 0 end) as TotalMotoristasSp,
	sum(Licencas) as TotaMotoristas
from fn_faturamento_otus7_extrato50m(@Mes)

GO
