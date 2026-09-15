-- ============================================================
-- BASELINE: dbo.UspFinAtualizaPagamentoSaida
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaPagamentoSaida]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinAtualizaPagamentoSaida]  (
	@CodPeriodoPagamento int,
	@IdRota int = null,
	@CodEspelho int = null
)
as
begin

	-- **************** ALTERAÇÕES ****************
	--Adiciona campo para transportadora definir se quando for ambulancia, deve ser pago primeira faixa
	--alter table tb_fin_base_frete_adicional_motorista add bfa_cd_ambulancia_primeira_faixa bit null


	--Adiciona campo para transportadora definir se na prefatura vier Endereço Não Visitado, zerar o valor da saida
	--alter table tb_fin_base_frete_adicional_motorista add bfa_cd_zerar_rota_endereco_nao_visitado bit null

	--Adiciona campo para transportadora definir se o pagamento deve ser o valor informado no frete multiplicado pela quantidade de pacotes
	--Vi que na parceiro spot tem isso para Triciclos, acho que poderia ter criado uma faixa unica de 1 a 9999
	--alter table tb_fin_base_frete_motorista add bfm_cd_pagar_por_pacotes bit null

	--Campo para informar se é uma ambulancia a rota
	--alter table tb_pgto_periodo_rota add ppr_in_ambulancia bit null

	--adiciona informação de qual contrato é o motorista
	--alter table tb_pag_espelhos add mtn_cd_tipo_contrato int null

	--********** CRIA TABELA PARA CONTROLAR STATUS DOS ESPELHOS **************
	--create table tb_status_espelho (
	--	sep_cd_status int not null identity(1,1)
	--	,sep_nm_status varchar(60) not null
	--	,sep_in_fechado bit not null
	--	,sep_cd_ordem tinyint not null
	--)

	--alter table tb_status_espelho add constraint PK_tb_status_espelho primary key (sep_cd_status)
	--alter table tb_status_espelho add constraint UQ_tb_status_espelho unique (sep_nm_status)

	--insert into tb_status_espelho
	--select
	--	lst_ds_label
	--	,lst_cd_fechado
	--	,lst_nr_ordem
	--from
	--	tb_lista l 
	--where 
	--	lst_nm_lista = 'Status motorista nfs' 
	--order by
	--	lst_nr_ordem


	----Atualiza status dos espelhos para nova lista
	--update 
	--	e
	--set
	--	e.mtn_cd_status = s.status_para
	--from
	--	tb_pag_espelhos e
	--	join (
	--			select
	--				l.lst_cd_lista status_de
	--				,s.sep_cd_status status_para
	--			from
	--				tb_lista l 
	--				join tb_status_espelho s on l.lst_ds_label = s.sep_nm_status
	--			where 
	--				lst_nm_lista = 'Status motorista nfs' 
	--		) s on e.mtn_cd_status = s.status_de

	---- exclui coluna que era utilizada somente para esta lista
	--alter table tb_lista drop column lst_cd_fechado

	/*
	21/10/2025
	Incluir a coluna [bfa_cd_ambulancia_primeira_faixa]
	na tabela tb_fin_base_frete_adicional_motorista
	e alterar a view [vw_fin_base_frete_adicional_motorista]

	Incluir a coluna ppr_in_ambulancia
	na tabela tb_pgto_periodo_rota

	incluir a coluna bfm_cd_pagar_por_pacotes
	na tabela TB_fin_base_frete_motorista
	e alterar a view [vw_fin_base_frete_motorista] e [vw_fin_base_frete_motorista_distritos]
	*/

	-- **************** FIM ALTERAÇÕES ****************



	--retirar campo lst_cd_fechado da tabela tb_lista e criar nova tabela (precisa mudar na tela)

	-- **************** DÚVIDAS ****************
	-- Qual critério para saber se o que está na tabela tb_pgto_periodo_rota é um calculo de rota ou um lançamento manual
	-- sendo que não posso filtrar lançamento apenas o campo ppr_lcto_cd_lancamento is null pois posso ter rota que vou ter isso calculado
	-- SOLUÇÃO: novo campo na tabela para informar qual é o tipo de lançamento: Rota do Meli, Lançamento Avulso, Lançamento Manual, etc...

	
	-- Qual coluna ficará armazenado o km utilizado para verificar a faixa? Coloquei ppr_total_km_rtt apenas para desenvolvimento da procedure mas irei remover com a informação do samuka
	-- SOLUÇÃO: ppr_total_km

	-- Se a transportadora usa a faixa de km da prefatura, essa informação já vai vim na tabela tb_pgto_periodo_rota ou preciso fazer um join na prefatura?
	-- SOLUÇÃO: o valor do inicio da faixa da prefatura vai para o campo ppr_total_km caso este seja o utilizado


	-- Na tela, o usuário pode editar a faixa de km, nesse caso, como devo fazer para pegar o frete? terá algum campo para dizer se preciso pegar a faixa de km?
	-- Exemplo: (
				--	r.KmRTT > (freteKmCidade.bfm_vl_inicio_faixa - 1)
				--	and r.KmRTT <= freteKmCidade.bfm_vl_fim_faixa
				--	and editrota.edit_Faixa_Km is null
				--)
				--or
				--editrota.edit_Faixa_Km = cast(freteKmCidade.bfm_vl_inicio_faixa as varchar) + '/' + cast(freteKmCidade.bfm_vl_fim_faixa as varchar)
	--SOLUÇÃO: já vai vim ajustado o valor no campo ppr_total_km


	-- A coluna de tipo de contrato já vai ficar na tabela tb_pgto_periodo_rota? se precisar fazer join com usuarios, verificar este ponto com a consulta para não duplicar
	--SOLUÇÃO: o campo vai ta na tb_pag_espelho e vou fazer join aqui


	-- O valor vei_vl_pagamento_fixo para ValorFixoPlacaRota já estará direto na tb_pgto_periodo_rota?
	--SOLUÇÃO: vai ter um parametro para informar se devo buscar deste lugar


	-- Garantir que a tabela tb_fin_base_frete_motorista não tenha inicio de faixa menor que 0
	--update tb_fin_base_frete_motorista set bfm_vl_inicio_faixa = 1 where bfm_vl_inicio_faixa < 1
	--ALTER TABLE tb_fin_base_frete_motorista
	--ADD CONSTRAINT chk_bfm_vl_inicio_faixa_gt_zero
	--CHECK (bfm_vl_inicio_faixa > 0);
	-- **************** FIM DÚVIDAS ****************



	--declare @CodPeriodoPagamento int = 2338
	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)

    SET @CodEspelho = CASE WHEN @CodEspelho = 0 THEN null ELSE @CodEspelho END
    SET @idrota     = CASE WHEN @idrota = 0 THEN null ELSE @idrota END

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1
	begin
	


		declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
		declare @IdTransportadora int = (select cli_id_logistics from tb_clientes where cli_cd_codigo_cliente=@CodigoCliente)
		declare @Operacao int = (select 
									lst_cd_lista 
								from    tb_lista as a with(nolock)
								inner   join [tb_pgto_periodo] as b with(nolock)
										on a.lst_cd_cliente = b.pgp_cd_cliente
										and a.lst_cd_lista = b.pgp_tipo_operacao
								where   lst_nm_lista = 'Operações Marketplace'
										and pgp_cd_periodo = @CodPeriodoPagamento  
								)


		declare @IdCliTransportadora int = (select 
												lst_cd_lista 
											from 
												tb_lista (NOLOCK)
											where 
												lst_nm_lista = 'Clientes transportadoras'
												and lst_ds_label = 'Mercado Livre'
												and lst_cd_cliente = @CodigoCliente
											)



		declare @UtilizaContrato int = (
								select prm_ds_valor 
								from tb_parametros 
								where prm_ds_categoria = 'Financeiro - Pagamentos'
								and prm_nm_parametro = 'Utiliza contrato'
								and prm_cod_cliente = @CodigoCliente
								)


		declare @TipoOperacao varchar(2) = (   
    
                select  lst_ds_valor
                from    tb_lista as a with(nolock)
                inner   join [tb_pgto_periodo] as b with(nolock)
                        on a.lst_cd_cliente = b.pgp_cd_cliente
                        and a.lst_cd_lista = b.pgp_tipo_operacao
                where   lst_nm_lista = 'Operações Marketplace'
                        and pgp_cd_periodo = @CodPeriodoPagamento   
    
		)


		------------------------------------------------------------
		-- GERA TABELA COM DADOS QUE SERÃO UTILIZADOS PARA CÁLCULO
		------------------------------------------------------------
		drop table if exists #tb_pgto_periodo_rota
		select	
			pgto.*
		into	
			#tb_pgto_periodo_rota
		from
			tb_pgto_periodo_rota pgto with(nolock)
		where
			pgto.ppr_cd_periodo = @CodPeriodoPagamento
			and pgto.ppr_cd_rota is not null
			and pgto.ppr_nm_pgto = 'Rota Mercado Livre'
			and pgto.ppr_in_excluido = 0
			and (pgto.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
			and (pgto.ppr_cd_rota = @IdRota or @IdRota is null)


		-- ===========================================================================
		-- OTIMIZACAO: Materializar as views em #temp tables filtradas por categoria
		-- Evita re-executar o UNION + joins com tb_lista 10+ vezes
		-- Separacao em 3 tabelas reduz o volume escaneado em cada join:
		--   #tmp_bf_normal  (~5517 linhas) - sem placa, sem paradas (5 joins)
		--   #tmp_bf_placa   (~72 linhas)   - com placa, sem paradas (4 joins)
		--   #tmp_bf_paradas (~396 linhas)  - sem placa, com paradas (4 joins)
		-- ===========================================================================

		-- Range de data_referencia para filtrar as #temp tables
		declare @min_data_referencia date, @max_data_referencia date
		select @min_data_referencia = min(ppr_data_referencia),
			   @max_data_referencia = max(ppr_data_referencia)
		from #tb_pgto_periodo_rota

		-- --- #temp 1: vw_fin_base_frete_motorista NORMAL (sem placa, sem paradas) ---
		-- Usada por: freteKm0a100Cidade, freteKm0a100, freteKmCidade, freteKm, FreteFixo
		drop table if exists #tmp_bf_normal
		select
			 bfm_cd_base_frete_motorista
			,bfm_cd_transportadora
			,bfm_cd_service_center
			,bfm_nm_cidade
			,bfm_cd_tipo_veiculo
			,bfm_vl_inicio_faixa
			,bfm_vl_fim_faixa
			,bfm_vl_frete
			,bfm_vl_frete_pm
			,bfm_vl_frete_fixo
			,bmf_cd_tipo_contrato
			,bfm_cd_codigo_cliente
			,bfm_vl_domfer_am
			,bfm_vl_domfer_pm
			,bfm_data_inicio_vigencia
			,bfm_data_fim_vigencia
			,bfm_nm_regiao
			,bfm_cd_operacao
			,ValidFrom
			,ValidTo
			,Operacao
			,bfm_cd_pagar_por_pacotes
			,bfm_vl_frete_sd
			,bfm_cd_criterio_pagamento
			,bfm_pag_pacote_entregues
			,CriterioPagamento
			,bfm_perc_minimo_endereco_nao_visitado
			,bfm_zerar_ambulancia_nao_aprovada
			,bfm_ds_placa
			,CriterioFaixa
			,bfm_vl_inicio_faixa2
			,bfm_vl_fim_faixa2
			,CriterioFaixa2
		into #tmp_bf_normal
		from vw_fin_base_frete_motorista
		where bfm_cd_transportadora = @CodigoCliente
		  and Operacao = @TipoOperacao
		  and bfm_ds_placa is null
		  and CriterioFaixa2 is null
		  and bfm_data_inicio_vigencia <= @max_data_referencia
		  and (bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= @min_data_referencia)

		-- Indice para joins por service_center + tipo_veiculo + cidade + faixa_km
		create nonclustered index IX_tmp_bf_normal_cidade
			on #tmp_bf_normal (bfm_cd_service_center, bfm_cd_tipo_veiculo, bfm_nm_cidade, bfm_vl_inicio_faixa, bfm_vl_fim_faixa)
			include (bfm_vl_frete, bfm_vl_frete_pm, bfm_vl_frete_fixo, bmf_cd_tipo_contrato,
					 bfm_cd_codigo_cliente, bfm_vl_domfer_am, bfm_vl_domfer_pm,
					 bfm_cd_pagar_por_pacotes, bfm_vl_frete_sd, bfm_zerar_ambulancia_nao_aprovada,
					 CriterioPagamento, bfm_data_inicio_vigencia, bfm_data_fim_vigencia)

		-- --- #temp 2: vw_fin_base_frete_motorista PLACA (com placa, sem paradas) ---
		-- Usada por: fretePlacaCidade, fretePlaca, frete0a100PlacaCidade, frete0a100Placa
		drop table if exists #tmp_bf_placa
		select
			 bfm_cd_base_frete_motorista
			,bfm_cd_transportadora
			,bfm_cd_service_center
			,bfm_nm_cidade
			,bfm_cd_tipo_veiculo
			,bfm_vl_inicio_faixa
			,bfm_vl_fim_faixa
			,bfm_vl_frete
			,bfm_vl_frete_pm
			,bfm_vl_frete_fixo
			,bmf_cd_tipo_contrato
			,bfm_cd_codigo_cliente
			,bfm_vl_domfer_am
			,bfm_vl_domfer_pm
			,bfm_data_inicio_vigencia
			,bfm_data_fim_vigencia
			,bfm_nm_regiao
			,bfm_cd_operacao
			,ValidFrom
			,ValidTo
			,Operacao
			,bfm_cd_pagar_por_pacotes
			,bfm_vl_frete_sd
			,bfm_cd_criterio_pagamento
			,bfm_pag_pacote_entregues
			,CriterioPagamento
			,bfm_perc_minimo_endereco_nao_visitado
			,bfm_zerar_ambulancia_nao_aprovada
			,bfm_ds_placa
			,CriterioFaixa
			,bfm_vl_inicio_faixa2
			,bfm_vl_fim_faixa2
			,CriterioFaixa2
		into #tmp_bf_placa
		from vw_fin_base_frete_motorista
		where bfm_cd_transportadora = @CodigoCliente
		  and Operacao = @TipoOperacao
		  and bfm_ds_placa is not null
		  and CriterioFaixa2 is null
		  and bfm_data_inicio_vigencia <= @max_data_referencia
		  and (bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= @min_data_referencia)

		-- Indice para joins por service_center + tipo_veiculo + placa + cidade + faixa_km
		create nonclustered index IX_tmp_bf_placa
			on #tmp_bf_placa (bfm_cd_service_center, bfm_cd_tipo_veiculo, bfm_ds_placa, bfm_nm_cidade, bfm_vl_inicio_faixa, bfm_vl_fim_faixa)
			include (bfm_vl_frete, bfm_vl_frete_pm, bfm_vl_frete_fixo, bmf_cd_tipo_contrato,
					 bfm_cd_codigo_cliente, bfm_vl_domfer_am, bfm_vl_domfer_pm,
					 bfm_vl_frete_sd, bfm_data_inicio_vigencia, bfm_data_fim_vigencia)

		-- --- #temp 3: vw_fin_base_frete_motorista PARADAS (sem placa, com paradas) ---
		-- Usada por: freteKmCidadeParadas, freteKmParadas, freteKm0a100CidadeParadas, freteKm0a100Paradas
		drop table if exists #tmp_bf_paradas
		select
			 bfm_cd_base_frete_motorista
			,bfm_cd_transportadora
			,bfm_cd_service_center
			,bfm_nm_cidade
			,bfm_cd_tipo_veiculo
			,bfm_vl_inicio_faixa
			,bfm_vl_fim_faixa
			,bfm_vl_frete
			,bfm_vl_frete_pm
			,bfm_vl_frete_fixo
			,bmf_cd_tipo_contrato
			,bfm_cd_codigo_cliente
			,bfm_vl_domfer_am
			,bfm_vl_domfer_pm
			,bfm_data_inicio_vigencia
			,bfm_data_fim_vigencia
			,bfm_nm_regiao
			,bfm_cd_operacao
			,ValidFrom
			,ValidTo
			,Operacao
			,bfm_cd_pagar_por_pacotes
			,bfm_vl_frete_sd
			,bfm_cd_criterio_pagamento
			,bfm_pag_pacote_entregues
			,CriterioPagamento
			,bfm_perc_minimo_endereco_nao_visitado
			,bfm_zerar_ambulancia_nao_aprovada
			,bfm_ds_placa
			,CriterioFaixa
			,bfm_vl_inicio_faixa2
			,bfm_vl_fim_faixa2
			,CriterioFaixa2
		into #tmp_bf_paradas
		from vw_fin_base_frete_motorista
		where bfm_cd_transportadora = @CodigoCliente
		  and Operacao = @TipoOperacao
		  and bfm_ds_placa is null
		  and CriterioFaixa2 = 'Paradas'
		  and bfm_data_inicio_vigencia <= @max_data_referencia
		  and (bfm_data_fim_vigencia is null or bfm_data_fim_vigencia >= @min_data_referencia)

		-- Indice para joins por service_center + tipo_veiculo + cidade + faixa_km
		create nonclustered index IX_tmp_bf_paradas_cidade
			on #tmp_bf_paradas (bfm_cd_service_center, bfm_cd_tipo_veiculo, bfm_nm_cidade, bfm_vl_inicio_faixa, bfm_vl_fim_faixa)
			include (bfm_vl_frete, bfm_vl_frete_pm, bfm_vl_frete_fixo, bmf_cd_tipo_contrato,
					 bfm_cd_codigo_cliente, bfm_vl_domfer_am, bfm_vl_domfer_pm,
					 bfm_vl_frete_sd, bfm_vl_inicio_faixa2, bfm_vl_fim_faixa2,
					 bfm_data_inicio_vigencia, bfm_data_fim_vigencia)

		-- --- #temp: vw_fin_base_frete_adicional_motorista filtrada ------------------
		drop table if exists #tmp_bfa
		select
			 bfa_cd_base_frete_adicional_motorista
			,bfa_cd_transportadora
			,bfa_cd_service_center
			,bfa_nm_cidade
			,bfa_cd_tipo_veiculo
			,bfa_tipo_adicional_domingo
			,bfa_vl_adicional_domingo
			,bfa_tipo_adicional_ciclo_pm
			,bfa_vl_adicional_ciclo_pm
			,bfa_vl_paradas0_60
			,bfa_vl_paradas61_75
			,bfa_vl_paradas76_85
			,bfa_vl_paradas86_90
			,bfa_vl_paradas_acima_90
			,bfa_tipo_adicional_ajudante
			,bfa_vl_adicional_ajudante
			,bfa_tipo_adicional_risco
			,bfa_vl_adicional_risco
			,bfa_calcula_por_parada
			,bfa_vl_adicional
			,bfa_tipo_adicional_pool
			,bfa_cd_tipo_contrato
			,bfa_tipo_insucesso
			,bfa_cd_insucesso
			,bfa_vl_insucesso
			,bfa_cd_dias_insentos
			,bfa_cd_pacote_ajudante
			,bfa_cd_pacote_ajudante_area_risco
			,bfa_cd_codigo_cliente
			,bfa_vl_adicional_recarga
			,bfa_vl_sdd
			,bfa_vl_adicional_km100
			,bfa_tipo_adicional_recarga
			,bfa_vl_qtd_pacote
			,bfa_qtd_pacote
			,bfa_vl_bonus_ds
			,bfa_tipo_desconto_flex_frota
			,bfa_vl_valor_desconto_flex_frota
			,bfa_tipo_desconto_cartao_flex_frota
			,bfa_vl_valor_desconto_cartao_flex_frota
			,bfa_data_inicio_vigencia
			,bfa_data_fim_vigencia
			,bfa_tipo_adicional_feriado
			,bfa_vl_adicional_feriado
			,bfa_cd_operacao
			,Operacao
			,bfa_cd_ambulancia_primeira_faixa
			,bfa_vl_adicional_pedagio
			,bfa_qtd_pacote_ambulancia
			,bfa_vl_pacote_ambulancia
			,bfa_ds_placa
		into #tmp_bfa
		from vw_fin_base_frete_adicional_motorista
		where bfa_cd_transportadora = @CodigoCliente
		  and bfa_data_inicio_vigencia <= @max_data_referencia
		  and (bfa_data_fim_vigencia is null or bfa_data_fim_vigencia >= @min_data_referencia)

		create nonclustered index IX_tmp_bfa_cidade
			on #tmp_bfa (bfa_cd_transportadora, bfa_cd_service_center, bfa_cd_tipo_veiculo, bfa_nm_cidade)
			include (bfa_cd_ambulancia_primeira_faixa, bfa_qtd_pacote_ambulancia, bfa_vl_pacote_ambulancia,
					 bfa_cd_tipo_contrato, bfa_ds_placa, bfa_data_inicio_vigencia, bfa_data_fim_vigencia)

		-- ===========================================================================
        -- QUERY PRINCIPAL - substitui views por #temp tables
        -- ===========================================================================
        drop table if exists #pagamento_base
        select
            @Operacao ppr_cd_operacao
            ,@IdCliTransportadora ppr_id_cliente_transportadora
            ,pgto.ppr_cd_motorista_nfs
            ,pgto.ppr_cd_pagamento_rota
            ,pgto.ppr_cd_periodo
            ,pgto.ppr_cd_rota
            ,pgto.ppr_base_principal
            ,pgto.ppr_ds_tipo_veiculo
            ,veic.tvl_cd_tipo_veiculo
            ,pgto.ppr_nome_motorista
            ,isnull(esp.mtn_cd_tipo_contrato,-1) tipo_contrato
            ,pgto.ppr_nm_cidade
            ,pgto.ppr_total_km
            ,pgto.ppr_qt_pacotes
            ,pgto.ppr_qt_pacotes_entregues
            ,pgto.ppr_in_zerar_rota

            ,case when v.vei_valor_fixo > 0 then v.vei_valor_fixo end ValorFixoPlacaRota
            ,case when pgto.ppr_tipo_rota like '%SD%' or pgto.ppr_ds_ciclo = 'SD' then coalesce(fretePlacaCidade.bfm_vl_frete_sd,fretePlaca.bfm_vl_frete_sd,freteKmCidadeParadas.bfm_vl_frete_sd,freteKmParadas.bfm_vl_frete_sd,freteKmCidade.bfm_vl_frete_sd,freteKm.bfm_vl_frete_sd) else null end ValorFixoSD
            ,case when (pgto.ppr_tipo_rota like '%SD%' or pgto.ppr_ds_ciclo = 'SD') and coalesce(fretePlacaCidade.bfm_vl_frete_sd,fretePlaca.bfm_vl_frete_sd,freteKmCidadeParadas.bfm_vl_frete_sd,freteKmParadas.bfm_vl_frete_sd,freteKmCidade.bfm_vl_frete_sd,freteKm.bfm_vl_frete_sd)  is not null then 1 else null end ppr_cd_desconto_sd

            --Parametros necessários para verificar se a rota deve ser pago a 1 faixa por ser ambulancia
            ,isnull(adicionalCidade.bfa_cd_ambulancia_primeira_faixa,adicional.bfa_cd_ambulancia_primeira_faixa) PagarPrimeiraFaixaAmbulancia
            ,pgto.ppr_in_ambulancia
            ,pgto.ppr_in_ambulancia_aprovada
            ,isnull(adicionalCidade.bfa_qtd_pacote_ambulancia,adicional.bfa_qtd_pacote_ambulancia) bfa_qtd_pacote_ambulancia
            ,isnull(adicionalCidade.bfa_vl_pacote_ambulancia,adicional.bfa_vl_pacote_ambulancia) bfa_vl_pacote_ambulancia

             --quando é pago por pacote, apesar que é cadastrado por faixa de km, posso sempre considerar a primeira faixa pois não é necessário olhar faixa de km, pois é cálculo é valor fixo x qtde de pacote
            ,isnull(freteKm0a100.bfm_cd_pagar_por_pacotes,freteKm0a100Cidade.bfm_cd_pagar_por_pacotes) PagarPorPacote
            --o isnull ta pegando as duas opções do mesmo cruzamento

            --verifica se foi cadastrada alguma regra de pagamento
            ,case
                when freteKmCidade.bfm_cd_base_frete_motorista is not null
                    then freteKmCidade.CriterioPagamento
                when freteKm.bfm_cd_base_frete_motorista is not null
                    then freteKm.CriterioPagamento
                when freteKm0a100Cidade.bfm_cd_base_frete_motorista is not null
                    then freteKm0a100Cidade.CriterioPagamento
                when freteKm0a100.bfm_cd_base_frete_motorista is not null
                    then freteKm0a100.CriterioPagamento
             end CriterioPagamento

            --verifica se foi cadastrado flag para zerar ambulancia não aprovada
            ,case
                when freteKmCidade.bfm_cd_base_frete_motorista is not null
                    then freteKmCidade.bfm_zerar_ambulancia_nao_aprovada
                when freteKm.bfm_cd_base_frete_motorista is not null
                    then freteKm.bfm_zerar_ambulancia_nao_aprovada
                when freteKm0a100Cidade.bfm_cd_base_frete_motorista is not null
                    then freteKm0a100Cidade.bfm_zerar_ambulancia_nao_aprovada
                when freteKm0a100.bfm_cd_base_frete_motorista is not null
                    then freteKm0a100.bfm_zerar_ambulancia_nao_aprovada
            end ZerarAmbulanciaNaoAprovada

            --Campos com valor frete
            ,coalesce(
                case when FreteFixo.bfm_vl_frete_fixo = 0 then null else FreteFixo.bfm_vl_frete_fixo end
                ,case
                    when ppr_ds_ciclo in ('PM','SD') and (ppr_in_dom = 1 or ppr_in_fer = 1)
                        then coalesce(
                                     freteKm0a100CidadeParadas.bfm_vl_domfer_pm
                                    ,freteKm0a100Paradas.bfm_vl_domfer_pm
                                    ,freteKm0a100CidadeParadas.bfm_vl_frete_pm
                                    ,freteKm0a100Paradas.bfm_vl_frete_pm
                                    ,freteKm0a100CidadeParadas.bfm_vl_frete
                                    ,freteKm0a100Paradas.bfm_vl_frete

                                    ,frete0a100PlacaCidade.bfm_vl_domfer_pm
                                    ,frete0a100Placa.bfm_vl_domfer_pm
                                    ,frete0a100PlacaCidade.bfm_vl_frete_pm
                                    ,frete0a100Placa.bfm_vl_frete_pm
                                    ,frete0a100PlacaCidade.bfm_vl_frete
                                    ,frete0a100Placa.bfm_vl_frete

                                    ,freteKm0a100Cidade.bfm_vl_domfer_pm
                                    ,freteKm0a100.bfm_vl_domfer_pm
                                    ,freteKm0a100Cidade.bfm_vl_frete_pm
                                    ,freteKm0a100.bfm_vl_frete_pm
                                    ,freteKm0a100Cidade.bfm_vl_frete
                                    ,freteKm0a100.bfm_vl_frete
                                    )
                    when ppr_ds_ciclo = 'AM' and (ppr_in_dom = 1 or ppr_in_fer = 1)
                        then coalesce(
                                     freteKm0a100CidadeParadas.bfm_vl_domfer_am
                                    ,freteKm0a100Paradas.bfm_vl_domfer_am
                                    ,freteKm0a100CidadeParadas.bfm_vl_frete
                                    ,freteKm0a100Paradas.bfm_vl_frete

                                    ,frete0a100PlacaCidade.bfm_vl_domfer_am
                                    ,frete0a100Placa.bfm_vl_domfer_am
                                    ,frete0a100PlacaCidade.bfm_vl_frete
                                    ,frete0a100Placa.bfm_vl_frete

                                    ,freteKm0a100Cidade.bfm_vl_domfer_am
                                    ,freteKm0a100.bfm_vl_domfer_am
                                    ,freteKm0a100Cidade.bfm_vl_frete
                                    ,freteKm0a100.bfm_vl_frete
                                    )
                    when ppr_ds_ciclo in ('PM','SD')
                        then coalesce(
                                     freteKm0a100CidadeParadas.bfm_vl_frete_pm
                                    ,freteKm0a100Paradas.bfm_vl_frete_pm
                                    ,freteKm0a100CidadeParadas.bfm_vl_frete
                                    ,freteKm0a100Paradas.bfm_vl_frete

                                    ,frete0a100PlacaCidade.bfm_vl_frete_pm
                                    ,frete0a100Placa.bfm_vl_frete_pm
                                    ,frete0a100PlacaCidade.bfm_vl_frete
                                    ,frete0a100Placa.bfm_vl_frete

                                    ,freteKm0a100.bfm_vl_frete_pm
                                    ,freteKm0a100Cidade.bfm_vl_frete_pm
                                    ,freteKm0a100.bfm_vl_frete
                                    ,freteKm0a100Cidade.bfm_vl_frete)
                    when ppr_ds_ciclo = 'AM'
                        then coalesce(
                                     freteKm0a100CidadeParadas.bfm_vl_frete
                                    ,freteKm0a100Paradas.bfm_vl_frete

                                    ,frete0a100PlacaCidade.bfm_vl_frete
                                    ,frete0a100Placa.bfm_vl_frete

                                    ,freteKm0a100.bfm_vl_frete
                                    ,freteKm0a100Cidade.bfm_vl_frete)
                    end
            ,0) SaidaKm0a100

            ,coalesce(
                 case when FreteFixo.bfm_vl_frete_fixo = 0 then null else FreteFixo.bfm_vl_frete_fixo end
                ,case
                    when ppr_ds_ciclo in ('PM','SD') and (ppr_in_dom = 1 or ppr_in_fer = 1)
                        then coalesce(
                                     isnull(fretePlacaCidade.bfm_vl_domfer_pm,fretePlaca.bfm_vl_domfer_pm)
                                    ,isnull(freteKmCidadeParadas.bfm_vl_domfer_pm,freteKmParadas.bfm_vl_domfer_pm)
                                    ,isnull(freteKmCidade.bfm_vl_domfer_pm,freteKmCidade.bfm_vl_domfer_pm)
                                    ,isnull(freteKm.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm)
                                    ,isnull(freteKm.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm)
                                    )
                    when ppr_ds_ciclo = 'AM' and (ppr_in_dom = 1 or ppr_in_fer = 1)
                        then coalesce(
                                     isnull(fretePlacaCidade.bfm_vl_domfer_am,fretePlaca.bfm_vl_domfer_am)
                                    ,isnull(freteKmCidadeParadas.bfm_vl_domfer_am,freteKmParadas.bfm_vl_domfer_am)
                                    ,isnull(freteKmCidade.bfm_vl_domfer_am,freteKmCidade.bfm_vl_domfer_am)
                                    ,isnull(freteKm.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am)
                                    ,isnull(freteKmCidadeParadas.bfm_vl_frete,freteKmParadas.bfm_vl_frete)
                                    ,isnull(freteKm.bfm_vl_frete,freteKm.bfm_vl_frete)
                                    )
                    when ppr_ds_ciclo in ('PM','SD')
                        then coalesce(
                                     fretePlacaCidade.bfm_vl_frete_pm
                                    ,fretePlaca.bfm_vl_frete_pm
                                    ,freteKmCidadeParadas.bfm_vl_frete_pm
                                    ,freteKmParadas.bfm_vl_frete_pm
                                    ,freteKmCidade.bfm_vl_frete_pm
                                    ,freteKm.bfm_vl_frete_pm
                                    )
                    when ppr_ds_ciclo = 'AM'
                        then coalesce(
                                     fretePlacaCidade.bfm_vl_frete
                                    ,fretePlaca.bfm_vl_frete
                                    ,freteKmCidadeParadas.bfm_vl_frete
                                    ,freteKmParadas.bfm_vl_frete
                                    ,freteKmCidade.bfm_vl_frete
                                    ,freteKm.bfm_vl_frete
                                    )
                    end
            ,0) SaidaKm


            ,cast(
                coalesce(
                     fretePlacaCidade.bfm_vl_inicio_faixa
                    ,fretePlaca.bfm_vl_inicio_faixa
                    ,freteKmCidadeParadas.bfm_vl_inicio_faixa
                    ,freteKmParadas.bfm_vl_inicio_faixa
                    ,freteKmCidade.bfm_vl_inicio_faixa
                    ,freteKm.bfm_vl_inicio_faixa
                        ) 
             as varchar)
                + '/' + 
             cast(
                coalesce(
                     fretePlacaCidade.bfm_vl_fim_faixa
                    ,fretePlaca.bfm_vl_fim_faixa
                    ,freteKmCidadeParadas.bfm_vl_fim_faixa
                    ,freteKmParadas.bfm_vl_fim_faixa
                    ,freteKmCidade.bfm_vl_fim_faixa
                    ,freteKm.bfm_vl_fim_faixa
                        ) 
             as varchar) FaixaKm

            ,cast(
                coalesce(
                     freteKm0a100CidadeParadas.bfm_vl_inicio_faixa
                    ,freteKm0a100Paradas.bfm_vl_inicio_faixa
                    ,frete0a100PlacaCidade.bfm_vl_inicio_faixa
                    ,frete0a100Placa.bfm_vl_inicio_faixa
                    ,freteKm0a100Cidade.bfm_vl_inicio_faixa
                    ,freteKm0a100.bfm_vl_inicio_faixa
                        ) 
             as varchar) 
                + '/' + 
             cast(
                coalesce(
                     freteKm0a100CidadeParadas.bfm_vl_fim_faixa
                    ,freteKm0a100Paradas.bfm_vl_fim_faixa
                    ,frete0a100PlacaCidade.bfm_vl_fim_faixa
                    ,frete0a100Placa.bfm_vl_fim_faixa
                    ,freteKm0a100Cidade.bfm_vl_fim_faixa
                    ,freteKm0a100.bfm_vl_fim_faixa
                        ) 
             as varchar) FaixaKm0a100

        into 
            #pagamento_base
        from
            #tb_pgto_periodo_rota pgto with(nolock)
            join tb_pgto_periodo per with(nolock) on pgto.ppr_cd_periodo = per.pgp_cd_periodo
            join tb_dra_tipo_veiculo veic with (nolock) on pgto.ppr_ds_tipo_veiculo = veic.tvl_nm_tipo_veiculo
            join tb_pag_espelhos esp with(nolock) on pgto.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
                                                    and esp.mtn_cd_cliente_transportadora = @IdCliTransportadora
                                                    and esp.mtn_cd_operacao = @Operacao
                                                    and esp.mtn_cd_status IN (34,228,38)

            left join tb_veiculos v with(nolock) on per.pgp_cd_cliente = v.vei_cd_cliente
                                                    and pgto.ppr_ds_placa = v.vei_ds_placa
                                                    and v.vei_in_ativo = 1
                                                    and v.vei_in_excluido = 0

            -- OTIMIZACAO: #tmp_bfa substitui vw_fin_base_frete_adicional_motorista
            left join #tmp_bfa adicionalCidade on per.pgp_cd_cliente = adicionalCidade.bfa_cd_transportadora
                                            and pgto.ppr_base_principal = adicionalCidade.bfa_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = adicionalCidade.bfa_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(adicionalCidade.bfa_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and pgto.ppr_nm_cidade = adicionalCidade.bfa_nm_cidade
                                            and pgto.ppr_data_referencia between adicionalCidade.bfa_data_inicio_vigencia and isnull(adicionalCidade.bfa_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and adicionalCidade.Operacao = @TipoOperacao
                                            and adicionalCidade.bfa_ds_placa is null

            left join #tmp_bfa adicional on per.pgp_cd_cliente= adicional.bfa_cd_transportadora
                                            and pgto.ppr_base_principal = adicional.bfa_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and (adicional.bfa_nm_cidade is null or adicional.bfa_nm_cidade  = '')
                                            and pgto.ppr_data_referencia between adicional.bfa_data_inicio_vigencia and isnull(adicional.bfa_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and adicional.Operacao = @TipoOperacao
                                            and adicional.bfa_ds_placa is null

            -- =======================================================================
            -- #tmp_bf_normal: sem placa, sem paradas (freteKm0a100*, freteKm*, FreteFixo)
            -- =======================================================================
            -- Calcula o valor pago para primeira faixa (0a100) com cidade
            left join #tmp_bf_normal freteKm0a100Cidade on per.pgp_cd_cliente = freteKm0a100Cidade.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKm0a100Cidade.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKm0a100Cidade.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100Cidade.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and freteKm0a100Cidade.bfm_nm_cidade is not null
                                            and pgto.ppr_nm_cidade = freteKm0a100Cidade.bfm_nm_cidade
                                            and freteKm0a100Cidade.bfm_vl_inicio_faixa in (0,1)
                                            and pgto.ppr_data_referencia between freteKm0a100Cidade.bfm_data_inicio_vigencia and isnull(freteKm0a100Cidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKm0a100Cidade.Operacao = @TipoOperacao
                                            and freteKm0a100Cidade.CriterioFaixa2 is null
                                            and freteKm0a100Cidade.bfm_ds_placa is null

            left join #tmp_bf_normal freteKm0a100 on per.pgp_cd_cliente = freteKm0a100.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKm0a100.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKm0a100.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and (freteKm0a100.bfm_nm_cidade is null or freteKm0a100.bfm_nm_cidade = '')
                                            and freteKm0a100.bfm_vl_inicio_faixa in (0,1)
                                            and pgto.ppr_data_referencia between freteKm0a100.bfm_data_inicio_vigencia and isnull(freteKm0a100.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKm0a100.Operacao = @TipoOperacao
                                            and freteKm0a100.CriterioFaixa2 is null
                                            and freteKm0a100.bfm_ds_placa is null

            -- Calcula o frete pelo km rodado
            left join #tmp_bf_normal freteKmCidade on per.pgp_cd_cliente = freteKmCidade.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKmCidade.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKmCidade.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKmCidade.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and freteKmCidade.bfm_nm_cidade is not null
                                            and pgto.ppr_nm_cidade = freteKmCidade.bfm_nm_cidade
                                            and pgto.ppr_data_referencia between freteKmCidade.bfm_data_inicio_vigencia and isnull(freteKmCidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKmCidade.Operacao = @TipoOperacao
                                            and freteKmCidade.CriterioFaixa2 is null
                                            and freteKmCidade.bfm_ds_placa is null

            left join #tmp_bf_normal freteKm on per.pgp_cd_cliente = freteKm.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKm.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKm.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and (freteKm.bfm_nm_cidade is null or freteKm.bfm_nm_cidade = '')
                                            and pgto.ppr_total_km > (freteKm.bfm_vl_inicio_faixa - 1)
                                            and pgto.ppr_total_km <= freteKm.bfm_vl_fim_faixa
                                            and pgto.ppr_data_referencia between freteKm.bfm_data_inicio_vigencia and isnull(freteKm.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKm.CriterioFaixa2 is null
                                            and freteKm.bfm_ds_placa is null

            left join #tmp_bf_normal FreteFixo on per.pgp_cd_cliente = FreteFixo.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = FreteFixo.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = FreteFixo.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(FreteFixo.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and (FreteFixo.bfm_nm_cidade is null or FreteFixo.bfm_nm_cidade = '' or FreteFixo.bfm_nm_cidade = pgto.ppr_nm_cidade)
                                            and pgto.ppr_data_referencia between FreteFixo.bfm_data_inicio_vigencia and isnull(FreteFixo.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and FreteFixo.Operacao = @TipoOperacao
                                            and FreteFixo.bfm_vl_frete_fixo is not null
                                            and FreteFixo.CriterioFaixa2 is null
                                            and FreteFixo.bfm_ds_placa is null

            -- =======================================================================
            -- #tmp_bf_paradas: sem placa, com paradas (freteKm*Paradas, freteKm0a100*Paradas)
            -- =======================================================================
            --Cruzamento para segunda faixa (paradas)
            left join #tmp_bf_paradas freteKmCidadeParadas on per.pgp_cd_cliente = freteKmCidadeParadas.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKmCidadeParadas.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKmCidadeParadas.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKmCidadeParadas.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and freteKmCidadeParadas.bfm_nm_cidade is not null
                                            and pgto.ppr_nm_cidade = freteKmCidadeParadas.bfm_nm_cidade
                                            and pgto.ppr_total_km > (freteKmCidadeParadas.bfm_vl_inicio_faixa - 1)
                                            and pgto.ppr_total_km <= freteKmCidadeParadas.bfm_vl_fim_faixa
                                            and pgto.ppr_data_referencia between freteKmCidadeParadas.bfm_data_inicio_vigencia and isnull(freteKmCidadeParadas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKmCidadeParadas.Operacao = @TipoOperacao
                                            and freteKmCidadeParadas.CriterioFaixa2 = 'Paradas'
                                            and pgto.ppr_qt_paradas > (freteKmCidadeParadas.bfm_vl_inicio_faixa2 - 1)
                                            and pgto.ppr_qt_paradas <= freteKmCidadeParadas.bfm_vl_fim_faixa2
                                            and freteKmCidadeParadas.bfm_ds_placa is null

            left join #tmp_bf_paradas freteKmParadas on per.pgp_cd_cliente = freteKmParadas.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKmParadas.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKmParadas.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKmParadas.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and (freteKmParadas.bfm_nm_cidade is null or freteKmParadas.bfm_nm_cidade = '')
                                            and pgto.ppr_total_km > (freteKmParadas.bfm_vl_inicio_faixa - 1)
                                            and pgto.ppr_total_km <= freteKmParadas.bfm_vl_fim_faixa
                                            and pgto.ppr_data_referencia between freteKmParadas.bfm_data_inicio_vigencia and isnull(freteKmParadas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKmParadas.CriterioFaixa2 = 'Paradas'
                                            and pgto.ppr_qt_paradas > (freteKmParadas.bfm_vl_inicio_faixa2 - 1)
                                            and pgto.ppr_qt_paradas <= freteKmParadas.bfm_vl_fim_faixa2
                                            and freteKmParadas.bfm_ds_placa is null

            left join #tmp_bf_paradas freteKm0a100CidadeParadas on per.pgp_cd_cliente = freteKm0a100CidadeParadas.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKm0a100CidadeParadas.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKm0a100CidadeParadas.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100CidadeParadas.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and freteKm0a100CidadeParadas.bfm_nm_cidade is not null
                                            and pgto.ppr_nm_cidade = freteKm0a100CidadeParadas.bfm_nm_cidade
                                            and freteKm0a100CidadeParadas.bfm_vl_inicio_faixa in (0,1)
                                            and pgto.ppr_data_referencia between freteKm0a100CidadeParadas.bfm_data_inicio_vigencia and isnull(freteKm0a100CidadeParadas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKm0a100CidadeParadas.Operacao = @TipoOperacao
                                            and freteKm0a100CidadeParadas.CriterioFaixa2 = 'Paradas'
                                            and freteKm0a100CidadeParadas.bfm_vl_inicio_faixa2 in (0,1)
                                            and freteKm0a100CidadeParadas.bfm_ds_placa is null

            left join #tmp_bf_paradas freteKm0a100Paradas on per.pgp_cd_cliente = freteKm0a100Paradas.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = freteKm0a100Paradas.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = freteKm0a100Paradas.bfm_cd_tipo_veiculo
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(freteKm0a100Paradas.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and (freteKm0a100Paradas.bfm_nm_cidade is null or freteKm0a100Paradas.bfm_nm_cidade = '')
                                            and freteKm0a100Paradas.bfm_vl_inicio_faixa in (0,1)
                                            and pgto.ppr_data_referencia between freteKm0a100Paradas.bfm_data_inicio_vigencia and isnull(freteKm0a100Paradas.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and freteKm0a100Paradas.CriterioFaixa2 = 'Paradas'
                                            and freteKm0a100Paradas.bfm_vl_inicio_faixa2 in (0,1)
                                            and freteKm0a100Paradas.bfm_ds_placa is null

            -- =======================================================================
            -- #tmp_bf_placa: com placa, sem paradas (fretePlaca*, frete0a100Placa*)
            -- =======================================================================
            --Regra de placas
            left join #tmp_bf_placa fretePlacaCidade on per.pgp_cd_cliente = fretePlacaCidade.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = fretePlacaCidade.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = fretePlacaCidade.bfm_cd_tipo_veiculo
                                            and pgto.ppr_ds_placa = fretePlacaCidade.bfm_ds_placa
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(fretePlacaCidade.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and pgto.ppr_nm_cidade = fretePlacaCidade.bfm_nm_cidade
                                            and pgto.ppr_total_km > (fretePlacaCidade.bfm_vl_inicio_faixa - 1)
                                            and pgto.ppr_total_km <= fretePlacaCidade.bfm_vl_fim_faixa
                                            and pgto.ppr_data_referencia between fretePlacaCidade.bfm_data_inicio_vigencia and isnull(fretePlacaCidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and fretePlacaCidade.Operacao = @TipoOperacao
                                            and fretePlacaCidade.bfm_cd_codigo_cliente = @IdCliTransportadora
                                            and fretePlacaCidade.CriterioFaixa2 is null

            left join #tmp_bf_placa fretePlaca on per.pgp_cd_cliente = fretePlaca.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = fretePlaca.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = fretePlaca.bfm_cd_tipo_veiculo
                                            and pgto.ppr_ds_placa = fretePlaca.bfm_ds_placa
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(fretePlaca.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and fretePlaca.bfm_nm_cidade is null
                                            and pgto.ppr_total_km > (fretePlaca.bfm_vl_inicio_faixa - 1)
                                            and pgto.ppr_total_km <= fretePlaca.bfm_vl_fim_faixa
                                            and pgto.ppr_data_referencia between fretePlaca.bfm_data_inicio_vigencia and isnull(fretePlaca.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and fretePlaca.Operacao = @TipoOperacao
                                            and fretePlaca.bfm_cd_codigo_cliente = @IdCliTransportadora
                                            and fretePlaca.CriterioFaixa2 is null

            left join #tmp_bf_placa frete0a100PlacaCidade on per.pgp_cd_cliente = frete0a100PlacaCidade.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = frete0a100PlacaCidade.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = frete0a100PlacaCidade.bfm_cd_tipo_veiculo
                                            and pgto.ppr_ds_placa = frete0a100PlacaCidade.bfm_ds_placa
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(frete0a100PlacaCidade.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and pgto.ppr_nm_cidade = frete0a100PlacaCidade.bfm_nm_cidade
                                            and frete0a100PlacaCidade.bfm_vl_inicio_faixa in (0,1)
                                            and pgto.ppr_data_referencia between frete0a100PlacaCidade.bfm_data_inicio_vigencia and isnull(frete0a100PlacaCidade.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and frete0a100PlacaCidade.Operacao = @TipoOperacao
                                            and frete0a100PlacaCidade.bfm_cd_codigo_cliente = @IdCliTransportadora
                                            and frete0a100PlacaCidade.CriterioFaixa2 is null

            left join #tmp_bf_placa frete0a100Placa on per.pgp_cd_cliente = frete0a100Placa.bfm_cd_transportadora
                                            and pgto.ppr_base_principal = frete0a100Placa.bfm_cd_service_center
                                            and veic.tvl_cd_tipo_veiculo = frete0a100Placa.bfm_cd_tipo_veiculo
                                            and pgto.ppr_ds_placa = frete0a100Placa.bfm_ds_placa
                                            and (
                                                    (@UtilizaContrato = 1 and isnull(esp.mtn_cd_tipo_contrato,-1) = isnull(frete0a100Placa.bmf_cd_tipo_contrato,-1))
                                                    or
                                                    @UtilizaContrato = 0
                                            )
                                            and frete0a100Placa.bfm_nm_cidade is null
                                            and frete0a100Placa.bfm_vl_inicio_faixa in (0,1)
                                            and pgto.ppr_data_referencia between frete0a100Placa.bfm_data_inicio_vigencia and isnull(frete0a100Placa.bfm_data_fim_vigencia,convert(date,dateadd(year,1,getdate())))
                                            and frete0a100Placa.Operacao = @TipoOperacao
                                            and frete0a100Placa.bfm_cd_codigo_cliente = @IdCliTransportadora
                                            and fretePlaca.CriterioFaixa2 is null
        OPTION (RECOMPILE)





		update
			pgto
		set
			pgto.ppr_vl_base = case when base.ppr_in_zerar_rota = 1 then 0
							   else case when base.ZerarAmbulanciaNaoAprovada = 1 and base.ppr_in_ambulancia = 1 and base.ppr_in_ambulancia_aprovada = 0 then 0
							   else case when base.ValorFixoPlacaRota is not null then ValorFixoPlacaRota
							   else case when base.PagarPorPacote = 1 then isnull(base.SaidaKm0a100,0) * isnull(base.ppr_qt_pacotes_entregues,0)
							   else case when base.PagarPrimeiraFaixaAmbulancia = 1 and base.ppr_in_ambulancia = 1 and base.ValorFixoSD is null then isnull(base.SaidaKm0a100,0) 
							   else case when base.ValorFixoSD is not null then base.ValorFixoSD
							   else isnull(base.SaidaKm,0) end end end end end end

			,pgto.ppr_cd_desconto_sd = base.ppr_cd_desconto_sd
			
			,pgto.ppr_cd_faixa_km = case when base.PagarPorPacote = 1 or (base.PagarPrimeiraFaixaAmbulancia = 1 and base.ppr_in_ambulancia = 1) then FaixaKm0a100
									else FaixaKm end
		from
			tb_pgto_periodo_rota pgto
			join #pagamento_base base on pgto.ppr_cd_pagamento_rota = base.ppr_cd_pagamento_rota
			join tb_pag_espelhos esp with(nolock) on base.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
													and esp.mtn_cd_cliente_transportadora = base.ppr_id_cliente_transportadora
													and esp.mtn_cd_operacao = base.ppr_cd_operacao
													--tirar após criar tabela de status de espelho
													and esp.mtn_cd_status IN (34,228,38)
			--mudar para join
			--left join tb_status_espelho sep with(nolock) on esp.mtn_cd_status = sep.sep_cd_status and sep.sep_in_fechado = 0 
		where
			pgto.ppr_cd_periodo = @CodPeriodoPagamento
			and pgto.ppr_cd_rota is not null
			and pgto.ppr_in_excluido = 0
			


		/*regra de pagamento de ambulancia para Hawk 

		SE A ROTA FOR AMBULÂNCIA E ELE ENTREGAR MENOS DE 30 PACOTES, PASSA A RECEBER POR PACOTE
		R$3,00 POR PACOTE PARA PASSEIO, VAN OU UTILITÁRIO
		R$10,00 POR PACOTE PARA VUC
		
		Veiculos que não estão citados estão com o vl_pacote_ambulancia_regra zerado e mantem o valor base
		*/

		update	tb_pgto_periodo_rota 
		set		ppr_vl_base =  case when base.ppr_in_zerar_rota = 1 then 0 else pgto.ppr_qt_pacotes_entregues * bfa_vl_pacote_ambulancia end

		from
			tb_pgto_periodo_rota pgto
			join #pagamento_base base on pgto.ppr_cd_pagamento_rota = base.ppr_cd_pagamento_rota
			join tb_pag_espelhos esp with(nolock) on base.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
													and esp.mtn_cd_cliente_transportadora = base.ppr_id_cliente_transportadora
													and esp.mtn_cd_operacao = base.ppr_cd_operacao
													--tirar após criar tabela de status de espelho
													and esp.mtn_cd_status IN (34,228,38)

		where
			pgto.ppr_cd_periodo = @CodPeriodoPagamento
			and pgto.ppr_cd_rota is not null
			and pgto.ppr_in_excluido = 0

			-- Validacoes de regra da ambulancia
			and pgto.ppr_in_ambulancia = 1
			and base.bfa_qtd_pacote_ambulancia is not null
			and base.bfa_vl_pacote_ambulancia is not null
			and pgto.ppr_qt_pacotes_entregues < base.bfa_qtd_pacote_ambulancia


	end

end

GO
