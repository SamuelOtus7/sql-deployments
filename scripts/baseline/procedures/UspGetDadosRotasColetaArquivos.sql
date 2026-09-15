-- ============================================================
-- BASELINE: dbo.UspGetDadosRotasColetaArquivos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetDadosRotasColetaArquivos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetDadosRotasColetaArquivos]
as
begin
	
	SET NOCOUNT ON
	declare @Path varchar(100) = 'C:\Scrap\Rotas\JSON_Coopmetro\JSON\'
	declare @DataColeta datetime = '2023-05-21 11:00:00.000' --'2023-02-09 23:59:59.000'
	declare @Transportadora varchar(20) = '1070423464'

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
		
		
		merge db_Irisys_Json.dbo.tb_ml_coleta_rotas as t
		using (
			select 
				@Transportadora cmr_cd_transportadora, 
				@Rota cmr_cd_rota, 
				[json] cmr_ds_json, 
				@DataColeta cmr_dh_coleta, 
				@DataColeta cmr_dh_escrita, 
				null cmr_dh_processamento, 
				0 cmr_in_processado,
				cast(@DataColeta as date) cmr_dh_referencia
			from 
				#DirectoryTree 
			where 
				arquivo=@Arquivo
			) as i
			ON t.cmr_cd_transportadora = i.cmr_cd_transportadora 
			and t.cmr_cd_rota = i.cmr_cd_rota 
			and t.cmr_dh_referencia = i.cmr_dh_referencia
		when matched then
		update set
			t.cmr_ds_json = i.cmr_ds_json
		when not matched by target then 
		insert (
				cmr_cd_transportadora, 
				cmr_cd_rota, 
				cmr_ds_json, 
				cmr_dh_coleta, 
				cmr_dh_escrita, 
				cmt_dh_processamento, 
				cmr_in_processado,
				cmr_dh_referencia
		) values (
				i.cmr_cd_transportadora, 
				i.cmr_cd_rota, 
				i.cmr_ds_json, 
				i.cmr_dh_coleta, 
				i.cmr_dh_escrita, 
				i.cmr_dh_processamento, 
				i.cmr_in_processado,
				i.cmr_dh_referencia
		);


		delete #DirectoryTree where arquivo=@Arquivo


	end

end
GO
