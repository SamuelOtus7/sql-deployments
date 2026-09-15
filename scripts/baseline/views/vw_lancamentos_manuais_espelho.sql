-- ============================================================
-- BASELINE: dbo.vw_lancamentos_manuais_espelho
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lancamentos_manuais_espelho]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_lancamentos_manuais_espelho]
as
select
	lan.tlm_cd_cliente IdTenant
	,lan.tlm_cd_lancamento_manual CodigoLancamento
	,lan.tlm_cd_motorista Motorista
	,tip.plm_nm_tipo TipoLancamento
	,cast(lan.tlm_dh_referencia as date) DataReferencia
	,pgt.pgp_cd_periodo IdPeriodo
	,pgt.pgp_nm_periodo Periodo
	,lan.tlm_cd_service_center ServiceCenter
	,case when lan.tlm_cd_rota = 'null' then '' else lan.tlm_cd_rota end Rota
	,case when tip.plm_nm_tipo = 'Apoio' and tlm_tipo_valor_apoio = 'Percentual' then 0 else isnull(lan.tlm_vl_valor_adicional,0) + isnull(lan.tlm_vl_valor_rota,0) + (isnull(lan.tlm_vl_valor_descontos,0)*-1) + (isnull(lan.tlm_vl_valor_apoio,0) * case when tip.plm_nm_tipo = 'Apoio' then -1 else 1 end) end Valor
	,case when tip.plm_nm_tipo = 'Apoio' and tlm_tipo_valor_apoio = 'Percentual' then lan.tlm_vl_valor_apoio / 100.00 end PercentualApoio
	,lan.tlm_ds_observacao Observacao
	,cast(case when pgt.pgp_dt_inicio >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else pgt.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from 
	tb_lancamentos_manuais lan with(nolock)
	join tb_aprovacao_lancamento_manual apr with(nolock) on lan.tlm_cd_lancamento_manual = apr.alm_cd_lancamento_manual
	join tb_tipos_lancamentos_manuais as tip with(nolock) on lan.tlm_cd_tipo = tip.plm_cd_tipo_lancamento_manual
	join tb_clientes cli with(nolock) on lan.tlm_cd_cliente = cli.cli_cd_codigo_cliente
	left join vw_rotas r with(nolock) on try_cast(lan.tlm_cd_rota as int) = r.IdRota and cli.cli_id_logistics = r.IdTransportadora and tipo = 'LM'
	join tb_pgto_periodo pgt with(nolock) on lan.tlm_cd_cliente = pgt.pgp_cd_cliente 
										and pgt.pgp_cd_status = 1
										and pgt.pgp_in_excluido = 0
										and (
											r.DataReferencia between pgt.pgp_dt_inicio and pgt.pgp_dt_fim
											or
											cast(lan.tlm_dh_referencia as date) between pgt.pgp_dt_inicio and pgt.pgp_dt_fim and lan.tlm_cd_rota = 'null'
										)
where 
	lan.tlm_in_ativo = 1
	and lan.tlm_in_excluido = 0
	and apr.alm_ds_status = 'Aprovado'

union all

select
	lan.tlm_cd_cliente IdTenant
	,lan.tlm_cd_lancamento_manual CodigoLancamento
	,lan.tlm_ds_motorista_apoio Motorista
	,tip.plm_nm_tipo TipoLancamento
	,cast(lan.tlm_dh_referencia as date) DataReferencia
	,pgt.pgp_cd_periodo IdPeriodo
	,pgt.pgp_nm_periodo Periodo
	,lan.tlm_cd_service_center ServiceCenter
	,case when lan.tlm_cd_rota = 'null' then '' else lan.tlm_cd_rota end Rota
	,case when tip.plm_nm_tipo = 'Apoio' and tlm_tipo_valor_apoio = 'Percentual' then 0 else isnull(lan.tlm_vl_valor_apoio,0) end Valor
	,case when tip.plm_nm_tipo = 'Apoio' and tlm_tipo_valor_apoio = 'Percentual' then lan.tlm_vl_valor_apoio / 100.00 end PercentualApoio
	,lan.tlm_ds_observacao Observacao
	,cast(case when pgt.pgp_dt_inicio >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else pgt.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from 
	tb_lancamentos_manuais lan with(nolock)
	join tb_aprovacao_lancamento_manual apr with(nolock) on lan.tlm_cd_lancamento_manual = apr.alm_cd_lancamento_manual
	join tb_tipos_lancamentos_manuais as tip with(nolock) on lan.tlm_cd_tipo = tip.plm_cd_tipo_lancamento_manual
	join tb_clientes cli with(nolock) on lan.tlm_cd_cliente = cli.cli_cd_codigo_cliente
	left join vw_rotas r with(nolock) on try_cast(lan.tlm_cd_rota as int) = r.IdRota and cli.cli_id_logistics = r.IdTransportadora and tipo = 'LM'
	join tb_pgto_periodo pgt with(nolock) on lan.tlm_cd_cliente = pgt.pgp_cd_cliente 
										and pgt.pgp_cd_status = 1
										and pgt.pgp_in_excluido = 0
										and (
											r.DataReferencia between pgt.pgp_dt_inicio and pgt.pgp_dt_fim
											or
											cast(lan.tlm_dh_referencia as date) between pgt.pgp_dt_inicio and pgt.pgp_dt_fim and lan.tlm_cd_rota = 'null'
										)
where 
	lan.tlm_in_ativo = 1
	and lan.tlm_in_excluido = 0
	and apr.alm_ds_status = 'Aprovado'
	and tip.plm_nm_tipo = 'Apoio'
	

-- 4.838
GO
