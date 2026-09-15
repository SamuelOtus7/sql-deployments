-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesNovo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesNovo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEGetPacotesNovo]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @CodigoRota varchar(30)
	declare @DataColeta datetime
	declare @VerificaJson bit
	declare @Erro bit = 0

	begin tran
	
	select
		@QueueID = Q.dac_cd_coleta, 
		@Json = Q.dac_ds_contexto_json,
		@Transportadora = Q.dac_cd_transportadora,
		@CodigoRota = Q.dac_ds_contexto,
		@DataColeta = Q.dac_dh_coleta,
		@VerificaJson = Q.verifica_json
	FROM 
		(
			SELECT 
				TOP 1 dac_cd_coleta, dac_in_processado, dac_cd_transportadora, dac_ds_contexto_json, dac_dh_coleta, dac_ds_contexto,
				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_ds_tipo_coleta = 'SP2_ROUTES_DETAILS'
				and dac_in_processado = 0
			ORDER BY 
				dac_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
	
	if @VerificaJson = 1
	begin
		begin try
			exec UspSPELoadPacotesNovo @Json, @CodigoRota, @Transportadora, @DataColeta
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
