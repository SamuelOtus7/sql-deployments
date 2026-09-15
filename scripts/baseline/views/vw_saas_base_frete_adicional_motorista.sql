-- ============================================================
-- BASELINE: dbo.vw_saas_base_frete_adicional_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_base_frete_adicional_motorista]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_saas_base_frete_adicional_motorista]
as
select
	f.bfa_cd_base_frete_adicional_motorista IdBaseFreteMotorista
	,cast(f.bfa_cd_transportadora as varchar) + '-' + isnull(l.lst_ds_label,'') + '-' + isnull(l2.lst_ds_label,'') + '-' + isnull(c.ttc_nm_tipo,'') + '-' + isnull(f.bfa_cd_service_center,'') + '-' + isnull(f.bfa_nm_cidade,'') + '-' + isnull(v.tvl_nm_tipo_veiculo,'') ChaveDimensao
	,f.bfa_cd_transportadora TenantId
	,l.lst_ds_label Cliente
	,l2.lst_ds_label Operacao
	,c.ttc_nm_tipo Contrato
	,bfa_data_inicio_vigencia InicioVigencia
	,bfa_data_fim_vigencia FimVigencia
	,case when bfa_data_fim_vigencia is null or bfa_data_fim_vigencia >= cast(getdate() as date) then 'Sim' else 'Não' end BaseVigente
	,f.bfa_cd_service_center Base
	,f.bfa_nm_cidade Cidade
	,v.tvl_nm_tipo_veiculo Veiculo
	,case when bfa_tipo_adicional_domingo = 1 then 'Percentual' else 'Valor Fechado' end TipoCalculoDomingo
	,bfa_vl_adicional_domingo ValorDomingo
	,case when bfa_tipo_adicional_feriado = 1 then 'Percentual' else 'Valor Fechado' end TipoCalculoFeriado
	,bfa_vl_adicional_feriado ValorFeriado
	,case when bfa_tipo_adicional_ciclo_pm = 1 then 'Percentual' else 'Valor Fechado' end TipoCalculoCicloPM
	,bfa_vl_adicional_ciclo_pm ValorCicloPM
	,bfa_vl_paradas0_60 ValorParadas0a60
	,bfa_vl_paradas61_75 ValorParadas61a75
	,bfa_vl_paradas76_85 ValorParadas76a85
	,bfa_vl_paradas86_90 ValorParadas86a90
	,bfa_vl_paradas_acima_90 ValorParadasAcima90
	,case when bfa_calcula_por_parada = 1 then 'Paradas' else 'Pontos' end CriterioCalculoParadas
	,bfa_vl_adicional ValorAdicional
	,bfa_vl_adicional_ajudante ValorAdicionalAjudante
	,bfa_ds_placa Placa
from
	tb_fin_base_frete_adicional_motorista f with(nolock)
	join tb_dra_tipo_veiculo v with(nolock) on f.bfa_cd_tipo_veiculo = v.tvl_cd_tipo_veiculo
	join tb_clientes cli with(nolock) on f.bfa_cd_transportadora = cli.cli_cd_codigo_cliente
									and cli.cli_in_ativo = 1
									and cli.cli_in_excluido = 0
	left join tb_tipo_contrato c with(nolock) on f.bfa_cd_tipo_contrato = c.ttc_cd_tipo_contrato
	left join tb_lista l with(nolock) on f.bfa_cd_codigo_cliente = l.lst_cd_lista
	left join tb_lista l2 with(nolock) on f.bfa_cd_operacao = l2.lst_cd_lista

	

GO
