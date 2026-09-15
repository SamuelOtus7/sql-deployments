-- ============================================================
-- BASELINE: dbo.UspFinLancamentoManualMeliLM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinLancamentoManualMeliLM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspFinLancamentoManualMeliLM] (
	@CodPeriodoPagamento int
	,@IdRota int = null
	,@CodEspelho int = null
	,@CodUsuario int = null
)
AS
BEGIN

	SET NOCOUNT ON;

	--declare @CodPeriodoPagamento int = 2616
	--declare @IdRota int = null
	--declare @CodEspelho int = null -- codigo espelho,
	--declare @CodUsuario int = null
	

	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @DataLimiteReanalise date = (select pgp_dt_limite_reanalise from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1 and cast(getdate() as date) <= isnull(@DataLimiteReanalise,cast(getdate() as date))
	begin

		
		------------------------------------------------------------
		-- INFORMAÇÕES SOBRE O PERÍODO QUE ESTÁ SENDO PROCESSADO
		------------------------------------------------------------
		declare @CodigoCliente int
		declare @DataInicial date
		declare @DataFinal date
		declare @Operacao int
		declare @IdCliTransportadora int
		declare @DataPrevistaPagamento date
		
		select
			@CodigoCliente = pgp_cd_cliente
			,@DataInicial = pgp_dt_inicio
			,@DataFinal = pgp_dt_fim
			,@Operacao = pgp_tipo_operacao
			,@IdCliTransportadora = pgp_cd_cliente_transportadora
			,@DataPrevistaPagamento = pgp_dt_prevista_pagamento
		from
			tb_pgto_periodo with(nolock)
		where
			pgp_cd_periodo = @CodPeriodoPagamento

		--select @CodigoCliente, @DataInicial, @DataFinal, @TipoContrato, @Operacao, @IdCliTransportadora
		
		set @CodUsuario = case when @CodUsuario is null then 7 else @CodUsuario end
		
		declare @IdTransportadora int = (select cli_id_logistics from tb_clientes with(nolock) where cli_cd_codigo_cliente = @CodigoCliente)


		------------------------------------------------------------
		-- PARAMETRIZAÇÃO FINANCEIRO DO CLIENTE
		------------------------------------------------------------
		declare @ParamDivisaoEspelho varchar(50) = lower(ltrim(rtrim(isnull(
															(select 
																prm_ds_valor
															from 
																tb_parametros with(nolock)
															where 
																prm_nm_parametro = 'Divisão  de espelho'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @CodigoCliente
															)
														,'false'))))

		
		declare @ParamDescontoNotVisited int = isnull(
														(select  
															prm_ds_valor
														from   
															tb_parametros with(nolock)
														where   
															prm_nm_parametro = 'Desconto Not Visited'
															and prm_in_ativo = 1
															and prm_in_excluido = 0
															and prm_cod_cliente = @CodigoCliente
														 )
													,0)


		declare @ParamCriarEspelho int = isnull(
												(select 
													prm_ds_valor 
												from 
													tb_parametros with(nolock)
												where 
													prm_nm_parametro = 'Geração automática de espelho'
													and prm_in_ativo = 1
													and prm_in_excluido = 0
													and prm_cod_cliente = @CodigoCliente
												)
											,0)
			




		------------------------------------------------------------
		-- CASO TENHA PASSADO APENAS UM ESPELHO PARA PROCESSAMENTO
		------------------------------------------------------------
		declare @Motorista varchar(100)
		declare @CodUsuarioMotorista int
		if @CodEspelho is not null
		begin
			select
				@Motorista = mtn_nome_motorista
				,@CodUsuarioMotorista = mtn_cd_motorista
			from
				tb_pag_espelhos with(nolock)
			where
				mtn_cd_motorista_nfs = @codEspelho
		end

		------------------------------------------------------------
		-- LANÇAMENTOS MANUAIS DO PERÍODO
		------------------------------------------------------------
		--Retorna todos os lançamentos do período
		drop table if exists #lancamentos
		select
			*
			into #lancamentos
		from
			(
				select  
					l.tlm_cd_lancamento_manual  
					,trim(cast(l.tlm_cd_rota as varchar(50))) tlm_cd_rota  
					,l.tlm_cd_motorista tlm_nome_motorista
					,l.tlm_cd_mot usr_cd_usuario 
					,cast(l.tlm_dh_referencia as date) tlm_dh_referencia  
					,tlm_vl_lancamento
					,l.plm_nm_tipo  
					,l.tlm_tipo_valor_apoio
					,l.tlm_ds_valor_referencia
					,l.tlm_cd_service_center  
					,l.tlm_ds_observacao
					,case when l.plm_nm_tipo = 'Apoio' then 'Motorista Solicitou Apoio' end tlm_fg_apoio
				from
					vw_lancamentos_manuais_aprovados l  
				where   
					l.plm_in_calculo_desconto = 0  
					and l.tlm_dh_referencia >= @DataInicial
					and l.tlm_dh_referencia < dateadd(day,1,@DataFinal)
					and l.tlm_cd_cliente = @CodigoCliente  
					and l.tlm_cd_operacao = @Operacao  
					and l.tlm_cd_cliente_transportadora = @IdCliTransportadora
					and (l.tlm_cd_rota = cast(@IdRota as varchar(50)) or @IdRota is null)
					and (
							(
								l.tlm_cd_motorista = @Motorista 
								or l.tlm_cd_mot = @CodUsuarioMotorista
								or l.tlm_cd_rota in (select ppr_cd_rota from tb_pgto_periodo_rota where ppr_cd_motorista_nfs = @CodEspelho and ppr_in_excluido = 0 and ppr_cd_rota <> '')
							)
							or
							@CodEspelho is null
						 )

   
				union all  
				
				select  
					l.tlm_cd_lancamento_manual  
					,trim(cast(l.tlm_cd_rota as varchar(50))) tlm_cd_rota  
					,l.tlm_ds_motorista_apoio tlm_nome_motorista
					,l.tlm_cd_mot_apoio usr_cd_usuario 
					,cast(l.tlm_dh_referencia as date) tlm_dh_referencia  
					,isnull(tlm_vl_valor_apoio,0) tlm_vl_lancamento    
					,l.plm_nm_tipo  
					,l.tlm_tipo_valor_apoio
					,l.tlm_ds_valor_referencia
					,l.tlm_cd_service_center 
					,l.tlm_ds_observacao  
					,case when l.plm_nm_tipo = 'Apoio' then 'Motorista Apoio' end tlm_fg_apoio
				from
					vw_lancamentos_manuais_aprovados l  
				where   
					l.plm_in_calculo_desconto = 0  
					and l.tlm_dh_referencia >= @DataInicial
					and l.tlm_dh_referencia < dateadd(day,1,@DataFinal)
					and l.tlm_cd_cliente = @CodigoCliente  
					and l.tlm_cd_operacao = @Operacao  
					and l.tlm_cd_cliente_transportadora = @IdCliTransportadora
					and l.plm_nm_tipo = 'Apoio'  
					and (l.tlm_cd_rota = cast(@IdRota as varchar(50)) or @IdRota is null)
					and (
							(
								l.tlm_ds_motorista_apoio = @Motorista 
								or l.tlm_cd_mot_apoio = @CodUsuarioMotorista
								or l.tlm_cd_rota in (select ppr_cd_rota from tb_pgto_periodo_rota where ppr_cd_motorista_nfs = @CodEspelho and ppr_in_excluido = 0 and ppr_cd_rota <> '')
							)
							or
							@CodEspelho is null
						 )

			) t

		
		------------------------------------------------------------
		-- NORMALIZA CAMPOS
		------------------------------------------------------------
		update
			#lancamentos
		set
			tlm_cd_rota = null
		where
			tlm_cd_rota = ''
			or tlm_cd_rota = '-'
			or tlm_cd_rota = 'null'
			or try_cast(tlm_cd_rota as int) is null

		update
			#lancamentos
		set
			tlm_ds_observacao = case when isnull(rtrim(ltrim(tlm_ds_observacao)),'') = '' then plm_nm_tipo else tlm_ds_observacao end 



		------------------------------------------------------------
		-- ATUALIZA VALOR DOS LANÇAMENTOS APOIO EM PERCENTUAL
		------------------------------------------------------------
		update
			l
		set
			l.tlm_vl_lancamento =  case when abs(l.tlm_vl_lancamento) > 100 then 1.00 else abs(l.tlm_vl_lancamento) / 100.00 end 
									* 
									case when l.tlm_ds_valor_referencia = 'Total' then p.ppr_vl_total - isnull(p.ppr_vl_lancamentos,0) else p.ppr_vl_base end
									* 
									case when l.tlm_fg_apoio = 'Motorista Solicitou Apoio' then -1 else 1 end	
		from 
			#lancamentos l
			join tb_pgto_periodo_rota p on l.tlm_cd_rota = p.ppr_cd_rota
										and p.ppr_cd_tipo_pgto = 1362
										and p.ppr_in_excluido = 0
										and p.ppr_cd_periodo = @CodPeriodoPagamento
			join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
													and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
													and e.mtn_cd_operacao = @Operacao
		where 
			plm_nm_tipo = 'Apoio' 
			and tlm_tipo_valor_apoio = 'Percentual' 
			and tlm_cd_rota is not null



		------------------------------------------------------------
		-- ATUALIZA VALOR DOS LANÇAMENTOS PARA PF - ENDEREÇO NÃO VISITADO
		------------------------------------------------------------
		if @ParamDescontoNotVisited > 0
		begin
			update
				l
			set
				tlm_vl_lancamento = case   
										when @ParamDescontoNotVisited = 0 then tlm_vl_lancamento --valor que vei ona prefatura
										when @ParamDescontoNotVisited = 2 then isnull(ppr_vl_base,0) * -1 --desconto_vl_base
										when @ParamDescontoNotVisited = 1 then (isnull(ppr_vl_base,0) + isnull(ppr_vl_dom_fer,0) + isnull(ppr_vl_paradas,0) + isnull(ppr_vl_pontos,0) + ISNULL(ppr_vl_bonus_ds, 0) 
				                                    + ISNULL(ppr_vl_adicional_KM, 0) + isnull(ppr_vl_bonus,0) + isnull(ppr_vl_ajudante,0) + isnull(ppr_vl_risco,0)
				                                    + isnull(ppr_vl_pedagio,0) + isnull(ppr_vl_aluguel,0) + isnull(ppr_vl_recarga,0) + isnull(ppr_vl_pacotes,0)) * -1 --desconto_vl_total
									end 
			from
				#lancamentos l
				join tb_pgto_periodo_rota p with(nolock) on l.tlm_cd_rota = p.ppr_cd_rota
														and p.ppr_in_excluido = 0
				join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
													and e.mtn_cod_cliente = @CodigoCliente
													and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
													and e.mtn_cd_operacao = @Operacao
													and e.mtn_in_excluido = 0
				join tb_pgto_periodo per with(nolock) on e.mtn_cd_pgto_periodo = per.pgp_cd_periodo
			where
				per.pgp_in_excluido = 0
				and l.plm_nm_tipo = 'PF - Endereço não visitado'  
				and per.pgp_cd_periodo = @CodPeriodoPagamento
		end



		------------------------------------------------------------
		-- SEPARA LANÇAMENTOS MANUAIS ENTRE ROTAS DO PERÍODO E OUTROS LANÇAMENTOS
		------------------------------------------------------------

		drop table if exists #lancamentos_rotas_periodo
		select
			l.*
			into #lancamentos_rotas_periodo
		from
			#lancamentos l
		where
			(
				plm_nm_tipo <> 'Apoio'
				or
				(plm_nm_tipo = 'Apoio' and tlm_fg_apoio = 'Motorista Solicitou Apoio')
			)
			and exists (select
							1
						from
							tb_pgto_periodo_rota p with(nolock)
							join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
														and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
														and e.mtn_cd_operacao = @Operacao
						where
							p.ppr_cd_periodo = @CodPeriodoPagamento
							and p.ppr_cd_tipo_pgto = 1362
							and p.ppr_in_excluido = 0
							and p.ppr_cd_rota = l.tlm_cd_rota
						)

	
		drop table if exists #lancamentos_sem_rotas_periodo
		select
			l.*
			into #lancamentos_sem_rotas_periodo
		from
			#lancamentos l
			left join #lancamentos_rotas_periodo l2 on l.tlm_cd_lancamento_manual = l2.tlm_cd_lancamento_manual
		where
			(l.plm_nm_tipo = 'Apoio' and l.tlm_fg_apoio = 'Motorista Apoio')
			or l2.tlm_cd_lancamento_manual is null


		------------------------------------------------------------
		-- ATUALIZA LANÇAMENTOS MANUAIS DO PERÍODO EM QUE EXISTEM ROTAS
		------------------------------------------------------------
		update
			p
		set
			p.ppr_vl_lancamentos = isnull(l.tlm_vl_lancamento,0)
			,p.ppr_vl_end_nvisitado = l.tlm_vl_end_nvisitado
			,p.ppr_vl_pct_perdido = l.tlm_vl_pct_perdido
			,p.ppr_vl_pnr = l.tlm_vl_pnr
			,p.ppr_lcto_observacao = l.tlm_descricao_lancamento
		from
			tb_pgto_periodo_rota p with(nolock)
			join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
									and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
									and e.mtn_cd_operacao = @Operacao
									and e.mtn_in_excluido = 0
									and e.mtn_cd_status IN (34, 228, 38, 1298)

			left join  (
							select
								tlm_cd_rota
								,sum(tlm_vl_lancamento) tlm_vl_lancamento
								,sum(case when l.plm_nm_tipo = 'PF - Endereço não visitado' then case when l.tlm_vl_lancamento > 0 then l.tlm_vl_lancamento * -1 else l.tlm_vl_lancamento end end) tlm_vl_end_nvisitado
								,sum(case when l.plm_nm_tipo = 'PF - Pacote Perdido' then case when l.tlm_vl_lancamento > 0 then l.tlm_vl_lancamento * -1 else l.tlm_vl_lancamento end end) tlm_vl_pct_perdido
								,sum(case when l.plm_nm_tipo = 'PF - PNR' then l.tlm_vl_lancamento end) tlm_vl_pnr
								,string_agg(cast(tlm_ds_observacao as varchar(max)) + ': R$ ' + format(isnull(tlm_vl_lancamento,0), 'N2', 'pt-BR'),CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)) tlm_descricao_lancamento
							from
								#lancamentos_rotas_periodo L
							group by
								tlm_cd_rota
						) l on l.tlm_cd_rota = p.ppr_cd_rota
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_cd_tipo_pgto = 1362
			and ppr_in_excluido = 0
			and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)



		------------------------------------------------------------
		-- CONSOLIDA LANÇAMENTOS MANUAIS PARA INSERÇÃO NO PERIODO
		------------------------------------------------------------
		--consolida tabela de lançamentos
		drop table if exists #lancamentos_pgto
		select 
			@CodPeriodoPagamento ppr_cd_periodo
			,@Operacao ppr_cd_operacao
			,@IdCliTransportadora ppr_cd_cliente_transportadora
			,l.tlm_cd_lancamento_manual ppr_lcto_cd_lancamento 
			,l.tlm_cd_rota ppr_cd_rota
			,coalesce(m2.Nome,m3.Nome,m.mot_nm_motorista,l.tlm_nome_motorista) ppr_nome_motorista
			,isnull(l.usr_cd_usuario,r.UsuarioDA) ppr_cd_motorista
			,l.tlm_dh_referencia ppr_lcto_dt_lancamento
			,l.tlm_dh_referencia ppr_data_referencia
			,l.tlm_vl_lancamento ppr_vl_lancamentos
			,case when l.plm_nm_tipo = 'PF - Endereço não visitado' then case when l.tlm_vl_lancamento > 0 then l.tlm_vl_lancamento * -1 else l.tlm_vl_lancamento end end ppr_vl_end_nvisitado
			,case when l.plm_nm_tipo = 'PF - Pacote Perdido' then case when l.tlm_vl_lancamento > 0 then l.tlm_vl_lancamento * -1 else l.tlm_vl_lancamento end end ppr_vl_pct_perdido
			,case when l.plm_nm_tipo = 'PF - PNR' then l.tlm_vl_lancamento end ppr_vl_pnr
			,l.tlm_cd_service_center ppr_base_principal
			,l.tlm_ds_observacao ppr_lcto_observacao
			,l.plm_nm_tipo ppr_lcto_tipo
			,@CodUsuario ppr_lcto_usr_criacao
			,@CodUsuario ppr_cd_usr_modificacao
			,@CodUsuario ppr_cd_usr_criacao
			,getdate() ppr_dh_criacao
			,getdate() ppr_dh_modificacao
			,1 ppr_in_ativo
			,0 ppr_in_excluido
			,1363 ppr_cd_tipo_pgto
			,r.DriverId ppr_driver_id
			,coalesce(dbo.fn_DocumentoValidoFormatado(m2.CPF), dbo.fn_DocumentoValidoFormatado(m3.CPF), dbo.fn_DocumentoValidoFormatado(m.mot_cpf)) ppr_cpf
			,cast(null as int) ppr_cd_motorista_nfs
			,cast(null as int) ppr_cd_pgto_espelho

			into #lancamentos_pgto
		from 
			#lancamentos_sem_rotas_periodo l
			left join tb_ml_rotas r with(nolock) on l.tlm_cd_rota = r.IdRota
												and r.IdTransportadora = @IdTransportadora
												and r.Excluido = 0
												and (
														l.plm_nm_tipo <> 'Apoio'
														or
														(l.plm_nm_tipo = 'Apoio' and tlm_fg_apoio = 'Motorista Solicitou Apoio')
													)
			left join tb_ml_motoristas m2 with(nolock) on r.DriverId = m2.IdMotorista
														and r.IdTransportadora = m2.IdTransportadora
			left join tb_usuario u with(nolock) on l.usr_cd_usuario = u.usr_cd_usuario
			left join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
													and m.mot_cd_cliente = @CodigoCliente
			left join tb_ml_motoristas m3 with(nolock) on u.usr_cd_driverid = m3.IdMotorista
														and m3.IdTransportadora = @IdTransportadora

		
		------------------------------------------------------------
		-- NORMALIZA NOME QUANDO O DOCUMENTO (CPF/CNPJ) ESTÁ PREENCHIDO
		-- Critério: maior DriverId (quando houver), depois maior nome
		------------------------------------------------------------
		;with nome_canonico_documento as (
			select
				r.ppr_cd_periodo
				,r.ppr_cd_cliente_transportadora
				,r.ppr_cd_operacao
				,case when @ParamDivisaoEspelho = 'true' then isnull(r.ppr_base_principal, N'') else N'' end base_chave
				,r.ppr_cpf
				,r.ppr_nome_motorista
				,row_number() over (
					partition by
						r.ppr_cd_periodo
						,r.ppr_cd_cliente_transportadora
						,r.ppr_cd_operacao
						,case when @ParamDivisaoEspelho = 'true' then isnull(r.ppr_base_principal, N'') else N'' end
						,r.ppr_cpf
					order by
						case when r.ppr_driver_id is not null then 1 else 0 end desc
						,r.ppr_driver_id desc
						,r.ppr_nome_motorista desc
				) ordem
			from
				#lancamentos_pgto r
			where
				r.ppr_cpf is not null
		)
		update
			r
		set
			r.ppr_nome_motorista = c.ppr_nome_motorista
		from
			#lancamentos_pgto r
			join nome_canonico_documento c on r.ppr_cd_periodo = c.ppr_cd_periodo
										and isnull(r.ppr_cd_cliente_transportadora, -1) = isnull(c.ppr_cd_cliente_transportadora, -1)
										and r.ppr_cd_operacao = c.ppr_cd_operacao
										and isnull(r.ppr_cpf, N'') = isnull(c.ppr_cpf, N'')
										and (
												@ParamDivisaoEspelho <> 'true'
												or isnull(r.ppr_base_principal, N'') = isnull(c.base_chave, N'')
											)
										and c.ordem = 1
		where
			r.ppr_cpf is not null


		------------------------------------------------------------
		-- CRIA ESPELHOS PARA LANÇAMENTOS MANUAIS: apenas INSERT se ainda não existir
		------------------------------------------------------------
		if @ParamCriarEspelho = 1
		begin
			
			------------------------------------------------------------
			-- ATUALIZA BASE QUE SERÁ REGISTRADO NO ESPELHO PARA TRANSPORTADORAS EM QUE NÃO HÁ DIVISÃO DE ESPELHOS POR BASE
			------------------------------------------------------------
			if @ParamDivisaoEspelho = 'false'
			begin
				update
					r
				set
					r.ppr_base_principal = r2.ppr_base_principal
				from
					#lancamentos_pgto r
					join (
						select
							ppr_nome_motorista
							,ppr_cpf
							,ppr_base_principal
							,row_number() over(partition by ppr_nome_motorista, ppr_cpf order by count(*) desc, ppr_base_principal desc) as ordem
						from
							#lancamentos_pgto
						group by
							ppr_nome_motorista
							,ppr_cpf
							,ppr_base_principal
					) r2 on isnull(r.ppr_nome_motorista, N'') = isnull(r2.ppr_nome_motorista, N'')
						and isnull(r.ppr_cpf, N'') = isnull(r2.ppr_cpf, N'')
						and r2.ordem = 1
			end



			drop table if exists #espelho
			select
				s.ppr_cd_periodo mtn_cd_pgto_periodo,
				s.ppr_cd_cliente_transportadora mtn_cd_cliente_transportadora,
				s.ppr_cd_operacao mtn_cd_operacao,
				b.bss_cd_base mtn_cd_base,
				s.ppr_base_principal mtn_base_principal,
				s.ppr_cd_motorista mtn_cd_motorista,
				s.ppr_nome_motorista mtn_nome_motorista,
				s.ppr_cpf mtn_cpf,
				s.ppr_driver_id mtn_driver_id,
				228 mtn_cd_status,
				cast(0 as decimal(10, 2)) mtn_vl_nfs,
				s.mtn_qt_rotas mtn_qt_rotas,
				94 mtn_cd_tipo_espelho,
				@CodigoCliente mtn_cod_cliente,
				getdate() mtn_dh_criacao,
				@CodUsuario mtn_cd_usr_criacao,
				getdate() mtn_dh_modificacao,
				@CodUsuario mtn_cd_usr_modificacao,
				0 mtn_in_excluido,
				case when @ParamDivisaoEspelho = 'true' then 1 else 0 end mtn_in_divisao
			into
				#espelho
			from
			(
				select
					r.ppr_cd_periodo,
					r.ppr_cd_cliente_transportadora,
					r.ppr_cd_operacao,
					r.ppr_base_principal,
					r.ppr_nome_motorista,
					r.ppr_cpf,
					max(r.ppr_cd_motorista) ppr_cd_motorista,
					max(r.ppr_driver_id) ppr_driver_id,
					count(1) mtn_qt_rotas
				from
					#lancamentos_pgto r
				group by
					r.ppr_cd_periodo,
					r.ppr_cd_cliente_transportadora,
					r.ppr_cd_operacao,
					r.ppr_base_principal,
					r.ppr_nome_motorista,
					r.ppr_cpf
			) s
			left join tb_bases b with(nolock) on s.ppr_base_principal = b.bss_ds_sigla
												and b.bss_cd_idtransportadora = @IdTransportadora
			where
				not exists (
					select
						1
					from
						tb_pag_espelhos ex with(nolock)
					where
						ex.mtn_in_excluido = 0
						and ex.mtn_cd_pgto_periodo = s.ppr_cd_periodo
						and isnull(ex.mtn_cd_cliente_transportadora, -1) = isnull(s.ppr_cd_cliente_transportadora, -1)
						and ex.mtn_cd_operacao = s.ppr_cd_operacao
						and isnull(ex.mtn_nome_motorista, '') = isnull(s.ppr_nome_motorista, '')
						and isnull(ex.mtn_cpf, '') = isnull(s.ppr_cpf, '')
						and (
								@ParamDivisaoEspelho <> 'true'
								or isnull(ex.mtn_base_principal, '') = isnull(s.ppr_base_principal, '')
							)
				)
				and (
						not exists (
							select
								1
							from
								tb_pag_espelhos en with(nolock)
							where
								en.mtn_in_excluido = 0
								and en.mtn_cd_pgto_periodo = s.ppr_cd_periodo
								and isnull(en.mtn_cd_cliente_transportadora, -1) = isnull(s.ppr_cd_cliente_transportadora, -1)
								and en.mtn_cd_operacao = s.ppr_cd_operacao
								and isnull(en.mtn_nome_motorista, '') = isnull(s.ppr_nome_motorista, '')
								and (
										@ParamDivisaoEspelho <> 'true'
										or isnull(en.mtn_base_principal, '') = isnull(s.ppr_base_principal, '')
									)
						)
						or nullif(ltrim(rtrim(isnull(s.ppr_cpf, ''))), '') is not null
					);

			insert into tb_pag_espelhos
			(
				mtn_cd_pgto_periodo,
				mtn_cd_cliente_transportadora,
				mtn_cd_operacao,
				mtn_cd_base,
				mtn_base_principal,
				mtn_cd_motorista,
				mtn_nome_motorista,
				mtn_cpf,
				mtn_driver_id,
				mtn_cd_status,
				mtn_vl_nfs,
				mtn_qt_rotas,
				mtn_cd_tipo_espelho,
				mtn_cod_cliente,
				mtn_dh_criacao,
				mtn_cd_usr_criacao,
				mtn_dh_modificacao,
				mtn_cd_usr_modificacao,
				mtn_in_excluido,
				mtn_in_divisao,
				mtn_ds_Banco,
				mtn_ds_NomeTitular,
				mtn_ds_CpfTitular,
				mtn_ds_CnpjTitular,
				mtn_ds_Agencia,
				mtn_ds_Conta,
				mtn_ds_TipoConta,
				mtn_ds_TipoChavePix,
				mtn_ds_ChavePix,
				mtn_ds_CnpjEmpresa,
				mtn_ds_RazaoSocial,
				mtn_ds_NomeFantasia,
				mtn_dt_prevista_pagamento
			)
			select
				e.mtn_cd_pgto_periodo,
				e.mtn_cd_cliente_transportadora,
				e.mtn_cd_operacao,
				e.mtn_cd_base,
				e.mtn_base_principal,
				e.mtn_cd_motorista,
				e.mtn_nome_motorista,
				e.mtn_cpf,
				e.mtn_driver_id,
				e.mtn_cd_status,
				e.mtn_vl_nfs,
				e.mtn_qt_rotas,
				e.mtn_cd_tipo_espelho,
				e.mtn_cod_cliente,
				e.mtn_dh_criacao,
				e.mtn_cd_usr_criacao,
				e.mtn_dh_modificacao,
				e.mtn_cd_usr_modificacao,
				e.mtn_in_excluido,
				e.mtn_in_divisao,
				m.Banco mtn_ds_Banco,
				m.NomeTitular mtn_ds_NomeTitular,
				m.CpfTitular mtn_ds_CpfTitular,
				m.CnpjTitular mtn_ds_CnpjTitular,
				m.Agencia mtn_ds_Agencia,
				m.Conta mtn_ds_Conta,
				m.TipoConta mtn_ds_TipoConta,
				m.TipoChavePix mtn_ds_TipoChavePix,
				m.ChavePix mtn_ds_ChavePix,
				m.CnpjEmpresa mtn_ds_CnpjEmpresa,
				m.RazaoSocial mtn_ds_RazaoSocial,
				m.NomeFantasia mtn_ds_NomeFantasia,
				@DataPrevistaPagamento mtn_dt_prevista_pagamento
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
		end


		------------------------------------------------------------
		-- ATUALIZA EM QUAL ESPELHO PERCENTE O LANÇAMENTO
		------------------------------------------------------------
		update
			r
		set
			r.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			,r.ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs
		from
			#lancamentos_pgto r
			join tb_pag_espelhos e with(nolock) on r.ppr_cd_periodo = e.mtn_cd_pgto_periodo
												and r.ppr_cd_cliente_transportadora = e.mtn_cd_cliente_transportadora
												and r.ppr_cd_operacao = e.mtn_cd_operacao
												and isnull(r.ppr_nome_motorista, '') = isnull(e.mtn_nome_motorista, '')
												and isnull(r.ppr_cpf, '') = isnull(e.mtn_cpf, '')
												and (
														(
															@ParamDivisaoEspelho = 'true'
															and r.ppr_base_principal = e.mtn_base_principal
														)
														or (@ParamDivisaoEspelho = 'false')
													)
												and e.mtn_in_excluido = 0
												and e.mtn_cd_status IN (34, 228, 38, 1298)

		
		
		--caso o cliente tenha divisão de espelho, mas só foi gerado um espelho para o motorista
		--considera ele como espelho que o lançamento irá mesmo sendo de svc diferente
		--é aplicável apenas os lançamentos qeu não foi possível associar espelho no update acima
		if @ParamDivisaoEspelho = 'true'
		begin
			update
				r
			set
				r.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				,r.ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs
			from
				#lancamentos_pgto r
				join tb_pag_espelhos e with(nolock) on r.ppr_cd_periodo = e.mtn_cd_pgto_periodo
													and r.ppr_cd_cliente_transportadora = e.mtn_cd_cliente_transportadora
													and r.ppr_cd_operacao = e.mtn_cd_operacao
													and isnull(r.ppr_nome_motorista, '') = isnull(e.mtn_nome_motorista, '')
													and isnull(r.ppr_cpf, '') = isnull(e.mtn_cpf, '')
													and e.mtn_in_excluido = 0
													and e.mtn_cd_status IN (34, 228, 38, 1298)
				join (
					select
						mtn_nome_motorista,
						mtn_cpf
					from
						tb_pag_espelhos e with(nolock)
					where
						mtn_cd_pgto_periodo = @CodPeriodoPagamento
						and mtn_cd_cliente_transportadora = @IdCliTransportadora
						and e.mtn_cd_operacao = @Operacao
						and e.mtn_in_excluido = 0
						--não devo fazer filtro de status porque a contagem é independente disso
					group by
						mtn_nome_motorista,
						mtn_cpf
					having
						count(1) = 1
				) e2 on isnull(e.mtn_nome_motorista, '') = isnull(e2.mtn_nome_motorista, '')
						and isnull(e.mtn_cpf, '') = isnull(e2.mtn_cpf, '')
			where
				r.ppr_cd_motorista_nfs is null
		end


		--atualiza qual espelho pertence o lançamento para casos de espelhos avulsos
		--nesse caso considera o merge pelo mtn_cd_motorista
		update
			r
		set
			r.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			,r.ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs
		from
			#lancamentos_pgto r
			join tb_pag_espelhos e with(nolock) on r.ppr_cd_periodo = e.mtn_cd_pgto_periodo
												and r.ppr_cd_cliente_transportadora = e.mtn_cd_cliente_transportadora
												and r.ppr_cd_operacao = e.mtn_cd_operacao
												and (
														(
															@ParamDivisaoEspelho = 'true'
															and r.ppr_base_principal = e.mtn_base_principal
														)
														or (@ParamDivisaoEspelho = 'false')
													)
												and r.ppr_cd_motorista = e.mtn_cd_motorista
												and e.mtn_in_excluido = 0
												and e.mtn_cd_status IN (34, 228, 38, 1298)
												and e.mtn_cd_tipo_espelho = 95 --espelho avulso
		where
			r.ppr_cd_motorista_nfs is null





		------------------------------------------------------------
		-- REGISTRA LANÇAMENTOS MANUAIS QUE NÃO FORAM INCLUÍDOS
		------------------------------------------------------------

		--remove erros encontrados no ultimo processamento
		delete 
			tb_lancamentos_manuais_erros 
		where 
			lme_cd_periodo = @CodPeriodoPagamento
			and lme_cd_cliente_transportadora = @IdCliTransportadora
			and lme_cd_operacao = @Operacao


		--insere na tabela de erro
		insert into tb_lancamentos_manuais_erros (lme_cd_lancamento_manual, lme_nm_tipo, lme_nm_motorista, lme_cd_periodo, lme_cd_cliente_transportadora, lme_cd_operacao, lme_ds_erro, lme_dh_criacao)
		select
			ppr_lcto_cd_lancamento lme_cd_lancamento_manual
			,ppr_lcto_tipo lme_nm_tipo
			,ppr_nome_motorista lme_nm_motorista
			,ppr_cd_periodo lme_cd_periodo
			,@IdCliTransportadora lme_cd_cliente_transportadora
			,@Operacao lme_cd_operacao
			,'Não foi possível atribuir o lançamento a um espelho.' lme_ds_erro
			,getdate() lme_dh_criacao
		from
			#lancamentos_pgto
		WHERE
			ppr_cd_motorista_nfs is null


		------------------------------------------------------------
		-- MERGE PAGAMENTO PERIODO ROTA PELO CÓDIGO DO LANÇAMENTO
		------------------------------------------------------------
		merge tb_pgto_periodo_rota target
        using (select * from #lancamentos_pgto where ppr_cd_motorista_nfs is not null) source
            on target.ppr_cd_periodo = source.ppr_cd_periodo
			and target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs
			and target.ppr_lcto_cd_lancamento = source.ppr_lcto_cd_lancamento
			and target.ppr_cd_tipo_pgto = 1363
			--and target.ppr_in_excluido = 0
		WHEN MATCHED THEN UPDATE SET
			ppr_cd_rota =			source.ppr_cd_rota
			,ppr_nome_motorista		= source.ppr_nome_motorista
			,ppr_cd_motorista		= source.ppr_cd_motorista
			,ppr_lcto_dt_lancamento = source.ppr_lcto_dt_lancamento
			,ppr_data_referencia	= source.ppr_data_referencia
			,ppr_vl_lancamentos		= source.ppr_vl_lancamentos
			,ppr_vl_end_nvisitado	= source.ppr_vl_end_nvisitado
			,ppr_vl_pct_perdido		= source.ppr_vl_pct_perdido
			,ppr_vl_pnr				= source.ppr_vl_pnr
			,ppr_base_principal		= source.ppr_base_principal
			,ppr_lcto_observacao	= source.ppr_lcto_observacao
			,ppr_lcto_tipo			= source.ppr_lcto_tipo
			,ppr_cd_usr_modificacao	= source.ppr_cd_usr_modificacao
			,ppr_dh_modificacao		= source.ppr_dh_modificacao
			,ppr_cd_motorista_nfs	= source.ppr_cd_motorista_nfs
			,ppr_cd_pgto_espelho	= source.ppr_cd_pgto_espelho
			,ppr_driver_id			= source.ppr_driver_id
			,ppr_in_excluido		= source.ppr_in_excluido
		WHEN NOT MATCHED BY TARGET THEN
			INSERT 
			(
				ppr_cd_periodo,
				ppr_cd_rota,
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
				ppr_cd_tipo_pgto,
				ppr_driver_id,
				ppr_lcto_dt_lancamento,
				ppr_vl_lancamentos,
				ppr_lcto_observacao,
				ppr_lcto_tipo,
				ppr_lcto_cd_lancamento,
				ppr_vl_end_nvisitado,
				ppr_vl_pct_perdido,
				ppr_vl_pnr
		)
		VALUES 
		(
			source.ppr_cd_periodo,
			source.ppr_cd_rota,
			source.ppr_dh_criacao,
			source.ppr_cd_usr_criacao,
			source.ppr_dh_modificacao,
			source.ppr_cd_usr_modificacao,
			source.ppr_in_ativo,
			source.ppr_in_excluido,
			source.ppr_cd_motorista,
			source.ppr_cd_motorista_nfs,
			source.ppr_cd_pgto_espelho,
			source.ppr_data_referencia,
			source.ppr_base_principal,
			source.ppr_nome_motorista,
			source.ppr_cd_tipo_pgto,
			source.ppr_driver_id,
			source.ppr_lcto_dt_lancamento,
			source.ppr_vl_lancamentos,
			source.ppr_lcto_observacao,
			source.ppr_lcto_tipo,
			source.ppr_lcto_cd_lancamento,
			source.ppr_vl_end_nvisitado,
			ppr_vl_pct_perdido,
			ppr_vl_pnr
		);



		------------------------------------------------------------
		-- REMOVE LANÇAMENTOS MANUAIS QUE NÃO ESTÃO MAIS ATIVOS
		------------------------------------------------------------
		if @CodEspelho is null and @IdRota is null
		begin
			--remove lançamentos que entraram como tipo de lançamento mas depois entrou uma rota para aquele lançamento manual e não faz mais sentido ter ele visivel
			update
				p
			set
				p.ppr_in_excluido = 1
			from
				tb_pgto_periodo_rota p
				join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_in_excluido = 0
										and e.mtn_cd_status IN (34, 228, 38, 1298)
				left join #lancamentos_pgto l on p.ppr_lcto_cd_lancamento = l.ppr_lcto_cd_lancamento
			where
				p.ppr_cd_periodo = @CodPeriodoPagamento
				and p.ppr_lcto_cd_lancamento is not null
				and p.ppr_cd_tipo_pgto = 1363
				and l.ppr_lcto_cd_lancamento is null


			--remove lançamentos que não estão mais aprovados
			update
				p
			set
				p.ppr_in_excluido = 1
			from
				tb_pgto_periodo_rota p
				join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
										and e.mtn_cd_operacao = @Operacao
										and e.mtn_in_excluido = 0
										and e.mtn_cd_status IN (34, 228, 38, 1298)
			where
				p.ppr_cd_periodo = @CodPeriodoPagamento
				and p.ppr_lcto_cd_lancamento is not null
				and p.ppr_cd_tipo_pgto = 1363
				and not exists (select 
									1 
								from 
									vw_lancamentos_manuais_aprovados l 
								where 
									l.tlm_dh_referencia >= @DataInicial
									and l.tlm_dh_referencia < dateadd(day,1,@DataFinal)
									and l.tlm_cd_cliente = @CodigoCliente  
									and l.tlm_cd_operacao = @Operacao  
									and l.tlm_cd_cliente_transportadora = @IdCliTransportadora
									and p.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
								);
		end



		

	end --fim do if que verifica se o período pode sofrer alterações


end --fim procedure
GO
