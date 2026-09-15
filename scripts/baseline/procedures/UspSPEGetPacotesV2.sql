-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesV2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesV2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEGetPacotesV2]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @IdStation int
	declare @IdMotorista int
	declare @DataColeta datetime
	declare @VerificaJson bit
	declare @Erro bit = 0

	begin tran
	
	select
		@QueueID = Q.dac_cd_coleta, 
		@Json = Q.dac_ds_contexto_json,
		@Transportadora = Q.dac_cd_transportadora,
		@IdStation = left(dac_ds_contexto,CHARINDEX(';',dac_ds_contexto)-1),
		@IdMotorista = right(dac_ds_contexto,len(dac_ds_contexto)-CHARINDEX(';',dac_ds_contexto)),
		@DataColeta = Q.dac_dh_coleta,
		@VerificaJson = Q.verifica_json
	FROM 
		(
			SELECT 
				TOP 1 dac_cd_coleta, dac_in_processado, dac_cd_transportadora, dac_ds_contexto_json, dac_dh_coleta, dac_ds_contexto,
				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' and dac_ds_contexto_json <> '{"message":"Success","data":{"count":10000,"total":0,"list":[],"pageno":1},"retcode":0}' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_ds_tipo_coleta = 'SP_PACKAGE'
				and dac_in_processado = 0
			ORDER BY 
				dac_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
	
	if @VerificaJson = 1
	begin
		begin try
			exec UspSPELoadPacotesV2 @Json, @Transportadora, @IdStation, @IdMotorista, @DataColeta
			set @Erro = 0
			commit
		end try
		begin catch
			set @Erro = 1
			rollback
		end catch
	end
	else
	begin
		commit
	end

	update 
		db_Irisys_Json.dbo.tb_dra_coleta 
	set 
		dac_dh_processamento = GETDATE(), 
		dac_in_processado = 1,
		dac_in_erro = @Erro
	where 
		dac_cd_coleta = @QueueID
	
	

end
GO
