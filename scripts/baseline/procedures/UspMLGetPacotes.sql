-- ============================================================
-- BASELINE: dbo.UspMLGetPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLGetPacotes]
as 
begin

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET XACT_ABORT ON;
SET NOCOUNT ON;

if object_id('tempdb..#tabela') is not null  drop table #tabela
select
	Q.cmr_cd_coleta, 
	Q.cmr_ds_json,
	Q.cmr_cd_transportadora,
	Q.cmr_cd_rota,
	Q.cmr_dh_coleta,
	Q.cmr_dh_referencia,
	Q.verifica_json,
	row_number() over (order by cmr_cd_coleta ) linha

	into #tabela

FROM 
	(
		SELECT 
			TOP 100
			cmr_cd_coleta, cmr_in_processado, cmr_cd_transportadora, cmr_cd_rota, cmr_ds_json, cmr_dh_coleta, cmr_dh_referencia,
			case when left(cmr_ds_json,1) in ('{','[') and cmr_ds_json <> '[]' then 1 else 0 end verifica_json

		FROM 
			db_Irisys_Json.dbo.tb_ml_coleta_rotas WITH (ROWLOCK, READPAST, UPDLOCK)
		WHERE 
			cmr_in_processado = 0
			ORDER BY 
			cmr_cd_coleta
) Q



declare @QueueID bigint = NULL
declare @Json varchar(max)
declare @Transportadora varchar(20)
declare @IdRota int
declare @DataColeta datetime
declare @DataReferencia date
declare @VerificaJson bit
declare @Erro bit = 0

declare @inicio int = 1
declare @fim int = (select max(linha)  from #tabela)

while @inicio <= @fim 
	begin 

	select 
	@QueueID = Q.cmr_cd_coleta, 
	@Json = Q.cmr_ds_json,
	@Transportadora = Q.cmr_cd_transportadora,
	@IdRota = Q.cmr_cd_rota,
	@DataColeta = Q.cmr_dh_coleta,
	@DataReferencia = Q.cmr_dh_referencia,
	@VerificaJson = Q.verifica_json
	from #tabela Q
	where linha  = @inicio 

	
	exec UspMLLoadPacotes @Json, @Transportadora, @IdRota, @DataColeta, @DataReferencia
	set @Erro = 0
	--select @QueueID

	update a
	set
		cmt_dh_processamento = GETDATE(), 
		cmr_in_processado = 1,
		cmt_in_erro = @Erro
	
	from db_Irisys_Json.dbo.tb_ml_coleta_rotas as a
	inner join #tabela as b
	on a.cmr_cd_coleta = b.cmr_cd_coleta
	where b.linha  = @inicio	

	set @inicio = @inicio + 1

	end 
end

	--coleta 27694372,27694394

GO
