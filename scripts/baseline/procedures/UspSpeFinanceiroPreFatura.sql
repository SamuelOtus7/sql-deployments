-- ============================================================
-- BASELINE: dbo.UspSpeFinanceiroPreFatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSpeFinanceiroPreFatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspSpeFinanceiroPreFatura] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin

delete tb_fin_spe_prefatura where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena

 exec usp_fin_TrataDadosUploadSpe -- procedure adicionada para tratar valores que estavam vindo string no lugar do valor - Matheus 30/06/25


--truncate  table tb_fin_spe_prefatura_upload
--BULK INSERT  tb_fin_spe_prefatura_upload 
--FROM 'C:\Users\samuel.nogueira\Documents\prefatura shopee.csv'
--WITH (
--FIELDTERMINATOR = ';',  -- Delimitador de campos (vírgula)
--FIRSTROW = 2,
--    ROWTERMINATOR = '\n' 

--	-- Delimitador de linhas (quebra de linha)
--    );



insert into tb_fin_spe_prefatura
select 
	 @IdTransportadora idtransportadora
	,TipoServico
	,Operacao
	,SOC
	,Hub
	,Rota
	,PeriodoAnoMesQuinzena
	,TrackingNumber
	,TrackingNumberAPI
	,convert(varchar(103),DataPrestacaoServico) as DataPrestacaoServico
	,NomeTomadorServico
	,CNPJTomador
	,NomeTransportadora
	,CNPJEmitente
	,CEPOrigem
	,CidadeOrigem
	,UFOrigem
	,CEPentrega
	,CidadeEntrega
	,UFEntrega
	,DadosSeller
	,DataEntrega
	,QuantidadeVolume
	,PesoReal
	,PesoCubado
	,PesoCalculadoCobrado
	,KMRodado
	,TipoVeiculo
	,FatorAgrupador
	,Placa
	,cast(replace(ValorNotaFiscalMercadoria,',','.') as decimal(10,2)) as ValorNotaFiscalMercadoria
	,cast(replace(replace(TarifaAplicada,'R$ ',''),',','.') as decimal(10,2)) as TarifaAplicada
	--,AT
	,cast(replace(replace(FreteTarifaBase,'R$ ',''),',','.') as decimal(10,2)) as FreteTarifaBase
	,cast(replace(replace(FreteCalculado,'R$ ',''),',','.') as decimal(10,2)) as FreteCalculado

	,ADV
	,cast(replace(replace(GRIS,'R$ ',''),',','.') as decimal(10,2)) as GRIS

	,cast(replace(replace(AliquotaICMSISS,'%',''),',','.') as decimal(10,2)) as AliquotaICMSISS

	,cast(replace(replace(BaseCalcICMSISS,'R$ ',''),',','.') as decimal(10,2)) as BaseCalcICMSISS
	,cast(replace(replace(ValorICMSISS,'R$ ',''),',','.') as decimal(10,2)) as ValorICMSISS

	,ICMS_Subst
	,cast(replace(replace(OutrosValores,'R$ ',''),',','.') as decimal(10,2)) as OutrosValores
	,cast(replace(replace(Descontos,'R$ ',''),',','.') as decimal(10,2)) as Descontos

	,cast(replace(replace(ValorFinalReceber,'R$ ',''),',','.') as decimal(10,2)) as ValorFinalReceber
	
	,DataEmissaoCteNF
	,Fatura
	,NumeroCte
	,NumeroNF
	,SerieCteNF
	,ChaveAcessoCte
	,MotivoRejeicaoCTE
	,PrefeituraNFSe
	,CAST(REPLACE(Valorajudante	,'"Valor ajudante: '	,'') AS decimal(10,2)) AS Valorajudante
	,CAST(REPLACE(Valorincentivo ,' Valor incentivo: '	,'') AS decimal(10,2)) AS Valorincentivo
	,CAST(REPLACE(REPLACE(FlagRisco		,' Flag Risco: '		,''),'"','') AS decimal(10,2)) AS FlagRisco
	,null DeAcordo
	,null Motivo
	,null ValorNegociado
	,null Observacoes
	,@ano	   as ano
	,@Mes	   as mes
	,@Quinzena as quinzena

	--into tb_fin_spe_prefatura

from tb_fin_spe_prefatura_upload

	--Atualiza Indicadores
	exec [UspFinanceiroAtualizaIndicadores] @IdTransportadora, @Ano, @Mes, @Quinzena, 'Prefatura'
	--atualiza financeiro
	--exec [UspAtualizaFinanceiro] @IdTransportadora, @Ano, @Mes, @Quinzena


end
GO
