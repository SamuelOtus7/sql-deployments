-- ============================================================
-- BASELINE: dbo.vw_validacoes_espelho_resultados_totais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_validacoes_espelho_resultados_totais]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_validacoes_espelho_resultados_totais]
as
select
	v.vle_nm_validacao Validacao
	,v.vle_ds_validacao DescricaoValidacao
	,l.lst_ds_label GrupoValidacao
	,l2.lst_ds_label TipoValidacao
	,t.vet_cd_periodo CodigoPeriodo
	,t.vet_cd_validacao_contexto CodigoValidacaoContexto
	,t.vet_nr_sucesso+isnull(QtdeInativado,0) QtdeSucesso --contabiliza também os que foram inativados
	,t.vet_nr_total QtdeTotal
	,conf.veg_in_obrigatorio_apuracao ObrigatorioApuracao
	,conf.veg_in_permite_desabilitar PermiteDesabilitar
	,case when l2.lst_ds_label = 'Information' then 0 else 1 end ExibirDetalhes
from
	tb_validacoes_espelho v with(nolock)
	join tb_lista l with(nolock) on v.vle_cd_grupo_validacao = l.lst_cd_lista
	join tb_lista l2 with(nolock) on v.vle_cd_tipo_validacao = l2.lst_cd_lista
	join tb_validacoes_espelho_contexto c with(nolock) on v.vle_cd_validacao = c.vec_cd_validacao
	join tb_validacoes_espelho_config conf with(nolock) on c.vec_cd_validacao_contexto = veg_cd_validacao_contexto
	join tb_validacoes_espelho_resultados_totais t with(nolock) on c.vec_cd_validacao_contexto = t.vet_cd_validacao_contexto
	left join (
		select
			ver_cd_validacao_contexto
			,count(1) QtdeInativado
		from
			tb_validacoes_espelho_resultados with(nolock)
		where
			ver_dh_inativacao is not null
		group by
			ver_cd_validacao_contexto
	) i on c.vec_cd_validacao_contexto = i.ver_cd_validacao_contexto

GO
