-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesV4_Arquivo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesV4_Arquivo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadPacotesV4_Arquivo] (
	@JSON VARCHAR(max),
	@IdTransportadora int,
	@DataColeta datetime
)
as
begin
	
	SET NOCOUNT ON;

	--declare @JSON VARCHAR(max)
	--declare @IdTransportadora int
	--declare @DataColeta datetime
	--declare @CodigoRota varchar(30)
	--declare @DataReferencia date

	--select
	--	@Json = Q.dac_ds_contexto_json,
	--	@IdTransportadora = Q.dac_cd_transportadora,
	--	@CodigoRota = Q.dac_ds_contexto,
	--	@DataColeta = Q.dac_dh_coleta,
	--	@DataReferencia = Q.dac_dh_referencia
	--from
	--	db_Irisys_Json.dbo.tb_dra_coleta Q
	--where
	--	dac_cd_coleta=3573859

	
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'packages')

	drop table if exists #pacotes
	create table #pacotes(
		CodigoRota varchar(30)  null,
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		DataReferencia date not null,
		DataHoraColeta datetime not null,
		DataHoraEntrega datetime not null,
		IdStatus int not null,
		IdSubstatus int null,
		IdMotorista int null,
		CEP varchar(9) null
	)

		
	insert into #pacotes
	select 
		CodigoRota CodigoRota
		,CodigoPacote
		,@IdTransportadora IdTransportadora
		,case IdStatus
			when 2 then cast(dateadd(second,((cast(DataHoraEmEntrega as bigint))) - 10800,'1970-01-01') as date)
			when 1 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 3 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 5 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 10 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 125 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 460 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 4 then cast(dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') as date)
		end DataReferencia
		,@DataColeta DataColeta
		,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
		,case when IdStatus in (1, 10, 125, 460) then 5 else IdStatus end IdStatus
		,IdInsucesso
		,IdMotorista
		,CEP
	from 
		openjson(@JsonList)
		WITH (
			CodigoRota varchar(1000) '$.assignment_task_id',
			CodigoPacote varchar(1000) '$.shipment_id',
			DataHoraEntrega varchar(1000) '$.delivered_time',
			DataHoraEmEntrega varchar(1000) '$.delivering_time',
			DataHoraInsucesso varchar(1000) '$.on_hold_time',
			IdStatus varchar(1000) '$.order_status',
			IdInsucesso varchar(1000) '$.on_hold_reason',
			IdMotorista varchar(1000) '$.driver_id',
			CEP varchar(1000) '$.postal_code'
		)

		
	
	merge tb_spe_pacotes_v4 as p
	using (
			select
				distinct
				p.*,
				s.Status StatusEntrega,
				m.Motivo SubStatus
			from
				#pacotes p
				left join tb_spe_status s on p.IdStatus = s.IdStatus
				left join tb_spe_motivos_insucessos m on p.IdSubstatus = m.IdMotivo
			where
				CodigoRota is not null
	
			) as i ON p.CodigoPacote = i.CodigoPacote and p.CodigoRota = i.CodigoRota and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
	when matched and (
					p.DataHoraColeta <> i.DataHoraColeta
					or p.DataHoraEntrega <> i.DataHoraEntrega
					or p.StatusEntrega <> i.StatusEntrega
					or p.SubStatus <> i.SubStatus
					or p.IdMotorista <> i.IdMotorista
	) then
	update set
		p.DataHoraColeta = i.DataHoraColeta
		,p.DataHoraEntrega = i.DataHoraEntrega
		,p.StatusEntrega = i.StatusEntrega
		,p.SubStatus = i.SubStatus
		,p.IdMotorista = i.IdMotorista
		,p.CEP = i.CEP
		,p.DataAtualizacao = getdate()
	when not matched by target then 
	insert (
			CodigoRota
			,CodigoPacote
			,IdTransportadora
			,DataReferencia
			,DataHoraColeta
			,DataHoraEntrega
			,StatusEntrega
			,SubStatus
			,IdMotorista
			,CEP
			,DataAtualizacao
	)
	values (
			i.CodigoRota
			,i.CodigoPacote
			,i.IdTransportadora
			,i.DataReferencia
			,i.DataHoraColeta
			,i.DataHoraEntrega
			,i.StatusEntrega
			,i.SubStatus
			,i.IdMotorista
			,CEP
			,getdate()
	);

	
	
end
GO
