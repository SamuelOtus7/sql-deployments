-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotes_bkp2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotes_bkp2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[UspSPEGetPacotes_bkp2]
as 
begin

	declare @CodigoColeta bigint

	drop table if exists #coleta
	select 
		* 
		into #coleta 
	from 
		tb_spe_export_rotas with(nolock)
	where 
		ser_in_processado = 0 
	order by 
		ser_cd_export

	
	--insere motoristas não cadastrados
	insert into tb_spe_motoristas
	select
		distinct 
		rotas.ser_driver_id,
		null IdTransportadora,
		null StationId,
		rotas.ser_driver_name,
		null TipoVeiculo,
		null TotalEntregas,
		null Latitude,
		null Longitude,
		case when CHARINDEX(')', rotas.ser_driver_name) > 1 then rtrim(ltrim(replace(left(rotas.ser_driver_name, CHARINDEX(')', rotas.ser_driver_name)-1),'(',''))) end Transportadora,
		case when CHARINDEX(')', rotas.ser_driver_name) > 1 then rtrim(ltrim(replace(right(rotas.ser_driver_name, len(rotas.ser_driver_name)-CHARINDEX(')', rotas.ser_driver_name)),'(',''))) else rotas.ser_driver_name end NomeMotorista
	from
		#coleta rotas with(nolock)
		left join tb_spe_motoristas motoristas with(nolock) on rotas.ser_driver_id = motoristas.IdMotorista
	where
		motoristas.IdMotorista is null
		


	--Vincula transportadora
	drop table if exists #transportadoras
	SELECT 
		cli_id_shopee, 
		value transportadora
		into #transportadoras
	FROM 
		tb_clientes  
		CROSS APPLY STRING_SPLIT(cli_nm_shopee, ',')
	where
		cli_id_shopee <> 0

	update
		m
	set
		IdTransportadora = t.cli_id_shopee
	from
		tb_spe_motoristas m
		join #transportadoras t on m.Transportadora like '%' + t.transportadora + '%'


	--caso não encontre motorista não é gerado pacote
	update
		c 
	set
		ser_in_processado = 1,
		ser_gerado_pacote = 0
	from
		tb_spe_export_rotas c
		join #coleta c2 on c.ser_cd_export = c2.ser_cd_export
		left join tb_spe_motoristas m on c.ser_driver_id = m.IdMotorista and m.IdTransportadora is not null
	where
		c.ser_in_processado = 0
		and m.IdMotorista is null

	update
		c2
	set
		ser_in_processado = 1
	from
		#coleta c2
		left join tb_spe_motoristas m on c2.ser_driver_id = m.IdMotorista and m.IdTransportadora is not null
	where
		m.IdMotorista is null


		
	while exists (select 1 from #coleta where ser_in_processado = 0)
	begin
		
		set @CodigoColeta = (select top 1 ser_cd_export from #coleta where ser_in_processado = 0 order by ser_cd_export)
		
		drop table if exists #pacotes
		select
			top 1
			ser_order_id CodigoPacote,
			ser_carrier_id IdTransportadora,
			ser_station_id IdStation,

			case when ser_onhold_time is not null then cast(ser_onhold_time as date)
			else case when ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) = cast(ser_delivered_time as date) then cast(ser_onhold_time as date)
			else case when ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) <> cast(ser_delivered_time as date) then cast(ser_onhold_time as date)
			else case when ser_onhold_time is null and ser_delivered_time is not null then cast(ser_delivered_time as date)
			else case when ser_onhold_time is null and ser_delivered_time is null then cast(ser_delivering_time as date)
			end end end end end DataReferencia,

			ser_onhold_time DataInsucesso,
			ser_delivered_time DataEntregue,
			ser_delivering_time DataPendente,
			case when ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) <> cast(ser_delivered_time as date) then 1 else 0 end GerarDuasRotas,

			case ser_status
				when 'Delivered' then ser_delivered_time
				when 'Delivering' then ser_delivering_time
				when 'OnHold' then ser_onhold_time
			end DataHoraEntrega,

			ser_status StatusEntrega,
			ser_driver_id IdMotorista,
			ser_buyer_name Comprador,
			ser_latitude Latitude,
			ser_longitude Longitude,
			null URLImagem,
			getdate() DataAtualizacao

			into #pacotes
		from
			#coleta
		where
			ser_in_processado = 0
		order by
			ser_cd_export
			

		if exists (select 1 from #pacotes where GerarDuasRotas = 1)
		begin
			insert into #pacotes
			select
				CodigoPacote
				,IdTransportadora
				,IdStation
				,cast(DataEntregue as date) DataReferencia
				,DataInsucesso
				,DataEntregue
				,DataPendente
				,GerarDuasRotas
				,DataHoraEntrega
				,StatusEntrega
				,IdMotorista
				,Comprador
				,Latitude
				,Longitude
				,URLImagem
				,DataAtualizacao
			from
				#pacotes

		end

		--considera a transportadora vinculada ao motorista
		update
			p
		set
			p.IdTransportadora = m.IdTransportadora
		from
			#pacotes p
			join tb_spe_motoristas m on p.IdMotorista = m.IdMotorista
		
			
		merge tb_spe_pacotes as p
		using #pacotes as i
				ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
		when matched then
		update set
			p.IdStation = i.IdStation
			,p.DataHoraEntrega = i.DataHoraEntrega
			,p.StatusEntrega = i.StatusEntrega
			,p.IdMotorista = i.IdMotorista
			,p.RecebidoPor = i.Comprador
			,p.Latitude = i.Latitude
			,p.Longitude = i.Longitude
			,p.URLImagem = i.URLImagem
			,p.DataAtualizacao = i.DataAtualizacao
		when not matched by target then 
		insert (
				CodigoPacote
				,IdTransportadora
				,IdStation
				,DataReferencia
				,DataHoraEntrega
				,StatusEntrega
				,IdMotorista
				,RecebidoPor
				,Latitude
				,Longitude
				,URLImagem
				,DataAtualizacao
		)
		values (
				i.CodigoPacote
				,i.IdTransportadora
				,i.IdStation
				,i.DataReferencia
				,i.DataHoraEntrega
				,i.StatusEntrega
				,i.IdMotorista
				,i.Comprador
				,i.Latitude
				,i.Longitude
				,i.URLImagem
				,i.DataAtualizacao
		);

		update tb_spe_export_rotas set ser_in_processado=1, ser_dh_processamento=getdate(), ser_in_erro = 0, ser_gerado_pacote = 1 where ser_cd_export = @CodigoColeta
		update #coleta set ser_in_processado=1 where ser_cd_export = @CodigoColeta
	

		drop table if exists #rotas
		select 
			distinct 
			IdTransportadora, 
			IdMotorista, 
			DataReferencia, 
			IdStation 
			into #rotas 
		from 
			#pacotes


		merge tb_spe_rotas as r
		using #rotas as i
				ON r.IdTransportadora = i.IdTransportadora and r.DataReferencia = i.DataReferencia and r.IdMotorista = i.IdMotorista
		when matched then
		update set
			r.IdStation = i.IdStation
			,r.DataAtualizacao = getdate()
			,r.Excluido = 0
		when not matched by target then 
		insert (
				IdTransportadora
				,DataReferencia
				,IdStation
				,IdMotorista
				,DataAtualizacao
				,Excluido
		)
		values (
				i.IdTransportadora
				,i.DataReferencia
				,i.IdStation
				,i.IdMotorista
				,getdate()
				,0
		);
	
	end
	



end
GO
