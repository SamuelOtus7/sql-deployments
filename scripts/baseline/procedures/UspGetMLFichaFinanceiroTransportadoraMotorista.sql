-- ============================================================
-- BASELINE: dbo.UspGetMLFichaFinanceiroTransportadoraMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetMLFichaFinanceiroTransportadoraMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		   
CREATE procedure [dbo].[UspGetMLFichaFinanceiroTransportadoraMotorista] 
(
	@Transportadora int 
	--@Rota varchar(50)
	,@Ano	  int
	,@Mes	  int
	,@Quinzena int
	,@svc varchar(max)
) as


--declare	@Transportadora int = 2087146923
--	--@Rota varchar(50)
--	,@Ano	  int		= 2024
--	,@Mes	  int		= 05
--	,@Quinzena int		= 2
--	,@svc varchar(max)	= 'SDF2'

--DECLARE @Transportadoraid INT =  (SELECT cli_cd_codigo_cliente  FROM tb_clientes WHERE cli_id_logistics = 2087146923 AND cli_cd_codigo_cliente <> 7)

--esta rpocedure alimenta a tela financeiro bravox


-- 	----'KM Rodado'	[Distância Percorrida]
-- 	----    'Link KM'	[Link da Distância]
-- 	----    'Ciclo'	[Período do Dia]
-- 	----    'Tipo de veículo'	[Tipo do Veículo]
-- 	----    'Base'	[Localização Base]
-- 	----    'Pacotes'	[Quantidade de Pacotes]
-- 	----    'Pontos'	[Quantidade de Pontos]
-- 	----    'Paradas'	[Quantidade de Paradas]
-- 	----    'Pacotes Entregues'	[Pacotes Entregues]
-- 	----    'Ajudante'	[Recebimento do Ajudante]
-- 	----    'Área de risco'	[Receb. Área de Risco]
-- 	----    'Data'	[Data da Rota]




SELECT  distinct 
	     cast(fin.[Ano]		 as int) as [Ano]		 
	    ,cast(fin.[Mes]		 as int) as [Mes]		 
	    ,cast(fin.[Quinzena] as int) as [Quinzena] 
	    ,cast(isnull(tbinsert.ID,fin.[IdRota]) as varchar(50)) as ID
	    ,cast(fin.[DataReferencia] as date) as Data
		,cast(isnull(tbinsert.[Hora Incio],fin.HoraInicio) as varchar(50)) as [Hora Incio]
	    ,cast(isnull(tbinsert.[Service Center],fin.[ServiceCenter])  as varchar(50))	as [Service Center]

	    ,cast(fin.[Placa] AS VARCHAR(10)) AS [Placa]

	    ,[Motorista]					-- campos da bravox
	    ,tbinsert.[Tipo de Contrato]				-- campos da bravox
	    ,tbinsert.[Prazo]					-- campos da bravox
	    ,tbinsert.[Tipo de rota]			-- campos da bravox --Tipo de contrato?

	    ,fin.[Cluster]
	    ,isnull(tbinsert.Categoria,fin.[TipoVeiculo])	as [Categoria] --[Tipo do Veículo]

	    ,isnull(tbinsert.Ciclo,[CicloPM])				as [Ciclo]

	    ,[QuantidadeParadas]							as [Quantidade de Paradas]

	    ,isnull(tbinsert.[Valor Saida] ,fin.[PgtoSaida])									as [Valor Saida]

	    , case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end								as [Valor Parada]
	    
		,case when tbinsert.[Tipo de rota] = 'Dividida' 
				then isnull(  tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end	 ,fin.[PgtoTotal] ) / 2 
				else isnull(  tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end	 ,fin.[PgtoTotal] ) end as [Total] --é esse campo mesmo? 

	    ,isnull(tbinsert.KM,fin.[KmColetadoPagamento])			as [KM]

	  , CAST(ISNULL( tbinsert.faixakm , fin.[FaixaKmPagamento]) AS varchar(10)) AS [Faixa de kM]

		,tbinsert.[Motorista recebedor]
		,tbinsert.[Motorista recebedor 2]
		,tbinsert.[Valores Extras]
		,tbinsert.[Valor de apoio]
		,tbinsert.[OBS Valor de apoio]
		,tbinsert.[Valor Pedágio]
		,tbinsert.[OBS Valor Pedágio]
		,tbinsert.[Valor Desconto]
		,tbinsert.[OBS Valor Desconto]
		,tbinsert.[Valor Extra]
		,tbinsert.[OBS Valor Extra]
		,tbinsert.ValorApoio_mt_apoio		
		,tbinsert.OBSValordeapoio_mt_apoio 
		,tbinsert.ValorPedágio_mt_apoio	
		,tbinsert.OBSValorPedágio_mt_apoio 
		,tbinsert.ValorDesconto_mt_apoio	
		,tbinsert.OBSValorDesconto_mt_apoio
		,tbinsert.ValorExtra_mt_apoio
		,tbinsert.OBSValorExtra_mt_apoio
		,tbinsert.PrazoMotoristaRecebedor2
		,tbinsert.ValorApoio2
		,tbinsert.OBSValordeapoio2
		,tbinsert.ValorPedagio2
		,tbinsert.ObsValorPedagio2
		,tbinsert.ValorDesconto2
		,tbinsert.ObsValorDesconto2
		,tbinsert.ValorExtra2
		,tbinsert.ObsValorExtra2
		,tbinsert.PrazoMotoristaRecebedorApoio
		,tbinsert.TipoContratoMotoristaRecebedorApoio
		,tbinsert.TipoContratoMotoristaRecebedor2
		,tbinsert.MotoristaRecebedorApoio



 FROM [vw_resultado_financeiro] fin

inner join tb_clientes as clientes
on fin.IdTransportadora = clientes.cli_cd_codigo_cliente --cli_id_logistics

left join 
		(
			select 
				idrota as idrotaapp
				,UsouAPP
			from vw_rotas_motoristas 
			where 1=1
			--and idrota = @rota
		)
		as usouapp
		on fin.idrota = usouapp.idrotaapp

left join [tb_fin_ficha_motorista] as tbinsert
on  clientes.cli_cd_codigo_cliente = tbinsert.[IdTransportadora]
and fin.[IdRota] = tbinsert.[id]

where 1=1
and clientes.cli_cd_codigo_cliente = @Transportadora
-- AND fin.IdRota = @Rota
and fin.Ano		 = @ano
and fin.Mes		 = @Mes
and fin.Quinzena = @Quinzena
and fin.[ServiceCenter] = @svc



GO
