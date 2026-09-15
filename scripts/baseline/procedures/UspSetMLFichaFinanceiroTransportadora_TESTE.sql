-- ============================================================
-- BASELINE: dbo.UspSetMLFichaFinanceiroTransportadora_TESTE
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSetMLFichaFinanceiroTransportadora_TESTE]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspSetMLFichaFinanceiroTransportadora_TESTE]
(
 @DataReferencia	date
,@idrota			int
,@CicloPM			varchar(MAX)
--,@Base	varchar
,@QuantidadePontos	int
,@QuantidadeParadas	int
,@QuantidadePacotes	int
,@PacotesEntregues	int
,@Ajudante			varchar(MAX)
,@AreaRisco			varchar(MAX)
,@TipoVeiculo		varchar(MAX)
,@KmColetado		decimal
,@LinkMapa			varchar(MAX)
,@idtransportadora	int
,@DomingoOuFeriado	varchar(5)
,@faixakm			varchar(MAX)
,@ervicecenter		varchar(MAX)
,@Observacao varchar(MAX)
,@Regiao varchar(MAX)
,@RiscoV2 varchar(MAX)
)
as


declare 	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint,
	@idtransportadoraML int

set @Ano = YEAR(@DataReferencia)
set @Mes = Month(@DataReferencia)
set @Quinzena  = (case when day(@DataReferencia) >= 1 and day(@DataReferencia) <= 15 then 1 else 2 end)
set @idtransportadoraML = (select distinct cli_id_logistics   from tb_clientes where  cli_cd_codigo_cliente = @idtransportadora and cli_cd_codigo_cliente <> 7  )

delete from  tb_fin_resultado_financeiro_alteracao 
where idtransportadora =  @idtransportadora and idrota = @idrota;

insert into tb_fin_resultado_financeiro_alteracao (DataReferencia ,idrota ,CicloPM  ,QuantidadePontos ,QuantidadeParadas ,QuantidadePacotes 
													,PacotesEntregues , Ajudante ,AreaRisco ,TipoVeiculo ,KmColetado ,LinkMapa ,idtransportadora,DomingoOuFeriado, faixakm ,servicecenter
													,Observacao,Regiao,RiscoV2)

select 
	 @DataReferencia
	,@idrota
	,@CicloPM
	--,@Base
	,@QuantidadePontos
	,@QuantidadeParadas
	,@QuantidadePacotes
	,@PacotesEntregues
	,@Ajudante
	,@AreaRisco
	,@TipoVeiculo
	,@KmColetado
	,@LinkMapa
	,@idtransportadora
	,@DomingoOuFeriado
	,@faixakm		
	,@ervicecenter	
	,@Observacao
	,@Regiao
	,@RiscoV2
GO
