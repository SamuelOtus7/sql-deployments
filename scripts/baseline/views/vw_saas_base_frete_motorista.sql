-- ============================================================
-- BASELINE: dbo.vw_saas_base_frete_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_base_frete_motorista]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_saas_base_frete_motorista]
as
select
	f.bfm_cd_base_frete_motorista IdBaseFreteMotorista
	,cast(f.bfm_cd_transportadora as varchar) + '-' + isnull(l.lst_ds_label,'') + '-' + isnull(l2.lst_ds_label,'') + '-' + isnull(c.ttc_nm_tipo,'') + '-' + isnull(f.bfm_cd_service_center,'') + '-' + isnull(f.bfm_nm_cidade,'') + '-' + isnull(v.tvl_nm_tipo_veiculo,'') ChaveDimensao
	,f.bfm_cd_transportadora TenantId
	,l.lst_ds_label Cliente
	,l2.lst_ds_label Operacao
	,c.ttc_nm_tipo Contrato
	,bfm_data_inicio_vigencia InicioVigencia
	,bfm_data_fim_vigencia FimVigencia
	,case when bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= cast(getdate() as date) then 'Sim' else 'Não' end BaseVigente
	,f.bfm_cd_service_center Base
	,f.bfm_nm_cidade Cidade
	,v.tvl_nm_tipo_veiculo Veiculo
	,f.bfm_vl_inicio_faixa InicioFaixa
	,f.bfm_vl_fim_faixa FimFaixa
	,cast(bfm_vl_inicio_faixa as varchar) + '/' + cast(bfm_vl_fim_faixa as varchar) Faixa
	,f.bfm_vl_frete ValorFrete
	,f.bfm_vl_frete_pm ValorFretePM
	,f.bfm_vl_frete_fixo ValorFreteFixo
	,f.bfm_vl_domfer_am ValorFreteDomingoAM
	,f.bfm_vl_domfer_pm ValorFreteDomingoPM
	,case when bfm_pag_pacote = 1 then 'Sim' else 'Não' end PagarPorPacote
	,l3.lst_ds_label CriterioFaixa2
	,bfm_vl_inicio_faixa2 InicioFaixa2
	,bfm_vl_fim_faixa2 FimFaixa2
	,cast(bfm_vl_inicio_faixa2 as varchar) + '/' + cast(bfm_vl_fim_faixa2 as varchar) Faixa2
	,bfm_ds_placa Placa
from
	tb_fin_base_frete_motorista f with(nolock)
	join tb_dra_tipo_veiculo v with(nolock) on f.bfm_cd_tipo_veiculo = v.tvl_cd_tipo_veiculo
	join tb_clientes cli with(nolock) on f.bfm_cd_transportadora = cli.cli_cd_codigo_cliente
									and cli.cli_in_ativo = 1
									and cli.cli_in_excluido = 0
	left join tb_tipo_contrato c with(nolock) on f.bmf_cd_tipo_contrato = c.ttc_cd_tipo_contrato
	left join tb_lista l with(nolock) on f.bfm_cd_codigo_cliente = l.lst_cd_lista
	left join tb_lista l2 with(nolock) on f.bfm_cd_operacao = l2.lst_cd_lista
	left join tb_lista l3 with(nolock) on f.bfm_cd_criterio_faixa2 = l3.lst_cd_lista
	

GO
