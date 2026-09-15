-- ============================================================
-- BASELINE: dbo.fn_faturamento_otus7
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_faturamento_otus7]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select * from [fn_faturamento_otus7] ('2026-01-01')

CREATE function [dbo].[fn_faturamento_otus7]
(
	@Mes date
)

returns table
as return

--declare @Mes date = '2026-06-01'
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
			Competencia,
			Transportadora,
			'Mercado Livre' MarketPlace,
			count(distinct NomeMotorista) TotalMotorista
		from (
					select
						dt.MesAno Competencia,
						t.tpr_nome_transportadora Transportadora,
						'Mercado Livre' MarketPlace,
						NomeMotorista
					from
						tb_ml_rotas r with(nolock)
						join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
						join DimData dt with(nolock) on r.DataReferencia = dt.Data
						join (
									select distinct IdRota,
										   IdTransportadora
									from 
										tb_ml_pacotes p with(nolock) 
									where 
										p.Excluido = 0
										and p.DataReferencia between @Mes and eomonth(@Mes)
									--	and p.StatusEntrega = 'delivered'
						) as p
						on r.IdRota = p.IdRota
							and r.IdTransportadora = p.IdTransportadora
					where
						r.Excluido = 0
						and r.DataReferencia between @Mes and eomonth(@Mes)
						and r.NomeMotorista <> '-'
						and r.NomeMotorista <> ''
						and r.IdTransportadora <> 1726310024
						and (
								r.statusrota <> 'planned'
								or (r.substatusrota in ('on_way_destination_facility','not_destination_facility')
								and t.tpr_nome_transportadora in ('Attitude','Maxx log','Rodoprime','Decargo Express','ADO Transportadora'))
								or (r.substatusrota in ('not_destination_facility')
								and t.tpr_nome_transportadora in ('Transmana'))
								--or (r.substatusrota in ('on_way_destination_facility')
								--and t.tpr_nome_transportadora in ('Decargo Express'))
							)
						--and (r.statusrota <> 'planned' or r.substatusrota = 'on_way_destination_facility' 
						--or t.tpr_nome_transportadora not in ('Hawk Transportes','Parceiro Spot','Maxx Log'))
					group by
						dt.MesAno,
						t.tpr_nome_transportadora,
						NomeMotorista
	
					union all

					select
						dt.MesAno Competencia,
						t.tpr_nome_transportadora Transportadora,
						'Mercado Livre' MarketPlace,
						NomeMotorista
					from
						tb_ml_lh_rotas r with(nolock)
						join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
						join DimData dt with(nolock) on r.DataReferencia = dt.Data
					where
						r.Excluido = 0
						and r.DataReferencia between @Mes and eomonth(@Mes)
						and r.NomeMotorista <> '-'
						and r.NomeMotorista <> ''
						and r.UsuarioDA is not null
						and r.IdTransportadora <> 1726310024
					group by
						dt.MesAno,
						r.DataReferencia,
						t.tpr_nome_transportadora,
						NomeMotorista

					union all
	
					select
						dt.MesAno Competencia,
						t.tpr_nome_transportadora Transportadora,
						'Mercado Livre' MarketPlace,
						NomeMotorista
					from
						tb_ml_fm_rotas r with(nolock)
						join tb_dra_transportadora t with(nolock) on r.IdTransportadora = t.tpr_cd_transportadora
						join DimData dt with(nolock) on r.DataReferencia = dt.Data
					where
						r.Excluido = 0
						and r.DataReferencia between @Mes and eomonth(@Mes)
						and r.NomeMotorista <> '-'
						and r.NomeMotorista <> ''
						and r.UsuarioDA is not null
						and r.IdTransportadora <> 1726310024
					group by
						dt.MesAno,
						r.DataReferencia,
						t.tpr_nome_transportadora,
						NomeMotorista
		) as base
		group by
			Competencia,
			Transportadora
	) ml
	full join
	(
		select
			Competencia,
			Transportadora,
			'Shopee' MarketPlace,
			count(distinct Motorista) TotalMotorista
		from
		(	
			select dt.MesAno Competencia,
				   c.cli_ds_nome Transportadora,
				   isnull(m.NomeMotorista,r.Motorista) as Motorista
			from 
				(select * from tb_spe_rotas_v5 r with(nolock) where r.DataReferencia between @Mes and eomonth(@Mes) and excluido = 0) as r
				join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_shopee and c.cli_id_shopee > 0
				join DimData dt with(nolock) on r.DataReferencia = dt.Data
				left join (
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
				left join (
							select distinct CodigoRota,
									IdTransportadora
									--,DataReferencia
							from 
								tb_spe_pacotes_FM p with(nolock) 
							where 
								p.Excluido = 0
								--and p.DataReferencia between '2025-09-01' and eomonth('2025-09-30')
				) as f
				on r.CodigoRota = cast(f.CodigoRota as varchar(20))
					and r.IdTransportadora = f.IdTransportadora
					--and r.DataReferencia = f.DataReferencia	
				left join (
							select distinct CodigoRota,
									IdTransportadora
									--,DataReferencia
							from 
								tb_spe_pacotes_lh p with(nolock) 
							--where 
								--p.Excluido = 0
								--and p.DataReferencia between '2025-09-01' and eomonth('2025-09-30')
				) as l
				on r.CodigoRota = l.CodigoRota
					and r.IdTransportadora = l.IdTransportadora
					--and r.DataReferencia = l.DataReferencia	
				left join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
			where
				r.Excluido = 0
				and r.DataReferencia between @Mes and eomonth(@Mes)
				and isnull(m.NomeMotorista,r.Motorista) <> '-'
				and isnull(m.NomeMotorista,r.Motorista) <> ''
				and r.IdTransportadora <> 20230007
				and (p.CodigoRota is not null or f.CodigoRota is not null or l.CodigoRota is not null)
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
