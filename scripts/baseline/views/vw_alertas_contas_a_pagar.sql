-- ============================================================
-- BASELINE: dbo.vw_alertas_contas_a_pagar
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_alertas_contas_a_pagar]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_alertas_contas_a_pagar]
as
select
	per.pgp_cd_cliente IdTenant
	,pgt.ppr_cd_periodo CodigoPeriodo
	,cast(pgt.ppr_cd_rota as varchar) IdRota
	,pgt.ppr_data_referencia DataReferencia
	,pgt.ppr_nome_motorista NomeMotorista
	,pgt.ppr_base_principal ServiceCenter
	,pgt.ppr_ds_tipo_veiculo TipoVeiculo
	,pgt.ppr_cd_faixa_km FaixaKm
	,pgt.ppr_vl_base ValorSaida
	,'Saída Zerada' Motivo
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo_rota pgt with(nolock)
	join tb_pgto_periodo per with(nolock) on pgt.ppr_cd_periodo = per.pgp_cd_periodo
where
	pgt.ppr_in_excluido = 0 
	and per.pgp_in_excluido = 0
	and isnull(pgt.ppr_vl_base,0) = 0
	and ppr_cd_rota is not null
	and ppr_lcto_observacao is null
	and per.pgp_dt_inicio >= '2025-03-01'


union all

select
	per.pgp_cd_cliente IdTenant
	,per.pgp_cd_periodo CodigoPeriodo
	,cast(r.IdRota as varchar) IdRota
	,r.DataReferencia DataReferencia
	,r.NomeMotorista
	,r.ServiceCenter ServiceCenter
	,r.TipoVeiculo
	,null FaixaKm
	,null ValorSaida
	,'Rota não incluídas no Espelho' Motivo
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo per with(nolock)
	join tb_clientes cli with(nolock) on per.pgp_cd_cliente = cli.cli_cd_codigo_cliente
	join vw_rotas r with(nolock) on cli.cli_id_logistics = r.IdTransportadora 
										and r.DataReferencia between per.pgp_dt_inicio and per.pgp_dt_fim
										and r.tipo = 'LM'
	left join tb_pgto_periodo_rota pgto with(nolock) on per.pgp_cd_periodo = pgto.ppr_cd_periodo
													and ppr_cd_rota is not null
													and cast(r.IdRota as varchar) = pgto.ppr_cd_rota

													
where
	per.pgp_in_excluido = 0
	and pgto.ppr_cd_pagamento_rota is null
	and per.pgp_dt_inicio >= '2025-03-01'
GO
