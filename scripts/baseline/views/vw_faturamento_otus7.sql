-- ============================================================
-- BASELINE: dbo.vw_faturamento_otus7
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_faturamento_otus7]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select * from [vw_faturamento_otus7]
CREATE view [dbo].[vw_faturamento_otus7]
as

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
		where
			r.Excluido = 0
			and r.DataReferencia between dateadd(day,1,eomonth(getdate(),-2)) and eomonth(getdate(),-1)
			and r.NomeMotorista <> '-'
			and r.NomeMotorista <> ''
			and exists (select 
							1 
						from 
							tb_ml_pacotes p with(nolock) 
						where 
							r.IdRota = p.IdRota
							and r.IdTransportadora = p.IdTransportadora
							and r.DataReferencia = p.DataReferencia
							and p.Excluido = 0
							and p.StatusEntrega = 'delivered'
						)
		and r.IdTransportadora <> 1726310024
		group by
			dt.MesAno,
			t.tpr_nome_transportadora
	) ml
	full join
	(
		select
			dt.MesAno Competencia,
			t.tpr_nome_transportadora Transportadora,
			'Shopee' MarketPlace,
			count(distinct NomeMotorista) TotalMotorista
		from
			tb_spe_rotas_v4 r with(nolock)
			join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
			join DimData dt with(nolock) on r.DataReferencia = dt.Data
			join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
		where
			r.Excluido = 0
			and r.DataReferencia between dateadd(day,1,eomonth(getdate(),-2)) and eomonth(getdate(),-1)
			and m.NomeMotorista <> '-'
			and m.NomeMotorista <> ''
			and r.IdTransportadora <> 20230007
			and exists (select 
							1 
						from 
							tb_spe_pacotes_v4 p with(nolock) 
						where 
							r.IdMotorista = p.IdMotorista
							and r.IdTransportadora = p.IdTransportadora
							and r.DataReferencia = p.DataReferencia
							and p.StatusEntrega = 'Delivered'
						)
			and r.IdTransportadora <> 1726310024
		group by
			dt.MesAno,
			t.tpr_nome_transportadora
	) sp on ml.Competencia = sp.Competencia and ml.Transportadora = sp.Transportadora
	
union all

--Faturamento 50 Mais
select
	max(Competencia) as Competencia,
	max(Transportadora) as Transportadora,
	sum(case when MarketPlace = 'Mercado Livre' then Licencas else 0 end) as TotalMotoristasML,
	sum(case when MarketPlace = 'Shopee' then Licencas else 0 end) as TotalMotoristasSp,
	sum(Licencas) as TotaMotoristas
from vw_faturamento_otus7_extrato50m
GO
