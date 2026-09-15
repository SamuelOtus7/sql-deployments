-- ============================================================
-- BASELINE: dbo.UspFinGeraPagamentoAdministrativo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraPagamentoAdministrativo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinGeraPagamentoAdministrativo]    (
    @CodPeriodoPagamento int,
	@avulso int = null -- codigo espelho,
)
as
begin

	--declare @CodPeriodoPagamento int = 2531
	--declare @avulso int = null -- codigo espelho


	set nocount on

	set @avulso = case when @avulso = 0 then null else @avulso end


	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @CalcularEspelho bit = isnull(
											(select 
												isnull(pep_in_calcular_espelho,1) 
											from 
												[tb_periodos_espelhos_pagamento] p with(nolock) 
												join tb_lista l on p.pep_cd_cliente_transportadora = l.lst_cd_lista
											where 
												pep_cd_periodo_pagamento = @CodPeriodoPagamento
												and l.lst_ds_valor = 'Administrativo'
											)
										,1)

	--Só faz alteração caso o período ainda esteja em aberto e tiver marcado a opção de calcular espelho
	if @StatusPeriodo = 1 and @CalcularEspelho = 1
	begin
		

		declare @CodigoCliente int
		declare @DataInicial date
		declare @DataFinal date
		declare @TipoContrato int
		declare @Operacao int
		declare @DataLimite date
		declare @IdCliTransportadora int
		declare @DataPrevistaPagamento date
		
		select
			@CodigoCliente = pgp_cd_cliente
			,@DataInicial = pgp_dt_inicio
			,@DataFinal = pgp_dt_fim
			,@TipoContrato = pgp_cd_tipo_contratos
			,@Operacao = pgp_tipo_operacao
			,@DataLimite = pgp_dt_limite_reanalise
			,@IdCliTransportadora = pgp_cd_cliente_transportadora
			,@DataPrevistaPagamento = pgp_dt_prevista_pagamento
		from
			tb_pgto_periodo
		where
			pgp_cd_periodo = @CodPeriodoPagamento


		declare @UsuarioCriacao int = 7
		declare @Base varchar(60) = 'Administrativo'
		declare @IdBase int = (select bss_cd_base from tb_bases where bss_cod_cliente = @CodigoCliente and bss_ds_marketplace = @Base and bss_in_excluido = 0)

		declare @ParamPeriodicidadeCalculo varchar(150) = isnull(
																	(select 
																		lst_ds_label
																	from 
																		tb_lista l with(nolock)
																		join tb_parametros p with(nolock) on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
																	where 
																		l.lst_nm_lista = 'Periodicidade Cálculo Administrativo'
																		and prm_nm_parametro = 'Periodicidade Cálculo Administrativo'
																		and prm_cod_cliente = @CodigoCliente
																		and prm_in_ativo = 1
																		and prm_in_excluido = 0
																	)
																,'Mensal')

		declare @DivisaoSalario decimal(3,2) = case @ParamPeriodicidadeCalculo
													when 'Semanal' then 4.00
													when 'Quinzenal' then 2.00
													when 'Mensal' then 1.00
												end

		declare @TextoDivisaoSalario varchar(30) = case @ParamPeriodicidadeCalculo
														when 'Semanal' then '1/4 do Salário'
														when 'Quinzenal' then 'Metade do Salário'
														when 'Mensal' then 'Salário'
													end


		drop table if exists #salarios
		select
			tsp_cd_salario CodigoSalario
			,tsp_cd_usuario CodigoUsuario
			,u.usr_nm_usuario NomeUsuario
			,case when tsp_dt_inicio < @DataInicial then @DataInicial else tsp_dt_inicio end InicioSalario
			,isnull(tsp_dt_fim,@DataFinal) FimSalario
			,usr_cd_tipo_contrato CodigoContrato
			,tsp_vl_salario / @DivisaoSalario Salario --paga metade do salário já que o pagamento é por quinzena
			,tsp_vl_salario SalarioBase
			,tsp_nm_cargo Cargo
			into #salarios
		from
			tb_fin_salarios_profissionais s with(nolock)
			join tb_usuario u with(nolock) on s.tsp_cd_usuario = usr_cd_usuario
											and u.usr_in_ativo = 1
			join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
			join tb_tipo_contrato c with(nolock) on m.mot_ctn_cd_tipo_contrato = c.ttc_cd_tipo_contrato	--u.usr_cd_tipo_contrato = c.ttc_cd_tipo_contrato
												and c.ttc_in_ativo = 1
												and c.ttc_in_excluido = 0
												and c.ttc_in_administrativo = 1
		where
			s.tsp_in_ativo = 1
			and s.tsp_in_excluido = 0
			and s.tsp_cd_client = @CodigoCliente
			and tsp_dt_inicio <= @DataFinal
			and (tsp_dt_fim IS NULL or tsp_dt_fim >= @DataInicial)
			and (c.ttc_cd_tipo_contrato = @TipoContrato or @TipoContrato = '-1')
			

		drop table if exists #contabiliza_dias_trabalhados
		select
			*
			,datediff(day,InicioSalario,FimSalario)+1 DiasTrabalhados
			,datediff(day,@DataInicial,@DataFinal)+1 DiasPeriodo
			into #contabiliza_dias_trabalhados
		from
			#salarios


		drop table if exists #calcula_salario
		select
			*
			,DiasTrabalhados / cast(DiasPeriodo as decimal(10,4)) PercentualPago
			,DiasTrabalhados / cast(DiasPeriodo as decimal(10,4)) * Salario SalarioProporcional
			into #calcula_salario
		from
			#contabiliza_dias_trabalhados

		
		drop table if exists #pagamento_rotas
		select
			@CodPeriodoPagamento ppr_cd_periodo
			,cast(CodigoSalario as varchar(50)) ppr_cd_rota
			,CodigoUsuario ppr_cd_motorista 
			,NomeUsuario ppr_nome_motorista 
			,@DataInicial ppr_data_referencia 
			,1362 ppr_cd_tipo_pgto
			,SalarioProporcional ppr_vl_base
			,SalarioProporcional ppr_vl_total
			,Cargo 
			,@Base ppr_base_principal
			,'ADM' ppr_cd_tipo
			,case when PercentualPago = 1 then 
				@TextoDivisaoSalario + ': ' + FORMAT(SalarioBase,'C','pt-Br')
			else
				'Pagamento: ' + format(PercentualPago,'P','pt-Br') + ' - ' + @TextoDivisaoSalario+ ': ' + FORMAT(SalarioBase,'C','pt-Br') 
			end ppr_lcto_observacao
			,cast(null as int) ppr_cd_motorista_nfs
			,cast(null as int) ppr_cd_pgto_espelho
			into #pagamento_rotas
		from
			#calcula_salario
			

			
		--Cria tabela para espelho
		drop table if exists #espelho
		select
			a.ppr_cd_motorista mtn_cd_motorista
			,a.ppr_nome_motorista as mtn_nome_motorista
			,a.ppr_cd_periodo as mtn_cd_pgto_periodo
			,228 mtn_cd_status
			,SUM(ppr_vl_total) as mtn_vl_nfs
			,null mtn_ds_link_nfs
			,@DataLimite as mtn_dt_prazo_contestacao
			,getdate() mtn_dh_criacao
			,7174 as mtn_cd_usr_criacao
			,getdate() mtn_dh_modificacao
			,7174 as mtn_cd_usr_modificacao
			,0 as mtn_in_excluido
			,@CodigoCliente as mtn_cod_cliente
			,count(*) as mtn_qt_rotas
			,94 as mtn_cd_tipo_espelho
			,@IdCliTransportadora as mtn_cd_cliente_transportadora
			,@IdBase mtn_cd_base
			,ppr_base_principal mtn_base_principal
			,@operacao as mtn_cd_operacao
			,null mtn_vl_imposto
			,null mtn_vl_liquido
			into #espelho
		from 
			#pagamento_rotas as a
		where 
			a.ppr_cd_motorista is not null
		group by
			a.ppr_cd_motorista
			,a.ppr_nome_motorista
			,a.ppr_cd_periodo
			,ppr_base_principal

		

		--Merge espelho
		MERGE tb_pag_espelhos AS target
		USING (
			select
				e.mtn_cd_motorista
				,e.mtn_nome_motorista
				,e.mtn_cd_pgto_periodo
				,e.mtn_cd_status
				,e.mtn_vl_nfs
				,e.mtn_ds_link_nfs
				,e.mtn_dt_prazo_contestacao
				,e.mtn_dh_criacao
				,e.mtn_cd_usr_criacao
				,e.mtn_dh_modificacao
				,e.mtn_cd_usr_modificacao
				,e.mtn_in_excluido
				,e.mtn_cod_cliente
				,e.mtn_qt_rotas
				,e.mtn_cd_tipo_espelho
				,e.mtn_cd_cliente_transportadora
				,e.mtn_cd_base
				,e.mtn_base_principal
				,e.mtn_cd_operacao
				,e.mtn_vl_imposto
				,e.mtn_vl_liquido
				,m.Banco mtn_ds_Banco
				,m.NomeTitular mtn_ds_NomeTitular
				,m.CpfTitular mtn_ds_CpfTitular
				,m.CnpjTitular mtn_ds_CnpjTitular
				,m.Agencia mtn_ds_Agencia
				,m.Conta mtn_ds_Conta
				,m.TipoConta mtn_ds_TipoConta
				,m.TipoChavePix mtn_ds_TipoChavePix
				,m.ChavePix mtn_ds_ChavePix
				,m.CnpjEmpresa mtn_ds_CnpjEmpresa
				,m.RazaoSocial mtn_ds_RazaoSocial
				,m.NomeFantasia mtn_ds_NomeFantasia
				,@DataPrevistaPagamento mtn_dt_prevista_pagamento
			from
				#espelho e
				left join (
							SELECT	
								*,
								ROW_NUMBER() OVER(PARTITION BY CodigoUsuario ORDER BY CodigoUsuario ASC)	AS ID
							FROM 
								vw_dados_motoristas
						) as m on m.CodigoUsuario = e.mtn_cd_motorista
								and m.id = 1
		) AS source
		ON (
			target.mtn_cd_motorista = source.mtn_cd_motorista
			AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
			AND target.mtn_cd_operacao = source.mtn_cd_operacao
			AND target.mtn_in_excluido = 0
		)
		WHEN MATCHED AND target.mtn_cd_status in (34,228,38) THEN --alterar para tabela de status quando subir
			UPDATE SET
				mtn_vl_nfs = source.mtn_vl_nfs
				,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
				,mtn_dh_modificacao = source.mtn_dh_modificacao
				,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
				,mtn_in_excluido = source.mtn_in_excluido
				,mtn_cod_cliente = source.mtn_cod_cliente
				,mtn_qt_rotas = source.mtn_qt_rotas
				,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
				,mtn_base_principal = source.mtn_base_principal
				,mtn_nome_motorista =  source.mtn_nome_motorista
				,mtn_cd_base = source.mtn_cd_base
				,mtn_cd_motorista = source.mtn_cd_motorista
				,mtn_vl_imposto = source.mtn_vl_imposto
				,mtn_vl_liquido = source.mtn_vl_liquido
				,mtn_ds_Banco = source.mtn_ds_Banco
				,mtn_ds_NomeTitular = source.mtn_ds_NomeTitular
				,mtn_ds_CpfTitular = source.mtn_ds_CpfTitular
				,mtn_ds_CnpjTitular = source.mtn_ds_CnpjTitular
				,mtn_ds_Agencia = source.mtn_ds_Agencia
				,mtn_ds_Conta = source.mtn_ds_Conta
				,mtn_ds_TipoConta = source.mtn_ds_TipoConta
				,mtn_ds_TipoChavePix = source.mtn_ds_TipoChavePix
				,mtn_ds_ChavePix = source.mtn_ds_ChavePix
				,mtn_ds_CnpjEmpresa = source.mtn_ds_CnpjEmpresa
				,mtn_ds_RazaoSocial = source.mtn_ds_RazaoSocial
				,mtn_ds_NomeFantasia = source.mtn_ds_NomeFantasia
				--ajuste para atualizar somente quando a data não for atualizada manualmente
				,mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end

		WHEN NOT MATCHED THEN
			INSERT (
				mtn_cd_motorista
				,mtn_cd_pgto_periodo
				,mtn_cd_status
				,mtn_vl_nfs
				,mtn_ds_link_nfs
				,mtn_dt_prazo_contestacao
				,mtn_dh_criacao
				,mtn_cd_usr_criacao
				,mtn_dh_modificacao
				,mtn_cd_usr_modificacao
				,mtn_in_excluido
				,mtn_cod_cliente
				,mtn_qt_rotas
				,mtn_cd_tipo_espelho
				,mtn_cd_cliente_transportadora
				,mtn_base_principal
				,mtn_nome_motorista
				,mtn_cd_base
				,mtn_vl_imposto
				,mtn_vl_liquido
				,mtn_cd_operacao
				,mtn_ds_Banco
				,mtn_ds_NomeTitular
				,mtn_ds_CpfTitular
				,mtn_ds_CnpjTitular
				,mtn_ds_Agencia
				,mtn_ds_Conta
				,mtn_ds_TipoConta
				,mtn_ds_TipoChavePix
				,mtn_ds_ChavePix
				,mtn_ds_CnpjEmpresa
				,mtn_ds_RazaoSocial
				,mtn_ds_NomeFantasia
				,mtn_dt_prevista_pagamento
			)
			VALUES (
				source.mtn_cd_motorista
				,source.mtn_cd_pgto_periodo
				,source.mtn_cd_status
				,source.mtn_vl_nfs
				,source.mtn_ds_link_nfs
				,source.mtn_dt_prazo_contestacao
				,source.mtn_dh_criacao
				,source.mtn_cd_usr_criacao
				,source.mtn_dh_modificacao
				,source.mtn_cd_usr_modificacao
				,source.mtn_in_excluido
				,source.mtn_cod_cliente
				,source.mtn_qt_rotas
				,source.mtn_cd_tipo_espelho
				,source.mtn_cd_cliente_transportadora
				,source.mtn_base_principal
				,source.mtn_nome_motorista
				,source.mtn_cd_base
				,source.mtn_vl_imposto
				,source.mtn_vl_liquido
				,source.mtn_cd_operacao
				,source.mtn_ds_Banco
				,source.mtn_ds_NomeTitular
				,source.mtn_ds_CpfTitular
				,source.mtn_ds_CnpjTitular
				,source.mtn_ds_Agencia
				,source.mtn_ds_Conta
				,source.mtn_ds_TipoConta
				,source.mtn_ds_TipoChavePix
				,source.mtn_ds_ChavePix
				,source.mtn_ds_CnpjEmpresa
				,source.mtn_ds_RazaoSocial
				,source.mtn_ds_NomeFantasia
				,source.mtn_dt_prevista_pagamento
			);

		--Atualiza código do espelho das rotas
		update
			p
		set
			ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			,ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs
		from
			#pagamento_rotas p
			join tb_pag_espelhos e on p.ppr_cd_periodo = e.mtn_cd_pgto_periodo
								and p.ppr_cd_motorista = e.mtn_cd_motorista
								and e.mtn_in_excluido = 0
								and e.mtn_cd_operacao = @Operacao
								and e.mtn_cd_status in (34,228,38)

		--Remove o que não encontrou espelho ativo
		delete from #pagamento_rotas where ppr_cd_motorista_nfs is null


		--deleta pagamentos que foram criados e não existem mais (em caso de exclusão de salário que foi cadastrado por exemplo ou que foi alterado data)
		--apenas se o espelho tiver em aberto ainda
		update
			p
		set
			ppr_in_excluido = 1
		from
			tb_pgto_periodo_rota p
			join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_in_excluido = 0
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_cd_status in (34,228,38)
			left join #pagamento_rotas p2 on p.ppr_cd_periodo = p2.ppr_cd_periodo
										and p.ppr_cd_rota = p2.ppr_cd_rota
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_cd_rota is not null
			and p.ppr_cd_tipo_pgto = 1362 
			and p2.ppr_cd_rota is null



		--Atualiza pagamento
		MERGE INTO [tb_pgto_periodo_rota] AS target
		USING #pagamento_rotas AS source
		ON 
			target.ppr_cd_periodo = source.ppr_cd_periodo
			AND target.ppr_cd_rota = source.ppr_cd_rota
		WHEN MATCHED THEN
			UPDATE SET
				target.ppr_vl_base = source.ppr_vl_base,
				target.ppr_vl_total = source.ppr_vl_total,
				target.ppr_dh_modificacao = getdate(),
				target.ppr_cd_usr_modificacao = @UsuarioCriacao,
				target.ppr_cd_motorista = source.ppr_cd_motorista,
				target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
				target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
				target.ppr_data_referencia = source.ppr_data_referencia,
				target.ppr_base_principal = source.ppr_base_principal,
				target.ppr_nome_motorista = source.ppr_nome_motorista,
				target.ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto,
				target.ppr_cd_tipo = source.ppr_cd_tipo,
				target.ppr_lcto_observacao = source.ppr_lcto_observacao
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				ppr_cd_periodo,
				ppr_cd_rota,
				ppr_vl_base,
				ppr_vl_total,
				ppr_dh_criacao,
				ppr_cd_usr_criacao,
				ppr_dh_modificacao,
				ppr_cd_usr_modificacao,
				ppr_in_ativo,
				ppr_in_excluido,
				ppr_cd_motorista,
				ppr_cd_motorista_nfs,
				ppr_cd_pgto_espelho,
				ppr_data_referencia,
				ppr_base_principal,
				ppr_nome_motorista,
				ppr_cd_tipo,
				ppr_cd_tipo_pgto,
				ppr_lcto_observacao
			)
			VALUES (
				source.ppr_cd_periodo,
				source.ppr_cd_rota,
				source.ppr_vl_base,
				source.ppr_vl_total,
				getdate(),
				@UsuarioCriacao,
				getdate(),
				@UsuarioCriacao,
				1,
				0,
				source.ppr_cd_motorista,
				source.ppr_cd_motorista_nfs,
				source.ppr_cd_pgto_espelho,
				source.ppr_data_referencia,
				source.ppr_base_principal,
				source.ppr_nome_motorista,
				source.ppr_cd_tipo,
				source.ppr_cd_tipo_pgto,
				source.ppr_lcto_observacao
			);
	end

end
GO
