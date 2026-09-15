-- ============================================================
-- BASELINE: dbo.UspMLAtualizaMotoristas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaMotoristas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLAtualizaMotoristas]
as 
begin

	SET NOCOUNT ON;
	
	declare @QueueID bigint = NULL
	declare @Json varchar(max)
	declare @Transportadora varchar(20)
	declare @IdRota int
	declare @DataColeta datetime
	declare @DataReferencia date
	
	drop table if exists #rotas_coletadas
	select
		distinct
		coleta.cmr_cd_coleta,
		coleta.cmr_ds_json,
		coleta.cmr_cd_transportadora,
		coleta.cmr_cd_rota,
		coleta.cmr_dh_coleta,
		coleta.cmr_dh_referencia,
		0 cmr_in_processado
		into #rotas_coletadas
	from
		tb_ml_rotas r with(nolock)
		join db_Irisys_Json.dbo.tb_ml_coleta_rotas coleta with(nolock) on r.IdTransportadora = coleta.cmr_cd_transportadora
										and r.IdRota = coleta.cmr_cd_rota
										and r.DataReferencia = coleta.cmr_dh_referencia
										and coleta.cmr_cd_coleta = (
													select
														max(cmr_cd_coleta)
													from
														db_Irisys_Json.dbo.tb_ml_coleta_rotas aux with(nolock)
													where
														coleta.cmr_cd_rota = aux.cmr_cd_rota 
														and coleta.cmr_cd_transportadora = aux.cmr_cd_transportadora
														and coleta.cmr_dh_referencia = aux.cmr_dh_referencia
													)
	where
		NomeMotorista = '-'
		and isnull(r.Excluido,0) = 0
		and r.DataReferencia < cast(getdate() as date)
	
	while exists (select 1 from #rotas_coletadas where cmr_in_processado = 0)
	begin
		UPDATE 
			Q
		SET 
			@QueueID = Q.cmr_cd_coleta, 
			@Json = Q.cmr_ds_json,
			@Transportadora = Q.cmr_cd_transportadora,
			@IdRota = Q.cmr_cd_rota,
			@DataColeta = Q.cmr_dh_coleta,
			@DataReferencia = Q.cmr_dh_referencia,
			cmr_in_processado = 1
		FROM 
			(
				SELECT 
					TOP 1 cmr_cd_coleta, cmr_in_processado, cmr_cd_transportadora, cmr_cd_rota, cmr_ds_json, cmr_dh_coleta, cmr_dh_referencia
				FROM 
					#rotas_coletadas
				WHERE 
					cmr_in_processado = 0
				ORDER BY 
					cmr_cd_coleta
		) Q
	
	
		exec UspMLLoadRotasRetroativo @Json, @Transportadora, @IdRota, @DataColeta, @DataReferencia

		update 
			#rotas_coletadas 
		set 
			cmr_in_processado = 1
		where 
			cmr_cd_coleta = @QueueID
	
	end

end
GO
