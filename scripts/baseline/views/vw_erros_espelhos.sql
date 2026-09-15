-- ============================================================
-- BASELINE: dbo.vw_erros_espelhos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_erros_espelhos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create view [dbo].[vw_erros_espelhos]
as
select 
	a.pee_id
	,a.pee_cd_motorista
	,a.pee_nm_motorista
	,a.pee_base
	,a.pee_cd_periodo
	,a.pee_ds_erro
	,a.pee_dh_criacao
	,a.pee_cd_cliente_transportadora
	,a.pee_cd_operacao
	,b.pgp_cd_cliente
from 
	tb_pag_espelhos_erros a with(nolock)
	join tb_pgto_periodo b with(nolock) on pee_cd_periodo = pgp_cd_periodo
where
	a.pee_cd_periodo > 2551 
	and b.pgp_in_excluido = 0
GO
