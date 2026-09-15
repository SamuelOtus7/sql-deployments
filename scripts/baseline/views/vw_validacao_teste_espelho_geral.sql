-- ============================================================
-- BASELINE: dbo.vw_validacao_teste_espelho_geral
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacao_teste_espelho_geral]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_validacao_teste_espelho_geral]
as
select 
	case when
		ISNULL(a.TotalEspelhos,0) <> ISNULL(d.TotalEspelhos,0)
		or ISNULL(a.TotalEspelhosAtivos,0) <> ISNULL(d.TotalEspelhosAtivos,0)
		or ISNULL(a.TotalEspelhosExcluidos,0) <> ISNULL(d.TotalEspelhosExcluidos,0)
		or ISNULL(a.TotalPagamentoEspelhos,0) <> ISNULL(d.TotalPagamentoEspelhos,0)
		or ISNULL(a.TotalPagamentoLiquidoEspelhos,0) <> ISNULL(d.TotalPagamentoLiquidoEspelhos,0)
	then 'Encontrou Divergência'
	else 'Validado' end StatusValidacao

	,isnull(a.mtn_cd_pgto_periodo,d.mtn_cd_pgto_periodo) Periodo
	,isnull(a.NomePeriodo,d.NomePeriodo) NomePeriodo
	,isnull(a.CodigoCliente,d.CodigoCliente) CodigoCliente
	,isnull(a.Cliente,d.Cliente) Cliente

	,a.TotalEspelhos TotalEspelhosAntes
	,d.TotalEspelhos TotalEspelhosDepois
	,isnull(a.TotalEspelhos,0) - isnull(d.TotalEspelhos,0) DiferencaTotalEspelhos
	
	,a.TotalEspelhosExcluidos TotalEspelhosExcluidosAntes
	,d.TotalEspelhosExcluidos TotalEspelhosExcluidosDepois
	,isnull(a.TotalEspelhosExcluidos,0) - isnull(d.TotalEspelhosExcluidos,0) DiferencaTotalEspelhosExcluidos

	,a.TotalEspelhosAtivos TotalEspelhosAtivosAntes
	,d.TotalEspelhosAtivos TotalEspelhosAtivosDepois
	,isnull(a.TotalEspelhosAtivos,0) - isnull(d.TotalEspelhosAtivos,0) DiferencaTotalEspelhosAtivos

	,a.TotalPagamentoEspelhos TotalPagamentoEspelhosAntes
	,d.TotalPagamentoEspelhos TotalPagamentoEspelhosDepois
	,isnull(a.TotalPagamentoEspelhos,0) - isnull(d.TotalPagamentoEspelhos,0) DiferencaTotalPagamentoEspelhos

	,a.TotalPagamentoLiquidoEspelhos TotalPagamentoLiquidoEspelhosAntes
	,d.TotalPagamentoLiquidoEspelhos TotalPagamentoLiquidoEspelhosDepois
	,isnull(a.TotalPagamentoLiquidoEspelhos,0) - isnull(d.TotalPagamentoLiquidoEspelhos,0) DiferencaTotalPagamentoLiquidoEspelhos
from 
	(select 
		mtn_cd_pgto_periodo
		,p.pgp_nm_periodo NomePeriodo
		,c.cli_cd_codigo_cliente CodigoCliente
		,c.cli_ds_nome Cliente
		,count(1) TotalEspelhos
		,count(case when mtn_in_excluido = 0 then 1 end) TotalEspelhosAtivos
		,count(case when mtn_in_excluido = 1 then 1 end) TotalEspelhosExcluidos
		,sum(case when mtn_in_excluido = 0 then mtn_vl_nfs end) TotalPagamentoEspelhos
		,sum(case when mtn_in_excluido = 0 then mtn_vl_liquido end) TotalPagamentoLiquidoEspelhos
	from 
		tb_pag_espelhos_teste_calculo e
		join tb_pgto_periodo p on e.mtn_cd_pgto_periodo = p.pgp_cd_periodo
		join tb_clientes c on p.pgp_cd_cliente = c.cli_cd_codigo_cliente
	where 
		mtn_fase_teste = 'Antes'
	group by
		mtn_cd_pgto_periodo
		,p.pgp_nm_periodo
		,c.cli_cd_codigo_cliente
		,c.cli_ds_nome
	) a
	full join (select 
					mtn_cd_pgto_periodo
					,p.pgp_nm_periodo NomePeriodo
					,c.cli_cd_codigo_cliente CodigoCliente
					,c.cli_ds_nome Cliente
					,count(1) TotalEspelhos
					,count(case when mtn_in_excluido = 0 then 1 end) TotalEspelhosAtivos
					,count(case when mtn_in_excluido = 1 then 1 end) TotalEspelhosExcluidos
					,sum(case when mtn_in_excluido = 0 then mtn_vl_nfs end) TotalPagamentoEspelhos
					,sum(case when mtn_in_excluido = 0 then mtn_vl_liquido end) TotalPagamentoLiquidoEspelhos
				from 
					tb_pag_espelhos_teste_calculo  e
					join tb_pgto_periodo p on e.mtn_cd_pgto_periodo = p.pgp_cd_periodo
					join tb_clientes c on p.pgp_cd_cliente = c.cli_cd_codigo_cliente
				where 
					mtn_fase_teste = 'Depois'
				group by
					mtn_cd_pgto_periodo
					,p.pgp_nm_periodo
					,c.cli_cd_codigo_cliente
					,c.cli_ds_nome
				) d on a.mtn_cd_pgto_periodo = d.mtn_cd_pgto_periodo

	
GO
