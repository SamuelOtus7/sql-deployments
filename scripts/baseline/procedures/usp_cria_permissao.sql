-- ============================================================
-- BASELINE: dbo.usp_cria_permissao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_cria_permissao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[usp_cria_permissao]
as
insert into tb_relatorios_filtros_usuarios
select
	rel2.rfl_cd_filtro,
	usu.rfu_cd_usuario
from
	tb_relatorios_filtros_usuarios usu
	join tb_relatorios_filtros rel on usu.rfu_cd_relatorios_filtro = rel.rfl_cd_filtro
	join tb_relatorios_filtros rel2 on rel.rfl_ds_tabela = rel2.rfl_ds_tabela and rel.rfl_ds_coluna = rel2.rfl_ds_coluna and rel.rfl_ds_valor = rel2.rfl_ds_valor and rel2.rfl_cd_rel_relatorio=1069
where
	rel.rfl_cd_rel_relatorio = 1062
	and rel.rfl_in_excluido = 0
	
GO
