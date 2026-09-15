-- ============================================================
-- BASELINE: dbo.UspGeraDistributedPointsShopee
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraDistributedPointsShopee]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGeraDistributedPointsShopee]

as

begin

	drop table if exists #rotas
	create table #rotas (CodigoRota varchar(30), DataReferencia date, IdTransportadora int, Versao varchar(30))

	insert into #rotas
	select
		rotas.CodigoRota,
		rotas.DataReferencia,
		rotas.IdTransportadora,
		'Novo' Versao
	from
		tb_spe_rotas_novo rotas with(nolock)
		left join tb_dra_coleta_maps coleta with(nolock) on rotas.CodigoRota = coleta.dam_cd_rota 
													and rotas.DataReferencia = coleta.dam_dh_referencia
													and rotas.IdTransportadora = coleta.dam_cd_transportadora
													and coleta.dam_nm_origem = 'Shopee'
													and coleta.dam_cd_marketplace = 2
		join tb_spe_station hub with(nolock) on rotas.IdStation = hub.IdStation
	where
		coleta.dam_cd_coleta is null
		and rotas.Excluido = 0
		and rotas.TotalPacotes = rotas.PacotesEntregues + rotas.PacotesNaoEntregue
		and hub.Latitude is not null
		and hub.Longitude is not null
		and not exists (select 1 from tb_spe_pacotes_maps p with(nolock) where rotas.CodigoRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		
	insert into #rotas
	select
		rotas.CodigoRota,
		rotas.DataReferencia,
		rotas.IdTransportadora,
		'V4' Versao
	from
		tb_spe_rotas_v4 rotas with(nolock)
		left join tb_dra_coleta_maps coleta with(nolock) on rotas.CodigoRota = coleta.dam_cd_rota 
													and rotas.DataReferencia = coleta.dam_dh_referencia
													and rotas.IdTransportadora = coleta.dam_cd_transportadora
													and coleta.dam_nm_origem = 'Shopee'
													and coleta.dam_cd_marketplace = 2
		join tb_spe_station hub with(nolock) on rotas.IdStation = hub.IdStation
	where
		coleta.dam_cd_coleta is null
		and rotas.Excluido = 0
		and rotas.TotalPacotes = rotas.PacotesEntregues + rotas.PacotesNaoEntregue
		and hub.Latitude is not null
		and hub.Longitude is not null
		and not exists (select 1 from tb_spe_pacotes_maps p with(nolock) where rotas.CodigoRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		

	declare @Rota varchar(30)
	declare @IdTransportadora int
	declare @DataReferencia date
	declare @Versao varchar(30)

	while exists (select 1 from #rotas)
	begin
		select
			top 1
			@Rota = CodigoRota,
			@IdTransportadora = IdTransportadora,
			@DataReferencia = DataReferencia,
			@Versao = Versao
		from
			#rotas

		exec UspGetpDistributedPointsShopee @Rota, @IdTransportadora, @DataReferencia, @Versao

		delete #rotas where CodigoRota = @Rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia

	end


end
GO
