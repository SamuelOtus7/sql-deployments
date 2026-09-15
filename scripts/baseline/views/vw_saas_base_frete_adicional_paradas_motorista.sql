-- ============================================================
-- BASELINE: dbo.vw_saas_base_frete_adicional_paradas_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_base_frete_adicional_paradas_motorista]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_saas_base_frete_adicional_paradas_motorista]
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
	,f.bfa_ds_placa Placa
	,isnull(l5.lst_ds_valor,'Todos os dias') DiaDaSemana
	,l6.lst_ds_valor TipoValor
	,l3.lst_ds_valor TipoFaixa1
	,p.bfa_fx_ini InicioFaixa1
	,p.bfa_fx_fim FimFaixa1
	,cast(p.bfa_fx_ini as varchar) + '/' + cast(p.bfa_fx_fim as varchar) Faixa1
	,l4.lst_ds_valor TipoFaixa2
	,p.bfa_fx_ini_2 InicioFaixa2
	,p.bfa_fx_fim_2 FimFaixa2
	,cast(p.bfa_fx_ini_2 as varchar) + '/' + cast(p.bfa_fx_fim_2 as varchar) Faixa2
	,p.bfa_fx_valor Valor

from
	tb_fin_base_frete_adicional_motorista f with(nolock)
	join tb_fin_base_frete_adicional_motorista_parada p on f.bfa_cd_base_frete_adicional_motorista = p.bfa_cd_adicional_motorista
	join tb_dra_tipo_veiculo v with(nolock) on f.bfa_cd_tipo_veiculo = v.tvl_cd_tipo_veiculo
	join tb_clientes cli with(nolock) on f.bfa_cd_transportadora = cli.cli_cd_codigo_cliente
									and cli.cli_in_ativo = 1
									and cli.cli_in_excluido = 0
	left join tb_tipo_contrato c with(nolock) on f.bfa_cd_tipo_contrato = c.ttc_cd_tipo_contrato
	left join tb_lista l with(nolock) on f.bfa_cd_codigo_cliente = l.lst_cd_lista
	left join tb_lista l2 with(nolock) on f.bfa_cd_operacao = l2.lst_cd_lista
	left join tb_lista as l3 on p.tipo_fx_1 = l3.lst_cd_lista and l3.lst_nm_lista = 'Tipos de Faixa Adicionais'
	left join tb_lista as l4 on p.tipo_fx_2 = l4.lst_cd_lista and l4.lst_nm_lista = 'Tipos de Faixa Adicionais'
	left join tb_lista as l5 on p.bfa_dia_util = l5.lst_ds_chave and l5.lst_nm_lista = 'Pagamento DiaUtil/Feriado - Faixa Adicionais'
	left join tb_lista as l6 on p.bfa_tipo_valor = l6.lst_ds_chave and l6.lst_nm_lista = 'Tipos de calculos para pagamento de adicionais por faixa de ponto ou paradas.'

GO
