-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesV42
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesV42]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEGetPacotesV42]
as 
begin


	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	

	--begin tran
	if object_id('tempdb..#base') is not null drop table #base 
	select
		Q.dac_cd_coleta, 
		Q.dac_ds_contexto_json,
		Q.dac_cd_transportadora,
		Q.dac_ds_contexto,
		Q.dac_dh_coleta,
		Q.dac_dh_referencia,
		Q.verifica_json,
		row_number() over (order by dac_cd_coleta ) linha
		
		INTO #base

	FROM 
		(
			SELECT 
				TOP 10000
				dac_cd_coleta, dac_in_processado, dac_cd_transportadora, dac_ds_contexto_json, dac_dh_coleta, dac_ds_contexto, dac_dh_referencia,
				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
			
			FROM 
				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_ds_tipo_coleta = 'SPE4_PACKAGES'
				--and dac_in_processado = 0
			ORDER BY 
				dac_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
declare @QueueID bigint = NULL
declare @Json varchar(max)
declare @Transportadora varchar(20)
declare @CodigoRota varchar(30)
declare @DataColeta datetime
declare @DataReferencia date
declare @VerificaJson bit
declare @Erro bit = 0

declare @inicio int = 1
declare @fim int = (select max(linha)  from #base)

while @inicio <= @fim 
	begin 
		
		select
		@QueueID = Q.dac_cd_coleta, 
		@Json = Q.dac_ds_contexto_json,
		@Transportadora = Q.dac_cd_transportadora,
		@CodigoRota = Q.dac_ds_contexto,
		@DataColeta = Q.dac_dh_coleta,
		@DataReferencia = Q.dac_dh_referencia,
		@VerificaJson = Q.verifica_json 
		from #base Q
		where linha = @inicio

		--executa a procedure 
	
		--begin try
			exec UspSPELoadPacotesV4 @Json, @CodigoRota, @Transportadora, @DataReferencia, @DataColeta
			set @Erro = 0

			--print(@QueueID)
		--	commit
		--end try
		--begin catch
		--	set @Erro = 1
		--	rollback
		--end catch
		

		update a
		set 	
			dac_dh_processamento = GETDATE(), 
			dac_in_processado = 1,
			dac_in_erro = @Erro

		from db_Irisys_Json.dbo.tb_dra_coleta as a
		inner join #base as b
		on a.dac_cd_coleta = b.dac_cd_coleta
		where b.linha  = @inicio 
		
		--print(@inicio)

		set @inicio = @inicio + 1

	end 

end
GO
