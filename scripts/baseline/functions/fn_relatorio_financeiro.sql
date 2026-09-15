-- ============================================================
-- BASELINE: dbo.fn_relatorio_financeiro
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
--/****** Object:  UserDefinedFunction [dbo].[fn_relatorio_financeiro]    Script Date: 13/08/2025 16:06:28 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
---- SET ANSI_NULLS ON
---- GO
---- SET QUOTED_IDENTIFIER ON
---- GO


CREATE FUNCTION [dbo].[fn_relatorio_financeiro_consolidado](
    @IdPeriodo int null,
    @Rota varchar(50) null
) 
RETURNS TABLE
AS
RETURN



select 
	pag.mtn_ds_CnpjEmpresa CnpjEmpresa
	,pag.mtn_ds_NomeTitular NomeTitular
	,pag.mtn_ds_CnpjTitular CnpjTitular
	,pag.mtn_ds_CpfTitular CpfTitular
	,pag.mtn_ds_Banco Banco
	,pag.mtn_ds_Agencia Agencia
	,pag.mtn_ds_Conta Conta
	,pag.mtn_ds_TipoConta TipoConta
	,pag.mtn_ds_TipoChavePix TipoChavePix
	,pag.mtn_ds_ChavePix ChavePix
	--m.CnpjEmpresa
	--,m.NomeTitular
	--,m.CnpjTitular
	--,m.CpfTitular
	--,m.Banco
	--,m.Agencia
	--,m.TipoConta
	--,m.Conta
	--,m.TipoChavePix
	--,m.ChavePix
	,ppr_base_principal SVC
	,ppr_cd_periodo
    ,pgp_nm_periodo
	,isnull(sum(case when ppr_fl_desconto = 0 then ppr_vl_total  end),0) - isnull(sum(case when ppr_fl_desconto = 1 then ppr_vl_total end),0) TotalLiquido

from 
	tb_pgto_periodo_rota a with(nolock)

	inner join tb_pag_espelhos as pag
	on ppr_cd_motorista_nfs = mtn_cd_motorista_nfs

	inner join tb_pgto_periodo as b with(nolock)
	on a.ppr_cd_periodo = b.pgp_cd_periodo

	left join tb_clientes as cli
	on b.pgp_cd_cliente = cli.cli_cd_codigo_cliente

	left join vw_resultado_financeiro as c
	on a.ppr_cd_rota = c.IdRota

	left join tb_fin_prefatura as pre with(nolock)
	on a.ppr_cd_rota = pre.IdRota

	--Inclusão para pegar dados de pagamentos dos motoristas solicitado pela 50+
	--left join vw_dados_motoristas m on a.ppr_cd_motorista = m.CodigoUsuario and b.pgp_cd_cliente = m.IdCliente



where 1=1 
--and pgp_cd_status = 1
and pgp_cd_periodo >= 370 
and (@IdPeriodo is null or ppr_cd_periodo = @IdPeriodo)
--and (ppr_cd_periodo = 393)
and (@Rota is null or ppr_cd_rota = @Rota)
and ppr_in_excluido = 0

group by
	--m.CnpjEmpresa
	--,m.NomeTitular
	--,m.CnpjTitular
	--,m.CpfTitular
	--,m.Banco
	--,m.Agencia
	--,m.TipoConta
	--,m.Conta
	--,m.TipoChavePix
	--,m.ChavePix
	pag.mtn_ds_CnpjEmpresa
	,pag.mtn_ds_NomeTitular
	,pag.mtn_ds_CnpjTitular
	,pag.mtn_ds_CpfTitular
	,pag.mtn_ds_Banco
	,pag.mtn_ds_Agencia
	,pag.mtn_ds_Conta
	,pag.mtn_ds_TipoConta
	,pag.mtn_ds_TipoChavePix
	,pag.mtn_ds_ChavePix
	,ppr_base_principal
	,ppr_cd_periodo
    ,pgp_nm_periodo
GO
