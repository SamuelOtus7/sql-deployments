-- ============================================================
-- BASELINE: dbo.vw_saas_pagamentos_administrativos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_pagamentos_administrativos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_saas_pagamentos_administrativos]
as
select
	per.pgp_cd_periodo IdPeriodo
	,esp.mtn_cd_motorista_nfs CodigoEspelho
	,esp.mtn_nome_motorista Colaborador
	,sta.lst_ds_label StatusEspelho
	,pgt.ppr_cd_pagamento_rota CodigoPagamento
	,pgt.ppr_cd_rota CodigoSalario
	,pgt.ppr_lcto_observacao DescricaoPagamento
	,pgt.ppr_vl_base PagamentoSalario
	,isnull(pgt.ppr_vl_lancamentos,0) ValorLancamento
	,pgt.ppr_vl_total TotalPagamento
	,pgt.ppr_data_referencia DataReferencia
	,sal.tsp_nm_cargo Cargo
	,esp.mtn_ds_Banco Banco
	,esp.mtn_ds_NomeTitular NomeTitular
	,esp.mtn_ds_CpfTitular CpfTitular
	,esp.mtn_ds_CnpjTitular CnpjTitular
	,esp.mtn_ds_Agencia Agencia
	,esp.mtn_ds_Conta Conta
	,esp.mtn_ds_TipoConta TipoConta
	,esp.mtn_ds_TipoChavePix TipoChavePix
	,esp.mtn_ds_ChavePix ChavePix
	,esp.mtn_ds_CnpjEmpresa CnpjEmpresa
	,esp.mtn_ds_RazaoSocial RazaoSocial
	,esp.mtn_ds_NomeFantasia NomeFantasia
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo per with(nolock)
	join tb_lista mkt with(nolock) on per.pgp_cd_cliente_transportadora = mkt.lst_cd_lista
	join tb_pag_espelhos esp with(nolock) on per.pgp_cd_periodo = esp.mtn_cd_pgto_periodo
											and esp.mtn_in_excluido = 0
	join tb_lista sta with(nolock) on esp.mtn_cd_status = sta.lst_cd_lista
	join tb_usuario usu with(nolock) on esp.mtn_cd_motorista = usu.usr_cd_usuario
	join tb_pgto_periodo_rota pgt with(nolock) on esp.mtn_cd_motorista_nfs = pgt.ppr_cd_motorista_nfs
	left join tb_fin_salarios_profissionais sal with(nolock) on pgt.ppr_cd_rota = sal.tsp_cd_salario
where
	per.pgp_in_excluido = 0
	and mkt.lst_ds_valor = 'Administrativo'
	and pgt.ppr_in_excluido = 0
GO
