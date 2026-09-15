-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesDetalhes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesDetalhes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEGetPacotesDetalhes]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	

	--begin tran
	
	if object_id('tempdb..#tabela_detalhes') is not null  drop table #tabela_detalhes
	select
		Q.dac_cd_coleta, 
		Q.dac_ds_contexto_json,
		Q.dac_cd_transportadora,
		Q.dac_ds_contexto,
		Q.verifica_json,
		Q.dac_dh_referencia,
		row_number() over (order by dac_cd_coleta ) linha
		
	into #tabela_detalhes

	FROM 
		(
			SELECT 
				TOP 100 dac_cd_coleta, dac_in_processado, dac_ds_contexto, dac_cd_transportadora, dac_ds_contexto_json, dac_dh_referencia,
				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_ds_tipo_coleta = 'SPE4_DETAILS'
				and dac_in_processado = 0
			ORDER BY 
				dac_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	



	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @CodigoPacote varchar(30)
	declare @VerificaJson bit
	declare @DataReferencia date
	declare @Erro bit = 0

	declare @inicio int = 1
	declare @fim int = (select max(linha)  from #tabela_detalhes)

while @inicio <= @fim 
	begin 

	select
		@QueueID = Q.dac_cd_coleta, 
		@Json = Q.dac_ds_contexto_json,
		@Transportadora = Q.dac_cd_transportadora,
		@CodigoPacote = Q.dac_ds_contexto,
		@VerificaJson = Q.verifica_json,
		@DataReferencia = Q.dac_dh_referencia
	from #tabela_detalhes as Q
	where linha = @inicio

	exec UspSPELoadPacotesDetalhes @Json, @Transportadora, @CodigoPacote, @DataReferencia
	set @Erro = 0
	


	update a
	set 	
		dac_dh_processamento = GETDATE(), 
		dac_in_processado = 1,
		dac_in_erro = @Erro

	from db_Irisys_Json.dbo.tb_dra_coleta as a
	inner join #tabela_detalhes as b
	on a.dac_cd_coleta = b.dac_cd_coleta
	where b.linha  = @inicio 	

print(@inicio)

		set @inicio = @inicio + 1

	end

	end
GO
