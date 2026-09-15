-- ============================================================
-- BASELINE: dbo.vw_validacoes_espelho
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacoes_espelho]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_validacoes_espelho]
as
select
	v.vle_cd_validacao
	,v.vle_nm_validacao
	,l3.lst_ds_valor vle_nm_grupo_validacao
	,v.vle_ds_sql_script
	,c.vec_cd_validacao_contexto
	,c.vec_cd_cliente_transportadora
	,l.lst_ds_valor vec_nm_cliente_transportadora
	,c.vec_cd_operacao
	,l2.lst_ds_valor vec_nm_operacao
	,f.veg_cd_cliente
from
	tb_validacoes_espelho v with(nolock)
	join tb_validacoes_espelho_contexto c with(nolock) on v.vle_cd_validacao = c.vec_cd_validacao
	join tb_lista l with(nolock) on c.vec_cd_cliente_transportadora = l.lst_cd_lista
	join tb_lista l2 with(nolock) on c.vec_cd_operacao = l2.lst_cd_lista
	join tb_lista l3 with(nolock) on v.vle_cd_grupo_validacao = l3.lst_cd_lista
	join tb_validacoes_espelho_config f with(nolock) on c.vec_cd_validacao_contexto = f.veg_cd_validacao_config
where
	v.vle_in_ativo = 1
	and c.vec_in_ativo = 1
	and veg_in_habilitado = 1
GO
