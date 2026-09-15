-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesV5
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesV5]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPEGetPacotesV5]
WITH RECOMPILE
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET XACT_ABORT ON;
SET NOCOUNT ON;



WITH UltimaInformacao AS (
    SELECT top 30 
        id,
        createdAt,
        jsonData,
        processingStatus,
        agency,
        idtransportadora,
        TipoJson,
        Codigopacote,
        ROW_NUMBER() OVER (PARTITION BY Codigopacote ORDER BY createdAt DESC) AS rn,
		Inprocessing
		
	
    FROM db_Irisys_Json.dbo.tb_spe_webhook WITH (NOLOCK)
    WHERE cast(createdAt as date) = cast(GETDATE()as date )
      AND processingStatus = 0
      AND TipoJson = 'order_update'
      AND idtransportadora IS NOT NULL
	  and UltimoRegistro = 1
	  and (Inprocessing = 0 or Inprocessing is null)
)

 
select 
    id,
    createdAt,
    jsonData,
    processingStatus,
    agency,
    idtransportadora,
    TipoJson,
	Codigopacote,
	row_number() over (order by createdAt ) linha

 into #base_processar

FROM UltimaInformacao
WHERE rn = 1



update a
set Inprocessing = 1
from db_Irisys_Json.dbo.tb_spe_webhook as a
inner join #base_processar  as b
on a.id = b.id




declare @Json varchar(max)
declare @inicio int = 1
declare @fim int = (select max(linha)  from #base_processar)
declare @Erro bit = 0
declare @QueueID bigint = NULL
declare @agency	int 
declare @idtransportadora	int 
declare @TipoJson	varchar(30)
declare @CodigoRota varchar(30)
declare @id int 

	while @inicio <= @fim 
		
	begin
			select 
			--	@QueueID = Q.createdAt, 
				@id = q.id,
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
				processingStatus = 1,
				Inprocessing = 0
			from db_Irisys_Json.dbo.tb_spe_webhook as a
			inner join #base_processar as b
			on a.id = b.id
			where b.linha  = @inicio	

			set @inicio = @inicio + 1

	end 	   


drop table if exists #base_processar



end

-- select top 10  * from db_Irisys_Json.dbo.tb_spe_webhook 
-- where left(jsonData,6) = '{"data'

-- order by 1 desc

-- select top 10 * from db_Irisys_Json.dbo.tb_spe_webhook where processingDatetime is not null 

GO
