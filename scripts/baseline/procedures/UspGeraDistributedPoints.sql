-- ============================================================
-- BASELINE: dbo.UspGeraDistributedPoints
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraDistributedPoints]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspGeraDistributedPoints]

as

begin

	drop table if exists #rotas
	select
		rotas.IdRota,
		rotas.DataReferencia,
		rotas.IdTransportadora
		into #rotas
	from
		tb_ml_rotas rotas with(nolock)
		left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
													and rotas.DataReferencia = coleta.dam_dh_referencia
													and rotas.IdTransportadora = coleta.dam_cd_transportadora
													and coleta.dam_nm_origem = 'Logistics'
													and coleta.dam_cd_marketplace = 1
		left join tb_ml_service_center_teste svc with(nolock) on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center and rotas.idtransportadora = svc.idtransportadora
		left join tb_ml_service_center_teste svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center and rotas.idtransportadora = svc2.idtransportadora
	where
		coleta.dam_cd_coleta is null
		--and rotas.TotalPacotes = rotas.PacotesEntregues + rotas.PacotesNaoEntregue
		and rotas.Excluido = 0
		and rotas.TotalPacotes > 0
		and case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end is not null 
		and case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end is not null
		and not exists (select 1 from tb_ml_pacotes_maps p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		and not exists (select 1 from vw_rotas_para_reprocessar r where rotas.IdRota = r.IdRota and rotas.DataReferencia = r.DataReferencia and rotas.IdTransportadora = r.IdTransportadora)
		and (rotas.DataReferencia < cast(getdate() as date) or rotas.StatusRota = 'close')
		and rotas.DataReferencia >= '2024-04-01'
		and rotas.idtransportadora = 2087146923

		
	declare @Rota int
	declare @IdTransportadora int
	declare @DataReferencia date

	while exists (select 1 from #rotas)
	begin
		select
			top 1
			@Rota = idRota,
			@IdTransportadora = IdTransportadora,
			@DataReferencia = DataReferencia
		from
			#rotas

		exec UspGetpDistributedPoints @Rota, @IdTransportadora, @DataReferencia

		delete #rotas where idRota = @Rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia

	end


end
GO
