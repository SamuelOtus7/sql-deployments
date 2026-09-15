-- ============================================================
-- BASELINE: dbo.UspMLLHGetRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLHGetRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLLHGetRotas]
as 
begin

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	drop table if exists #coleta_rotas
	select
		dac_cd_coleta
		,cast(dac_cd_transportadora as int) dac_cd_transportadora
		,dac_ds_contexto_json
		,dac_dh_coleta
		,cast(dac_dh_referencia as date) dac_dh_referencia
		,verifica_json
		,row_number() over (order by dac_cd_coleta ) linha
		into #coleta_rotas
	from
		(
		SELECT 
			TOP 1000 dac_cd_coleta, dac_cd_transportadora, dac_ds_contexto_json, dac_dh_coleta, dac_dh_referencia,
			case when left(dac_ds_contexto_json,1) in ('{','[') and dac_ds_contexto_json <> '[]' then 1 else 0 end verifica_json
        FROM 
			db_Irisys_Json.dbo.tb_dra_coleta WITH (ROWLOCK, READPAST, UPDLOCK)
		WHERE 
			dac_in_processado = 0
			and dac_ds_tipo_coleta = 'ML_LH_ROUTES'
		ORDER BY 
			dac_cd_coleta
		) Q


	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora int
	declare @TransportadoraJson int
	declare @DataColeta datetime
	declare @DataReferencia date
	declare @VerificaJson bit
	declare @Erro bit = 0

	declare @inicio int = 1
	declare @fim int = (select max(linha) from #coleta_rotas)
	while @inicio <= @fim 
	begin 
		
		select
			@QueueID = Q.dac_cd_coleta, 
			@Json = Q.dac_ds_contexto_json,
			@Transportadora = Q.dac_cd_transportadora,
			@DataColeta = Q.dac_dh_coleta,
			@DataReferencia = Q.dac_dh_referencia,
			@VerificaJson = Q.verifica_json
			--@TransportadoraJson = try_cast(JSON_VALUE(Q.dac_ds_contexto_json, '$.line_hauls_by_route.list[0].carrier_id') as int)
		FROM 
			#coleta_rotas Q
		where 
			linha = @inicio 

		--Adicionado verificação de TransportadoraJson por Saulo Barros em 02/03/2026
		--Motivo: existem algumas transportadora que está coletando dados de outra transportadora, por tanto, só deve 
		--		  chamar a procedure UspMLLHLoadRotas se for da mesma transportadora

		--Comentado em 10/04/2026 por Saulo Barros pois foi verificado que o Json contém varias listas de várias transportadoras
		--	então a verificação tem que ser feita na procedure UspMLLHLoadRotas e não aqui
		
		if @VerificaJson = 1 --and @Transportadora = isnull(@TransportadoraJson,0)
		--PRINT(@inicio)
		begin
			exec UspMLLHLoadRotas @Json, @Transportadora, @DataColeta, @DataReferencia
		end
		
		update 
			t
		set 
			dac_dh_processamento = GETDATE(), 
			dac_in_processado = 1,
			dac_in_erro = @Erro
		from
			db_Irisys_Json.dbo.tb_dra_coleta t
			join #coleta_rotas b on t.dac_cd_coleta = b.dac_cd_coleta
		where 
			b.linha  = @inicio	
		
		set @inicio = @inicio + 1

	end

end
GO
