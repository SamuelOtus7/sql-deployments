-- ============================================================
-- BASELINE: dbo.UspMLLoadRotas_old
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadRotas_old]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLLoadRotas_old] (
	@JSON VARCHAR(max),
	@Transportadora varchar(20),
	@ServiceCenter varchar(20),
	@DataColeta datetime,
	@DataReferencia date
)
as
begin

	SET NOCOUNT ON;

	--declare @JSON VARCHAR(max)
	--declare @Transportadora varchar(20)
	--declare @@ServiceCenter int
	--declare @DataColeta datetime
	
	--select
	--	@JSON = cmt_ds_json,
	--	@Transportadora = cmt_cd_transportadora,
	--	@ServiceCenter = cmt_cd_servicecenter,
	--	@DataColeta = cmt_dh_coleta
	--from
	--	tb_ml_coleta_totalizador
	--where
	--	cmt_cd_coleta=0
	
	drop table if exists #rotas
	CREATE TABLE #rotas (
		[IdRota] [int] NOT NULL,
		[DataReferencia] [date] null,
		[ServiceCenter] [varchar](50) NOT NULL,
		[TipoRota] [varchar](10) NULL,
		[StatusRota] [varchar](50) NOT NULL,
		[SubStatusRota] [varchar](50) NULL,
		[TipoEntrega] [varchar](30) NOT NULL,
		[NomeTransportadora] [varchar](60) NOT NULL,
		[DataHoraInicio] [datetime] NOT NULL,
		[DataHoraFim] [datetime] NULL,
		[TotalPacotes] [int] NULL,
		[PacotesEntregues] [int] NULL,
		[PacotesNaoEntregue] [int] NULL,
		[PacotesPendentes] [int] NULL,
		[TemAmbulancia] [bit] NOT NULL,
		[StatusPrazo] [varchar](30) NULL,
		[NomeMotorista] [varchar](100) NOT NULL,
		[NivelExperienciaMotorista] [varchar](40) NULL,
		[MotoristaArriscado] [bit] NOT NULL,
		[QuantidadeReclamacoesMotorista] [int] NULL,
		[TaxaDeContatoMotorista] [decimal](5, 4) NULL,
		[IdNivelMotorista] [varchar](30) NULL,
		[NivelMotorista] [varchar](30) NULL,
		[QuantidadePacotesTransportados] [int] NULL,
		[PercentualEntregasBemSucedidas] [decimal](5, 4) NULL,
		[PercentualEntregasSemRelamacaoes] [decimal](5, 4) NULL,
		[TipoVeiculo] [varchar](100) NULL,
		[Placa] [varchar](10) NOT NULL,
		[TempoPlanejadoMinutos] [int] NULL,
		[PercentualProgresso] [decimal](5, 4) NULL,
		[KmTotal] [decimal](8, 4) NULL,
		[TempoEmRota] [int] NOT NULL,
		[TempoChegadaAreaEntrega] [int] NOT NULL,
		[TempoAreaEntrega] [int] NOT NULL,
		[TempoRetornoCentroDistribuicao] [int] NOT NULL,
		[TempoInativo] [int] NULL,
		[DataHoraColeta] [datetime] NOT NULL,
		[DataAtualizacao] [datetime] NULL
	)

	INSERT INTO #rotas
	SELECT 
		IdRota
		,@DataReferencia DataReferencia
		,@ServiceCenter ServiceCenter
		,TipoRota
		,StatusRota
		,SubStatusRota
		,TipoEntrega
		,NomeTransportadora
		,dateadd(second,((cast(DataHoraInicio as bigint))) - 10800,'1970-01-01') DataHoraInicio
		,case when DataHoraFim = '' then null else dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataHoraFim
		,TotalPacotes
		,PacotesEntregues
		,PacotesNaoEntregue
		,PacotesPendentes
		,case when TemAmbulancia = 'true' then 1 else 0 end TemAmbulancia
		,StatusPrazo
		,NomeMotorista
		,NivelExperienciaMotorista
		,case when MotoristaArriscado = 'true' then 1 else 0 end MotoristaArriscado
		,QuantidadeReclamacoesMotorista
		,cast(replace(TaxaDeContatoMotorista,',','.') as decimal(5,4)) TaxaDeContatoMotorista
		,IdNivelMotorista
		,NivelMotorista
		,cast(replace(left(QuantidadePacotesTransportados,charindex(' p', QuantidadePacotesTransportados)-1),'.','') as int) QuantidadePacotesTransportados
		,cast(cast(replace(left(PercentualEntregasBemSucedidas,charindex('%', PercentualEntregasBemSucedidas)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4)) PercentualEntregasBemSucedidas
		,cast(cast(replace(left(PercentualEntregasSemRelamacaoes,charindex('%', PercentualEntregasSemRelamacaoes)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4)) PercentualEntregasSemRelamacaoes
		,TipoVeiculo
		,Placa
		,TempoPlanejadoMinutos
		,cast(cast(replace(PercentualProgresso,',','.') as decimal(5,2)) / 100 as decimal(5,4)) PercentualProgresso
		,cast(KmTotal as decimal(8,4)) KmTotal
		,TempoEmRota
		,TempoChegadaAreaEntrega
		,TempoAreaEntrega
		,TempoRetornoCentroDistribuicao
		,TempoInativo
		,@DataColeta DataHoraColeta
		,getdate() DataAtualizacao 
	FROM 
		OPENJSON (@JSON)
	WITH 
		(
			IdRota int '$.id' 
			,TipoRota varchar(10) '$.cluster'
			,StatusRota varchar(50) '$.status'
			,SubStatusRota varchar(50) '$.substatus'
			,TipoEntrega varchar(30) '$.deliveryType'
			,NomeTransportadora varchar(60) '$.carrier'
			,DataHoraInicio int '$.initDate'
			,DataHoraFim int '$.finalDate'
			,TotalPacotes int '$.counters.total'
			,PacotesEntregues int '$.counters.delivered'
			,PacotesNaoEntregue int '$.counters.notDelivered'
			,PacotesPendentes int '$.counters.pending'
			,TemAmbulancia varchar(5) '$.counters.pending'
			,StatusPrazo varchar(30) '$.routePerformanceScore'
			,NomeMotorista varchar(100) '$.driver.driverName'
			,NivelExperienciaMotorista varchar(40) '$.driver.experience'
			,MotoristaArriscado varchar(5) '$.driver.isDriverRisky'
			,QuantidadeReclamacoesMotorista int '$.driver.driverClaims'
			,TaxaDeContatoMotorista varchar(10) '$.driver.contactRate'
			,IdNivelMotorista varchar(30) '$.driver.loyalty.id'
			,NivelMotorista varchar(30) '$.driver.loyalty.name'
			,QuantidadePacotesTransportados varchar(30) '$.driver.loyalty.stats[0].label'
			,PercentualEntregasBemSucedidas varchar(30) '$.driver.loyalty.stats[1].label'
			,PercentualEntregasSemRelamacaoes varchar(30) '$.driver.loyalty.stats[2].label'
			,TipoVeiculo varchar(100) '$.vehicle.description'
			,Placa varchar(10) '$.vehicle.license'
			,TempoPlanejadoMinutos int '$.plannedRoute.duration'
			,PercentualProgresso varchar(10) '$.plannedRoute.progressPercent'
			,KmTotal varchar(10) '$.plannedRoute.distance'
			,TempoEmRota int '$.timingData.orh'
			,TempoChegadaAreaEntrega int '$.timingData.stemOut'
			,TempoAreaEntrega int '$.timingData.ozh'
			,TempoRetornoCentroDistribuicao int '$.timingData.stemIn'
			,TempoInativo int '$.timingData.inactivity.inactivityValue'
		)


	merge tb_ml_rotas as r
	using (
			select 
				r.*,
				t.tpr_cd_transportadora
			from
				#rotas r
				left join tb_ml_transportadora t on r.NomeTransportadora = t.tpr_nome_transportadora
			) as i
			ON r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.tpr_cd_transportadora
	when matched then
	update set
		r.ServiceCenter = i.ServiceCenter
		,r.TipoRota = i.TipoRota
		,r.StatusRota = i.StatusRota
		,r.SubStatusRota = i.SubStatusRota
		,r.TipoEntrega = i.TipoEntrega
		,r.DataHoraInicio = i.DataHoraInicio
		,r.DataHoraFim = i.DataHoraFim
		,r.TotalPacotes = i.TotalPacotes
		,r.PacotesEntregues = i.PacotesEntregues
		,r.PacotesNaoEntregue = i.PacotesNaoEntregue
		,r.PacotesPendentes = i.PacotesPendentes
		,r.TemAmbulancia = i.TemAmbulancia
		,r.StatusPrazo = i.StatusPrazo
		,r.NomeMotorista = i.NomeMotorista
		,r.NivelExperienciaMotorista = i.NivelExperienciaMotorista
		,r.MotoristaArriscado = i.MotoristaArriscado
		,r.QuantidadeReclamacoesMotorista = i.QuantidadeReclamacoesMotorista
		,r.TaxaDeContatoMotorista = i.TaxaDeContatoMotorista
		,r.IdNivelMotorista = i.IdNivelMotorista
		,r.NivelMotorista = i.NivelMotorista
		,r.QuantidadePacotesTransportados = i.QuantidadePacotesTransportados
		,r.PercentualEntregasBemSucedidas = i.PercentualEntregasBemSucedidas
		,r.PercentualEntregasSemRelamacaoes = i.PercentualEntregasSemRelamacaoes
		,r.TipoVeiculo = i.TipoVeiculo
		,r.Placa = i.Placa
		,r.TempoPlanejadoMinutos = i.TempoPlanejadoMinutos
		,r.PercentualProgresso = i.PercentualProgresso
		,r.KmTotal = i.KmTotal
		,r.TempoEmRota = i.TempoEmRota
		,r.TempoChegadaAreaEntrega = i.TempoChegadaAreaEntrega
		,r.TempoAreaEntrega = i.TempoAreaEntrega
		,r.TempoRetornoCentroDistribuicao = i.TempoRetornoCentroDistribuicao
		,r.TempoInativo = i.TempoInativo
		,r.DataHoraColeta = i.DataHoraColeta
		,r.DataAtualizacao = i.DataAtualizacao
	when not matched by target then 
	insert (
			IdRota
			,DataReferencia
			,ServiceCenter
			,TipoRota
			,StatusRota
			,SubStatusRota
			,TipoEntrega
			,IdTransportadora
			,DataHoraInicio
			,DataHoraFim
			,TotalPacotes
			,PacotesEntregues
			,PacotesNaoEntregue
			,PacotesPendentes
			,TemAmbulancia
			,StatusPrazo
			,NomeMotorista
			,NivelExperienciaMotorista
			,MotoristaArriscado
			,QuantidadeReclamacoesMotorista
			,TaxaDeContatoMotorista
			,IdNivelMotorista
			,NivelMotorista
			,QuantidadePacotesTransportados
			,PercentualEntregasBemSucedidas
			,PercentualEntregasSemRelamacaoes
			,TipoVeiculo
			,Placa
			,TempoPlanejadoMinutos
			,PercentualProgresso
			,KmTotal
			,TempoEmRota
			,TempoChegadaAreaEntrega
			,TempoAreaEntrega
			,TempoRetornoCentroDistribuicao
			,TempoInativo
			,DataHoraColeta
			,DataAtualizacao
	)
	values (
		i.IdRota
		,i.DataReferencia
		,i.ServiceCenter
		,i.TipoRota
		,i.StatusRota
		,i.SubStatusRota
		,i.TipoEntrega
		,i.tpr_cd_transportadora
		,i.DataHoraInicio
		,i.DataHoraFim
		,i.TotalPacotes
		,i.PacotesEntregues
		,i.PacotesNaoEntregue
		,i.PacotesPendentes
		,i.TemAmbulancia
		,i.StatusPrazo
		,i.NomeMotorista
		,i.NivelExperienciaMotorista
		,i.MotoristaArriscado
		,i.QuantidadeReclamacoesMotorista
		,i.TaxaDeContatoMotorista
		,i.IdNivelMotorista
		,i.NivelMotorista
		,i.QuantidadePacotesTransportados
		,i.PercentualEntregasBemSucedidas
		,i.PercentualEntregasSemRelamacaoes
		,i.TipoVeiculo
		,i.Placa
		,i.TempoPlanejadoMinutos
		,i.PercentualProgresso
		,i.KmTotal
		,i.TempoEmRota
		,i.TempoChegadaAreaEntrega
		,i.TempoAreaEntrega
		,i.TempoRetornoCentroDistribuicao
		,i.TempoInativo
		,i.DataHoraColeta
		,i.DataAtualizacao
	);

end
GO
