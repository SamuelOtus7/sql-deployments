-- ============================================================
-- BASELINE: dbo.UspSPEGetPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPEGetPacotes]
as 
begin

	--update 
	--	tb_spe_export_rotas 
	--set 
	--	ser_in_processado=1, 
	--	ser_dh_processamento=getdate(), 
	--	ser_gerado_pacote=0 
	--where 
	--	ser_current_station='XPT_SP_Guaratinguetá'
	--	and ser_in_processado = 0

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

	--Acrescenta 03 horas nas colunas de datas
	update 
		#coleta 
	set 
		ser_delivering_time = dateadd(hour,3,ser_delivering_time),
		ser_delivered_time = dateadd(hour,3,ser_delivered_time),
		ser_onhold_time = dateadd(hour,3,ser_onhold_time)
	
	
	
	--insere motoristas não cadastrados
	insert into tb_spe_motoristas (IdMotorista, IdTransportadora, IdStation, Nome, TipoVeiculo, TotalEntregas, Latitude, Longitude, Transportadora, NomeMotorista)
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
		case when CHARINDEX(')', rotas.ser_driver_name) > 1 then ltrim(rtrim(right(ltrim(rtrim(rotas.ser_driver_name)), len(ltrim(rtrim(rotas.ser_driver_name)))-CHARINDEX(')', ltrim(rtrim(rotas.ser_driver_name)))))) else  ltrim(rtrim(rotas.ser_driver_name)) end NomeMotorista
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
		left join tb_clientes cli on m.IdTransportadora = cli.cli_id_shopee
	where
		c.ser_in_processado = 0
		and (m.IdMotorista is null or cli.cli_nm_versao_spe <> 1)

	update
		c2
	set
		ser_in_processado = 1
	from
		#coleta c2
		left join tb_spe_motoristas m on c2.ser_driver_id = m.IdMotorista and m.IdTransportadora is not null
		left join tb_clientes cli on m.IdTransportadora = cli.cli_id_shopee
	where
		m.IdMotorista is null
		and (m.IdMotorista is null or cli.cli_nm_versao_spe <> 1)



	drop table if exists #pacotes_aux
	select
		ser_data_exportacao DataExportacao,
		ser_order_id CodigoPacote,
		m.IdTransportadora IdTransportadora,
		ser_current_station NomeHub,

		case when ser_onhold_time is not null then cast(ser_onhold_time as date)
		else case when ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) = cast(ser_delivered_time as date) then cast(ser_onhold_time as date)
		else case when ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) <> cast(ser_delivered_time as date) then cast(ser_onhold_time as date)
		else case when ser_onhold_time is null and ser_delivered_time is not null then cast(ser_delivered_time as date)
		else case when ser_onhold_time is null and ser_delivered_time is null then cast(ser_delivering_time as date)
		end end end end end DataReferencia,

		ser_onhold_time DataInsucesso,
		ser_delivered_time DataEntregue,
		ser_delivering_time DataPendente,
		--case when ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) <> cast(ser_delivered_time as date) then 1 else 0 end GerarDuasRotas,
		case when 
			(ser_onhold_time is not null and ser_delivered_time is not null and cast(ser_onhold_time as date) <> cast(ser_delivered_time as date))
			or
			(ser_onhold_time is not null and ser_delivering_time is not null and cast(ser_onhold_time as date) <> cast(ser_delivering_time as date))
		then 1 else 0 end GerarDuasRotas,

		case ser_status
			when 'Delivered' then ser_delivered_time
			when 'Delivering' then ser_delivering_time
			when 'OnHold' then ser_onhold_time
		end DataHoraEntrega,
		
		ser_status StatusEntrega,
		case when ser_status = 'OnHold' then ser_onhold_reason end SubStatus,
		ser_driver_id IdMotorista,
		ser_buyer_name Comprador,
		ser_latitude Latitude,
		ser_longitude Longitude,
		null URLImagem,
		getdate() DataAtualizacao

		into #pacotes_aux
	from
		#coleta c
		join tb_spe_motoristas m on c.ser_driver_id = m.IdMotorista
	where
		ser_in_processado = 0
	
	
	--Considera apenas a última informação coletada
	drop table if exists #pacotes
	select
		*
		into #pacotes
	from
		#pacotes_aux p
	where
		DataExportacao = (
			select
				max(DataExportacao)
			from
				#pacotes_aux p2
			where
				p.CodigoPacote = p2.CodigoPacote
				and p.IdTransportadora = p2.IdTransportadora
				and p.DataReferencia = p2.DataReferencia
	)
	
	
	--Gera novos pacotes alterando data referencia quando necessário
	insert into #pacotes
	select
		DataExportacao
		,CodigoPacote
		,IdTransportadora
		,NomeHub
		,cast(isnull(DataEntregue,DataPendente) as date) DataReferencia
		,DataInsucesso
		,DataEntregue
		,DataPendente
		,GerarDuasRotas
		,DataHoraEntrega
		,StatusEntrega
		,SubStatus
		,IdMotorista
		,Comprador
		,Latitude
		,Longitude
		,URLImagem
		,DataAtualizacao
	from
		#pacotes
	where 
		GerarDuasRotas=1
	
	
	drop table if exists #pacotesSemDuplicatas
	select pacotes.*
	into #pacotesSemDuplicatas
	from #pacotes as pacotes
		inner join (
						select CodigoPacote, IdTransportadora, DataReferencia, max(DataExportacao) as UltimaExportacao
						from #pacotes
						group by CodigoPacote, IdTransportadora, DataReferencia
				   ) as UltimaAtualizacao
		on pacotes.IdTransportadora = UltimaAtualizacao.IdTransportadora
		and pacotes.DataReferencia = UltimaAtualizacao.DataReferencia
		and pacotes.CodigoPacote = UltimaAtualizacao.CodigoPacote
		and pacotes.DataExportacao = UltimaAtualizacao.UltimaExportacao

	--o que mantem duplicado, apaga para manter apenas o pacote com a ultima data de entrega
	delete
		p
	from
		#pacotesSemDuplicatas p
		join (
			select
				CodigoPacote,
				IdTransportadora,
				DataReferencia
			from
				#pacotesSemDuplicatas
			group by
				CodigoPacote,
				IdTransportadora,
				DataReferencia
			having
				count(1) > 1
		) p2 on p.CodigoPacote = p2.CodigoPacote and p.IdTransportadora = p2.IdTransportadora and p.DataReferencia = p2.DataReferencia
	where
		p.DataHoraEntrega < (
			select
				max(DataHoraEntrega)
			from
				#pacotesSemDuplicatas p3
			where
				p.CodigoPacote = p3.CodigoPacote 
				and p.IdTransportadora = p3.IdTransportadora 
				and p.DataReferencia = p3.DataReferencia
		)


	merge tb_spe_pacotes as p
	using (
			select
				distinct
				p.*,
				s.IdStation
			from
				#pacotesSemDuplicatas  p
				join tb_spe_station s on p.NomeHub = s.NomeStation
			
		 ) as i
			ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
	when matched then
	update set
		p.IdStation = i.IdStation
		,p.DataHoraEntrega = i.DataHoraEntrega
		,p.StatusEntrega = i.StatusEntrega
		,p.SubStatus = i.SubStatus
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
			,SubStatus
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
			,i.SubStatus
			,i.IdMotorista
			,i.Comprador
			,i.Latitude
			,i.Longitude
			,i.URLImagem
			,i.DataAtualizacao
	);


	--atualiza status processado
	update 
		coleta
	set 
		ser_in_processado=1, 
		ser_dh_processamento=getdate(), 
		ser_in_erro = 0, 
		ser_gerado_pacote = 1
	from
		tb_spe_export_rotas coleta
		join #coleta temp on coleta.ser_cd_export = temp.ser_cd_export
	where
		temp.ser_in_processado = 0
		
	

	drop table if exists #rotas
	select 
		IdTransportadora, 
		IdMotorista, 
		DataReferencia, 
		max(IdStation) as IdStation
		into #rotas 
	from 
		(
			select
				p.*,
				s.IdStation
			from
				#pacotesSemDuplicatas  p
				join tb_spe_station s on p.NomeHub = s.NomeStation
			
		 ) t
	group by IdTransportadora, 
		     IdMotorista, 
		     DataReferencia


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
GO
