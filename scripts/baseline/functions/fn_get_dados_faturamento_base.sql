-- ============================================================
-- BASELINE: dbo.fn_get_dados_faturamento_base
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_dados_faturamento_base]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_get_dados_faturamento_base]
(
@Mes date
)
returns table as return
select
			Competencia,
			Transportadora,
			'Shopee' MarketPlace,
			NomeHub,
			count(distinct Motorista) TotalMotorista
		from
		(	
			select dt.MesAno Competencia,
				   c.cli_ds_nome Transportadora,
				   isnull(m.NomeMotorista,r.Motorista) as Motorista,
				   r.NomeHub
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
				and c.cli_ds_nome = 'JMT Log'
			) as base
		group by
			Competencia,
			Transportadora,
			NomeHub
GO
