-- ============================================================
-- BASELINE: dbo.UspGeraValidacoesEspelho
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraValidacoesEspelho]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspGeraValidacoesEspelho]    (
    @CodigoPeriodo int
)
as
begin
	
	set nocount on
	
	--declare @CodigoPeriodo int = 737

	drop table if exists #resultado_validacoes
	create table #resultado_validacoes
	(
		IdPagamentoRota int null
		,IdRota varchar(30) null
		,IdLancamentoManual int null
		,Validacao bit not null
	)

	drop table if exists #validacoes
	select
		val.vec_cd_validacao_contexto
		,val.vle_nm_grupo_validacao
		,val.vle_ds_sql_script
		into #validacoes
	from
		tb_pgto_periodo per with(nolock)
		join tb_lista l with(nolock) on per.pgp_cd_cliente_transportadora = l.lst_cd_lista
		join tb_lista l2 with(nolock) on per.pgp_tipo_operacao = l2.lst_cd_lista
		join vw_validacoes_espelho val on per.pgp_cd_cliente = val.veg_cd_cliente
									and l.lst_ds_valor = val.vec_nm_cliente_transportadora
									and l2.lst_ds_valor = val.vec_nm_operacao
	where
		per.pgp_cd_periodo = @CodigoPeriodo

	while exists (select 1 from #validacoes)
	begin
		declare @vec_cd_validacao_contexto int
		declare @vle_nm_grupo_validacao varchar(60)
		declare @vle_ds_sql_script varchar(max)

		select
			top 1
			@vec_cd_validacao_contexto = vec_cd_validacao_contexto
			,@vle_nm_grupo_validacao = vle_nm_grupo_validacao
			,@vle_ds_sql_script = replace(vle_ds_sql_script,'@Periodo',@CodigoPeriodo)
		from
			#validacoes
		order by
			vec_cd_validacao_contexto

		truncate table #resultado_validacoes
	
		insert into #resultado_validacoes
		exec(@vle_ds_sql_script)
	
		--print(@vle_ds_sql_script)
		
		/*
		delete tb_validacoes_espelho_resultados where ver_cd_validacao_contexto = @vec_cd_validacao_contexto and ver_cd_periodo = @CodigoPeriodo

		insert into tb_validacoes_espelho_resultados (ver_cd_validacao_contexto, ver_cd_periodo, ver_cd_pagamento_rota, ver_cd_rota, ver_cd_lancamento_manual, ver_in_resultado_sucesso, ver_cd_usuario_inativacao, ver_dh_inativacao)
		select 
			@vec_cd_validacao_contexto ver_cd_validacao_contexto
			,@CodigoPeriodo ver_cd_periodo
			,IdPagamentoRota ver_cd_pagamento_rota
			,IdRota ver_cd_rota
			,IdLancamentoManual ver_cd_lancamento_manual
			,Validacao ver_in_resultado_sucesso
			,null ver_cd_usuario_inativacao
			,null ver_dh_inativacao 
		from 
			#resultado_validacoes
		*/

		MERGE tb_validacoes_espelho_resultados AS tgt
		USING (
			SELECT
				@vec_cd_validacao_contexto AS ver_cd_validacao_contexto,
				@CodigoPeriodo             AS ver_cd_periodo,
				IdPagamentoRota            AS ver_cd_pagamento_rota,
				IdRota                     AS ver_cd_rota,
				IdLancamentoManual         AS ver_cd_lancamento_manual,
				Validacao                  AS ver_in_resultado_sucesso
			FROM #resultado_validacoes
		) AS src
		ON  tgt.ver_cd_validacao_contexto = src.ver_cd_validacao_contexto
		AND tgt.ver_cd_periodo             = src.ver_cd_periodo
		AND isnull(tgt.ver_cd_pagamento_rota,0)      = isnull(src.ver_cd_pagamento_rota,0)
		AND isnull(tgt.ver_cd_rota,0)                = isnull(src.ver_cd_rota,0)
		AND isnull(tgt.ver_cd_lancamento_manual,0)   = isnull(src.ver_cd_lancamento_manual,0)

		WHEN MATCHED THEN
			UPDATE SET
				--caso antes não era sucesso a validação e passou a ser depois de algum reprocessamento, salva o horário que foi alterado
				tgt.ver_dh_sucesso = case when tgt.ver_in_resultado_sucesso = 0 and src.ver_in_resultado_sucesso = 1 then getdate() else tgt.ver_dh_sucesso end
				,tgt.ver_in_resultado_sucesso = src.ver_in_resultado_sucesso
				

		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				ver_cd_validacao_contexto,
				ver_cd_periodo,
				ver_cd_pagamento_rota,
				ver_cd_rota,
				ver_cd_lancamento_manual,
				ver_in_resultado_sucesso,
				ver_cd_usuario_inativacao,
				ver_dh_inativacao,
				ver_dh_sucesso
			)
			VALUES (
				src.ver_cd_validacao_contexto,
				src.ver_cd_periodo,
				src.ver_cd_pagamento_rota,
				src.ver_cd_rota,
				src.ver_cd_lancamento_manual,
				src.ver_in_resultado_sucesso,
				NULL,
				NULL,
				NULL
			)

		WHEN NOT MATCHED BY SOURCE
			 AND tgt.ver_cd_validacao_contexto = @vec_cd_validacao_contexto
			 AND tgt.ver_cd_periodo = @CodigoPeriodo
		THEN DELETE;


		delete tb_validacoes_espelho_resultados_totais where vet_cd_validacao_contexto = @vec_cd_validacao_contexto and vet_cd_periodo = @CodigoPeriodo
		
		insert into tb_validacoes_espelho_resultados_totais
		select
			ver_cd_validacao_contexto vet_cd_validacao_contexto,
			ver_cd_periodo vet_cd_periodo,
			count(case when ver_in_resultado_sucesso = 1 then ver_in_resultado_sucesso end) vet_nr_sucesso,
			count(1) vet_nr_total
		from
			tb_validacoes_espelho_resultados
		where
			ver_cd_validacao_contexto = @vec_cd_validacao_contexto 
			and ver_cd_periodo = @CodigoPeriodo
		group by
			ver_cd_validacao_contexto,
			ver_cd_periodo



		delete #validacoes where vec_cd_validacao_contexto = @vec_cd_validacao_contexto


	end

end


	
GO
