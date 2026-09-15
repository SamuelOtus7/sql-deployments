-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesReprocessar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesReprocessar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEGetPacotesReprocessar]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @CodigoPacote varchar(30)
	declare @VerificaJson bit
	declare @Erro bit = 0

	begin tran
	
	select
		@QueueID = Q.dac_cd_coleta, 
		@Json = Q.dac_ds_contexto_json,
		@Transportadora = Q.dac_cd_transportadora,
		@CodigoPacote = Q.dac_ds_contexto,
		@VerificaJson = Q.verifica_json
	FROM 
		(
			SELECT 
				TOP 1 dac_cd_coleta, dac_in_processado, dac_ds_contexto, dac_cd_transportadora, dac_ds_contexto_json,
				case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dac_ds_tipo_coleta = 'SP_DETAIL'
				and dac_in_processado = 0
			ORDER BY 
				dac_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
	
	if @VerificaJson = 1
	begin
		begin try
			exec UspSPELoadPacotesReprocessar @Json, @Transportadora, @CodigoPacote
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
