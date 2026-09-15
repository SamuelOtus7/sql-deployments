-- ============================================================
-- BASELINE: dbo.UspMTRLoadOcorrencias
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMTRLoadOcorrencias]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMTRLoadOcorrencias] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@DataColeta datetime
)
as
begin

	SET NOCOUNT ON;	

	--declare @JSON VARCHAR(max)
	--declare @IdTransportadora int
	--declare @DataColeta datetime
	
	--select
	--	@JSON = jsonData,
	--	@IdTransportadora = tenantId,
	--	@DataColeta = createdAt
	--from
	--	tb_mtr_webhook with(nolock) 
	--where
	--	id = 103309

	drop table if exists #ocorrencias
	select
		@IdTransportadora IdTransportadora
		,case when isnumeric(CodigoOcorrencia) = 1 then CodigoOcorrencia else 0 end as CodigoOcorrencia
		,NumeroPedido
		,NumeroRemessa
		,DescricaoOcorrencia
		,convert(datetime, DataHoraOcorrencia, 103) DataHoraOcorrencia
		,PlacaVeiculo
		,CpfMotorista
		,CnpjCpfDestinatario
		,Iccid
		,Observacao
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao
		,0 Excluido
		into #ocorrencias
	from
		OPENJSON (@JSON)
	with
	(
		CodigoOcorrencia varchar(30) '$.codOcorrencia' 
		,NumeroPedido bigint '$.numeroPedido' 
		,NumeroRemessa varchar(30) '$.numeroRemessa'
		,DescricaoOcorrencia varchar(100) '$.descOcorrencia'
		,DataHoraOcorrencia varchar(60) '$.datahoraOcorrencia'
		,PlacaVeiculo varchar(10) '$.placaVeiculo'
		,CpfMotorista varchar(20) '$.cpfMotorista'
		,CnpjCpfDestinatario varchar(20) '$.cnpjCpfDes' 
		,Iccid varchar(30) '$.iccid' 
		,Observacao varchar(100) '$.obsMov'
	)

	merge tb_mtr_ocorrencias as o
	using #ocorrencias as i ON o.IdTransportadora = i.IdTransportadora and o.CodigoOcorrencia = i.CodigoOcorrencia
	and o.NumeroPedido = i.NumeroPedido
	and o.DataHoraOcorrencia = i.DataHoraOcorrencia
	and o.CnpjCpfDestinatario = i.CnpjCpfDestinatario
	when matched then
	update set
		 o.NumeroRemessa = i.NumeroRemessa
		,o.DescricaoOcorrencia = i.DescricaoOcorrencia
		,o.PlacaVeiculo = i.PlacaVeiculo
		,o.CpfMotorista = i.CpfMotorista
		,o.Iccid = i.Iccid
		,o.Observacao = i.Observacao
		,o.DataHoraColeta = i.DataHoraColeta
		,o.DataAtualizacao = i.DataAtualizacao
		,o.Excluido = i.Excluido

	when not matched by target then 
	insert (
			IdTransportadora
			,CodigoOcorrencia
			,NumeroPedido
			,NumeroRemessa
			,DescricaoOcorrencia
			,DataHoraOcorrencia
			,PlacaVeiculo
			,CpfMotorista
			,CnpjCpfDestinatario
			,Iccid
			,Observacao
			,DataHoraColeta
			,DataAtualizacao
			,Excluido
	)
	values (
			i.IdTransportadora
			,i.CodigoOcorrencia
			,i.NumeroPedido
			,i.NumeroRemessa
			,i.DescricaoOcorrencia
			,i.DataHoraOcorrencia
			,i.PlacaVeiculo
			,i.CpfMotorista
			,i.CnpjCpfDestinatario
			,i.Iccid
			,i.Observacao
			,i.DataHoraColeta
			,i.DataAtualizacao
			,i.Excluido
);
	
end
	
	
GO
