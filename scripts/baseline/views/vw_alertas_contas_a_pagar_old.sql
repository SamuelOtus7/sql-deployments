-- ============================================================
-- BASELINE: dbo.vw_alertas_contas_a_pagar_old
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_alertas_contas_a_pagar_old]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_alertas_contas_a_pagar_old]
as
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
	,'Motorista não cadastrado' Motivo
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo per with(nolock)
	join tb_clientes cli with(nolock) on per.pgp_cd_cliente = cli.cli_cd_codigo_cliente
	join vw_rotas r with(nolock) on cli.cli_id_logistics = r.IdTransportadora 
										and r.DataReferencia between per.pgp_dt_inicio and per.pgp_dt_fim
													
where
	per.pgp_cd_status = 1
	and per.pgp_dt_inicio >= '2025-03-01'
	and per.pgp_in_excluido = 0
	and r.UsuarioDA is null
	and per.pgp_cd_cliente = 11
	
	
union all

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
	per.pgp_cd_status = 1
	and per.pgp_dt_inicio >= '2025-03-01'
	and pgt.ppr_in_excluido = 0 
	and per.pgp_in_excluido = 0
	and isnull(pgt.ppr_vl_base,0) = 0
	and ppr_cd_rota is not null
	and ppr_lcto_observacao is null
	and per.pgp_cd_cliente = 11
	

union all

select
	per.pgp_cd_cliente IdTenant
	,per.pgp_cd_periodo CodigoPeriodo
	,cast(pre.IdRota as varchar) IdRota
	,pre.DataTermino DataReferencia
	,pre.Motorista NomeMotorista
	,pre.ServiceCenter ServiceCenter
	,pre.Veiculo + case when pre.ContinuacaoVeiculo is not null then ' - ' + pre.ContinuacaoVeiculo else '' end TipoVeiculo
	,pre.IntervaloFaixa FaixaKm
	,null ValorSaida
	,'Somente Prefatura' Motivo
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo per with(nolock)
	join tb_clientes cli with(nolock) on per.pgp_cd_cliente = cli.cli_cd_codigo_cliente
	join tb_fin_prefatura pre with(nolock) on cli.cli_id_logistics = pre.IdTransportadora 
										and cast(cast(pre.Ano as varchar(4)) + '-' + cast(pre.Mes as varchar(2)) + '-' + case when Quinzena = 1 then '01' else '16' end as date) between per.pgp_dt_inicio and per.pgp_dt_fim
	left join tb_pgto_periodo_rota pgt with(nolock) on per.pgp_cd_periodo = pgt.ppr_cd_periodo
													and pgt.ppr_in_excluido = 0 
													and pre.IdRota = pgt.ppr_cd_rota
													
where
	per.pgp_cd_status = 1
	and per.pgp_dt_inicio >= '2025-03-01'
	and per.pgp_in_excluido = 0
	and pgt.ppr_cd_pagamento_rota is null
	and per.pgp_cd_cliente = 11
	

union all

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
	,'Não existe na Prefatura' Motivo
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo_rota pgt with(nolock)
	join tb_pgto_periodo per with(nolock) on pgt.ppr_cd_periodo = per.pgp_cd_periodo
	join tb_clientes cli with(nolock) on per.pgp_cd_cliente = cli.cli_cd_codigo_cliente
	left join tb_fin_prefatura pre with(nolock) on cli.cli_id_logistics = pre.IdTransportadora 
										and cast(cast(pre.Ano as varchar(4)) + '-' + cast(pre.Mes as varchar(2)) + '-' + case when Quinzena = 1 then '01' else '16' end as date) between per.pgp_dt_inicio and per.pgp_dt_fim
										and pgt.ppr_cd_rota = pre.IdRota
													
where
	per.pgp_cd_status = 1
	and per.pgp_dt_inicio >= '2025-03-01'
	and pgt.ppr_in_excluido = 0 
	and per.pgp_in_excluido = 0
	and ppr_cd_rota is not null
	and ppr_lcto_observacao is null
	and pre.IdTransportadora is null
	and per.pgp_cd_cliente = 11
	
GO
