-- ============================================================
-- BASELINE: dbo.UspMLGetRotasBkp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetRotasBkp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLGetRotasBkp]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @ServiceCenter varchar(20)
	declare @DataColeta datetime
	declare @DataReferencia date
	declare @VerificaJson bit
	declare @Erro bit = 0

	begin tran
	
	select
		@QueueID = Q.cmt_cd_coleta, 
		@Json = Q.cmt_ds_json,
		@Transportadora = Q.cmt_cd_transportadora,
		@ServiceCenter = Q.cmt_cd_servicecenter,
		@DataColeta = Q.cmt_dh_coleta,
		@DataReferencia = Q.cmt_dh_referencia,
		@VerificaJson = Q.verifica_json
	FROM 
		(
			SELECT 
				TOP 1 cmt_cd_coleta, cmt_in_processado, cmt_cd_transportadora, cmt_cd_servicecenter, cmt_ds_json, cmt_dh_coleta, cmt_dh_referencia,
				case when left(cmt_ds_json,1) in ('{','[') and cmt_ds_json <> '[]' then 1 else 0 end verifica_json
			FROM 
				db_Irisys_Json.dbo.tb_ml_coleta_totalizador WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				cmt_in_processado = 0
			ORDER BY 
				cmt_cd_coleta
	) Q
	--waitfor delay '00:00:03'
	
	
	if @VerificaJson = 1
	begin
		begin try
			exec UspMLLoadRotas @Json, @Transportadora, @ServiceCenter, @DataColeta, @DataReferencia
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
		db_Irisys_Json.dbo.tb_ml_coleta_totalizador 
	set 
		cmt_dh_processamento = GETDATE(), 
		cmt_in_processado = 1,
		cmt_in_erro = @Erro
	where 
		cmt_cd_coleta = @QueueID
	
	

end
GO
