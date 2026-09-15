-- ============================================================
-- BASELINE: dbo.vw_validacao_teste_pgto_lancamento_manual
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacao_teste_pgto_lancamento_manual]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vw_validacao_teste_pgto_lancamento_manual]
as
select
	isnull(depois.ppr_cd_periodo,antes.ppr_cd_periodo) ppr_cd_periodo
	,isnull(depois.ppr_lcto_cd_lancamento,antes.ppr_lcto_cd_lancamento) ppr_lcto_cd_lancamento
	,antes.ppr_cd_motorista ppr_cd_motorista_antes
	,depois.ppr_cd_motorista ppr_cd_motorista_depois
	,antes.ppr_nome_motorista ppr_nome_motorista_antes
	,depois.ppr_nome_motorista ppr_nome_motorista_depois
	,antes.ppr_base_principal ppr_base_principal_antes
	,depois.ppr_base_principal ppr_base_principal_depois
	,antes.ppr_data_referencia ppr_data_referencia_antes
	,depois.ppr_data_referencia ppr_data_referencia_depois
	,antes.ppr_vl_lancamentos ppr_vl_lancamentos_antes
	,depois.ppr_vl_lancamentos ppr_vl_lancamentos_depois
from
	(
	select 
		ppr_cd_periodo,
		ppr_lcto_cd_lancamento, 
		ppr_vl_lancamentos,
		ppr_cd_motorista,
		ppr_nome_motorista,
		ppr_base_principal,
		ppr_data_referencia
	from 
		tb_pgto_periodo_rota_teste_calculo
	where 
		ppr_fase_teste = 'Depois'
		and isnull(ppr_cd_tipo_pgto,0) <> 1362
		and ppr_lcto_cd_lancamento is not null
	) depois
	full join 
	(
	select 
		ppr_cd_periodo,
		ppr_lcto_cd_lancamento, 
		ppr_vl_lancamentos,
		ppr_cd_motorista,
		ppr_nome_motorista,
		ppr_base_principal,
		ppr_data_referencia
	from 
		tb_pgto_periodo_rota_teste_calculo
	where 
		ppr_fase_teste = 'Antes'
		and isnull(ppr_cd_tipo_pgto,0) <> 1362
		and ppr_lcto_cd_lancamento is not null
	) antes on depois.ppr_cd_periodo = antes.ppr_cd_periodo and depois.ppr_lcto_cd_lancamento = antes.ppr_lcto_cd_lancamento
where
	isnull(antes.ppr_vl_lancamentos,0) <> isnull(depois.ppr_vl_lancamentos,0)
	
GO
