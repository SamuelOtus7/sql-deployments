-- ============================================================
-- BASELINE: dbo.UspSPEGetRotasV5
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetRotasV5]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPEGetRotasV5]
WITH RECOMPILE
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET XACT_ABORT ON;
SET NOCOUNT ON;

drop table if exists #base_processar 
select top 10

	id
	,createdAt	
	,jsonData
	,processingStatus
	,agency	
	,idtransportadora	
	,TipoJson	
	,CodigoRota
	,row_number() over (order by createdAt ) linha

 into #base_processar

from db_Irisys_Json.dbo.tb_spe_webhook with(nolock)
where createdAt >= '2024-09-18'
and processingStatus = 0
and TipoJson = 'trip_info'
-- and left(jsonData,6) = '{"data'
and idtransportadora is not null
order by 1





declare @Json varchar(max)
declare @inicio int = 1
declare @fim int = (select max(linha)  from #base_processar)
declare @Erro bit = 0
declare @QueueID bigint = NULL
declare @agency	int 
declare @idtransportadora	int 
declare @TipoJson	varchar(30)
declare @CodigoRota varchar(30)

	while @inicio <= @fim 
		
	begin
			select 
			--	@QueueID = Q.createdAt, 
				@Json = Q.jsonData,
                @agency = Q.agency,
                @idtransportadora = Q.idtransportadora,
                @TipoJson = Q.TipoJson
			from #base_processar Q
			where linha  = @inicio 

			--, @agency,@idtransportadora
			exec UspLoadRotasV5 @Json, @agency,@idtransportadora,@TipoJson ;
			set @Erro = 0

			update a
			set
				processingDatetime = GETDATE(), 
				processingStatus = 1
			
			from db_Irisys_Json.dbo.tb_spe_webhook as a
			inner join #base_processar as b
			on a.id = b.id
			where b.linha  = @inicio	

			set @inicio = @inicio + 1

	end 	   

end

-- select top 10  * from db_Irisys_Json.dbo.tb_spe_webhook 
-- where left(jsonData,6) = '{"data'

-- order by 1 desc

-- select top 10 * from db_Irisys_Json.dbo.tb_spe_webhook where processingDatetime is not null 

GO
