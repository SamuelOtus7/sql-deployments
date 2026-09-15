-- ============================================================
-- BASELINE: dbo.UspMLGetVeiculos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetVeiculos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLGetVeiculos]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @DataColeta datetime
	declare @VerificaJson bit
	declare @Erro bit = 0

	begin tran
	
	select
		@QueueID = Q.cmv_cd_coleta, 
		@Json = Q.cmv_ds_json,
		@Transportadora = Q.cmv_cd_transportadora,
		@DataColeta = Q.cmv_dh_coleta,
		@VerificaJson = Q.verifica_json
	FROM 
		(
			SELECT 
				TOP 1 cmv_cd_coleta, cmv_in_processado, cmv_cd_transportadora, cmv_ds_json, cmv_dh_coleta,
				case when left(cmv_ds_json,1) in ('{','[') and cmv_ds_json <> '[]' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_ml_coleta_veiculos WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				cmv_in_processado = 0
			ORDER BY 
				cmv_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
	
	if @VerificaJson = 1
	begin
		begin try
			exec UspMLLoadVeiculos @Json, @Transportadora, @DataColeta
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
		db_Irisys_Json.dbo.tb_ml_coleta_veiculos 
	set 
		cmv_dh_processamento = GETDATE(), 
		cmv_in_processado = 1,
		cmv_in_erro = @Erro
	where 
		cmv_cd_coleta = @QueueID
	
	

end
GO
