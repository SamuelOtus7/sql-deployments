-- ============================================================
-- BASELINE: dbo.UspSetMLFichaFinanceiroMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSetMLFichaFinanceiroMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSetMLFichaFinanceiroMotorista]
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
,@ValorApoio_mt_apoio					decimal(9,2)
,@OBSValordeapoio_mt_apoio 				varchar(max)
,@ValorPedágio_mt_apoio					decimal(9,2)
,@OBSValorPedágio_mt_apoio 				varchar(max)
,@ValorDesconto_mt_apoio				decimal(9,2)
,@OBSValorDesconto_mt_apoio				varchar(max)
,@ValorExtra_mt_apoio					decimal(9,2)
,@OBSValorExtra_mt_apoio				varchar(max)

,@PrazoMotoristaRecebedor2				varchar(max)			
,@TipoContratoMotoristaRecebedor2		varchar(max)
--,@MotoristaRecebedor2					varchar(max)
,@ValorApoio2							decimal(9,2)
,@OBSValordeapoio2						varchar(max)
,@ValorPedagio2							decimal(9,2)
,@ObsValorPedagio2						varchar(max)
,@ValorDesconto2						decimal(9,2)
,@ObsValorDesconto2						varchar(max)
,@ValorExtra2							decimal(9,2)
,@ObsValorExtra2						varchar(max)
,@PrazoMotoristaRecebedorApoio			varchar(max)
,@TipoContratoMotoristaRecebedorApoio	varchar(max)
,@MotoristaRecebedorApoio				int


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
      ,ValorApoio_mt_apoio			= @ValorApoio_mt_apoio		
	  ,OBSValordeapoio_mt_apoio 	= @OBSValordeapoio_mt_apoio 
	  ,ValorPedágio_mt_apoio		= @ValorPedágio_mt_apoio	
	  ,OBSValorPedágio_mt_apoio 	= @OBSValorPedágio_mt_apoio 
	  ,ValorDesconto_mt_apoio		= @ValorDesconto_mt_apoio	
	  ,OBSValorDesconto_mt_apoio	= @OBSValorDesconto_mt_apoio
	  ,ValorExtra_mt_apoio			= @ValorExtra_mt_apoio
	  ,OBSValorExtra_mt_apoio		= @OBSValorExtra_mt_apoio
	  ,PrazoMotoristaRecebedor2				= @PrazoMotoristaRecebedor2				
	  ,TipoContratoMotoristaRecebedor2		= @TipoContratoMotoristaRecebedor2		
	  --,MotoristaRecebedor2					= @MotoristaRecebedor2					
	  ,ValorApoio2							= @ValorApoio2							
	  ,OBSValordeapoio2						= @OBSValordeapoio2						
	  ,ValorPedagio2						= @ValorPedagio2						
	  ,ObsValorPedagio2						= @ObsValorPedagio2						
	  ,ValorDesconto2						= @ValorDesconto2						
	  ,ObsValorDesconto2					= @ObsValorDesconto2					
	  ,ValorExtra2							= @ValorExtra2							
	  ,ObsValorExtra2						= @ObsValorExtra2						
	  ,PrazoMotoristaRecebedorApoio			= @PrazoMotoristaRecebedorApoio			
	  ,TipoContratoMotoristaRecebedorApoio	= @TipoContratoMotoristaRecebedorApoio	
	  ,MotoristaRecebedorApoio				= @MotoristaRecebedorApoio				



exec [dbo].[UspGetMLFichaFinanceiroTransportadoraMotorista]
	@IdTransportadora 
	,@Ano	  
	,@Mes	  
	,@Quinzena 
	,@ServiceCenter 

GO
