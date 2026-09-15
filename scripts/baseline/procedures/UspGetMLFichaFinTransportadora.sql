-- ============================================================
-- BASELINE: dbo.UspGetMLFichaFinTransportadora
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetMLFichaFinTransportadora]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[UspGetMLFichaFinTransportadora] 
(
	@Transportadora int,
	@Rota VARCHAR(50)
)as

--'KM Rodado'	[Distância Percorrida]
--    'Link KM'	[Link da Distância]
--    'Ciclo'	[Período do Dia]
--    'Tipo de veículo'	[Tipo do Veículo]
--    'Base'	[Localização Base]
--    'Pacotes'	[Quantidade de Pacotes]
--    'Pontos'	[Quantidade de Pontos]
--    'Paradas'	[Quantidade de Paradas]
--    'Pacotes Entregues'	[Pacotes Entregues]
--    'Ajudante'	[Recebimento do Ajudante]
    --'Área de risco'	[Receb. Área de Risco]
    --'Data'	[Data da Rota]

--declare	@Transportadora int = 1,
--	@Rota int = 127844655


SELECT  
		[IdTransportadora]
  --    ,[Ano]
  --    ,[Mes]
  --    ,[Quinzena]
      ,[IdRota]
      ,[DataReferencia]								as [Data da Rota]
	  ,HoraInicio									as [Hora Incio da Rota]
      ,[ServiceCenter]
      ,[ServiceCenterPreFatura]
  --    ,[XPT]
  --    ,[Base]
  --    ,[Placa]
  --    ,[Motorista]
  --    ,[Destino]
  --    ,[Cluster]
      ,[TipoVeiculo]								as [Tipo do Veículo]
	  ,TipoVeiculoPreFatura								as [Tipo do Veículo Pre Fatura] 
      ,[CicloPM]									as [Período do Dia]
      ,CicloPMFatura								as [Período do Dia Pre fatura]
      ,[DomingoOuFeriado]							as [Domingo ou feriado]
  --    ,[TipoPagamentoFrete]
      ,[TipoPagamentoAdicional]						as [Tipo de Pagamento Adicional]
      ,[QuantidadePacotes]							as [Quantidade de Pacotes]
      ,[PacotesEntregues]							as [Pacotes Entregues]
  --    ,[Insucessos]
  --    ,[Pendentes]
      ,[QuantidadeParadas]							as [Quantidade de Paradas]
      ,[QuantidadePontos]							as [Quantidade de Pontos]

  --    ,[PgtoSaida]
  --    ,[PgtoSaidaKmMotorista]
  --    ,[PgtoSaidaKm0a100]

      ,FretePreFatura /*[TotalPrefatura]*/ /*[PgtoSaidaKmPreFatura] alteração Vitor Reunião	*/					as [Valor DA KM da pré-fatura]
	  ,FretePreFatura-nullif([RecebMeli],0) as Diferenca_ValorDA_KMPreFatura
	  --,0.0 as Diferenca_ValorDA_KMPreFatura
      ,isnull(FretePreFatura/nullif([RecebMeli],0),0) as Perc_ValorDA_KMPreFatura

  --    ,[PgtoParadas]
  --    ,[PgtoRisco]
  --    ,[PgtoAjudante]

      ,isnull([PgtoLancamentoManual]	  ,0)		as [Valor de Lançamentos Manuais]	
	  
  --    ,isnull([MotivoPgtoLancamentoManual],0) as [MotivoPgtoLancamentoManual]
  --    ,[PgtoValorManual]
  --    ,[PgtoTotal]
  --    ,[Adicional]

      ,cast([KmColetado] as decimal(10,2))									as [KM Rodado]
      ,[LinkMapa]									as [Link da Mapa]
      ,[FaixaKm]									as [Faixa kM (DA)]
	  ,[FaixaPreFatura]								as [Faixa kM (Pré Fatura)]
      ,RecebimentoBase								as [Recebimento Base]
	  ,[RecebMeli]									as [Valor DA]

	  ,[TotalPrefatura]								as [Valor Pré-Fatura]
	  ,[TotalPrefatura]-nullif([RecebMeli],0)   	as Diferenca_ValorDA_PreFatura
	  ,isnull([TotalPrefatura]/nullif([RecebMeli],0),0)		as perc_ValorDA_PreFatura

      ,[RecebimentoParadas]							as [Adicional pontos/paradas]
      ,[RecebimentoDomingo]							as [Adicional domingo ou feriado] 
      ,[RecebimentoRisco]							as [Adicional Área de Risco]

      ,case when [RecebimentoRisco] > 0 then 'Sim' else 'Não' end as [Área de Risco]
      ,[RecebimentoAjudante]					as [Adicional Ajudante]
      ,case when [RecebimentoAjudante] > 0 then 'Sim' else 'Não' end as [Ajudante]
      ,[Pedagio] as [Valor do Pedágio]

  --    ,[RecebimentoLancamentoManual]
  --    ,[RecebimentoValorManual]
  --    ,[ReceitaTotal]



  --    ,[MaiorValor]
  --    ,[ValorFinal]
  --    ,[RecebMeli0a100]
  --    ,[FretePreFatura]
  --    ,[RecebimentoDomingoPrefatura]

	    ,DescontoCicloPM AS [Desconto PM]
		,UsouAPP [Usou o App]
		,ValorAdicional0_60			as [Valor Adicional 0 até 60]
		,ValorAdicional61_90		as [Valor Adicional 61 até 90]
		,ValorAdicionalAcima_90		as [Valor Adicional acima de 90]
		,NULL [Versao Do APP]

		,fin.TxAdicionalDomingo  [Taxa Adicional domingo ou feriado]
		,fin.TxAdicionalCiclo_pm [Taxa Adicional desconto PM]
		,fin.TxAdicionalAjudante [Taxa Adicional Ajudante]
		,fin.TxAdicionalRisco 	 [Taxa Adicional área de risco]
		,fin.observacao			as Observacao
		,fin.regiao				as Regiao
		,fin.RiscoV2			as RiscoV2

	  ,case when isnull(fin.totalprefatura,0) = 0 then 1 else 0 end as Alarme_sem_pre_fatura_cad

	  ,case 
				when RecebimentoBase = 0
					then 1 
				else 0 end Alarme_sem_base_frete_trans_cad	 

	  ,case 
			when [TipoPagamentoAdicional] is not null and [RecebimentoParadas]+[RecebimentoDomingo]+[RecebimentoRisco]+[RecebimentoAjudante] = 0
					then 1 	
			else 0
			end Alarme_sem_base_adicional_trans_cad	 	
	  ,case 
				when UsouAPP = 'Não'
					then 1 
				else 0 end Alarme_sem_KM_apurado_sem_uso_do_App
	  ,case 
		when IdRota = 118251981 
			then 1 
		else case 
				when IdRota = 119900747 
					then 1 
				else 0 end
		end Alarme_sem_KM_apurado_com_uso_do_App

	  ,case when [RecebMeli] <> FretePreFatura then 1 else 0 end Alarme_diferenca_da_pre_pfatura_AMARELO
	  ,case when [RecebMeli] = FretePreFatura then 1 else 0 end Alarme_resultado_da_igual_prefatura_VERDE
	  
	  


FROM [vw_resultado_financeiro] fin

inner join tb_clientes as clientes
on fin.IdTransportadora = clientes.cli_cd_codigo_cliente



where 1=1
AND fin.IdRota = @Rota
and clientes.cli_cd_codigo_cliente = @Transportadora


GO
