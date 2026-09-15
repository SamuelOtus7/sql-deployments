-- ============================================================
-- BASELINE: dbo.UspGetDadosRotasArquivos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosRotasArquivos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetDadosRotasArquivos]
as
begin
	
	SET NOCOUNT ON
	declare @Path varchar(100) = 'C:\Scrap\Rotas\Bravox\'
	declare @DataColeta datetime = '2023-04-29 11:00:00.000' --'2023-02-09 23:59:59.000'
	declare @Transportadora varchar(20) = '834780814'

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
		declare @ServiceCenter varchar(50)
	

		select
			top 1
			@Arquivo = arquivo
		from
			#DirectoryTree
		
		SET @Sql = 'UPDATE #DirectoryTree SET JSON = (SELECT * FROM OPENROWSET(BULK ''' + @Path + @Arquivo + ''', SINGLE_CLOB) AS JSON) where Arquivo=''' + @Arquivo + ''''
		EXEC(@Sql)

		set @ServiceCenter = replace(@Arquivo,'.json','')
		set @JSON = (select [json] from #DirectoryTree where arquivo=@Arquivo)
		
		
		merge db_Irisys_Json.dbo.tb_ml_coleta_totalizador as t
		using (
			select 
				@Transportadora cmt_cd_transportadora, 
				@ServiceCenter cmt_cd_servicecenter, 
				[json] cmt_ds_json, 
				@DataColeta cmt_dh_coleta, 
				@DataColeta cmt_dh_escrita, 
				null cmt_dh_processamento, 
				0 cmt_in_processado,
				cast(@DataColeta as date) cmt_dh_referencia
			from 
				#DirectoryTree 
			where 
				arquivo=@Arquivo
			) as i
			ON t.cmt_cd_transportadora = i.cmt_cd_transportadora 
			and t.cmt_cd_servicecenter = i.cmt_cd_servicecenter 
			and t.cmt_dh_coleta = i.cmt_dh_coleta
		when matched then
		update set
			t.cmt_ds_json = i.cmt_ds_json
		when not matched by target then 
		insert (
				cmt_cd_transportadora, 
				cmt_cd_servicecenter, 
				cmt_ds_json, 
				cmt_dh_coleta, 
				cmt_dh_escrita, 
				cmt_dh_processamento, 
				cmt_in_processado,
				cmt_dh_referencia
		) values (
				i.cmt_cd_transportadora, 
				i.cmt_cd_servicecenter, 
				i.cmt_ds_json, 
				i.cmt_dh_coleta, 
				i.cmt_dh_escrita, 
				i.cmt_dh_processamento, 
				i.cmt_in_processado,
				i.cmt_dh_referencia
		);


		delete #DirectoryTree where arquivo=@Arquivo


	end

end
GO
