-- ============================================================
-- BASELINE: dbo.usp_script_shopev4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_script_shopev4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_script_shopev4]
as
drop table if exists #rotas
create table #rotas(
	CodigoRota varchar(30) not null,
	IdTransportadora int not null,
	DataReferencia date not null,
	DataHoraInicio date not null,
	DataHoraFim datetime null,
	DataHoraColeta datetime not null,
	IdStation int not null,
	IdMotorista int null,
	IdStatus int null,
	Pacotes varchar(max) null
)


drop table if exists #base
select
	c.dac_cd_coleta
	into #base
from
	db_Irisys_Json.dbo.tb_dra_coleta c with(nolock)
where
	c.dac_ds_tipo_coleta = 'SPE4_ROUTES' 
	and c.dac_in_processado = 1
	--and c.dac_cd_coleta = (
	--							select
	--								max(dac_cd_coleta)
	--							from
	--								db_Irisys_Json.dbo.tb_dra_coleta caux with(nolock)
	--							where
	--								caux.dac_ds_tipo_coleta = c.dac_ds_tipo_coleta
	--								and caux.dac_ds_contexto = c.dac_ds_contexto
	--								and caux.dac_dh_referencia = c.dac_dh_referencia
	--								and caux.dac_cd_transportadora = c.dac_cd_transportadora
	--								and caux.dac_in_processado = 1
	--						)
declare @cont int = 1
while exists (select 1 from #base)
begin
	print @cont
	set @cont = @cont + 1
	declare @JSON VARCHAR(max)
	declare @IdTransportadora int
	declare @IdStations int
	declare @DataColeta datetime
	declare @IdColeta int

	set @IdColeta = (select top 1 dac_cd_coleta from #base )

	SELECT 
		@JSON = dac_ds_contexto_json,
		@IdTransportadora = dac_cd_transportadora,
		@IdStations = dac_ds_contexto,
		@DataColeta = dac_dh_coleta
	FROM 
		db_Irisys_Json.dbo.tb_dra_coleta WITH (nolock)
	WHERE 
		dac_cd_coleta = @IdColeta

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')

	INSERT INTO #rotas
	SELECT 
		IdRota
		,@IdTransportadora IdTransportadora
		,cast(dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') as date) DataReferencia
		,dateadd(second,((cast(DataRerencia as bigint))) - 10800,'1970-01-01') DataHoraInicio
		,case when DataHoraFim = '' or DataHoraFim = 0 then null else dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataHoraFim
		,@DataColeta DataHoraColeta
		,@IdStations IdStation
		,IdMotorista
		,IdStatus
		,Pacotes
	FROM 
		OPENJSON (@JsonList)
	WITH 
		(
			IdRota varchar(30) '$.assignment_task_id'
			,IdMotorista int '$.driver_id'
			,DataRerencia varchar(1000) '$.assigned_time'
			,DataHoraFim varchar(1000) '$.complete_time'
			,IdStatus int '$.status'
			,Pacotes varchar(max) '$.shipment_id'
			--,DataRerencia varchar(1000) '$.ctime'
			--,DataRerencia2 varchar(1000) '$.mtime'
			--,DataRerencia3 varchar(1000) '$.delivery_time'
			--,DataRerencia4 varchar(1000) '$.processing_time'
			--,DataRerencia5 varchar(1000) '$.assigned_time'
			--,DataRerencia6 varchar(1000) '$.processed_time'
			--,DataRerencia7 varchar(1000) '$.partially_assigned_time'
		)

	delete #base where dac_cd_coleta=@IdColeta




end


drop table if exists #pacotes

SELECT 
	CodigoRota, 
	IdTransportadora,
	DataReferencia,
	value Pacotes
	into #pacotes
FROM 
	#rotas  
	CROSS APPLY STRING_SPLIT(Pacotes, ',')

	--select * from #rotas where Pacotes like '%BR230034999570Y%'
	--select * from #pacotes where Pacotes='BR230034999570Y'
update
	p
set
	Excluido = 1
from
	tb_spe_pacotes_v4 p
	left join #pacotes p2 on p.CodigoRota = p2.CodigoRota 
							and p.IdTransportadora = p2.IdTransportadora 
							and p.DataReferencia = p2.DataReferencia 
							and p.CodigoPacote = p2.Pacotes
where
	p.DataReferencia > '2023-08-07'
	and p2.CodigoRota is null
	--select * from tb_spe_pacotes_v4 where Excluido=1

update
	p
set
	Excluido = 1
from
	tb_spe_pacotes_v4 p
	left join tb_spe_rotas_v4 r on p.CodigoRota = r.CodigoRota and p.DataReferencia = r.DataReferencia and p.IdTransportadora = r.IdTransportadora and r.Excluido = 0
where
	r.Id is null
	and p.Excluido = 0


update	
	p
set
	p.SubStatusAnterior = p.SubStatus,
	p.SubStatus='transferred'
from
	tb_spe_pacotes_v4 p
	join tb_spe_pacotes_v4 p2 on p.CodigoPacote = p2.CodigoPacote
							and p.IdTransportadora = p2.IdTransportadora
							and p.DataReferencia = p2.DataReferencia
							and p.CodigoRota <> p2.CodigoRota
							and p2.StatusEntrega = 'Delivered'
							and p.StatusEntrega <> 'Delivered'
							and p.Excluido = 0
							and p2.Excluido = 0
where
	p.DataReferencia > '2023-08-07'
	--and p.CodigoPacote='BR232779369416A'
	--update tb_spe_pacotes_v4 set Excluido=0
select * from tb_spe_pacotes_v4 where CodigoPacote='BR2375290649009' and Excluido = 0
select * from tb_spe_rotas_v4 where CodigoRota in ('AT202308150857X', 'AT2023081608E4F')

select * from vw_pacotes_spe_v4 where CodigoPacote='BR2375290649009'

exec UspSPEAtualizaIndicadoresRotaV4 16


select * from tb_spe_pacotes_v4 where CodigoPacote='BR2355741539427'

GO
