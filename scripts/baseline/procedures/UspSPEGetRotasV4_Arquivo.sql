-- ============================================================
-- BASELINE: dbo.UspSPEGetRotasV4_Arquivo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetRotasV4_Arquivo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   procedure [dbo].[UspSPEGetRotasV4_Arquivo]
as
begin

	declare @Path varchar(100) = 'C:\Scrap\Rotas\50mais\Leitura\'
	declare @DataColeta datetime = '2023-08-10 19:00:00.000'
	declare @IdTransportadora int = 20230007
	declare @IdStations int = 5680

	drop table if exists #DirectoryTree
	CREATE TABLE #DirectoryTree (
			arquivo varchar(100)
			,depth int
			,isfile bit
			,json nvarchar(max)
		);

	insert into #DirectoryTree (arquivo,depth,isfile)
	EXEC master.sys.xp_dirtree @Path,0,1

	while exists (select 1 from #DirectoryTree)
	begin
	
		declare @Arquivo varchar(100)
		declare @Sql VARCHAR(MAX)
		declare @JSON VARCHAR(max)
		declare @Rota varchar(50)
	

		select
			top 1
			@Arquivo = arquivo
		from
			#DirectoryTree
		
		SET @Sql = 'UPDATE #DirectoryTree SET JSON = (SELECT * FROM OPENROWSET(BULK ''' + @Path + @Arquivo + ''', SINGLE_CLOB) AS JSON) where Arquivo=''' + @Arquivo + ''''
		EXEC(@Sql)

		set @Rota = replace(@Arquivo,'.json','')
		set @JSON = (select [json] from #DirectoryTree where arquivo=@Arquivo)
		
		
		exec UspSPELoadRotasV4_Arquivo @Json, @IdTransportadora, @IdStations, @DataColeta
		

		delete #DirectoryTree where arquivo=@Arquivo


	end

end
GO
