-- ============================================================
-- BASELINE: dbo.UspMLGetRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UspMLGetRotas]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	drop table if exists #coleta_totalizador
	select
		cmt_cd_coleta
		,cmt_in_processado
		,cmt_cd_transportadora
		,cmt_cd_servicecenter
		,cmt_ds_json
		,cmt_dh_coleta
		-- ,cmt_dh_referencia
		,cast(cmt_dh_escrita as date) as cmt_dh_referencia
		,verifica_json
		,row_number() over (order by cmt_cd_coleta ) linha
		into #coleta_totalizador
	from
		(
		SELECT 
			TOP 1000 cmt_cd_coleta, cmt_in_processado, cmt_cd_transportadora, cmt_cd_servicecenter, cmt_ds_json, cmt_dh_coleta, cmt_dh_referencia, cmt_dh_escrita,
			case when left(cmt_ds_json,1) in ('{','[') and cmt_ds_json <> '[]' then 1 else 0 end verifica_json
		
        FROM 
			db_Irisys_Json.dbo.tb_ml_coleta_totalizador WITH (ROWLOCK, READPAST, UPDLOCK)
		WHERE 
			cmt_in_processado = 0 
		ORDER BY 
			cmt_cd_coleta
		) Q


	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @ServiceCenter varchar(20)
	declare @DataColeta datetime
	declare @DataReferencia date
	declare @VerificaJson bit
	declare @Erro bit = 0

	declare @inicio int = 1
	declare @fim int = (select max(linha) from #coleta_totalizador)
	while @inicio <= @fim 
	begin 
		
		set @Erro = 0

		select
			@QueueID = Q.cmt_cd_coleta, 
			@Json = Q.cmt_ds_json,
			@Transportadora = Q.cmt_cd_transportadora,
			@ServiceCenter = Q.cmt_cd_servicecenter,
			@DataColeta = Q.cmt_dh_coleta,
			@DataReferencia = Q.cmt_dh_referencia,
			@VerificaJson = Q.verifica_json
		FROM 
			#coleta_totalizador Q
		where 
			linha = @inicio 

		if @VerificaJson = 1
		--PRINT(@inicio)
		begin
			--Incluido begin try por Saulo Barros em 04/07/2025 para continuar a execução mesmo em caso de erro
			BEGIN TRY
				exec UspMLLoadRotas @Json, @Transportadora, @ServiceCenter, @DataColeta
			END TRY
			BEGIN CATCH
				SET @Erro = 1;
				-- Opcional: registrar o erro em log
				-- PRINT('Erro ao executar UspMLLoadRotas para Coleta: ' + CAST(@QueueID AS VARCHAR))
			END CATCH
		end
		
		update 
			t
		set 
			cmt_dh_processamento = GETDATE(), 
			cmt_in_processado = 1,
			cmt_in_erro = @Erro
		from
			db_Irisys_Json.dbo.tb_ml_coleta_totalizador t
			join #coleta_totalizador b on t.cmt_cd_coleta = b.cmt_cd_coleta
		where 
			b.linha  = @inicio	
		
		set @inicio = @inicio + 1

	
	end

end
GO
