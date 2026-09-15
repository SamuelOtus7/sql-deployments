-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesV2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesV2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPELoadPacotesV2] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@IdStation int,
	@IdMotorista int,
	@DataColeta datetime
)
as
begin
	
	SET NOCOUNT ON;


	--declare @Json varchar(max)
	--declare @Transportadora varchar(20)
	--declare @IdStation int
	--declare @IdMotorista int
	--declare @DataColeta datetime
	--
	--select
	--	@Json = Q.dac_ds_contexto_json,
	--	@IdTransportadora = Q.dac_cd_transportadora,
	--	@IdStation = left(dac_ds_contexto,CHARINDEX(';',dac_ds_contexto)-1),
	--	@IdMotorista = right(dac_ds_contexto,len(dac_ds_contexto)-CHARINDEX(';',dac_ds_contexto)),
	--	@DataColeta = Q.dac_dh_coleta
	--from
	--	db_Irisys_Json.dbo.tb_dra_coleta Q
	--where
	--	dac_cd_coleta=1583381

	update
		tb_spe_motoristas
	set
		IdTransportadora = @IdTransportadora
	where
		IdTransportadora is null
		and IdMotorista = @IdMotorista


	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')
	
	drop table if exists #pacotes
	create table #pacotes(
		CodigoRota varchar(30) not null,
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		IdStation int not null,
		IdMotorista int not null,
		DataReferencia date not null,
		DataHoraColeta datetime not null,
		DataHoraEntrega datetime not null,
		IdStatus int not null,
		IdSubstatus int null,
		AssigmentTask varchar(30) null
	)
	
		
	insert into #pacotes
	select convert(varchar,cast(dateadd(second,((cast(DataReferencia as bigint))) - 10800,'1970-01-01') as date),112)
		   + '-' + cast(@IdMotorista as varchar(10)) as CodigoRota
		,CodigoPacote
		,@IdTransportadora IdTransportadora
		,@IdStation
		,@IdMotorista
		,cast(dateadd(second,((cast(DataReferencia as bigint))) - 10800,'1970-01-01') as date) DataReferencia
		,@DataColeta DataColeta
		,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
		,IdStatus
		,IdInsucesso
		,AssigmentTask
	from 
		openjson(@JsonList)
		WITH (
			CodigoPacote varchar(1000) '$.shipment_id',
			DataReferencia varchar(1000) '$.ctime',
			DataHoraEntrega varchar(1000) '$.ctime',
			IdStatus varchar(1000) '$.status',
			IdInsucesso varchar(1000) '$.on_hold_reason',
			Content varchar(1000) '$.content'
		) as base
	cross apply (
		select AssigmentTask
		from openjson(base.Content)
		with (
			AssigmentTask varchar(1000) '$.assignment_task_id'
		)
	) as at

	select pac.CodigoRota,
		   pac.CodigoPacote,
		   pac.IdTransportadora,
		   pac.IdStation,
		   pac.IdMotorista,
		   pac.DataReferencia,
		   pac.DataHoraColeta,
		   pac.DataHoraEntrega,
		   pac.IdStatus,
		   pac.IdSubstatus,
		   at.AT as AssigmentTask
	into #pacotes_final
	from #pacotes as pac
		join (
				select CodigoPacote,
					   max(DataHoraEntrega) as UltimaEntrega
				from #pacotes
				group by CodigoPacote
			 ) as Ultimo
		on pac.CodigoPacote = Ultimo.CodigoPacote
		and pac.DataHoraEntrega = Ultimo.UltimaEntrega
		left join (
			select CodigoPacote, 
				   max(AssigmentTask) as AT 
			from #pacotes 
			where AssigmentTask <> '' 
			group by CodigoPacote
		) as At
		on pac.CodigoPacote = at.CodigoPacote

		
	
	merge tb_spe_pacotes as p
	using (
			select
				distinct
				p.*,
				s.Status StatusEntrega,
				m.Motivo SubStatus
			from
				#pacotes_final  p
				left join tb_spe_status s on p.IdStatus = s.IdStatus
				left join tb_spe_motivos_insucessos m on p.IdSubstatus = m.IdMotivo
		 ) as i
			ON p.CodigoPacote = i.CodigoPacote and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
	when matched then
	update set
		p.IdStation = i.IdStation
		,p.DataHoraEntrega = i.DataHoraEntrega
		,p.StatusEntrega = i.StatusEntrega
		,p.SubStatus = i.SubStatus
		,p.IdMotorista = i.IdMotorista
		--,p.RecebidoPor = i.Comprador
		--,p.Latitude = i.Latitude
		--,p.Longitude = i.Longitude
		--,p.URLImagem = i.URLImagem
		,p.DataAtualizacao = getdate()
	when not matched by target then 
	insert (
			 IdRota
			,CodigoPacote
			,IdTransportadora
			,IdStation
			,DataReferencia
			,DataHoraEntrega
			,StatusEntrega
			,SubStatus
			,IdMotorista
			--,RecebidoPor
			--,Latitude
			--,Longitude
			--,URLImagem
			,DataAtualizacao
	)
	values (
			case when isnull(i.AssigmentTask,'') = '' then i.CodigoRota else i.AssigmentTask end
			,i.CodigoPacote
			,i.IdTransportadora
			,i.IdStation
			,i.DataReferencia
			,i.DataHoraEntrega
			,i.StatusEntrega
			,i.SubStatus
			,i.IdMotorista
			--,i.Comprador
			--,i.Latitude
			--,i.Longitude
			--,i.URLImagem
			,getdate()
	);



	drop table if exists #rotas
	select 
		IdTransportadora, 
		AssigmentTask, 
		IdMotorista,
		DataReferencia, 
		max(IdStation) as IdStation
		into #rotas 
	from 
		#pacotes_final
	group by 
		IdTransportadora, 
		AssigmentTask,
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
			,IdRota
			,DataAtualizacao
			,Excluido
	)
	values (
			i.IdTransportadora
			,i.DataReferencia
			,i.IdStation
			,i.IdMotorista
			,i.AssigmentTask
			,getdate()
			,0
	);

end
GO
