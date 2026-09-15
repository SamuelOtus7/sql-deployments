-- ============================================================
-- BASELINE: dbo.UspMLLoadRotasRetroativo_old
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadRotasRetroativo_old]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLLoadRotasRetroativo_old] (
	@JSON VARCHAR(max),
	@Transportadora varchar(20),
	@IdRota int,
	@DataColeta datetime,
	@DataReferencia date
)
as
begin

	SET NOCOUNT ON;
	
	drop table if exists #pacotes
	CREATE TABLE #pacotes (
		[IdPacote] [bigint] NOT NULL,
		[IdRota] [int] NOT NULL,
		[IdTransportadora] [int] NOT NULL,
		[DataReferencia] [date] NULL,
		[DataHoraColeta] [datetime] NOT NULL,
		[DataHoraEntrega] [datetime] NOT NULL,
		[Status] [varchar](50) NULL,
		[SubStatus] [varchar](50) NULL,
		[StatusEntrega] [varchar](50) NULL,
		[TipoEndereco] [varchar](30) NULL,
		[TipoEnderecoPreferencia] [varchar](30) NULL,
		[IdRotaOrigem] [bigint] NULL,
		[IdRotaDestino] [bigint] NULL,
		[QuantidadeReclamacoes] [int] NULL,
		[ForaAreaEntrega] [bit] NULL,
		[TemVolumoso] [bit] NULL,
		[NomeEtiqueta] [varchar](30) NULL,
		[Endereco] [varchar](100) NULL,
		[IdParada] [bigint] NOT NULL,
		[SequenciaParada] [int] NULL,
		[StatusParada] [varchar](50) NOT NULL,
		[EnderecoParada] [varchar](100) NULL,
		[TipoEnderecoParada] [varchar](30) NULL,
		[LatitudeEnderecoParada] [varchar](15) NULL,
		[LongitudeEnderecoParada] [varchar](15) NULL,
		[QuantidadePontosParada] [tinyint] NOT NULL,
		[DataAtualizacao] datetime not null,

		--campos que não existem na tabela de pacotes e precigo buscar do json para insert na tabela de rotas
		[ServiceCenter] [varchar](50) NOT NULL,
		[TipoRota] [varchar](10) NULL,
		[StatusRota] varchar(50) null,
		[SubStatusRota] [varchar](50) NULL,
		[StatusPrazo] varchar(30) NULL,
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
		[Placa] [varchar](10) NULL,
		[TempoEmRota] [int] NOT NULL,
		[TempoChegadaAreaEntrega] [int] NOT NULL,
		[TempoAreaEntrega] [int] NOT NULL
	)

	
	--busca informações que não existem na tabela tb_ml_pacotes para incluir na rota
	declare @ServiceCenter varchar(50)
	declare @TipoRota varchar(10)
	declare @StatusRota varchar(50)
	declare @SubStatusRota varchar(50)
	declare @StatusPrazo varchar(30)
	declare @NomeMotorista varchar(100)
	declare @NivelExperienciaMotorista varchar(40)
	declare @MotoristaArriscado bit
	declare @QuantidadeReclamacoesMotorista int
	declare @TaxaDeContatoMotorista decimal(5,4)
	declare @IdNivelMotorista varchar(30)
	declare @NivelMotorista varchar(30)
	declare @QuantidadePacotesTransportados int
	declare @PercentualEntregasBemSucedidas decimal(5, 4)
	declare @PercentualEntregasSemRelamacaoes decimal(5, 4)
	declare @TipoVeiculo varchar(100)
	declare @Placa varchar(10)
	declare @TempoEmRota int
	declare @TempoChegadaAreaEntrega int
	declare @TempoAreaEntrega int

	SELECT 
		@ServiceCenter = ServiceCenter
		,@TipoRota = TipoRota
		,@StatusRota = StatusRota
		,@SubStatusRota = SubStatusRota
		,@StatusPrazo = StatusPrazo
		,@NomeMotorista = NomeMotorista
		,@NivelExperienciaMotorista = NivelExperienciaMotorista
		,@MotoristaArriscado = case when MotoristaArriscado = 'false' then 0 else 1 end
		,@QuantidadeReclamacoesMotorista = QuantidadeReclamacoesMotorista
		,@TaxaDeContatoMotorista = cast(replace(TaxaDeContatoMotorista,',','.') as decimal(5,4))
		,@IdNivelMotorista = IdNivelMotorista
		,@NivelMotorista = NivelMotorista
		,@QuantidadePacotesTransportados = cast(replace(left(QuantidadePacotesTransportados,charindex(' p', QuantidadePacotesTransportados)-1),'.','') as int)
		,@PercentualEntregasBemSucedidas = cast(cast(replace(left(PercentualEntregasBemSucedidas,charindex('%', PercentualEntregasBemSucedidas)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4))
		,@PercentualEntregasSemRelamacaoes = cast(cast(replace(left(PercentualEntregasSemRelamacaoes,charindex('%', PercentualEntregasSemRelamacaoes)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4))
		,@TipoVeiculo = TipoVeiculo
		,@Placa = Placa
		,@TempoEmRota = TempoEmRota
		,@TempoChegadaAreaEntrega = TempoChegadaAreaEntrega
		,@TempoAreaEntrega = TempoAreaEntrega
	FROM 
		OPENJSON (@JSON)
		with (
			ServiceCenter varchar(50) '$.serviceCenterId'
			,TipoRota varchar(10)  '$.cluster'
			,StatusRota varchar(50) '$.status'
			,SubStatusRota varchar(50) '$.substatus'
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
			,TipoVeiculo varchar(50) '$.vehicleType'
			,Placa varchar(10) '$.license'
			,TempoEmRota int '$.flags.orh'
			,TempoChegadaAreaEntrega int '$.flags.stemOut'
			,TempoAreaEntrega int '$.flags.ozh'
		)
	
	
	
	

	DECLARE @JsonStops nvarchar(max) = (SELECT value FROM OPENJSON (@JSON) WHERE [key] = 'stops')

	drop table if exists #paradas
	SELECT 
		IdParada
		,SequenciaParada
		,StatusParada
		,EnderecoParada
		,case when addressTypeResidential = 'true' then 'residential' else case when addressTypeBusiness = 'true' then 'business' else 'notCategorized' end end TipoEnderecoParada
		,LatidudeEnderecoParada
		,LongitudeEnderecoParada
		,QuantidadePontosParada
		,Pontos
		into #paradas
	FROM 
		OPENJSON(@JsonStops)
		WITH (
			IdParada bigint '$.id'	
			,SequenciaParada int '$.sequence'	
			,StatusParada varchar(50) '$.status'	
			,EnderecoParada varchar(100) '$.stopAddress'	
			,addressTypeResidential varchar(5) '$.addressTypeResidential'
			,addressTypeBusiness varchar(5) '$.addressTypeBusiness'
			,addressTypeNotCategorized varchar(5) '$.addressTypeNotCategorized'
			,LatidudeEnderecoParada varchar(15) '$.address.latitude'
			,LongitudeEnderecoParada varchar(15) '$.address.longitude'
			,QuantidadePontosParada int '$.ordersAmount'
			,Pontos nvarchar(max) '$.orders'  as json
		)

	declare @IdParada bigint
	declare @SequenciaParada int
	declare @StatusParada varchar(50)
	declare @JsonOrders nvarchar(max)
	declare @JsonTransportUnits nvarchar(max)
	declare @Endereco varchar(100)
	declare @TipoEnderecoParada varchar(30)
	declare @LatidudeEnderecoParada varchar(15)
	declare @LongitudeEnderecoParada varchar(15)
	declare @QuantidadePontosParada int
	declare @EnderecoParada varchar(100)

	DECLARE cursor_pontos CURSOR FOR select IdParada, Pontos, SequenciaParada, StatusParada, TipoEnderecoParada, LatidudeEnderecoParada, LongitudeEnderecoParada, QuantidadePontosParada, EnderecoParada from #paradas order by SequenciaParada
	OPEN cursor_pontos FETCH NEXT FROM cursor_pontos INTO @IdParada, @JsonOrders, @SequenciaParada, @StatusParada, @TipoEnderecoParada, @LatidudeEnderecoParada, @LongitudeEnderecoParada, @QuantidadePontosParada, @EnderecoParada
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	
		DROP TABLE IF EXISTS #json_pacotes
		SELECT
			Endereco
			,transportUnits
			into #json_pacotes
		FROM 
			OPENJSON(@JsonOrders)
			WITH (
				Endereco varchar(100) '$.address'
				,transportUnits	nvarchar(max) '$.transportUnits' AS JSON
				)

		DECLARE cursor_pacotes CURSOR FOR select Endereco, transportUnits from #json_pacotes
		OPEN cursor_pacotes  
		FETCH NEXT FROM cursor_pacotes INTO @Endereco, @JsonTransportUnits
		WHILE @@FETCH_STATUS = 0  
		BEGIN 
		
			insert into #pacotes
			select
				IdPacote
				,@IdRota IdRota
				,@Transportadora IdTransportadora
				,@DataReferencia DataReferencia
				,@DataColeta DataColeta
				,dateadd(second,((cast(DataHoraEntrega as bigint))) - 10800,'1970-01-01') DataHoraEntrega
				,Status
				,SubStatus
				,StatusEntrega
				,TipoEndereco
				,TipoEnderecoPreferencia
				,case when IdRotaOrigem = 'false' then null else cast(IdRotaOrigem as bigint) end IdRotaOrigem
				,case when IdRotaDestino = 'false' then null else cast(IdRotaDestino as bigint) end IdRotaDestino
				,QuantidadeReclamacoes
				,case when ForaAreaEntrega = 'false' then 0 else 1 end ForaAreaEntrega
				,case when TemVolumoso = 'false' then 0 else 1 end TemVolumoso
				,NomeEtiqueta
				,@Endereco Endereco
				,@IdParada IdParada
				,@SequenciaParada SequenciaParada
				,@StatusParada StatusParada
				,@EnderecoParada EnderecoParada
				,@TipoEnderecoParada TipoEnderecoParada
				,@LatidudeEnderecoParada LatidudeEnderecoParada
				,@LongitudeEnderecoParada LongitudeEnderecoParada
				,@QuantidadePontosParada QuantidadePontosParada
				,getdate() DataAtualizacao

				--novos campos para criar as rotas
				,@ServiceCenter
				,@TipoRota
				,@StatusRota
				,@SubStatusRota
				,@StatusPrazo
				,@NomeMotorista
				,@NivelExperienciaMotorista
				,@MotoristaArriscado
				,@QuantidadeReclamacoesMotorista
				,@TaxaDeContatoMotorista
				,@IdNivelMotorista
				,@NivelMotorista
				,@QuantidadePacotesTransportados
				,@PercentualEntregasBemSucedidas
				,@PercentualEntregasSemRelamacaoes
				,@TipoVeiculo
				,@Placa
				,@TempoEmRota
				,@TempoChegadaAreaEntrega
				,@TempoAreaEntrega
			from 
				openjson(@JsonTransportUnits)
				WITH (
						IdPacote bigint '$.relatedEntity.id'
						,DataHoraEntrega int '$.relatedEntity.timestamp'
						,Status varchar(50) '$.relatedEntity.status'
						,SubStatus varchar(50) '$.relatedEntity.substatus'
						,StatusEntrega varchar(50) '$.relatedEntity.frontStatus'
						,TipoEndereco varchar(30) '$.relatedEntity.addressType'
						,TipoEnderecoPreferencia varchar(30) '$.relatedEntity.receiverInfo.delivery_preference'
						,IdRotaOrigem varchar(30) '$.relatedEntity.fromRoute'
						,IdRotaDestino varchar(30) '$.relatedEntity.toRoute' 
						,QuantidadeReclamacoes int '$.relatedEntity.claimsAmount'
						,ForaAreaEntrega varchar(5) '$.relatedEntity.outRangeDelivery'
						,TemVolumoso varchar(5) '$.relatedEntity.hasBulky'
						,NomeEtiqueta varchar(30) '$.printedLabel'
					)


		FETCH NEXT FROM cursor_pacotes INTO @Endereco, @JsonTransportUnits
		END   
		CLOSE cursor_pacotes;  
		DEALLOCATE cursor_pacotes; 


	FETCH NEXT FROM cursor_pontos INTO @IdParada, @JsonOrders, @SequenciaParada, @StatusParada, @TipoEnderecoParada, @LatidudeEnderecoParada, @LongitudeEnderecoParada, @QuantidadePontosParada, @EnderecoParada
	END   
	CLOSE cursor_pontos;  
	DEALLOCATE cursor_pontos;  

	select 
		IdRota
		,DataHoraColeta
		,ServiceCenter
		,TipoRota
		,StatusRota
		,SubStatusRota
		,'driver' TipoEntrega
		,IdTransportadora
		,min(DataReferencia) DataReferencia
		,min(DataHoraEntrega) DataHoraInicio
		,max(DataHoraEntrega) DataHoraFim
		,count(1) TotalPacotes
		,sum(case when StatusEntrega = 'delivered' then 1 else 0 end) PacotesEntregues
		,sum(case when StatusEntrega = 'not_delivered' then 1 else 0 end) PacotesNaoEntregue
		,sum(case when StatusEntrega = 'pending' then 1 else 0 end) PacotesPendentes
		,0 TemAmbulancia
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
		,isnull(Placa,'NA') Placa
		,0 TempoPlanejadoMinutos
		,0 PercentualProgresso
		,max(m.cmm_vl_km) KmTotal
		,sum(TempoEmRota) TempoEmRota
		,sum(TempoChegadaAreaEntrega) TempoChegadaAreaEntrega
		,sum(TempoAreaEntrega) TempoAreaEntrega
		,0 TempoRetornoCentroDistribuicao
		,0 TempoInativo
		,getdate() DataAtualizacao
		into #rotas
	from
		#pacotes p
		left join tb_ml_coleta_maps m on p.IdRota = m.cmm_cd_rota
										and p.IdTransportadora = m.cmm_cd_transportadora
										and m.cmm_dh_coleta = (
											select 
												max(cmm_dh_coleta)
											from
												tb_ml_coleta_maps m2
											where
												m.cmm_cd_rota = m2.cmm_cd_rota
												and m.cmm_cd_transportadora = m2.cmm_cd_transportadora
										)
	where
		p.StatusEntrega = 'delivered'
	group by
		IdRota
		,DataHoraColeta
		,ServiceCenter
		,TipoRota
		,StatusRota
		,SubStatusRota
		,IdTransportadora
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
		,isnull(Placa,'NA')

	merge tb_ml_rotas as r
	using #rotas as i
			ON r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
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
		,DataReferencia
		,i.ServiceCenter
		,i.TipoRota
		,i.StatusRota
		,i.SubStatusRota
		,i.TipoEntrega
		,i.IdTransportadora
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
