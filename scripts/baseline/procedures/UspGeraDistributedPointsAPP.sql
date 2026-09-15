-- ============================================================
-- BASELINE: dbo.UspGeraDistributedPointsAPP
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraDistributedPointsAPP]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGeraDistributedPointsAPP]

as

begin

	drop table if exists #temp_rotas
	select
		IdRota,
		DataReferencia,
		IdTransportadora,
		NomeMotorista,
		UsuarioDA
		into #temp_rotas
	from
		tb_ml_rotas rotas with(nolock)
	where
		DataReferencia >= dateadd(month,-1,cast(getdate() as date))
		and (rotas.DataReferencia < cast(getdate() as date) or rotas.StatusRota = 'close')
		and not exists (select 1 from tb_ml_gps_maps_app p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		and not exists (select 1 from vw_rotas_para_reprocessar r where rotas.IdRota = r.IdRota and rotas.DataReferencia = r.DataReferencia and rotas.IdTransportadora = r.IdTransportadora)
	
	declare @data_inicio date = (select min(DataReferencia) from #temp_rotas)

	drop table if exists #temp_gps
	select
		rgp_cd_usuario,
		cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date) rgp_dh_data_hora
		into #temp_gps
	from
		tb_registro_gps as gps with(nolock)
	where
		dateadd(hour,-3,gps.rgp_dh_data_hora) >= @data_inicio


	drop table if exists #rotas
	create table #rotas (
		IdUsuario int not null,
		IdRota int not null,
		DataReferencia date not null,
		IdTransportadora int not null,
		Origem varchar(100) not null
	)
	insert into #rotas
	select 
		distinct
		gps.rgp_cd_usuario IdUsuario,
		rotas.IdRota,
		rotas.DataReferencia,
		rotas.IdTransportadora as IdTransportadora,
		'DA' Origem
	from 
		#temp_gps as gps
		join tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
		join tb_clientes as cli with(nolock) on users.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente
		join #temp_rotas rotas  on cli.cli_id_logistics = rotas.IdTransportadora 
								--and users.usr_nm_usuario = rotas.NomeMotorista
								and gps.rgp_cd_usuario = rotas.UsuarioDA
								and rgp_dh_data_hora = rotas.DataReferencia	
		left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
													and rotas.DataReferencia = coleta.dam_dh_referencia
													and rotas.IdTransportadora = coleta.dam_cd_transportadora
													and coleta.dam_nm_origem = 'App'
													and coleta.dam_cd_marketplace = 1
	where
		coleta.dam_cd_coleta is null
	
	/*

	insert into #rotas
	select 
		distinct
		gps.rgp_cd_usuario IdUsuario,
		rotas.IdRota,
		rotas.DataReferencia,
		rotas.IdTransportadora as IdTransportadora,
		'PlayTelematics' Origem
	from 
		db_PlayTelematics.dbo.tb_registro_gps as gps with(nolock)
		join db_PlayTelematics.dbo.tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
		join db_PlayTelematics.dbo.tb_clientes as cli with(nolock) on users.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente
		join tb_ml_rotas rotas with(nolock) on cli.cli_id_logistics = rotas.IdTransportadora 
								and users.usr_nm_usuario = rotas.NomeMotorista
								and cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)  = rotas.DataReferencia	
		left join tb_dra_coleta_maps coleta with(nolock) on rotas.IdRota = coleta.dam_cd_rota 
													and rotas.DataReferencia = coleta.dam_dh_referencia
													and rotas.IdTransportadora = coleta.dam_cd_transportadora
													and coleta.dam_nm_origem = 'App'
	where
		coleta.dam_cd_coleta is null
		and DataReferencia < cast(getdate() as date)
		and not exists (select 1 from tb_ml_gps_maps_app p with(nolock) where rotas.IdRota = p.Rota and rotas.DataReferencia = p.DataReferencia and rotas.IdTransportadora = p.IdTransportadora)
		and not exists (select 1 from vw_rotas_para_reprocessar r where rotas.IdRota = r.IdRota and rotas.DataReferencia = r.DataReferencia and rotas.IdTransportadora = r.IdTransportadora)
		and DataReferencia >= '2023-04-01'
	
	*/
	
	declare @Rota int
	declare @IdTransportadora int
	declare @DataReferencia date
	declare @IdUsuario int
	declare @Origem varchar(100)

	while exists (select 1 from #rotas)
	begin
		select
			top 1
			@IdUsuario = IdUsuario,
			@Rota = idRota,
			@IdTransportadora = IdTransportadora,
			@DataReferencia = DataReferencia,
			@Origem = Origem
		from
			#rotas

		exec UspGetpDistributedPointsAPP @IdUsuario, @Rota, @IdTransportadora, @DataReferencia, @Origem

		delete #rotas where idRota = @Rota and IdTransportadora = @IdTransportadora and DataReferencia = @DataReferencia

	end


end
GO
