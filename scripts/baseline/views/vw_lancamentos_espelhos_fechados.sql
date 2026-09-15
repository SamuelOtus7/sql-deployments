-- ============================================================
-- BASELINE: dbo.vw_lancamentos_espelhos_fechados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lancamentos_espelhos_fechados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_lancamentos_espelhos_fechados]
as
select
	per.pgp_cd_cliente CodigoCliente
	,per.pgp_nm_periodo Periodo
	,e.mtn_nome_motorista Motorista
	,p.ppr_lcto_cd_lancamento IdLancamentoManual
from
	tb_pgto_periodo_rota p
	join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
	join tb_pgto_periodo per on e.mtn_cd_pgto_periodo = per.pgp_cd_periodo
	join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista 
where
	p.ppr_in_excluido = 0
	and p.ppr_lcto_cd_lancamento is not null
	and e.mtn_in_excluido = 0
	and (
		per.pgp_cd_status = 2
		or
		lst_cd_fechado = 1
	)
GO
