-- ============================================================
-- BASELINE: dbo.fn_faturamento_otus7_detalhe_JOICE
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_faturamento_otus7_detalhe_JOICE]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--declare @Competencia date = '2025-11-01'
--declare @Transportadora varchar(255) = 'JMT Log'

CREATE function [dbo].[fn_faturamento_otus7_detalhe_JOICE] (
	@Competencia date,
	@Transportadora varchar(255)
)

returns table
as return
	
	select
		@Competencia Competencia,
		'Shopee' MarketPlace,
		NomeMotorista,
		dt.data
		--max(stations.NomeStation) as Base
	from
		tb_spe_rotas_v5 r with(nolock)
		join tb_clientes t with(nolock) on r.IdTransportadora = t.cli_id_shopee
		join DimData dt with(nolock) on r.DataReferencia = dt.Data
		join tb_spe_motoristas m with(nolock) on r.IdMotorista = m.IdMotorista
		--left join tb_spe_station stations with(nolock) on r.IdStation = stations.IdStation
	where
		r.Excluido = 0
		and r.DataReferencia between @Competencia and eomonth(@Competencia)
		and m.NomeMotorista <> '-'
		and m.NomeMotorista <> ''
		and t.cli_ds_nome = @Transportadora
		and exists (select 
						1 
					from 
						tb_spe_pacotes_v5 p with(nolock) 
					where 
						r.IdMotorista = p.IdMotorista
						and r.IdTransportadora = p.IdTransportadora
						and r.DataReferencia = p.DataReferencia
						and p.StatusEntrega = 'Delivered'
					)
	group by
		dt.MesAno,
		NomeMotorista,
		dt.data
GO
