-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotesV4_Arquivo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotesV4_Arquivo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspSPEGetPacotesV4_Arquivo]
as
begin

	declare @Path varchar(100) = 'C:\Scrap\Rotas\50mais\Leitura\'
	declare @DataColeta datetime = '2023-08-10 19:00:00.000'
	declare @IdTransportadora int = 20230007
	

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
	

		select
			top 1
			@Arquivo = arquivo
		from
			#DirectoryTree
		
		SET @Sql = 'UPDATE #DirectoryTree SET JSON = (SELECT * FROM OPENROWSET(BULK ''' + @Path + @Arquivo + ''', SINGLE_CLOB) AS JSON) where Arquivo=''' + @Arquivo + ''''
		EXEC(@Sql)

		
		set @JSON = (select [json] from #DirectoryTree where arquivo=@Arquivo)
		 
		 DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'packages')
		 

		--drop table if exists #pacotes
		--create table #pacotes(
		--	Id int not null identity(1,1),
		--	CodigoRota varchar(30)  null,
		--	CodigoPacote varchar(30) not null,
		--	IdTransportadora int not null,
		--	DataReferencia date null,
		--	DataHoraColeta datetime not null,
		--	DataHoraEntrega datetime not null,
		--	IdStatus int not null,
		--	IdSubstatus int null,
		--	IdMotorista int null,
		--	CEP varchar(9) null
		--)
		--insert into #pacotes
		--select 
		--	CodigoRota CodigoRota
		--	,CodigoPacote
		--	,@IdTransportadora IdTransportadora
		--	,case IdStatus
		--		when 2 then cast(dateadd(second,((cast(DataHoraEmEntrega as bigint))) - 10800,'1970-01-01') as date)
		--		when 1 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
		--		when 3 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
		--		when 5 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
		--		when 10 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
		--		when 125 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
		--		when 460 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
		--		when 4 then cast(dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') as date)
		--	end DataReferencia
		--	,@DataColeta DataColeta
		--	,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
		--	,case when IdStatus in (1, 10, 125, 460) then 5 else IdStatus end IdStatus
		--	,IdInsucesso
		--	,IdMotorista
		--	,CEP
		--from 
		--	openjson(@JsonList)
		--	WITH (
		--		CodigoRota varchar(1000) '$.assignment_task_id',
		--		CodigoPacote varchar(1000) '$.shipment_id',
		--		DataHoraEntrega varchar(1000) '$.delivered_time',
		--		DataHoraEmEntrega varchar(1000) '$.delivering_time',
		--		DataHoraInsucesso varchar(1000) '$.on_hold_time',
		--		IdStatus varchar(1000) '$.order_status',
		--		IdInsucesso varchar(1000) '$.on_hold_reason',
		--		IdMotorista varchar(1000) '$.driver_id',
		--		CEP varchar(1000) '$.postal_code'
		--	)
		
		
		

		exec UspSPELoadPacotesV4_Arquivo @Json, @IdTransportadora, @DataColeta


		delete #DirectoryTree where arquivo=@Arquivo


	end
	
	--truncate table #pacotes
	--select * from #pacotes where DataReferencia is null
	--select * from #pacotes where CodigoRota is null
	--select distinct IdStatus from #pacotes order by 1 

end
GO
