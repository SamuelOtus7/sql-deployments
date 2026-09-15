-- ============================================================
-- BASELINE: dbo.UspMTRLoadPedidos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMTRLoadPedidos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMTRLoadPedidos] (
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
	
	-- select
	-- 	@JSON = jsonData,
	-- 	@IdTransportadora = tenantId,
	-- 	@DataColeta = createdAt
	-- from
	-- 	tb_mtr_webhook with(nolock)
	-- where
	-- 	id = 55

	drop table if exists #pedidos
	SELECT
		@IdTransportadora IdTransportadora
		,NumeroPedido
		,NumeroRemessa
		,CnpjCpfDestinatario
		,NomeDestinatario
		,Telefone
		,Endereco
		,NumeroEndereco
		,Bairro
		,Cidade
		,Estado
		,Complemento
		,ObservacaoEndereco
		,CEP
		,QuantidadeVolumes
		,convert(datetime, DataPrevistaEntregaFim, 103) DataPrevistaEntregaFim
		,NomeFilial
		,TipoEntrega
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao
		,0 Excluido
		into #pedidos
	FROM 
		OPENJSON (@JSON)
	with
	(
		NumeroPedido bigint '$.numeroPedido' 
		,NumeroRemessa varchar(30) '$.numeroRemessa' 
		,CnpjCpfDestinatario bigint '$.cnpjCpfDes' 
		,NomeDestinatario varchar(60) '$.nomeDes'
		,Telefone varchar(20) '$.telefoneDes'
		,Endereco varchar(100) '$.endDes'
		,NumeroEndereco varchar(10) '$.numDes' 
		,Bairro varchar(60) '$.baiDes'
		,Cidade varchar(60) '$.cidDes'
		,Estado char(2) '$.ufDes'
		,Complemento varchar(60) '$.cplDes'
		,ObservacaoEndereco varchar(100) '$.obsEndDes'
		,CEP varchar(8) '$.cepDes'
		,QuantidadeVolumes int '$.qtdVolumes' 
		,DataPrevistaEntregaFim varchar(60) '$.dataPrevEntregafim'
		,NomeFilial varchar(60) '$.nomeFilial'
		,TipoEntrega varchar(60) '$.desctipoEntrega'
	)

	merge tb_mtr_pedidos as p
	using #pedidos as i ON p.IdTransportadora = i.IdTransportadora and p.NumeroPedido = i.NumeroPedido
	when matched then
	update set
		p.NumeroRemessa = i.NumeroRemessa
		,p.CnpjCpfDestinatario = i.CnpjCpfDestinatario
		,p.NomeDestinatario = i.NomeDestinatario
		,p.Telefone = i.Telefone
		,p.Endereco = i.Endereco
		,p.NumeroEndereco = i.NumeroEndereco
		,p.Bairro = i.Bairro
		,p.Cidade = i.Cidade
		,p.Estado = i.Estado
		,p.Complemento = i.Complemento
		,p.ObservacaoEndereco = i.ObservacaoEndereco
		,p.CEP = i.CEP
		,p.QuantidadeVolumes = i.QuantidadeVolumes
		,p.DataPrevistaEntregaFim = i.DataPrevistaEntregaFim
		,p.NomeFilial = i.NomeFilial
		,p.TipoEntrega = i.TipoEntrega
		,p.DataHoraColeta = i.DataHoraColeta
		,p.DataAtualizacao = i.DataAtualizacao
		,p.Excluido = i.Excluido

	when not matched by target then 
	insert (
			IdTransportadora
			,NumeroPedido
			,NumeroRemessa
			,CnpjCpfDestinatario
			,NomeDestinatario
			,Telefone
			,Endereco
			,NumeroEndereco
			,Bairro
			,Cidade
			,Estado
			,Complemento
			,ObservacaoEndereco
			,CEP
			,QuantidadeVolumes
			,DataPrevistaEntregaFim
			,NomeFilial
			,TipoEntrega
			,DataHoraColeta
			,DataAtualizacao
			,Excluido
	)
	values (
			i.IdTransportadora
			,i.NumeroPedido
			,i.NumeroRemessa
			,i.CnpjCpfDestinatario
			,i.NomeDestinatario
			,i.Telefone
			,i.Endereco
			,i.NumeroEndereco
			,i.Bairro
			,i.Cidade
			,i.Estado
			,i.Complemento
			,i.ObservacaoEndereco
			,i.CEP
			,i.QuantidadeVolumes
			,i.DataPrevistaEntregaFim
			,i.NomeFilial
			,i.TipoEntrega
			,i.DataHoraColeta
			,i.DataAtualizacao
			,i.Excluido
	);
	
end
	
GO
