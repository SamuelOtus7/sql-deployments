/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpq9ny
  Autor        : Devin
  Data         : 2026-09-30
  Descrição    : Parametriza dbo.UspMLAtualizaIndicadoresRota:
                 - Novos parâmetros @DataInicial / @DataFinal (intervalo de data
                   dinâmico). Se não informados, comportamento continua IDÊNTICO
                   ao atual (janela de @QtdeDiasRetroativo dias).
                 - @IdTransportadora passa a funcionar sozinho (filtra a
                   transportadora dentro do intervalo). Antes só fazia efeito
                   junto com @IdRota.
                 NENHUMA regra, cálculo, join ou filtro de negócio foi alterado -
                 somente o trecho de filtro de parâmetros, mantendo a mesma
                 estrutura original.
  Rollback     : scripts/rollback/2026/09/017_rollback_CU-86akpq9ny_parametros_indicadores_rota.sql
  Objetos      : dbo.UspMLAtualizaIndicadoresRota
  Dependências : dbo.tb_ml_pacotes, dbo.tb_ml_rotas, dbo.tb_ml_traducoes,
                 dbo.tb_clientes, dbo.tb_ml_status_entrega, dbo.tb_ml_pnr;
                 chamada por dbo.UspMLAtualizaRotasRetroativo e pelo job
                 "DriveAnalytics - Carrega Pacotes - Instance 01"
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

	CREATE OR ALTER PROCEDURE [dbo].[UspMLAtualizaIndicadoresRota] (
		@QtdeDiasRetroativo int = 1--5 alterado para 1 dia por conta de rodar de minuto em minuto -- Matheus 20/08/25
		,@IdRota int = null
		,@IdTransportadora int = null
		,@DataInicial date = null
		,@DataFinal date = null
	)
	as
	begin

		SET NOCOUNT ON;

		-- se datas nao informadas, mantem o comportamento atual (retroativo)
		declare @dtIni date = isnull(@DataInicial, dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date)))
		declare @dtFim date = @DataFinal   -- null = sem teto (igual hoje)

		select 
			distinct 
			p.IdRota,
			p.IdRotaOrigem,
			p.DataReferencia,
			p.IdTransportadora
			into #pacotes_ambulancia
		from 
			tb_ml_pacotes p with(nolock) 
		where 
			p.Excluido = 0
			and (@IdTransportadora is null or p.IdTransportadora = @IdTransportadora)
			and (
					(@Idrota is null and p.DataReferencia >= @dtIni and (@dtFim is null or p.DataReferencia <= @dtFim))
					or
					(@IdRota is not null and p.IdRota = @Idrota)
				)
			and p.IdRotaOrigem is not null

		select
			r2.IdRota,
			r2.IdTransportadora,
			r2.DataReferencia,
			r2.OrigemSaida

			into #rotas_ambulancia

		from
			tb_ml_rotas r2 with(nolock)
		where
			r2.Excluido = 0 
			and isnull(r2.OrigemSaida,'') <> ''
			and (@IdTransportadora is null or r2.IdTransportadora = @IdTransportadora)
			and (
					(@Idrota is null and r2.DataReferencia >= @dtIni and (@dtFim is null or r2.DataReferencia <= @dtFim))
					or
					(@IdRota is not null and r2.IdRota = @Idrota)
				)


		update
			r
		set
			r.QuantidadePontos = isnull(p.QuantidadePontos,0),
			r.QuantidadeParadas = isnull(p.QuantidadeParadas,0),
			r.DataUltimaAtualizacaoPacote = p.UltimaAtualizacao,
			r.DataPrimeiraEntrega = p.PrimeiraEntrega,
			r.DataUltimaEntrega = p.DataUltimaEntrega,
			r.StatusPrimeiraEntrega = p2.StatusPrimeiraEntrega,
			r.StatusSegundaEntrega = p2.StatusSegundaEntrega,
			r.QuantidadeReclamacoes = isnull(p.QuantidadeReclamacoes,0),
			--r.Ambulancia = case when (r.PacotesEntregues = r.QuantidadeAmbulancia or r.PacotesRecebidos = r.TotalPacotes) and TotalPacotes > 0 and PacotesEntregues > 0 then 1 else 0 end,
			--r.Ambulancia = case when r.PacotesEntregues = r.PacotesRecebidos and TotalPacotes > 0 and PacotesEntregues > 0 then 1 else 0 end,
			r.Ambulancia = case when QuantidadeAmbulancia > 0 then 1 else 0 end,
			r.OrigemSaidaAmbulancia = ambulancia.OrigemSaida,
			r.EnderecosVisitados = isnull(p.EnderecosVisitados,0)
		from
			tb_ml_rotas r
			left join (
				select
					p.IdTransportadora,
					p.IdRota,
					p.DataReferencia,
					max(pontos.QuantidadePontosParada) QuantidadePontos,
					count(distinct p.IdParada) QuantidadeParadas,
					sum(p.QuantidadeReclamacoes) QuantidadeReclamacoes,
					max(p.DataAtualizacao) UltimaAtualizacao,
					min(case when p.StatusEntrega = 'delivered' then p.DataHoraEntrega end) PrimeiraEntrega,
					max(case when p.StatusEntrega = 'delivered' then p.DataHoraEntrega end) DataUltimaEntrega,
					sum(case when st.se_ds_classificacao in ('Visitado') then 1 else 0 end) EnderecosVisitados
				from
					tb_ml_pacotes p with(nolock)
					left join tb_ml_traducoes t3 on p.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus'
					left join tb_clientes cli with(nolock) on p.IdTransportadora = cli.cli_id_logistics
					left join tb_ml_status_entrega as st on t3.tds_ds_traducao = st.se_ds_status_entrega and st.TenantID = cli.cli_cd_codigo_cliente
					
					left join (
						select
							IdTransportadora,
							IdRota,
							DataReferencia,
							sum(QuantidadePontosParada) QuantidadePontosParada
						from
							(
								select
									IdTransportadora,
									IdRota,
									DataReferencia,
									IdParada,
									max(QuantidadePontosParada) QuantidadePontosParada
								from
									tb_ml_pacotes p with(nolock)
								where
									Excluido = 0
									and (isnull(p.SubStatus,'') not in('transferred')
										 or isnull(p.SubStatus,'') not in('missing') and p.statusparada = 'incomplete')
									and (@IdTransportadora is null or p.IdTransportadora = @IdTransportadora)
									and (
										(@Idrota is null and p.DataReferencia >= @dtIni and (@dtFim is null or p.DataReferencia <= @dtFim))
										or
										(@IdRota is not null and p.IdRota = @Idrota)
									)
								group by
									IdTransportadora,
									IdRota,
									DataReferencia,
									IdParada
							) p
					

						group by
							IdTransportadora,
							IdRota,
							DataReferencia
					) pontos on p.IdTransportadora = pontos.IdTransportadora and p.IdRota = pontos.IdRota 
					--and p.DataReferencia = pontos.DataReferencia
				where
					p.Excluido = 0
					and (@IdTransportadora is null or p.IdTransportadora = @IdTransportadora)
					and (
						(@Idrota is null and p.DataReferencia >= @dtIni and (@dtFim is null or p.DataReferencia <= @dtFim))
						or
						(@IdRota is not null and p.IdRota = @Idrota)
					)
					and (isnull(p.SubStatus,'') not in('transferred')
							 or isnull(p.SubStatus,'') not in('missing') and p.StatusParada = 'incomplete')

				group by
					p.IdTransportadora,
					p.IdRota,
					p.DataReferencia
			) p on r.IdTransportadora = p.IdTransportadora and r.IdRota = p.IdRota 
			--and r.DataReferencia = p.DataReferencia
			left join (
				select
					IdTransportadora,
					IdRota,
					DataReferencia,
					max(case when Ordem = 1 then StatusEntrega else null end) as StatusPrimeiraEntrega,
					max(case when Ordem = 2 then StatusEntrega else null end) as StatusSegundaEntrega
				from
					(
						select
							IdTransportadora,
							IdRota,
							DataReferencia,
							ROW_NUMBER() over(partition by IdTransportadora, IdRota, DataReferencia order by DataHoraEntrega, IdPacote) as Ordem,
							t.tds_ds_traducao StatusEntrega
						from
							tb_ml_pacotes p with(nolock)
							left join tb_ml_traducoes t with(nolock) on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
						where
							Excluido = 0
							and (@IdTransportadora is null or p.IdTransportadora = @IdTransportadora)
							and (
								(@Idrota is null and p.DataReferencia >= @dtIni and (@dtFim is null or p.DataReferencia <= @dtFim))
								or
								(@IdRota is not null and p.IdRota = @Idrota)
							)
							and DataHoraEntrega >= DataReferencia 
					) base
				where
					Ordem in (1,2)
				group by
					IdTransportadora,
					IdRota,
					DataReferencia
			) p2 on r.IdTransportadora = p2.IdTransportadora and r.IdRota = p2.IdRota
			--and r.DataReferencia = p2.DataReferencia
			left join (
				select 
					distinct 
					p.IdRota,
					p.DataReferencia,
					p.IdTransportadora,
					r2.OrigemSaida 
				from 
					#pacotes_ambulancia p
					join #rotas_ambulancia r2 with(nolock) on r2.IdRota = p.IdRotaOrigem and r2.IdTransportadora = p.IdTransportadora 
					--and r2.DataReferencia = p.DataReferencia
			) ambulancia on r.IdRota = ambulancia.IdRota and r.IdTransportadora = ambulancia.IdTransportadora
			--and r.DataReferencia = ambulancia.DataReferencia 
		where
			(@IdTransportadora is null or r.IdTransportadora = @IdTransportadora)
			and (
				(@Idrota is null and r.DataReferencia >= @dtIni and (@dtFim is null or r.DataReferencia <= @dtFim))
				or
				(@IdRota is not null and r.IdRota = @Idrota)
			)

		
		--quando é ambulancia, no mercado livre não vem a informação de xpt
		--faz a atualização buscando a origemsaida da rota de origem
		update
			tb_ml_rotas
		set
			OrigemSaida = OrigemSaidaAmbulancia
		where
			(@IdTransportadora is null or IdTransportadora = @IdTransportadora)
			and (
				(@Idrota is null and DataReferencia >= @dtIni and (@dtFim is null or DataReferencia <= @dtFim))
				or
				(@IdRota is not null and IdRota = @Idrota)
			)
			and Ambulancia = 1
			and isnull(OrigemSaida,'') = ''
			and isnull(OrigemSaidaAmbulancia,'') <> ''


		-- Atualiza coluna QuantidadePnr
		DROP TABLE IF EXISTS #UPD_PRN

		SELECT	ROT.IdRota,
				COUNT(1)		AS QuantidadePnr
		INTO #UPD_PRN
		FROM tb_ml_rotas		 AS ROT (NOLOCK)
		INNER JOIN tb_ml_pacotes AS PAC (NOLOCK) ON PAC.idtransportadora = ROT.IdTransportadora
												AND PAC.idrota			 = ROT.idrota
												--AND PAC.datareferencia	 = ROT.DataReferencia
		INNER JOIN tb_ml_pnr	 AS PNR (NOLOCK) ON PNR.idpacote		 = PAC.idpacote 
												AND PNR.motorista		 = ROT.nomemotorista
 
		WHERE ROT.Excluido = 0
			AND PAC.excluido = 0
			AND isnull(PAC.SubStatus,'') <> 'transferred'
			and (@IdTransportadora is null or ROT.IdTransportadora = @IdTransportadora)
			and (
					(@Idrota is null and ROT.DataReferencia >= @dtIni and (@dtFim is null or ROT.DataReferencia <= @dtFim))
					or
					(@IdRota is not null and ROT.IdRota = @Idrota)
				)
		GROUP BY ROT.IdRota

		UPDATE ROT
		SET QuantidadePnr = UPD.QuantidadePnr
		FROM tb_ml_rotas	AS ROT
		INNER JOIN #UPD_PRN AS UPD ON UPD.IdRota = ROT.IdRota
		WHERE UPD.IdRota IS NOT NULL

	end

	PRINT 'SUCESSO: UspMLAtualizaIndicadoresRota alterada com sucesso.';

END TRY
BEGIN CATCH
	PRINT 'ERRO: ' + ERROR_MESSAGE();
	PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
	PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

	THROW;
END CATCH
