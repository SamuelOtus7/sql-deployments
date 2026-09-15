-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesNovo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesNovo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadPacotesNovo] (
	@JSON VARCHAR(max),
	@CodigoRota varchar(30),
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

	--select
	--	@Json = Q.dac_ds_contexto_json,
	--	@IdTransportadora = Q.dac_cd_transportadora,
	--	@CodigoRota = Q.dac_ds_contexto,
	--	@DataColeta = Q.dac_dh_coleta
	--from
	--	db_Irisys_Json.dbo.tb_dra_coleta Q
	--where
	--	dac_cd_coleta=783277

	
	drop table if exists #pacotes
	create table #pacotes(
		CodigoRota varchar(30) not null,
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		DataReferencia date not null,
		DataHoraColeta datetime not null,
		DataHoraEntrega datetime not null,
		IdStatus int not null,
		IdSubstatus int null
	)

		
	insert into #pacotes
	select 
		@CodigoRota CodigoRota
		,CodigoPacote
		,@IdTransportadora IdTransportadora
		,cast(dateadd(second,((cast(DataReferencia as bigint))) - 10800,'1970-01-01') as date) DataReferencia
		,@DataColeta DataColeta
		,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
		,IdStatus
		,IdInsucesso
	from 
		openjson(@Json)
		WITH (
			CodigoPacote varchar(1000) '$.shipment_id',
			DataReferencia varchar(1000) '$.assigned_time',
			DataHoraEntrega varchar(1000) '$.assigned_time',
			IdStatus varchar(1000) '$.status',
			IdInsucesso varchar(1000) '$.on_hold_reason'
		)

		
	
	merge tb_spe_pacotes_novo as p
	using (
			select
				p.*,
				s.Status StatusEntrega,
				i.Motivo SubStatus
			from
				#pacotes p
				join tb_spe_status s on p.IdStatus = s.IdStatus
				left join tb_spe_motivos_insucessos i on p.IdSubstatus = i.IdMotivo
	
			) as i ON p.CodigoPacote = i.CodigoPacote and p.CodigoRota = i.CodigoRota and p.IdTransportadora = i.IdTransportadora and p.DataReferencia = i.DataReferencia
	when matched and (
					p.DataHoraColeta <> i.DataHoraColeta
					or p.DataHoraEntrega <> i.DataHoraEntrega
					or p.StatusEntrega <> i.StatusEntrega
					or p.SubStatus <> i.SubStatus
	) then
	update set
		p.DataHoraColeta = i.DataHoraColeta
		,p.DataHoraEntrega = i.DataHoraEntrega
		,p.StatusEntrega = i.StatusEntrega
		,p.SubStatus = i.SubStatus
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
			,getdate()
	);

	
	
end
GO
