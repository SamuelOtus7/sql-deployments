-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotes_bkp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotes_bkp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEGetPacotes_bkp]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @IdTransportadora int
	declare @DataColeta datetime
	declare @DataReferencia date
	declare @VerificaJson bit

	begin tran
	
	UPDATE 
		Q
	SET 
		@QueueID = Q.dac_cd_coleta, 
		@Json = Q.dac_ds_contexto_json,
		@IdTransportadora = 20230001, --Q.dac_cd_transportadora,
		@DataColeta = dac_dh_coleta,
		@DataReferencia = dac_dh_referencia,
		@VerificaJson = Q.verifica_json,
		dac_in_processado = 1
	FROM 
		(
			SELECT 
				TOP 1 dac_cd_coleta, dac_in_processado, dac_ds_contexto, dac_ds_contexto_json, dac_dh_coleta, dac_dh_referencia, dac_cd_transportadora,
				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_ds_tipo_coleta = 'ORDER'
				and dac_in_processado = 0
			ORDER BY 
				dac_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
	
	if @VerificaJson = 1
	begin
		exec UspSPELoadPacotes @Json, @IdTransportadora, @DataColeta, @DataReferencia
	end

	update 
		db_Irisys_Json.dbo.tb_dra_coleta 
	set 
		dac_dh_processamento = GETDATE(), 
		dac_in_processado = 1
	where 
		dac_cd_coleta = @QueueID
	
	--if right(cast(@QueueID as varchar(10)),1) = '0'
	commit

end
GO
