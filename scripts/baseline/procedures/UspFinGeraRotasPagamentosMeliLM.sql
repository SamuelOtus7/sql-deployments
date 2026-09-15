-- ============================================================
-- BASELINE: dbo.UspFinGeraRotasPagamentosMeliLM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraRotasPagamentosMeliLM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspFinGeraRotasPagamentosMeliLM]  (
	@CodPeriodoPagamento int
	,@IdRota int = null
	,@CodEspelho int = null
	,@CodUsuario int = null
)
AS
BEGIN
	
	SET NOCOUNT ON;


	--declare @CodPeriodoPagamento int = 3357
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
		declare @TipoContrato int
		declare @Operacao int
		declare @IdCliTransportadora int
		declare @DataPrevistaPagamento date
		
		select
			@CodigoCliente = pgp_cd_cliente
			,@DataInicial = pgp_dt_inicio
			,@DataFinal = pgp_dt_fim
			,@TipoContrato = pgp_cd_tipo_contratos
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
		declare @TipoOperacao varchar(2) = (select lst_ds_valor from tb_lista with(nolock) where lst_nm_lista = 'Operações Marketplace' and lst_cd_lista = @Operacao)

		------------------------------------------------------------
		-- PARAMETRIZAÇÃO FINANCEIRO DO CLIENTE
		------------------------------------------------------------
		declare @ParamUtilizaSVC int = isnull(
												(select  
													prm_ds_valor
												from    
													tb_parametros with(nolock)
												where   
													prm_nm_parametro = 'Service Center Padrão'
													and prm_cod_cliente = @CodigoCliente 
													and prm_in_ativo = 1
													and prm_in_excluido = 0
												)
										,0)

		declare @ParamVeiculo varchar(50) = (
												select 
													lst_ds_valor
												from 
													tb_lista l with(nolock)
													join tb_parametros p with(nolock) on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
												where 
													l.lst_nm_lista = 'Parâmetros do financeiro - Veiculo'
													and prm_ds_categoria = 'Financeiro - Pagamentos'
													and prm_cod_cliente = @CodigoCliente
													and prm_in_ativo = 1
													and prm_in_excluido = 0
											)

		
		 
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

		 declare @ParamKmSelecionado1 varchar(150) = (select 
														lst_ds_label
													from 
														tb_lista l with(nolock)
														join tb_parametros p with(nolock) on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where 
														l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
														and prm_nm_parametro = 'Km a ser utilizado.'
														and prm_cod_cliente = @CodigoCliente
														and prm_in_ativo = 1
														and prm_in_excluido = 0
													)

		 declare @ParamKmSelecionado2 varchar(150) = (select 
														lst_ds_label
													from 
														tb_lista l with(nolock)
														join tb_parametros p with(nolock) on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where 
														l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
														and prm_nm_parametro = 'Km a ser utilizado 2'
														and prm_cod_cliente = @CodigoCliente
														and prm_in_ativo = 1
														and prm_in_excluido = 0
													)

		declare @ParamKmSelecionado3 varchar(150) = isnull((select 
														lst_ds_label
													from 
														tb_lista l with(nolock)
														join tb_parametros p with(nolock) on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where 
														l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
														and prm_nm_parametro = 'Km a ser utilizado 3'
														and prm_cod_cliente = @CodigoCliente
														and prm_in_ativo = 1
														and prm_in_excluido = 0
													),'')

		declare @ParamKmSelecionado4 varchar(150) = isnull((select 
														lst_ds_label
													from 
														tb_lista l with(nolock)
														join tb_parametros p with(nolock) on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where 
														l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
														and prm_nm_parametro = 'Km a ser utilizado 4'
														and prm_cod_cliente = @CodigoCliente
														and prm_in_ativo = 1
														and prm_in_excluido = 0
													),'')

		declare @ParamMenorValorKm varchar(5) = lower(ltrim(rtrim(isnull(
														(select 
															prm_ds_valor
														from 
															tb_parametros with(nolock)
														where 
															prm_nm_parametro = 'Considerar menor valor entre KM'
															and prm_cod_cliente = @CodigoCliente
																and prm_in_ativo = 1
																and prm_in_excluido = 0
														)
													,'false'))))

		 declare @ParamKmMinimo varchar(50) = lower(ltrim(rtrim(isnull(
															(select 
																prm_ds_valor
															from 
																tb_parametros with(nolock)
															where 
																prm_nm_parametro = 'Aplicar Km mínimo'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @CodigoCliente
															)
														,'false'))))

		declare @ParamOrigemParadas varchar(20) = isnull(
															(select  
																lst_ds_valor
															from    
																tb_lista l (nolock)
																join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
															where   
																p.prm_nm_parametro = 'Fonte Valores'
																and p.prm_cod_cliente = @CodigoCliente
																and p.prm_in_ativo = 1
																and p.prm_in_excluido = 0
																and l.lst_nm_lista = 'Parâmetros do financeiro - Fonte Valores'
															)
														,'Silos')

		declare @ParamOrigemParadas2 varchar(20) = (select  
														lst_ds_valor
													from    
														tb_lista l (nolock)
														join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where   
														p.prm_nm_parametro = 'Fonte Paradas 2'
														and p.prm_cod_cliente = @CodigoCliente
														and p.prm_in_ativo = 1
														and p.prm_in_excluido = 0
														and l.lst_nm_lista = 'Parâmetros do financeiro - Fonte Valores'
													)

		declare @ParamRegrasPontos varchar(100) = (select  
														lst_ds_valor
													from    
														tb_lista l (nolock)
														join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where   
														p.prm_nm_parametro = 'Regras Pontos'
														and p.prm_cod_cliente = @CodigoCliente
														and p.prm_in_ativo = 1
														and p.prm_in_excluido = 0
														and l.lst_nm_lista = 'Parâmetros do financeiro - Regras Paradas/Pontos'
													)

		declare @ParamRegrasParadas varchar(100) = (select  
														lst_ds_valor
													from    
														tb_lista l (nolock)
														join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
													where   
														p.prm_nm_parametro = 'Regras Paradas'
														and p.prm_cod_cliente = @CodigoCliente
														and p.prm_in_ativo = 1
														and p.prm_in_excluido = 0
														and l.lst_nm_lista = 'Parâmetros do financeiro - Regras Paradas/Pontos'
													)
													
		declare @ParamVisualizarTodasBases int = isnull(
															(select 
																prm_ds_valor
															from 
																tb_parametros with(nolock)
															where 
																prm_nm_parametro = 'Visibilidade Padrão de Bases'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @CodigoCliente
															)
														,1)

		declare @ParamOrigemAmbulancia varchar(20) = isnull(
															(select  
																lst_ds_valor
															from    
																tb_lista l (nolock)
																join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
															where   
																p.prm_nm_parametro = 'Origem Ambulancia'
																and p.prm_cod_cliente = @CodigoCliente
																and p.prm_in_ativo = 1
																and p.prm_in_excluido = 0
																and l.lst_nm_lista = 'Parâmetros do financeiro - Fonte Valores'
															)
														,'Silos')

		
		declare @ParamRegraSDD int = isnull((
													select 
														prm_ds_valor 
													from 
														tb_parametros 
													where 
														prm_ds_categoria = 'Financeiro - Pagamentos'
														and prm_nm_parametro = 'Regra Pagamento Ambulancia SDD'
														and prm_cod_cliente = @CodigoCliente
														and prm_in_ativo = 1
														and prm_in_excluido = 0  
										),0)

		declare @ParamOrigemCiclo varchar(20) = isnull(
															(select  
																lst_ds_valor
															from    
																tb_lista l (nolock)
																join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
															where   
																p.prm_nm_parametro = 'Fonte Ciclo'
																and p.prm_cod_cliente = @CodigoCliente
																and p.prm_in_ativo = 1
																and p.prm_in_excluido = 0
																and l.lst_nm_lista = 'Parâmetros do financeiro - Fonte Valores'
															)
														,'Silos')

		declare @ParamGerarEspelhosUsuariosAtivos int --precisamos ter um parametro para definir se será gerado espelho apenas se tiver cadastro no irisys (a 50+ faz isso)
		

		------------------------------------------------------------
		-- DADOS EDITADOS NA TELA DE ESPELHO
		------------------------------------------------------------
		drop table if exists #tb_pgto_periodo_rota_edit
		select 
			try_cast(replace(replace(replace(edit_rota, char(9), ''), char(10), ''), char(13), '') as int) edit_rota
			,edit_cd_periodo
			,edit_cd_espelho
			,edit_Service_Center
			,edit_Tipo_Veiculo
			,edit_Faixa_KM
			,edit_Ciclo_PM
			,edit_Placa
			,edit_Quantidade_Pontos
			,edit_Quantidade_Paradas
			,edit_cd_usr_criacao
			,edit_dh_criacao
			,edit_Quantidade_Pacotes
			,edit_usou_app
			,edit_Observacao
			,edit_Regiao
			,edit_RiscoV2
			,edit_Ajudante
			,edit_AreaRisco
			,edit_cidade
			,edit_Total_KM
			,edit_ambulancia
			,edit_ds_motivo
			,edit_zerar_pagamento
			,edit_quantidade_pacotes_entregues
			,case when CHARINDEX('/', edit_Faixa_KM) > 1 then cast(SUBSTRING(edit_Faixa_KM, 1, CHARINDEX('/', edit_Faixa_KM) - 1) as decimal(12,4)) end edit_km_selecionado
			,edit_origem_km
			into #tb_pgto_periodo_rota_edit
		from 
			tb_pgto_periodo_rota_edit (NOLOCK)
		where 
			edit_cd_periodo =  @CodPeriodoPagamento
			and try_cast(replace(replace(replace(edit_rota, char(9), ''), char(10), ''), char(13), '') as int) is not null

		

		------------------------------------------------------------
		--Etapa de Edit Origem Rotas KM
		--Feito para o cliente alterar a fonte do KM selecionado
		------------------------------------------------------------
		alter table #tb_pgto_periodo_rota_edit add KmEditado decimal(10,4)
		alter table #tb_pgto_periodo_rota_edit add NomeKmEditado varchar(100)
    
		update
			edit
		set
			edit.edit_Total_KM = isnull(case 
									when lst_ds_label = 'KM do app Irisys'                                  then km.pontosAppRotasTotalKm
									when lst_ds_label = 'KM latitude e longetude dos Pacotes'               then km.pontosRotasPacotesKm
									when lst_ds_label = 'Km por trevo a trevo'                              then trv.bkt_vl_km_ideal
									when lst_ds_label = 'Km do RTT'                                         then rtt.KmRTT
									when lst_ds_label = 'Faixa km da prefatura'                             then pre.FimIntervalo
									when lst_ds_label = 'Km do app Irisys ou KM lat e long dos pacotes.'    then isnull(case when km.pontosAppRotasTotalKm = 0 then km.pontosRotasPacotesKm else km.pontosAppRotasTotalKm end,1)
									when lst_ds_label = 'Km coletado do Silos'                              then r.KmTotal
								 end,0)

		  , edit.NomeKmEditado = edit.edit_origem_km
		from    
			vw_ml_rotas as r
			inner join #tb_pgto_periodo_rota_edit as edit
				on r.IdRota = edit.edit_rota 
				and edit.edit_origem_km is not null
			inner join tb_lista as lst 
				on lst.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem' 
				and edit.edit_origem_km = lst.lst_ds_label
			left join tb_ml_processamento_km_rotas as km 
				on r.IdKmProcessado = km.id
			left join vw_prefatura_espelhos as pre
				on r.IdRota = pre.IdRota
				and r.IdTransportadora = pre.IdTransportadora
			left join tb_fin_base_km_trevo as trv
				on r.idtrevo = trv.bkt_cd_base_km_trevo
			left join (
						SELECT IdRota , cast(KmTotal as decimal(10,4)) KmRTT
						FROM (
							SELECT *,
								   ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY quinzena DESC) AS rn
							FROM tb_ml_bsc_rtt WITH (NOLOCK)
						) AS sub
						WHERE rn = 1
				) AS rtt on rtt.idrota = r.idrota
		where
			r.datareferencia between @DataInicial and @DataFinal
			and r.idtransportadora = @IdTransportadora
			and (@CodEspelho is null or edit.edit_cd_espelho = @CodEspelho)



		------------------------------------------------------------
		-- Materializa KmColetadoFin uma vez por periodo (evita join com view PBI dentro do SQL dinamico)
		------------------------------------------------------------
		drop table if exists #KmColetadoFin;
		select
			aud.IdRota,
			aud.IdTransportadora,
			aud.DataReferencia,
			aud.KmColetadoFin,
			aud.TipoKmColetado
		into #KmColetadoFin
		from 
			dbo.vw_pbi_auditoria_km_rotas_v2 as aud with (nolock)
		where 
			aud.IdTransportadora = @IdTransportadora
			and aud.TipoRota = @TipoOperacao
			and aud.DataReferencia between @DataInicial and @DataFinal;





		------------------------------------------------------------
		-- ROTAS DO PERÍODO TEMPORARIA PARA MELHORAR A PERFORMANCE
		------------------------------------------------------------
		drop table if exists #temp_rotas_financeiro
		select
			r.*		
		into 
			#temp_rotas_financeiro
		from 
			vw_ml_rotas_financeiro as r	
		
		where
				(
					@TipoOperacao = 'LM' and (r.TotalPacotes > 0 or r.PacotesTransferidos > 0) 
					or
					@TipoOperacao <> 'LM'

				)
			and r.TipoRota = @TipoOperacao
			and r.IdTransportadora = @IdTransportadora
			and r.DataReferencia between @DataInicial and @DataFinal
			and (r.IdRota = @IdRota or @IdRota is null)
			and (
					exists (select 
								1 
							from 
								tb_pgto_periodo_rota pgto with(nolock)
							where 
								pgto.ppr_cd_motorista_nfs = @CodEspelho 
								and pgto.ppr_cd_tipo_pgto = 1362
								and pgto.ppr_in_excluido = 0
								and pgto.ppr_cd_rota = r.IdRota
							)
					or
					@CodEspelho is null
				)



		------------------------------------------------------------
		-- PERFORMANCE HISTORICO ROTAS
		------------------------------------------------------------
		--if @CodigoCliente = 45
		--begin

			drop table if exists #temp_performance
			select 
					dhr_cd_cliente Cliente
				,	dhr_dt_data DataRef
				,	dhr_nr_rota IdRota
				,	cast((dhr_vl_delivery_success / 100) as decimal(10,2)) dhr_vl_delivery_success
				,	cast(( 1 - (dhr_nr_nao_visitado  / 100)) as decimal(10,2)) dhr_nr_nao_visitado 
				,	max(dhr_dh_coleta) dhr_dh_coleta
			into
				#temp_performance
			from 
				tb_dra_historico_rotas as a
			where 
				dhr_cd_cliente = case when @CodigoCliente = 45 then 1950609251 else 0 end 
				and dhr_dt_data between @DataInicial and @DataFinal
			group	by 
					dhr_cd_cliente
				,	dhr_dt_data
				,	dhr_nr_rota
				,	dhr_vl_delivery_success
				,	dhr_nr_nao_visitado  

		--end

		------------------------------------------------------------
		-- ROTAS DO PERÍODO
		------------------------------------------------------------
		drop table if exists #rotas
		select
			@CodPeriodoPagamento ppr_cd_periodo
			,@Operacao ppr_cd_operacao
			,@IdCliTransportadora ppr_cd_cliente_transportadora
			,r.IdTransportadora
			,c.cli_cd_codigo_cliente pgp_cd_cliente
			,isnull(m.mot_ctn_cd_tipo_contrato,-1) mtn_cd_tipo_contrato
			,cast(r.IdRota as varchar(50)) as ppr_cd_rota

			,r.UsuarioDA ppr_cd_motorista
			,r.DriverId ppr_driver_id
			,coalesce(m2.Nome,m.mot_nm_motorista,r.NomeMotorista) ppr_nome_motorista

			,coalesce(e.edit_Service_Center, v.vei_ds_base_espelho, base_xpt.bss_ds_sigla, case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and @ParamUtilizaSVC = 0 then OrigemSaida else r.ServiceCenter end) ppr_base_principal
			,coalesce(e.edit_Service_Center, v.vei_ds_base_espelho, base_xpt.bss_ds_sigla, case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and @ParamUtilizaSVC = 0 then OrigemSaida else r.ServiceCenter end) svc_espelho
			,coalesce(e.edit_Service_Center, v.vei_ds_base_espelho_calculo) ppr_base_calculo

			,isnull(e.edit_Placa, r.Placa) ppr_ds_placa
			
			,coalesce(
					e.edit_Tipo_Veiculo, 
					v.vei_ds_veiculo_espelho_calculo,
					case @ParamVeiculo
						when 'Cadastro de veiculos' then v.vei_ds_tipo
						when 'Pre Fatura' then p.Veiculo
						when 'Base MarketPlace' then r.TipoVeiculo
					else
						r.TipoVeiculo
					end,
					r.TipoVeiculo
					) ppr_ds_tipo_veiculo

			,isnull(e.edit_cidade, r.CidadeDistante) ppr_nm_cidade
			,r.DataReferencia ppr_data_referencia
			,isnull(feriado.Feriado, 0) ppr_in_fer
			,case when dt.NumDiaSemana = 1 then 1 else 0 end ppr_in_dom
			,case when dt.NumDiaSemana = 7 then 1 else 0 end ppr_in_sab
			,case when isnull(feriado.Feriado, 0) = 1 or dt.NumDiaSemana = 1 then 1 else 0 end ppr_in_dom_fer

			,isnull(
				e.edit_ambulancia,
				case @ParamOrigemAmbulancia
					when 'Silos' then r.Ambulancia
					when 'Pre Fatura' then case when p.KmCiclo = 'AMBULANCE' then 1 else 0 end 
					when 'Looker' then case when r.AmbulanciaStatus is not null then 1 else 0 end
					when 'Pre Fatura / Silos' then case when p.KmCiclo = 'AMBULANCE' then 1 else r.Ambulancia end
					else r.Ambulancia
				end
			) ppr_in_ambulancia
			
			,case when @ParamOrigemAmbulancia = 'Looker' and r.AmbulanciaStatus is not null then 
				case when r.AmbulanciaPagamento = 'Sim' then 1 else 0 end 
			end ppr_in_ambulancia_aprovada

			--,isnull(e.edit_Ciclo_PM,r.Ciclo_Novo/*,case when datepart(hour,isnull(r.DataHoraSaidaEstacao,r.DataHoraInicio)) < 12 then 'AM' when format(isnull(r.DataHoraSaidaEstacao,r.DataHoraInicio), 'HH:mm') between '15:40' and '17:30' then 'SD' else 'PM' end*/) ppr_ds_ciclo
			,isnull(
				e.edit_Ciclo_PM
				,case @ParamOrigemCiclo
					when 'Pre Fatura' then case when p.CicloPM = 'PM' then 'PM' else 'AM' end
					when 'Silos' then r.Ciclo_Novo
				else
					r.Ciclo_Novo
				end
			) ppr_ds_ciclo
			
			,isnull(e.edit_usou_app, r.UsouAPP) ppr_usou_app
			,isnull(e.edit_Quantidade_Pacotes, r.TotalPacotes) ppr_qt_pacotes
			,isnull(e.edit_quantidade_pacotes_entregues, r.PacotesEntregues) as ppr_qt_pacotes_entregues
			,PacotesNaoEntregue ppr_vl_insucessos
			,PacotesPendentes ppr_qt_pacotes_pendentes
			,isnull(r.EnderecosNaoVisitados,0) ppr_qt_enderecos_nao_visitados
			,isnull(per.dhr_vl_delivery_success,nullif(isnull(e.edit_quantidade_pacotes_entregues, r.PacotesEntregues),0) / nullif(cast(isnull(e.edit_Quantidade_Pacotes, r.TotalPacotes) as decimal(10,2)),0)) ppr_vl_success_delivery
			
			,coalesce(
				e.edit_Quantidade_Pontos,
				case @ParamOrigemParadas
					when 'Pre Fatura' then p.Parada
					when 'Silos' then r.QuantidadePontos
					when 'Looker' then paradas.QuantidadeParadas
					else r.QuantidadePontos --quando o parametro não é definido é considerado o que vem do monitoramento
				end + case when @ParamRegrasPontos = 'Retirar pacotes não entregues da contagem' then -isnull(r.PacotesNaoEntregue,0) else 0 end,
				case @ParamOrigemParadas2
					when 'Pre Fatura' then p.Parada
					when 'Silos' then r.QuantidadePontos
					when 'Looker' then paradas.QuantidadeParadas
				end + case when @ParamRegrasPontos = 'Retirar pacotes não entregues da contagem' then -isnull(r.PacotesNaoEntregue,0) else 0 end
			) ppr_qt_pontos


			,coalesce(
				e.edit_Quantidade_Paradas,
				case @ParamOrigemParadas
					when 'Pre Fatura' then p.Parada
					when 'Silos' then r.QuantidadeParadas
					when 'Looker' then paradas.QuantidadeParadas
					else r.QuantidadeParadas --quando o parametro não é definido é considerado o que vem do monitoramento
				end + case when @ParamRegrasParadas = 'Retirar pacotes não entregues da contagem' then -isnull(r.PacotesNaoEntregue,0) else 0 end,
				case @ParamOrigemParadas2
					when 'Pre Fatura' then p.Parada
					when 'Silos' then r.QuantidadeParadas
					when 'Looker' then paradas.QuantidadeParadas
				end + case when @ParamRegrasParadas = 'Retirar pacotes não entregues da contagem' then -isnull(r.PacotesNaoEntregue,0) else 0 end
			) ppr_qt_paradas

			,r.EnderecosVisitados ppr_qtd_enderecos_visitados
			,isnull(per.dhr_nr_nao_visitado,nullif(r.EnderecosVisitados,0) / nullif(cast(isnull(e.edit_Quantidade_Pacotes, r.TotalPacotes) as decimal(10,5)),0)) ppr_per_endereco_nao_visitado

			,'Rota Mercado Livre' ppr_nm_pgto
			,1362 ppr_cd_tipo_pgto
			,r.TipoRotaDetalhe ppr_tipo_rota
			,0 ppr_qt_faixa
			,@TipoOperacao ppr_cd_tipo
			,0 ppr_in_area_risco --infromacao que vira da ficha de rota
			,0 ppr_in_ajudante --infromacao que vira da ficha de rota
			,@CodUsuario ppr_cd_usr_modificacao
			,@CodUsuario ppr_cd_usr_criacao
			,getdate() ppr_dh_criacao
			,getdate() ppr_dh_modificacao
			,1 ppr_in_ativo
			,0 ppr_in_excluido
			,1 ppr_in_calcular_adicional
			,case when e.edit_zerar_pagamento = 1 then 1 else 0 end ppr_in_zerar_rota
			,case when e.edit_zerar_pagamento = 1 then e.edit_ds_motivo end ppr_motivo_rota_zerada

			,coalesce(
					 e.edit_Total_KM
					,e.edit_km_selecionado
					,audKm.KmColetadoFin
					,r.KmColetado
					,cast(f.vmp_kmpagamento as decimal(10,4))
			 ) ppr_total_km

			,cast(
				case 
					when e.edit_Total_KM is not null then 'Km Editado'
					when e.edit_km_selecionado is not null then 'Faixa Km Editado'
				else
					audKm.TipoKmColetado
				end

			 as varchar(60)) ppr_nm_origem_km
				
			,case when @ParamMenorValorKm = 'true' and e.edit_km_selecionado is null and e.edit_Total_KM is null then 1 else 0 end ppr_aplicar_regra_menor_km
			,isnull(dbo.fn_DocumentoValidoFormatado(m2.CPF), dbo.fn_DocumentoValidoFormatado(m.mot_cpf)) ppr_cpf

			,cast(null as int) ppr_cd_motorista_nfs
			,cast(null as int) ppr_cd_pgto_espelho

			,cast(r.RotaTipoSaca as bit) ppr_in_rota_saca
			into #rotas
		from
			#temp_rotas_financeiro r with(nolock)
			join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics
											and c.cli_cd_codigo_cliente <> 7 --Não considera Otus7
			left join tb_usuario u with(nolock) on r.UsuarioDA = u.usr_cd_usuario
			left join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
													and m.mot_cd_cliente = @CodigoCliente
			left join #tb_pgto_periodo_rota_edit e on r.IdRota = e.edit_rota
			left join tb_ml_motoristas m2 with(nolock) on r.DriverId = m2.IdMotorista
														and r.IdTransportadora = m2.IdTransportadora
			--preciso alinhar com samuka pois esses placas duplicadas por cliente
			left join tb_veiculos v with(nolock) on c.cli_cd_codigo_cliente = v.vei_cd_cliente
												and r.Placa = v.vei_ds_placa
												and v.vei_in_ativo = 1
												and v.vei_in_excluido = 0
			left join vw_prefatura_espelhos p on r.IdRota = p.IdRota
											and r.IdTransportadora = p.IdTransportadora
											and (
													p.DataInicio between @DataInicial and @DataFinal 
													or p.DataFim between @DataInicial and @DataFinal
												)
			left join tb_validacao_mapas f with(nolock) on r.IdRota = f.vmp_cd_rota
			--left join tb_fin_base_km_trevo t with(nolock) on r.IdTrevo = t.bkt_cd_base_km_trevo
			--left join tb_ml_processamento_km_rotas k with(nolock) on r.IdKmProcessado = k.id
			--left join #tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota
			left join vw_feriados feriado on r.DataReferencia = feriado.Data
											and r.IdTransportadora = feriado.IdTransportadora
											and r.ServiceCenter = feriado.ServiceCenter
			left join DimData dt on isnull(cast(r.DataHoraSaidaEstacao as date),r.DataReferencia) = dt.data

			--caso a base cadastrada esteja marcado como bss_espelho_xpt então devo considerar para calculo o xpt
			left join tb_bases base_xpt with(nolock) on r.OrigemSaida = base_xpt.bss_ds_sigla 
													and r.IdTransportadora = base_xpt.bss_cd_idtransportadora
													and base_xpt.bss_espelho_xpt = 1
			left join tb_ml_bsc_paradas paradas with(nolock) on r.IdRota = paradas.IdRota
															and c.cli_cd_codigo_cliente = paradas.IdCliente
			left join #KmColetadoFin as audKm on r.IdRota = audKm.IdRota
											   and r.IdTransportadora = audKm.IdTransportadora
											   and r.DataReferencia = audKm.DataReferencia
			left join #temp_performance as per on r.IdRota = per.IdRota
												and r.IdTransportadora = per.Cliente

		where
			(m.mot_ctn_cd_tipo_contrato = @TipoContrato or @TipoContrato = -1)
			and coalesce(m2.Nome,m.mot_nm_motorista,r.NomeMotorista) is not null
			and coalesce(m2.Nome,m.mot_nm_motorista,r.NomeMotorista) <> ''
			and coalesce(m2.Nome,m.mot_nm_motorista,r.NomeMotorista) <> '-'


		
		--remove as bases que não tiverem setadas como visivéis caso esteja parametrizado para não exibir todas as bases para transportadora
		if @ParamVisualizarTodasBases = 0
		begin
			delete
				r
			from
				#rotas r
				left join tb_bases b with(nolock) on r.ppr_base_principal = b.bss_ds_sigla
										and r.IdTransportadora = b.bss_cd_idtransportadora
										and b.bss_visibilidade = 1
			where
				b.bss_cd_base is null
		end


		--Caso o veiculo for SDD e ambulancia é convertido seu tipo de veiculo para SPOT caso esteja parametrizado
		if @ParamRegraSDD = 1
		begin
			update	
				r
			set	
				ppr_ds_tipo_veiculo = REPLACE(r.ppr_ds_tipo_veiculo, N' SDD', N'')
			from	
				#rotas as r
			where	
				r.ppr_in_ambulancia = 1
				and r.ppr_ds_tipo_veiculo like '%SDD'
		end


		

		--Atualiza ciclo da rota em casos de regra definida nas bases
		update
			r
		set
			r.ppr_ds_ciclo = case l.lst_ds_valor
								when 'Considerar sempre como AM' then 'AM'
							else
								r.ppr_ds_ciclo
							end
		from
			#rotas r
			join tb_bases b with(nolock) on r.ppr_base_principal = b.bss_ds_sigla
										and r.IdTransportadora = b.bss_cd_idtransportadora
										and b.bss_regra_ciclo is not null
			join tb_lista l with(nolock) on b.bss_regra_ciclo = l.lst_cd_lista


		----Caso a transportadora considere como regra de cálculo o menor km do que foi definido, ajusta o km total
		--if @ParamMenorValorKm = 'true'
		--begin
		--	update 
		--		r
		--	set
		--		ppr_total_km = v.MenorKm,
		--		ppr_nm_origem_km = v.OrigemKm
		--	from
		--		#rotas r
		--		cross apply (
		--			select 
		--				top 1 *
		--			from 
		--				(values
		--				(ParamKmSelecionado1, ParamOrigemKmSelecionado1),
		--				(ParamKmSelecionado2, ParamOrigemKmSelecionado2),
		--				(ParamKmSelecionado3, ParamOrigemKmSelecionado3),
		--				(ParamKmSelecionado4, ParamOrigemKmSelecionado4)
		--				) as x(Km, OrigemKm)
		--			where 
		--				Km > 0
		--			order by 
		--				Km
		--		) v (MenorKm, OrigemKm)
		--		where
		--			ppr_aplicar_regra_menor_km = 1

		--	/*
		--	update
		--		#rotas
		--	set
		--		ppr_total_km = case when ParamKmSelecionado1 < ParamKmSelecionado2 then ParamKmSelecionado1 else ParamKmSelecionado2 end
		--		,ppr_nm_origem_km = case when ParamKmSelecionado1 < ParamKmSelecionado2 then ParamOrigemKmSelecionado1 else ParamOrigemKmSelecionado2 end
		--	where
		--		ppr_aplicar_regra_menor_km = 1
		--		and ParamKmSelecionado1 > 0
		--		and ParamKmSelecionado2 > 0
		--	*/
		--end

		--Caso não tenha sido coletado km, considera o km igual a 1 caso tenha sido parametrizado a regra para transportadora
		if @ParamKmMinimo = 'true'
		begin
			update
				#rotas
			set
				ppr_total_km = 1
				,ppr_nm_origem_km = 'Km não coletado. Aplicado Km mínimo.'
			where
				ppr_total_km = 0 or ppr_total_km is null
		end


		------------------------------------------------------------
		-- NORMALIZA NOME QUANDO O DOCUMENTO (CPF/CNPJ) ESTÁ PREENCHIDO
		-- Critério: maior DriverId (quando houver), depois maior nome
		------------------------------------------------------------
		;with nome_canonico_documento as (
			select
				r.ppr_cd_periodo
				,r.ppr_cd_cliente_transportadora
				,r.ppr_cd_operacao
				,case when @ParamDivisaoEspelho = 'true' then isnull(r.svc_espelho, N'') else N'' end base_chave
				,r.ppr_cpf
				,r.ppr_nome_motorista
				,row_number() over (
					partition by
						r.ppr_cd_periodo
						,r.ppr_cd_cliente_transportadora
						,r.ppr_cd_operacao
						,case when @ParamDivisaoEspelho = 'true' then isnull(r.svc_espelho, N'') else N'' end
						,r.ppr_cpf
					order by
						case when r.ppr_driver_id is not null then 1 else 0 end desc
						,r.ppr_driver_id desc
						,r.ppr_nome_motorista desc
				) ordem
			from
				#rotas r
			where
				nullif(ltrim(rtrim(isnull(r.ppr_cpf, ''))), '') is not null
		)
		update
			r
		set
			r.ppr_nome_motorista = c.ppr_nome_motorista
		from
			#rotas r
			join nome_canonico_documento c on r.ppr_cd_periodo = c.ppr_cd_periodo
										and isnull(r.ppr_cd_cliente_transportadora, -1) = isnull(c.ppr_cd_cliente_transportadora, -1)
										and r.ppr_cd_operacao = c.ppr_cd_operacao
										and isnull(r.ppr_cpf, N'') = isnull(c.ppr_cpf, N'')
										and (
												@ParamDivisaoEspelho <> 'true'
												or isnull(r.svc_espelho, N'') = isnull(c.base_chave, N'')
											)
										and c.ordem = 1
		where
			nullif(ltrim(rtrim(isnull(r.ppr_cpf, ''))), '') is not null



		------------------------------------------------------------
		-- ATUALIZA BASE QUE SERÁ REGISTRADO NO ESPELHO PARA TRANSPORTADORAS EM QUE NÃO HÁ DIVISÃO DE ESPELHOS POR BASE
		------------------------------------------------------------
		if @ParamDivisaoEspelho = 'false'
		begin
			update 
				r
			set 
				r.svc_espelho = r2.ppr_base_principal
			from 
				#rotas r
				join (
					select
						ppr_nome_motorista
						,ppr_cpf
						,ppr_base_principal
						,row_number() over(partition by ppr_nome_motorista, ppr_cpf order by count(*) desc, ppr_base_principal desc) as ordem
					from 
						#rotas
					group by 
						ppr_nome_motorista
						,ppr_cpf
						,ppr_base_principal
				) r2 on isnull(r.ppr_nome_motorista, N'') = isnull(r2.ppr_nome_motorista, N'')
					and isnull(r.ppr_cpf, N'') = isnull(r2.ppr_cpf, N'')
					and r2.ordem = 1
		end


		
		------------------------------------------------------------
		-- GERA ESPELHOS
		------------------------------------------------------------
		drop table if exists #espelho
		select
            r.ppr_cd_periodo mtn_cd_pgto_periodo
            ,r.ppr_cd_cliente_transportadora mtn_cd_cliente_transportadora
            ,r.ppr_cd_operacao mtn_cd_operacao
            ,b.bss_cd_base mtn_cd_base
            ,r.svc_espelho mtn_base_principal
			,r.ppr_nome_motorista mtn_nome_motorista
			,r.ppr_cpf mtn_cpf
            ,max(r.ppr_cd_motorista) mtn_cd_motorista
            ,max(r.ppr_driver_id) mtn_driver_id
            ,228 mtn_cd_status
            ,cast(0 as decimal(10, 2)) mtn_vl_nfs
            ,cast(count(1) as int) mtn_qt_rotas
            ,cast(94 as int) mtn_cd_tipo_espelho
            ,r.pgp_cd_cliente mtn_cod_cliente
            ,getdate() mtn_dh_criacao
            ,r.ppr_cd_usr_criacao mtn_cd_usr_criacao
            ,getdate() mtn_dh_modificacao
            ,r.ppr_cd_usr_modificacao mtn_cd_usr_modificacao
            ,ppr_in_excluido mtn_in_excluido
			,max(r.mtn_cd_tipo_contrato) mtn_cd_tipo_contrato
			,case when @ParamDivisaoEspelho = 'true' then 1 else 0 end mtn_in_divisao
			into #espelho
        from 
			#rotas r
			left join tb_bases b with(nolock) on r.svc_espelho = b.bss_ds_sigla
													and b.bss_cd_idtransportadora = r.IdTransportadora
		group by
			r.ppr_cd_periodo
            ,r.ppr_cd_cliente_transportadora
            ,r.ppr_cd_operacao
            ,b.bss_cd_base
            ,r.svc_espelho
            ,r.pgp_cd_cliente
            ,r.ppr_nome_motorista
            ,r.ppr_cpf
			,r.ppr_cd_usr_criacao
			,r.ppr_cd_usr_modificacao
			,r.ppr_in_excluido

		
		------------------------------------------------------------
		-- VERIFICA CONFLITOS DO ESPELHO PARA EVITAR ERRO NO MERGE
		------------------------------------------------------------
		
		--remove erros encontrados no ultimo processamento
		delete 
			tb_pag_espelhos_erros 
		where 
			pee_cd_periodo = @CodPeriodoPagamento
			and pee_cd_cliente_transportadora = @IdCliTransportadora
			and pee_cd_operacao = @Operacao

		-- Duplicidade estrita da chave que será protegida pela UQ
		drop table if exists #espelhos_duplicados_uq
		select
			mtn_cd_pgto_periodo
			,mtn_cd_cliente_transportadora
			,mtn_cd_operacao
			,mtn_nome_motorista
			,mtn_cpf
			,case when isnull(mtn_in_divisao, 0) = 1 then isnull(mtn_base_principal, N'') else N'' end mtn_base_principal
			into #espelhos_duplicados_uq
		from
			#espelho
		group by
			mtn_cd_pgto_periodo
			,mtn_cd_cliente_transportadora
			,mtn_cd_operacao
			,mtn_nome_motorista
			,mtn_cpf
			,case when isnull(mtn_in_divisao, 0) = 1 then isnull(mtn_base_principal, N'') else N'' end
		having
			count(1) > 1

		insert into tb_pag_espelhos_erros (pee_cd_periodo, pee_cd_cliente_transportadora, pee_cd_operacao, pee_cd_motorista, pee_nm_motorista, pee_base, pee_ds_erro, pee_dh_criacao)
		select
			d.mtn_cd_pgto_periodo
			,d.mtn_cd_cliente_transportadora
			,d.mtn_cd_operacao
			,e.mtn_cd_motorista
			,d.mtn_nome_motorista
			,case when isnull(e.mtn_in_divisao, 0) = 1 then d.mtn_base_principal else null end pee_base
			,'Espelhos duplicados pela chave da constraint (nome + cpf)' pee_ds_erro
			,getdate() pee_dh_criacao
		from
			#espelhos_duplicados_uq d
			join #espelho e on e.mtn_cd_pgto_periodo = d.mtn_cd_pgto_periodo
							and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(d.mtn_cd_cliente_transportadora, -1)
							and e.mtn_cd_operacao = d.mtn_cd_operacao
							and isnull(e.mtn_nome_motorista, N'') = isnull(d.mtn_nome_motorista, N'')
							and isnull(e.mtn_cpf, N'') = isnull(d.mtn_cpf, N'')
							and (
									isnull(e.mtn_in_divisao, 0) = 0
									or isnull(e.mtn_base_principal, N'') = isnull(d.mtn_base_principal, N'')
								)

		delete
			e
		from
			#espelho e
		where
			exists (
				select
					1
				from
					#espelhos_duplicados_uq d
				where
					e.mtn_cd_pgto_periodo = d.mtn_cd_pgto_periodo
					and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(d.mtn_cd_cliente_transportadora, -1)
					and e.mtn_cd_operacao = d.mtn_cd_operacao
					and isnull(e.mtn_nome_motorista, N'') = isnull(d.mtn_nome_motorista, N'')
					and isnull(e.mtn_cpf, N'') = isnull(d.mtn_cpf, N'')
					and (
							isnull(e.mtn_in_divisao, 0) = 0
							or isnull(e.mtn_base_principal, N'') = isnull(d.mtn_base_principal, N'')
						)
			)


		------------------------------------------------------------
		-- UPDATE de documento no espelho já existente (antes do MERGE)
		-- Somente quando: existe exatamente 1 espelho ativo no contexto+nome sem documento
		-- e a fonte #espelho traz um único documento (CPF/CNPJ) distinto para esse nome+contexto.
		------------------------------------------------------------
		update
			t
		set
			t.mtn_cpf = x.mtn_cpf
			,t.mtn_dh_modificacao = getdate()
			,t.mtn_cd_usr_modificacao = @CodUsuario
		from
			tb_pag_espelhos t
			inner join (
				select
					s.mtn_cd_pgto_periodo
					,s.mtn_cd_cliente_transportadora
					,s.mtn_cd_operacao
					,s.mtn_nome_motorista
					,case when isnull(s.mtn_in_divisao, 0) = 1 then isnull(s.mtn_base_principal, N'') else N'' end base_chave
					,max(s.mtn_cpf) mtn_cpf
				from
					#espelho s
				where
					s.mtn_in_excluido = 0
					and nullif(ltrim(rtrim(isnull(s.mtn_cpf, N''))), N'') is not null
				group by
					s.mtn_cd_pgto_periodo
					,s.mtn_cd_cliente_transportadora
					,s.mtn_cd_operacao
					,s.mtn_nome_motorista
					,case when isnull(s.mtn_in_divisao, 0) = 1 then isnull(s.mtn_base_principal, N'') else N'' end
				having
					count(distinct nullif(ltrim(rtrim(isnull(s.mtn_cpf, N''))), N'')) = 1
			) x on t.mtn_cd_pgto_periodo = x.mtn_cd_pgto_periodo
				and isnull(t.mtn_cd_cliente_transportadora, -1) = isnull(x.mtn_cd_cliente_transportadora, -1)
				and t.mtn_cd_operacao = x.mtn_cd_operacao
				and isnull(t.mtn_nome_motorista, N'') = isnull(x.mtn_nome_motorista, N'')
				and (
						@ParamDivisaoEspelho <> 'true'
						or isnull(t.mtn_base_principal, N'') = isnull(x.base_chave, N'')
					)
		where
			t.mtn_in_excluido = 0
			and t.mtn_cd_pgto_periodo = @CodPeriodoPagamento
			and isnull(t.mtn_cd_cliente_transportadora, -1) = isnull(@IdCliTransportadora, -1)
			and t.mtn_cd_operacao = @Operacao
			and nullif(ltrim(rtrim(isnull(t.mtn_cpf, N''))), N'') is null
			and (
					select
						count(1)
					from
						tb_pag_espelhos e with(nolock)
					where
						e.mtn_in_excluido = 0
						and e.mtn_cd_pgto_periodo = t.mtn_cd_pgto_periodo
						and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(t.mtn_cd_cliente_transportadora, -1)
						and e.mtn_cd_operacao = t.mtn_cd_operacao
						and isnull(e.mtn_nome_motorista, N'') = isnull(t.mtn_nome_motorista, N'')
						and (
								isnull(e.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 0
								or isnull(e.mtn_base_principal, N'') = isnull(t.mtn_base_principal, N'')
							)
						and nullif(ltrim(rtrim(isnull(e.mtn_cpf, N''))), N'') is null
				) = 1

		------------------------------------------------------------
		-- UPDATE de nome no espelho já existente (antes do MERGE)
		-- Quando: exatamente 1 espelho ativo no contexto+CPF (documento preenchido)
		-- e #espelho traz um único nome distinto para esse CPF+contexto,
		-- e o nome na tabela difere do nome na fonte.
		------------------------------------------------------------
		update
			t
		set
			t.mtn_nome_motorista = x.mtn_nome_motorista
			,t.mtn_dh_modificacao = getdate()
			,t.mtn_cd_usr_modificacao = @CodUsuario
		from
			tb_pag_espelhos t
			inner join (
				select
					s.mtn_cd_pgto_periodo
					,s.mtn_cd_cliente_transportadora
					,s.mtn_cd_operacao
					,nullif(ltrim(rtrim(isnull(s.mtn_cpf, N''))), N'') cpf_chave
					,case when isnull(s.mtn_in_divisao, 0) = 1 then isnull(s.mtn_base_principal, N'') else N'' end base_chave
					,max(s.mtn_nome_motorista) mtn_nome_motorista
				from
					#espelho s
				where
					s.mtn_in_excluido = 0
					and nullif(ltrim(rtrim(isnull(s.mtn_cpf, N''))), N'') is not null
				group by
					s.mtn_cd_pgto_periodo
					,s.mtn_cd_cliente_transportadora
					,s.mtn_cd_operacao
					,nullif(ltrim(rtrim(isnull(s.mtn_cpf, N''))), N'')
					,case when isnull(s.mtn_in_divisao, 0) = 1 then isnull(s.mtn_base_principal, N'') else N'' end
				having
					count(distinct isnull(s.mtn_nome_motorista, N'')) = 1
			) x on t.mtn_cd_pgto_periodo = x.mtn_cd_pgto_periodo
				and isnull(t.mtn_cd_cliente_transportadora, -1) = isnull(x.mtn_cd_cliente_transportadora, -1)
				and t.mtn_cd_operacao = x.mtn_cd_operacao
				and nullif(ltrim(rtrim(isnull(t.mtn_cpf, N''))), N'') = x.cpf_chave
				and (
						@ParamDivisaoEspelho <> 'true'
						or isnull(t.mtn_base_principal, N'') = isnull(x.base_chave, N'')
					)
		where
			t.mtn_in_excluido = 0
			and t.mtn_cd_pgto_periodo = @CodPeriodoPagamento
			and isnull(t.mtn_cd_cliente_transportadora, -1) = isnull(@IdCliTransportadora, -1)
			and t.mtn_cd_operacao = @Operacao
			and nullif(ltrim(rtrim(isnull(t.mtn_cpf, N''))), N'') is not null
			and isnull(t.mtn_nome_motorista, N'') <> isnull(x.mtn_nome_motorista, N'')
			and (
					isnull(t.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 0
					or isnull(t.mtn_base_principal, N'') = isnull(x.base_chave, N'')
				)
			and (
					select
						count(1)
					from
						tb_pag_espelhos e with(nolock)
					where
						e.mtn_in_excluido = 0
						and e.mtn_cd_pgto_periodo = t.mtn_cd_pgto_periodo
						and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(t.mtn_cd_cliente_transportadora, -1)
						and e.mtn_cd_operacao = t.mtn_cd_operacao
						and nullif(ltrim(rtrim(isnull(e.mtn_cpf, N''))), N'') = nullif(ltrim(rtrim(isnull(t.mtn_cpf, N''))), N'')
						and (
								isnull(e.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 0
								or isnull(e.mtn_base_principal, N'') = isnull(t.mtn_base_principal, N'')
							)
				) = 1
			and not exists (
				select
					1
				from
					tb_pag_espelhos o with(nolock)
				where
					o.mtn_in_excluido = 0
					and o.mtn_cd_motorista_nfs <> t.mtn_cd_motorista_nfs
					and o.mtn_cd_pgto_periodo = t.mtn_cd_pgto_periodo
					and isnull(o.mtn_cd_cliente_transportadora, -1) = isnull(t.mtn_cd_cliente_transportadora, -1)
					and o.mtn_cd_operacao = t.mtn_cd_operacao
					and isnull(o.mtn_nome_motorista, N'') = isnull(x.mtn_nome_motorista, N'')
					and nullif(ltrim(rtrim(isnull(o.mtn_cpf, N''))), N'') = nullif(ltrim(rtrim(isnull(t.mtn_cpf, N''))), N'')
					and (
							(
								isnull(t.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 1
								and isnull(o.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 1
								and isnull(o.mtn_base_principal, N'') = isnull(t.mtn_base_principal, N'')
							)
							or (
								isnull(t.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 0
								and isnull(o.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 0
							)
						)
			);

			
		------------------------------------------------------------
		-- Homônimo por nome no contexto (#espelho + espelhos ativos):
		-- - Se todos sem documento: não remove (pode cadastrar).
		-- - Se há mais de um registro e mistura com/sem documento: remove só os sem documento na #espelho.
		------------------------------------------------------------
		drop table if exists #espelhos_homonimo_misto
		;with universo_homonimo as (
			select
				s.mtn_cd_pgto_periodo
				,s.mtn_cd_cliente_transportadora
				,s.mtn_cd_operacao
				,s.mtn_nome_motorista
				,isnull(s.mtn_cpf, N'') mtn_cpf
				,isnull(s.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) mtn_in_divisao
				,isnull(s.mtn_base_principal, N'') mtn_base_principal
			from
				#espelho s
			where
				s.mtn_in_excluido = 0

			union all

			select
				e.mtn_cd_pgto_periodo
				,e.mtn_cd_cliente_transportadora
				,e.mtn_cd_operacao
				,e.mtn_nome_motorista
				,isnull(e.mtn_cpf, N'') mtn_cpf
				,isnull(e.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) mtn_in_divisao
				,isnull(e.mtn_base_principal, N'') mtn_base_principal
			from
				tb_pag_espelhos e with(nolock)
			where
				e.mtn_in_excluido = 0
				and e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
				and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(@IdCliTransportadora, -1)
				and e.mtn_cd_operacao = @Operacao
		)
		select
			u.mtn_cd_pgto_periodo
			,u.mtn_cd_cliente_transportadora
			,u.mtn_cd_operacao
			,u.mtn_nome_motorista
			,case when u.mtn_in_divisao = 1 then u.mtn_base_principal else N'' end mtn_base_principal
			into #espelhos_homonimo_misto
		from
			universo_homonimo u
		group by
			u.mtn_cd_pgto_periodo
			,u.mtn_cd_cliente_transportadora
			,u.mtn_cd_operacao
			,u.mtn_nome_motorista
			,case when u.mtn_in_divisao = 1 then u.mtn_base_principal else N'' end
		having
			count(1) > 1
			and sum(case when nullif(ltrim(rtrim(isnull(u.mtn_cpf, N''))), N'') is null then 1 else 0 end) > 0
			and sum(case when nullif(ltrim(rtrim(isnull(u.mtn_cpf, N''))), N'') is not null then 1 else 0 end) > 0

		insert into tb_pag_espelhos_erros (pee_cd_periodo, pee_cd_cliente_transportadora, pee_cd_operacao, pee_cd_motorista, pee_nm_motorista, pee_base, pee_ds_erro, pee_dh_criacao)
		select
			h.mtn_cd_pgto_periodo
			,h.mtn_cd_cliente_transportadora
			,h.mtn_cd_operacao
			,e.mtn_cd_motorista
			,h.mtn_nome_motorista
			,case when isnull(e.mtn_in_divisao, 0) = 1 then h.mtn_base_principal else null end pee_base
			,'Homonimo: removida linha sem documento no contexto (mantidas apenas com CPF/CNPJ)' pee_ds_erro
			,getdate() pee_dh_criacao
		from
			#espelhos_homonimo_misto h
			join #espelho e on e.mtn_cd_pgto_periodo = h.mtn_cd_pgto_periodo
							and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(h.mtn_cd_cliente_transportadora, -1)
							and e.mtn_cd_operacao = h.mtn_cd_operacao
							and isnull(e.mtn_nome_motorista, N'') = isnull(h.mtn_nome_motorista, N'')
							and (
									isnull(e.mtn_in_divisao, 0) = 0
									or isnull(e.mtn_base_principal, N'') = isnull(h.mtn_base_principal, N'')
								)
							and nullif(ltrim(rtrim(isnull(e.mtn_cpf, N''))), N'') is null

		delete
			e
		from
			#espelho e
		where
			exists (
				select
					1
				from
					#espelhos_homonimo_misto h
				where
					e.mtn_cd_pgto_periodo = h.mtn_cd_pgto_periodo
					and isnull(e.mtn_cd_cliente_transportadora, -1) = isnull(h.mtn_cd_cliente_transportadora, -1)
					and e.mtn_cd_operacao = h.mtn_cd_operacao
					and isnull(e.mtn_nome_motorista, N'') = isnull(h.mtn_nome_motorista, N'')
					and (
							isnull(e.mtn_in_divisao, 0) = 0
							or isnull(e.mtn_base_principal, N'') = isnull(h.mtn_base_principal, N'')
						)
			)
			and nullif(ltrim(rtrim(isnull(e.mtn_cpf, N''))), N'') is null

		


		------------------------------------------------------------
		-- MERGE ESPELHOS
		------------------------------------------------------------
		merge tb_pag_espelhos target
        using (
			select
				e.mtn_cd_pgto_periodo
				,e.mtn_cd_cliente_transportadora
				,e.mtn_cd_operacao
				,e.mtn_cd_base
				,e.mtn_base_principal
				,e.mtn_cd_motorista
				,e.mtn_nome_motorista
				,e.mtn_driver_id
				,e.mtn_cd_status
				,e.mtn_vl_nfs
				,e.mtn_qt_rotas
				,e.mtn_cd_tipo_espelho
				,e.mtn_cod_cliente
				,e.mtn_dh_criacao
				,e.mtn_cd_usr_criacao
				,e.mtn_dh_modificacao
				,e.mtn_cd_usr_modificacao
				,e.mtn_in_excluido
				,e.mtn_cd_tipo_contrato
				,e.mtn_cpf
				,e.mtn_in_divisao
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
		
		) source
            on target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
			and target.mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
			and target.mtn_cd_operacao = source.mtn_cd_operacao
			and isnull(target.mtn_in_divisao, source.mtn_in_divisao) = source.mtn_in_divisao
			and (
					source.mtn_in_divisao = 0
					or isnull(target.mtn_base_principal, N'') = isnull(source.mtn_base_principal, N'')
				)
			and isnull(target.mtn_nome_motorista, N'') = isnull(source.mtn_nome_motorista, N'')
			and isnull(target.mtn_cpf, N'') = isnull(source.mtn_cpf, N'')
			and target.mtn_in_excluido = 0
        WHEN MATCHED AND target.mtn_cd_status IN (34, 228, 38, 1298) THEN --atualiza apenas espelhos em aberto
            UPDATE SET
                --target.mtn_vl_nfs						= source.mtn_vl_nfs, --comentado para não zerar os espelhos durante o processamento
                target.mtn_qt_rotas						= source.mtn_qt_rotas,
                target.mtn_dh_modificacao				= getdate(),
                target.mtn_cd_usr_modificacao			= @CodUsuario,
                target.mtn_cd_base						= source.mtn_cd_base,
                target.mtn_base_principal				= source.mtn_base_principal,
                target.mtn_nome_motorista				= source.mtn_nome_motorista,
                target.mtn_driver_id					= source.mtn_driver_id,
                target.mtn_cd_motorista					= COALESCE(source.mtn_cd_motorista, target.mtn_cd_motorista),
				target.mtn_cd_tipo_contrato				= source.mtn_cd_tipo_contrato,
				target.mtn_cpf							= source.mtn_cpf,
				target.mtn_in_divisao					= source.mtn_in_divisao,
				target.mtn_ds_NomeTitular				= source.mtn_ds_NomeTitular,
				target.mtn_ds_Banco						= source.mtn_ds_Banco,
				target.mtn_ds_CpfTitular				= source.mtn_ds_CpfTitular,
				target.mtn_ds_CnpjTitular				= source.mtn_ds_CnpjTitular,
				target.mtn_ds_Agencia					= source.mtn_ds_Agencia,
				target.mtn_ds_Conta						= source.mtn_ds_Conta,
				target.mtn_ds_TipoConta					= source.mtn_ds_TipoConta,
				target.mtn_ds_TipoChavePix				= source.mtn_ds_TipoChavePix,
				target.mtn_ds_ChavePix					= source.mtn_ds_ChavePix,
				target.mtn_ds_CnpjEmpresa				= source.mtn_ds_CnpjEmpresa,
				target.mtn_ds_RazaoSocial				= source.mtn_ds_RazaoSocial,
				target.mtn_ds_NomeFantasia				= source.mtn_ds_NomeFantasia,
				--ajuste para atualizar somente quando a data não for atualizada manualmente
				target.mtn_dt_prevista_pagamento		= case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end
        WHEN NOT MATCHED BY TARGET THEN
            INSERT
            (
                mtn_cd_motorista,
                mtn_nome_motorista,
                mtn_cd_pgto_periodo,
                mtn_cd_status,
                mtn_vl_nfs,
                mtn_ds_link_nfs,
                mtn_dt_prazo_contestacao,
                mtn_dh_criacao,
                mtn_cd_usr_criacao,
                mtn_dh_modificacao,
                mtn_cd_usr_modificacao,
                mtn_in_excluido,
                mtn_cod_cliente,
                mtn_qt_rotas,
                mtn_cd_tipo_espelho,
                mtn_cd_cliente_transportadora,
                mtn_cd_base,
                mtn_base_principal,
                mtn_cd_operacao,
                mtn_driver_id,
				mtn_cd_tipo_contrato,
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
				mtn_cpf,
				mtn_in_divisao,
				mtn_dt_prevista_pagamento
            )
            VALUES
            (
                source.mtn_cd_motorista,
                source.mtn_nome_motorista,
                source.mtn_cd_pgto_periodo,
                source.mtn_cd_status,
                source.mtn_vl_nfs,
                NULL,
                isnull(@DataLimiteReanalise,dateadd(day, 30, @DataFinal)),
                source.mtn_dh_criacao,
                source.mtn_cd_usr_criacao,
                source.mtn_dh_modificacao,
                source.mtn_cd_usr_modificacao,
                0,
                source.mtn_cod_cliente,
                source.mtn_qt_rotas,
                source.mtn_cd_tipo_espelho,
                source.mtn_cd_cliente_transportadora,
                source.mtn_cd_base,
                source.mtn_base_principal,
                source.mtn_cd_operacao,
                source.mtn_driver_id,
				source.mtn_cd_tipo_contrato,
				source.mtn_ds_Banco,
				source.mtn_ds_NomeTitular,
				source.mtn_ds_CpfTitular,
				source.mtn_ds_CnpjTitular,
				source.mtn_ds_Agencia,
				source.mtn_ds_Conta,
				source.mtn_ds_TipoConta,
				source.mtn_ds_TipoChavePix,
				source.mtn_ds_ChavePix,
				source.mtn_ds_CnpjEmpresa,
				source.mtn_ds_RazaoSocial,
				source.mtn_ds_NomeFantasia,
				source.mtn_cpf,
				source.mtn_in_divisao,
				source.mtn_dt_prevista_pagamento
            );


		------------------------------------------------------------
		-- ATUALIZA QUAL ESPELHO A ROTA PERTENCE
		------------------------------------------------------------
		update
			r
		set
			r.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			,r.ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs
		from
			#rotas r
			join tb_pag_espelhos e with(nolock) on r.ppr_cd_periodo = e.mtn_cd_pgto_periodo
												and r.ppr_cd_cliente_transportadora = e.mtn_cd_cliente_transportadora
												and r.ppr_cd_operacao = e.mtn_cd_operacao
												and (
														isnull(e.mtn_in_divisao, case when @ParamDivisaoEspelho = 'true' then 1 else 0 end) = 0
														or r.svc_espelho = e.mtn_base_principal
													)
												and isnull(r.ppr_nome_motorista, N'') = isnull(e.mtn_nome_motorista, N'')
												and isnull(r.ppr_cpf, N'') = isnull(e.mtn_cpf, N'')
												and e.mtn_in_excluido = 0
												and e.mtn_cd_status IN (34, 228, 38, 1298)

		
		------------------------------------------------------------
		-- EXCLUI ROTAS DUPLICADAS
		------------------------------------------------------------
		--remove erros do último processamento
		delete
			tb_pgto_periodo_rota_erro
		where
			pre_cd_periodo = @CodPeriodoPagamento
			and pre_cd_cliente_transportadora = @IdCliTransportadora
			and pre_cd_operacao = @Operacao
			

		--verifica se existe rotas duplicadas
		drop table if exists #rotas_duplicadas
		select
			ppr_cd_periodo
			,ppr_cd_cliente_transportadora
			,ppr_cd_operacao
			,ppr_cd_rota
			into #rotas_duplicadas
		from
			#rotas
		group by
			ppr_cd_periodo
			,ppr_cd_cliente_transportadora
			,ppr_cd_operacao
			,ppr_cd_rota
		having
			count(1) > 1

		
		--insere na tabela de erro
		insert into tb_pgto_periodo_rota_erro (pre_cd_periodo, pre_cd_cliente_transportadora, pre_cd_operacao, pre_cd_rota, pre_base, pre_ds_erro, pre_dh_criacao)
		select
			d.ppr_cd_periodo
			,d.ppr_cd_cliente_transportadora
			,d.ppr_cd_operacao
			,d.ppr_cd_rota
			,r.ppr_base_principal
			,'Rotas duplicadas' pee_ds_erro
			,getdate() pee_dh_criacao
		from
			#rotas_duplicadas d
			join #rotas r on d.ppr_cd_rota = r.ppr_cd_rota


		--remove rotas duplicados
		delete
			r
		from
			#rotas r
			join #rotas_duplicadas r2 on r.ppr_cd_rota = r2.ppr_cd_rota

		
		------------------------------------------------------------
		-- MERGE PAGAMENTO PERIODO ROTA
		------------------------------------------------------------
		merge tb_pgto_periodo_rota target
        using (select 
				* 
				from 
					#rotas 
				where 
					ppr_cd_motorista_nfs is not null
				) source
            on target.ppr_cd_periodo = source.ppr_cd_periodo
			and target.ppr_cd_rota = source.ppr_cd_rota 
			and target.ppr_cd_tipo_pgto = 1362
		WHEN MATCHED THEN UPDATE SET
			ppr_ds_placa = source.ppr_ds_placa,
			ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo,
			ppr_ds_ciclo = source.ppr_ds_ciclo,
			ppr_qt_faixa = source.ppr_qt_faixa,
			ppr_in_area_risco = source.ppr_in_area_risco,
			ppr_in_ajudante = source.ppr_in_ajudante,
			ppr_in_fer = source.ppr_in_fer,
			ppr_in_dom = source.ppr_in_dom,
			ppr_in_dom_fer = source.ppr_in_dom_fer,
			ppr_dh_modificacao = getdate(),
			ppr_cd_usr_modificacao = source.ppr_cd_usr_modificacao,
			ppr_cd_motorista = source.ppr_cd_motorista,
			ppr_qt_pacotes_entregues = source.ppr_qt_pacotes_entregues,
			ppr_qt_pacotes_pendentes = source.ppr_qt_pacotes_pendentes,
			ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
			ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
			ppr_usou_app = source.ppr_usou_app,
			ppr_data_referencia = source.ppr_data_referencia,
			ppr_base_principal = source.ppr_base_principal,
			ppr_base_calculo = source.ppr_base_calculo,
			ppr_tipo_rota = source.ppr_tipo_rota,
			ppr_nome_motorista = source.ppr_nome_motorista,
			ppr_nm_cidade = source.ppr_nm_cidade,
			ppr_total_km = source.ppr_total_km,
			ppr_qtd_enderecos_visitados = source.ppr_qtd_enderecos_visitados,
			ppr_per_endereco_nao_visitado = source.ppr_per_endereco_nao_visitado,
			ppr_qt_pontos = source.ppr_qt_pontos,
			ppr_qt_paradas  = source.ppr_qt_paradas,
			ppr_in_sab = source.ppr_in_sab,
			ppr_qt_enderecos_nao_visitados = source.ppr_qt_enderecos_nao_visitados,
			ppr_vl_success_delivery = source.ppr_vl_success_delivery,
			ppr_in_ambulancia = source.ppr_in_ambulancia,
			ppr_in_ambulancia_aprovada = source.ppr_in_ambulancia_aprovada,
			ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto,
			ppr_vl_insucessos = source.ppr_vl_insucessos,
			ppr_driver_id = source.ppr_driver_id,
			ppr_nm_pgto = source.ppr_nm_pgto,
			ppr_qt_pacotes = source.ppr_qt_pacotes,
			ppr_nm_origem_km = source.ppr_nm_origem_km,
			ppr_in_zerar_rota = source.ppr_in_zerar_rota,
			ppr_motivo_rota_zerada = source.ppr_motivo_rota_zerada,
			ppr_in_rota_saca = source.ppr_in_rota_saca

		WHEN NOT MATCHED BY TARGET THEN
			INSERT 
			(
				ppr_cd_periodo,
				ppr_cd_rota,
				ppr_ds_placa,
				ppr_ds_tipo_veiculo,
				ppr_ds_ciclo,
				ppr_qt_pacotes,
				ppr_qt_faixa,
				ppr_in_area_risco,
				ppr_in_ajudante,
				ppr_in_fer,
				ppr_in_dom,
				ppr_in_dom_fer,
				ppr_in_sab,
				ppr_dh_criacao,
				ppr_cd_usr_criacao,
				ppr_dh_modificacao,
				ppr_cd_usr_modificacao,
				ppr_in_ativo,
				ppr_in_excluido,
				ppr_cd_motorista,
				ppr_qt_pacotes_entregues,
				ppr_qt_pacotes_pendentes,
				ppr_cd_motorista_nfs,
				ppr_cd_pgto_espelho,
				ppr_usou_app,
				ppr_data_referencia,
				ppr_base_principal,
				ppr_base_calculo,
				ppr_tipo_rota,
				ppr_nome_motorista,
				ppr_nm_cidade,
				ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
				ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento
				ppr_total_km,
				ppr_qtd_enderecos_visitados,
				ppr_per_endereco_nao_visitado,
				ppr_qt_pontos,
				ppr_qt_paradas,
				ppr_qt_enderecos_nao_visitados,
				ppr_vl_success_delivery,
				ppr_in_ambulancia,
				ppr_in_ambulancia_aprovada,
				ppr_cd_tipo_pgto,
				ppr_vl_insucessos,
				ppr_driver_id,
				ppr_in_calcular_adicional,
				ppr_nm_origem_km,
				ppr_in_zerar_rota,
				ppr_motivo_rota_zerada,
				ppr_in_rota_saca
		)
		VALUES 
		(
			source.ppr_cd_periodo,
			source.ppr_cd_rota,
			source.ppr_ds_placa,
			source.ppr_ds_tipo_veiculo,
			source.ppr_ds_ciclo,
			source.ppr_qt_pacotes,
			source.ppr_qt_faixa,
			source.ppr_in_area_risco,
			source.ppr_in_ajudante,
			source.ppr_in_fer,
			source.ppr_in_dom,
			source.ppr_in_dom_fer,
			source.ppr_in_sab,
			source.ppr_dh_criacao,
			source.ppr_cd_usr_criacao,
			source.ppr_dh_modificacao,
			source.ppr_cd_usr_modificacao,
			source.ppr_in_ativo,
			source.ppr_in_excluido,
			source.ppr_cd_motorista,
			source.ppr_qt_pacotes_entregues,
			source.ppr_qt_pacotes_pendentes,
			source.ppr_cd_motorista_nfs,
			source.ppr_cd_pgto_espelho,
			source.ppr_usou_app,
			source.ppr_data_referencia,
			source.ppr_base_principal,
			source.ppr_base_calculo,
			source.ppr_tipo_rota,
			source.ppr_nome_motorista,
			source.ppr_nm_cidade,
			source.ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
			source.ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento
			source.ppr_total_km,
			source.ppr_qtd_enderecos_visitados,
			source.ppr_per_endereco_nao_visitado,
			source.ppr_qt_pontos,
			source.ppr_qt_paradas,
			source.ppr_qt_enderecos_nao_visitados,
			source.ppr_vl_success_delivery,
			source.ppr_in_ambulancia,
			source.ppr_in_ambulancia_aprovada,
			source.ppr_cd_tipo_pgto,
			source.ppr_vl_insucessos,
			source.ppr_driver_id,
			source.ppr_in_calcular_adicional,
			source.ppr_nm_origem_km,
			source.ppr_in_zerar_rota,
			source.ppr_motivo_rota_zerada,
			source.ppr_in_rota_saca
		);


		------------------------------------------------------------
		-- EXCLUI ROTAS QUE ENTRAM UMA VEZ NO PERÍODO MAS NÃO APARECEM MAIS (POR EXEMPLO POR MUDANÇA DE DATA)
		------------------------------------------------------------
		--só executa se tiver rodando o período todo
		if @IdRota is null and @CodEspelho is null
		begin
			update
				p
			set
				p.ppr_in_excluido = 1
			from
				tb_pgto_periodo_rota p
				join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
											and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
											and e.mtn_cd_operacao = @Operacao
				left join #rotas r on p.ppr_cd_rota = r.ppr_cd_rota
				left join #rotas_duplicadas r2 on p.ppr_cd_rota = r2.ppr_cd_rota
			where
				p.ppr_cd_periodo = @CodPeriodoPagamento
				and p.ppr_in_excluido = 0
				and p.ppr_cd_tipo_pgto = 1362
				and e.mtn_cd_status in (34,228,38,1298)
				and r.ppr_cd_rota is null
				and r2.ppr_cd_rota is null
		end

	end --fim do if que verifica se o período pode sofrer alterações

end --fim procedure

GO
