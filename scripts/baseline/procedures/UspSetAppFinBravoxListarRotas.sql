-- ============================================================
-- BASELINE: dbo.UspSetAppFinBravoxListarRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSetAppFinBravoxListarRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSetAppFinBravoxListarRotas]
(

 @IdTransportadora						int
,@Ano									int
,@Mes									int
,@Quinzena								int
,@ServiceCenter							varchar(max)
,@Placa							        varchar(max)
,@Cluster							    varchar(max)
,@ValorSaida						    decimal(9,2)
,@HoraIncio							    varchar(max)
,@ID								    varchar(50)
,@Categoria							    varchar(max)
,@KM								    decimal(9,2)
,@Prazo							        varchar(max)
,@Ciclo							        varchar(15)
,@TipodeContrato						varchar(max)
,@Tipoderota							varchar(max)
,@Motoristarecebedor					int
,@Motoristarecebedor2					int
,@ValoresExtras						    decimal(9,2)
,@Valordeapoio						    decimal(9,2)
,@OBSValordeapoio						varchar(max)
,@ValorPedágio						    decimal(9,2)
,@OBSValorPedágio						varchar(max)
,@ValorDesconto							decimal(9,2)
,@OBSValorDesconto						varchar(max)
,@ValorExtra							decimal(9,2)
,@OBSValorExtra							varchar(max)
,@faixakm								varchar(50)

) as 

declare @transportadora  int = (select cli_id_logistics from tb_clientes where cli_cd_codigo_cliente = @IdTransportadora)


declare @faixakmalterado int = isnull(LEFT(@faixakm , CHARINDEX('/',@faixakm ) - 1), @faixakm) 

exec [dbo].[UspGeraPagamentoMotoristaBravox] @transportadora ,@Ano , @Mes , @Quinzena , @ID , @prazo,@Tipoderota ,@TipodeContrato,@faixakmalterado



update tb_fin_ficha_motorista
set 
       [Cluster]				= @Cluster
     --  [Service Center]         = @ServiceCenter
      ,[Hora Incio]				= @HoraIncio
      ,[KM]						= @KM
      ,[Prazo]					= @Prazo
      ,[Ciclo]					= @Ciclo
      ,[Motorista recebedor]	= @Motoristarecebedor
      ,[Motorista recebedor 2]	= @Motoristarecebedor2
      ,[Valores Extras]			= @ValoresExtras
      ,[Valor de apoio]			= @Valordeapoio
      ,[OBS Valor de apoio]		= @OBSValordeapoio
      ,[Valor Pedágio]			= @ValorPedágio
      ,[OBS Valor Pedágio]		= @OBSValorPedágio
      ,[Valor Desconto]			= @ValorDesconto
      ,[OBS Valor Desconto]		= @OBSValorDesconto
      ,[Valor Extra]			= @ValorExtra
      ,[OBS Valor Extra]		= @OBSValorExtra
      ,[IdTransportadora]		= @IdTransportadora
      ,[Ano]					= @Ano
      ,[Mes]					= @Mes
      ,[Quinzena]				= @Quinzena
	  ,[faixakm]				= @faixakm
      



exec [dbo].[UspGetMLFichaFinanceiroTransportadoraMotorista]
	@IdTransportadora 
	,@Ano	  
	,@Mes	  
	,@Quinzena 
	,@ServiceCenter 
GO
