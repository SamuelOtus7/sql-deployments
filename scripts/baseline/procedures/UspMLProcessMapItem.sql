-- ============================================================
-- BASELINE: dbo.UspMLProcessMapItem
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLProcessMapItem]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLProcessMapItem]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	begin tran
	
	UPDATE 
		Q
	SET 
		@QueueID = Q.dam_cd_coleta, 
		dam_in_processado = 1
	FROM 
		(
			SELECT 
				TOP 1 *
			FROM 
				tb_dra_coleta_maps WITH (ROWLOCK, READPAST, UPDLOCK)
			WHERE 
				dam_in_processado = 0
			ORDER BY 
				dam_cd_coleta
	) Q
	--waitfor delay '00:00:01'
	
	
	--Chamar procedure para processamento do JSON passado como parâmetro
	update tb_dra_coleta_maps 
	set dam_dh_processamento = GETDATE(), dam_in_processado = 1
	where dam_cd_coleta = @QueueID
	if right(cast(@QueueID as varchar(10)),1) = '0'
	commit

end
GO
