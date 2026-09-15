-- ============================================================
-- BASELINE: dbo.UspGeraDistributedPointsGEO
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraDistributedPointsGEO]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGeraDistributedPointsGEO]

as

begin

	drop table if exists #rotas
	select 
		distinct
		rotas.NomeMotorista,
		rotas.IdRota,
		rotas.DataReferencia,
		rotas.IdTransportadora as IdTransportadora
		into #rotas
	from 
		vw_tb_apontamento_geo geo
		join tb_ml_rotas rotas with(nolock) on geo.apg_cd_transportadora = rotas.IdTransportadora
											and geo.apg_cd_motorista = rotas.NomeMotorista
											and cast(geo.DataHoraReferencia as date) = rotas.DataReferencia
		left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
													and rotas.DataReferencia = coleta.dam_dh_referencia
													and rotas.IdTransportadora = coleta.dam_cd_transportadora
													and coleta.dam_nm_origem = 'Geo'
													and coleta.dam_cd_marketplace = 1
	where
		coleta.dam_cd_coleta is null
		and (rotas.DataReferencia < cast(getdate() as date) or rotas.StatusRota = 'close')
		and not exists (select 1 from tb_ml_gps_maps_geo p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		and not exists (select 1 from vw_rotas_para_reprocessar r where rotas.IdRota = r.IdRota and rotas.DataReferencia = r.DataReferencia and rotas.IdTransportadora = r.IdTransportadora)
		and DataReferencia >= '2023-04-01' 
		
		
		
	
	declare @Motorista varchar(100)
	declare @Rota int
	declare @IdTransportadora int
	declare @DataReferencia date

	while exists (select 1 from #rotas)
	begin
		select
			top 1
			@Motorista = NomeMotorista,
			@Rota = idRota,
			@IdTransportadora = IdTransportadora,
			@DataReferencia = DataReferencia
		from
			#rotas

		exec UspGetpDistributedPointsGEO @Motorista, @Rota, @IdTransportadora, @DataReferencia

		delete #rotas where idRota = @Rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia 

	end


end
GO
