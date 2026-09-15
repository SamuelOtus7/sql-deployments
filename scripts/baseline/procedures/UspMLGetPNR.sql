-- ============================================================
-- BASELINE: dbo.UspMLGetPNR
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetPNR]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspMLGetPNR]
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	DECLARE @QueueID BIGINT = NULL;
	DECLARE @Json VARCHAR(MAX);
	DECLARE @IdTransportadora INT;
	DECLARE @Quinzena VARCHAR(20);
	DECLARE @DataColeta DATETIME;
	DECLARE @VerificaJson BIT;
	DECLARE @Erro BIT = 0;

	SELECT
		@QueueID = Q.dac_cd_coleta,
		@IdTransportadora = Q.dac_cd_transportadora,
		@Quinzena = Q.dac_ds_contexto,
		@Json = Q.dac_ds_contexto_json,
		@DataColeta = Q.dac_dh_coleta,
		@VerificaJson = Q.verifica_json
	FROM 
		(
			SELECT 
				TOP 1 
				dac_cd_coleta, 
				dac_ds_contexto_json, 
				dac_dh_coleta, 
				dac_ds_contexto, 
				dac_cd_transportadora,
				CASE 
					WHEN LEFT(dac_ds_contexto_json, 1) IN ('{', '[') 
						AND dac_ds_contexto_json <> '[]' 
					THEN 1 
					ELSE 0 
				END AS verifica_json
			FROM db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_in_processado = 0
				AND dac_ds_tipo_coleta = 'ML_PNR'
			ORDER BY 
				dac_cd_coleta
		) Q;
	
	IF @VerificaJson = 1
	BEGIN
		BEGIN TRY
			EXEC UspMLLoadPNR @IdTransportadora, @Quinzena, @Json, @DataColeta;
			SET @Erro = 0;
		END TRY
		BEGIN CATCH
			SET @Erro = 1;
		END CATCH
	END;
	
	UPDATE db_Irisys_Json.dbo.tb_dra_coleta 
	SET 
		dac_dh_processamento = GETDATE(), 
		dac_in_processado = 1,
		dac_in_erro = @Erro
	WHERE 
		dac_cd_coleta = @QueueID;

END
GO
