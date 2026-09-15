-- ============================================================
-- BASELINE: dbo.UspSPELoadPacotesV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPELoadPacotesV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspSPELoadPacotesV4] (
	@JSON VARCHAR(max),
	@CodigoRota varchar(30),
	@IdTransportadora int,
	@DataReferencia date,
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

	DECLARE @JsonData nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'data')
	DECLARE @JsonList nvarchar(max) = (SELECT value FROM OPENJSON (@JsonData) WHERE [key] = 'list')

	drop table if exists #pacotes
	create table #pacotes(
		CodigoRota varchar(30) not null,
		CodigoPacote varchar(30) not null,
		IdTransportadora int not null,
		DataReferencia date not null,
		DataHoraColeta datetime not null,
		DataHoraEntrega datetime null,
		IdStatus int not null,
		Substatus varchar(60) null,
		IdMotorista int null,
		CEP varchar(9) null
	)

		
	insert into #pacotes
	select 
		@CodigoRota CodigoRota
		,CodigoPacote
		,@IdTransportadora IdTransportadora
		,case IdStatus
			when 2 then cast(dateadd(second,((cast(DataHoraEmEntrega as bigint))) - 10800,'1970-01-01') as date)
			when 3 then cast(dateadd(second,((cast(DataHoraInsucesso as bigint))) - 10800,'1970-01-01') as date)
			when 4 then cast(dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') as date)
		end DataReferencia
		,@DataColeta DataColeta
		,case when dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') = '1969-12-31 21:00:00.000' then null else dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') end DataHoraEntrega
		,IdStatus
		,case when IdStatus = 3 then Substatus end Substatus
		,IdMotorista
		,CEP
	from 
		openjson(@JSON)
		WITH (
			CodigoPacote varchar(1000) '$.shipment_id',
			DataHoraEntrega varchar(1000) '$.delivered_time',
			DataHoraEmEntrega varchar(1000) '$.delivering_time',
			DataHoraInsucesso varchar(1000) '$.onhold_time',
			IdStatus varchar(1000) '$.status',
			SubStatus varchar(1000) '$.onhold_reason',
			IdMotorista varchar(1000) '$.driver_id',
			CEP varchar(1000) '$.postal_code'
		)

		
	
	merge tb_spe_pacotes_v4 as p
	using (
			select
				p.*,
				s.Status StatusEntrega
			from
				#pacotes p
				left join tb_spe_status s on p.IdStatus = s.IdStatus
	
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

    
    -- declare @count int = (select count(1) from #pacotes)
	-- if @count > 0
	-- begin
	-- 	update
	-- 		p
	-- 	set
	-- 		Excluido = 1,
	-- 		DataAtualizacao = getdate()
	-- 	from
	-- 		tb_spe_pacotes_v4 p
	-- 		left join #pacotes i 
    --         on p.CodigoRota = i.CodigoRota and p.CodigoPacote = i.CodigoPacote and p.DataReferencia = i.DataReferencia and p.IdTransportadora = i.IdTransportadora
	-- 	where
	-- 		i.CodigoPacote is null
	-- 		and p.Excluido = 0
	-- 		and p.CodigoPacote = @CodigoRota
	-- 		and p.IdTransportadora = @IdTransportadora
	-- 		and p.DataReferencia = @DataReferencia
	-- end

end
GO
