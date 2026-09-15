-- ============================================================
-- BASELINE: dbo.UspMLLoadRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspMLLoadRotas]
	(
	@JSON VARCHAR(max),
	@Transportadora varchar(20),
	@ServiceCenter varchar(20),
	@DataColeta datetime
--	@DataReferencia date
)
as
begin

	-- SET NOCOUNT ON;

	-- declare @JSON VARCHAR(max)
	-- declare @Transportadora varchar(20)
	-- declare @ServiceCenter varchar(20)
	-- declare @DataColeta datetime
	-- -- declare @DataReferencia datetime

	-- select
	-- 	@JSON = cmt_ds_json,
	-- 	@Transportadora = cmt_cd_transportadora,
	-- 	@ServiceCenter = cmt_cd_servicecenter,
	-- 	@DataColeta = cmt_dh_coleta
	-- 	-- @DataReferencia = cmt_dh_referencia
	-- -- select *
	-- from
	-- 	tb_ml_coleta_totalizador
	-- where
	-- 	cmt_cd_coleta=26665122

-- 	declare @datareferencia varchar(max) = (
	
-- 	select lst_ds_valor
-- 	from tb_parametros as a

-- 		inner join tb_clientes as cli
-- 		on cli.cli_cd_codigo_cliente = a.prm_cod_cliente

-- 		inner join tb_lista as lst
-- 		on a.prm_ds_valor = lst.lst_cd_lista

-- 	where prm_nm_parametro = 'Data do Monitoramento'
-- 		and cli.cli_id_logistics = @Transportadora

-- )

	drop table if exists #rotas
	CREATE TABLE #rotas
	(
		[IdRota] [int] NOT NULL,
		[DataReferencia] [date] null,
		[ServiceCenter] [varchar](50) NOT NULL,
		[OrigemSaida] [varchar](50) NULL,
		[TipoOrigemSaida] [varchar](50) NULL,
		[Tipo] [varchar](30) null,
		[TipoRota] [varchar](10) NULL,
		[StatusRota] [varchar](50) NOT NULL,
		[SubStatusRota] [varchar](50) NULL,
		[TipoEntrega] [varchar](30) NOT NULL,
		IdTransportadora int NOT NULL,
		[DataHoraInicio] [datetime] NOT NULL,
		[DataHoraFim] [datetime] NULL,
		[TotalPacotes] [smallint] NULL,
		[PacotesEntregues] [smallint] NULL,
		[PacotesNaoEntregue] [smallint] NULL,
		[PacotesPendentes] [smallint] NULL,
		[PacotesEntreguesForaAreaEntrega] [smallint] NOT NULL,
		[PacotesTransferidos] [smallint] NOT NULL,
		[PacotesRecebidos] [smallint] NOT NULL,
		[TotalSacas] [smallint] NOT NULL,
		[QuantidadeAmbulancia] varchar(5) NOT NULL,
		[StatusPrazo] [varchar](30) NULL,
		[NomeMotorista] [varchar](100) NOT NULL,
		[DriverId] int null,
		[NivelExperienciaMotorista] [varchar](40) NULL,
		[MotoristaArriscado] [bit] NOT NULL,
		[QuantidadeReclamacoesMotorista] [int] NULL,
		[TaxaDeContatoMotorista] [decimal](7, 4) NULL,
		[IdNivelMotorista] [varchar](30) NULL,
		[NivelMotorista] [varchar](30) NULL,
		[QuantidadePacotesTransportados] [int] NULL,
		[PercentualEntregasBemSucedidas] [decimal](5, 4) NULL,
		[PercentualEntregasSemRelamacaoes] [decimal](5, 4) NULL,
		[PossuiAjudante] [bit] NOT NULL,
		[TipoVeiculo] [varchar](100) NULL,
		[Placa] [varchar](11) NOT NULL,
		[TempoPlanejadoMinutos] [int] NULL,
		[PercentualProgresso] [decimal](5, 4) NULL,
		[KmTotal] [decimal](10, 4) NULL,
		[TempoEmRota] [int] NOT NULL,
		[TempoChegadaAreaEntrega] [int] NOT NULL,
		[TempoAreaEntrega] [int] NOT NULL,
		[TempoRetornoCentroDistribuicao] [int] NOT NULL,
		[TempoInativo] [decimal](18,12) NULL,
		[DataHoraColeta] [datetime] NOT NULL,
		[DataAtualizacao] [datetime] NULL,
		DataCriacao [datetime] null,
		QuantidadeReclamacoesAbertas [int] null,
		QuantidadeReclamacoesFechadas [int] null,
		DataInicioRotaInt [Int] null,
		DataFimRotaInt [Int] null,
		DataInicioRota [datetime] null,
		DataFimRota [datetime] null
		--DataHoraSaidaEstacao  [datetime] null
	)

	INSERT INTO #rotas
	SELECT
		IdRota
		-- , dateadd(second,((cast(@DataReferencia as bigint))) - 10800,'1970-01-01') DataReferencia
		, null DataReferencia
		, @ServiceCenter ServiceCenter
		, OrigemSaida
		, TipoOrigemSaida
		, Tipo
		, TipoRota
		, StatusRota
		, SubStatusRota
		, TipoEntrega
		, IdTransportadora
		, dateadd(second,((cast(DataHoraInicio as bigint))) - 10800,'1970-01-01') DataHoraInicio
		, case when DataHoraFim = '' then null else dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataHoraFim
		, isnull(TotalPacotes,0) TotalPacotes
		, isnull(PacotesEntregues,0) PacotesEntregues
		, isnull(PacotesNaoEntregue,0) PacotesNaoEntregue
		, isnull(PacotesPendentes,0) PacotesPendentes
		, isnull(PacotesEntreguesForaAreaEntrega,0) PacotesEntreguesForaAreaEntrega
		, isnull(PacotesTransferidos,0) PacotesTransferidos
		, isnull(PacotesRecebidos,0) PacotesRecebidos
		, isnull(TotalSacas,0) TotalSacas
		, CASE 
			WHEN idtransportadora IN (678279205, 643493085) THEN 
				CASE 
					WHEN tiporota IS NULL OR LTRIM(RTRIM(tiporota)) = '' THEN 1
					WHEN tiporota NOT LIKE '%[^0-9]%' THEN 1
					ELSE 0
				END
			ELSE 
				ISNULL(
					CASE 
						WHEN QuantidadeAmbulancia = 'false' THEN 0
						WHEN tiporota IS NULL AND QuantidadeAmbulancia <> 'false' THEN CAST(QuantidadeAmbulancia AS SMALLINT)
					END,
				0)
			END AS QuantidadeAmbulancia


		, StatusPrazo
		, NomeMotorista
		, try_cast(DriverId as int) DriverId
		, NivelExperienciaMotorista
		, case when MotoristaArriscado = 'true' then 1 else 0 end MotoristaArriscado
		, QuantidadeReclamacoesMotorista
		, cast(replace(TaxaDeContatoMotorista,',','.') as decimal(7,4)) TaxaDeContatoMotorista
		, IdNivelMotorista
		, NivelMotorista
		, 0 as QuantidadePacotesTransportados
		, 0 as PercentualEntregasBemSucedidas
		, 0 as PercentualEntregasSemRelamacaoes
		-- Dados comentados pois começou a dar erro em 2025-01-08 devido à alterações no JSON | Vitor Ferreira
		--,cast(replace(left(QuantidadePacotesTransportados,charindex(' p', QuantidadePacotesTransportados)-1),'.','') as int) QuantidadePacotesTransportados
		--,cast(cast(replace(left(PercentualEntregasBemSucedidas,charindex('%', PercentualEntregasBemSucedidas)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4)) PercentualEntregasBemSucedidas
		--,cast(cast(replace(left(PercentualEntregasSemRelamacaoes,charindex('%', PercentualEntregasSemRelamacaoes)-1),',','.') as decimal(5,2)) / 100 as decimal(5,4)) PercentualEntregasSemRelamacaoes
		, case when PossuiAjudante = 'true' then 1 else 0 end PossuiAjudante
		, replace(replace(replace(replace(replace(TipoVeiculo, 'UtilitÃ¡rio', 'Utilitário'), 'Ãºnica', 'única'), 'VeÃ­culo', 'Veículo'), ' â€“ ', ' – '),'MÃ©dio', 'Médio') TipoVeiculo
		, Placa
		, TempoPlanejadoMinutos
		, case when isnumeric(replace(PercentualProgresso,',','.')) = 0 then 0 else
		cast(cast(replace(PercentualProgresso,',','.') as decimal(5,2)) / 100 as decimal(5,4)) end as PercentualProgresso
		, cast(KmTotal as decimal(10,4)) KmTotal
		, TempoEmRota
		, TempoChegadaAreaEntrega
		, TempoAreaEntrega
		, TempoRetornoCentroDistribuicao
		,  TempoInativo --null
		, @DataColeta DataHoraColeta
		, getdate() DataAtualizacao 
		, dateadd(second,((cast(DataCriacao as bigint))) - 10800,'1970-01-01') as DataCriacao
 
		, case 
			when StatusReclamacoes1 = 'opened' then QuantidadeReclamacoes1 
			when StatusReclamacoes2 = 'opened' then QuantidadeReclamacoes2
			else null end QuantidadeReclamacoesAbertas 
		, case 
			when StatusReclamacoes1 = 'closed' then QuantidadeReclamacoes1 
			when StatusReclamacoes2 = 'closed' then QuantidadeReclamacoes2
			else null end QuantidadeReclamacoesFechadas 
		, DataInicioRotaInt
		, DataFimRotaInt
		, null DataInicioRota
		, null DataFimRota
--		,dateadd(
--    second,
--    (cast(DataHoraInicio as bigint)) - 10800,
--    '1970-01-01'
--) AS DataHoraSaidaEstacao

	FROM
		OPENJSON (@JSON)
	WITH 
		(
			IdRota int '$.id' 
			,OrigemSaida varchar(50) '$.facilityId'
			,IdTransportadora int '$.carrierId'
			,TipoOrigemSaida varchar(50) '$.facilityType'
			,Tipo varchar(30) '$.type'
			,TipoRota varchar(10) '$.cluster'
			,StatusRota varchar(50) '$.status'
			,SubStatusRota varchar(50) '$.substatus'
			,TipoEntrega varchar(30) '$.deliveryType'
			,NomeTransportadora varchar(60) '$.carrier'
			,DataHoraInicio int '$.initDate'
			,DataHoraFim int '$.finalDate'
			,TotalPacotes smallint '$.counters.total'
			,PacotesEntregues smallint '$.counters.delivered'
			,PacotesNaoEntregue smallint '$.counters.notDelivered'
			,PacotesPendentes smallint '$.counters.pending'
			,PacotesEntreguesForaAreaEntrega smallint '$.outRangeDeliveryFilter'
			,PacotesTransferidos smallint '$.counters.toRoutes'
			,PacotesRecebidos smallint '$.counters.fromRoutes'
			,TotalSacas smallint '$.counters.totalBags'
			,QuantidadeAmbulancia varchar(5) '$.hasAmbulance'
			      --  ,QuantidadeAmbulancia bit '$.stops[0].ambulance'

			,StatusPrazo varchar(30) '$.routePerformanceScore'
			,NomeMotorista varchar(100) '$.driver.driverName'
			,DriverId varchar(100) '$.driver.driverId'
			,NivelExperienciaMotorista varchar(40) '$.driver.experience'
			,MotoristaArriscado varchar(5) '$.driver.isDriverRisky'
			,QuantidadeReclamacoesMotorista int '$.driver.driverClaims'
			,TaxaDeContatoMotorista varchar(10) '$.driver.contactRate'
			,IdNivelMotorista varchar(30) '$.driver.loyalty.id'
			,NivelMotorista varchar(30) '$.driver.loyalty.name'
			,QuantidadePacotesTransportados varchar(30) '$.driver.loyalty.stats[1].label'
			,PercentualEntregasBemSucedidas varchar(30) '$.driver.loyalty.stats[2].label'
			,PercentualEntregasSemRelamacaoes varchar(30) '$.driver.loyalty.stats[3].label'
			,PossuiAjudante varchar(5) '$.hasHelper'
			,TipoVeiculo varchar(100) '$.vehicle.description'
			,Placa varchar(11) '$.vehicle.license'
			,TempoPlanejadoMinutos int '$.plannedRoute.duration'
			,PercentualProgresso varchar(10) '$.plannedRoute.progressPercent'
			,KmTotal varchar(15) '$.plannedRoute.distance'
			,TempoEmRota int '$.timingData.orh'
			,TempoChegadaAreaEntrega int '$.timingData.stemOut'
			,TempoAreaEntrega int '$.timingData.ozh'
			,TempoRetornoCentroDistribuicao int '$.timingData.stemIn'
			,TempoInativo decimal(18,12) '$.timingData.inactivity.inactivityValue'
			,DataCriacao int  '$.dateCreated'

            ,QuantidadeReclamacoes1 int  '$.claims[0].count'
			,StatusReclamacoes1 varchar(10)  '$.claims[0].status'
			,QuantidadeReclamacoes2 int  '$.claims[1].count'
			,StatusReclamacoes2 varchar(10)  '$.claims[1].status'
			,DataInicioRotaInt int '$.initDate'	
			,DataFimRotaInt int '$.finalDate'
		);


update aux
set 
DataInicioRota = case when isnull(DataInicioRotaInt,0) = 0 then cast(dateadd(hour,-3,@DataColeta) as date) else dateadd(second,((cast(DataInicioRotaInt as bigint))) - 10800,'1970-01-01') end,
DataFimRota = case when isnull(DataInicioRotaInt,0) = 0 then cast(dateadd(hour,-3,@DataColeta) as date) else dateadd(second,((cast(DataFimRotaInt as bigint))) - 10800,'1970-01-01') end					
					
from #rotas aux;

update aux
set datareferencia = --DataInicioRota
	CASE
		WHEN prmData.prm_ds_valor = 1159 THEN DataInicioRota
		WHEN isnull(prmData.prm_ds_valor,1162) = 1162 THEN CASE WHEN DataFimRotaInt = 0 THEN cast(dateadd(hour,-3,@DataColeta) as date) ELSE DataFimRota END
	END
from #rotas aux
 LEFT JOIN (
  SELECT
        cli.cli_id_logistics,
        prm_ds_valor
    FROM tb_parametros AS a
        INNER JOIN tb_clientes AS cli
        ON cli.cli_cd_codigo_cliente = a.prm_cod_cliente
        INNER JOIN tb_lista AS lst
        ON a.prm_ds_valor = lst.lst_cd_lista
    WHERE prm_nm_parametro = 'Data do Monitoramento'
) AS prmData
    ON prmData.cli_id_logistics = aux.IdTransportadora;




	merge tb_ml_rotas as r
	using #rotas as i 
	ON r.IdRota = i.IdRota
		--	and r.DataReferencia = i.DataReferencia 
		and r.IdTransportadora = i.IdTransportadora
	when matched then
	update set
		r.ServiceCenter = i.ServiceCenter
		,r.OrigemSaida = i.OrigemSaida
		,r.TipoOrigemSaida = i.TipoOrigemSaida
		,r.Tipo = i.Tipo
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
		,r.PacotesEntreguesForaAreaEntrega = i.PacotesEntreguesForaAreaEntrega
		,r.PacotesTransferidos = i.PacotesTransferidos
		,r.PacotesRecebidos = i.PacotesRecebidos
		,r.TotalSacas = i.TotalSacas
		,r.QuantidadeAmbulancia = i.QuantidadeAmbulancia
		,r.StatusPrazo = i.StatusPrazo
		,r.NomeMotorista = i.NomeMotorista
		,r.DriverId = i.DriverId
		,r.NivelExperienciaMotorista = i.NivelExperienciaMotorista
		,r.MotoristaArriscado = i.MotoristaArriscado
		,r.QuantidadeReclamacoesMotorista = i.QuantidadeReclamacoesMotorista
		,r.TaxaDeContatoMotorista = i.TaxaDeContatoMotorista
		,r.IdNivelMotorista = i.IdNivelMotorista
		,r.NivelMotorista = i.NivelMotorista
		,r.QuantidadePacotesTransportados = i.QuantidadePacotesTransportados
		,r.PercentualEntregasBemSucedidas = i.PercentualEntregasBemSucedidas
		,r.PercentualEntregasSemRelamacaoes = i.PercentualEntregasSemRelamacaoes
		,r.PossuiAjudante = i.PossuiAjudante
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
		,r.Excluido = 0
		,r.DataCriacao = i.DataCriacao
        -- ,r.QuantidadeReclamacoesClaims = i.QuantidadeReclamacoesClaims
        -- ,r.StatusReclamacoes = i.StatusReclamacoes
        ,r.QuantidadeReclamacoesAbertas  = i.QuantidadeReclamacoesAbertas
        ,r.QuantidadeReclamacoesFechadas = i.QuantidadeReclamacoesFechadas
		,r.DataInicioRota = i.DataInicioRota
		,r.DataFimRota = i.DataFimRota
		,r.datareferencia = i.DataReferencia
	--	,r.DataHoraSaidaEstacao = i.DataHoraSaidaEstacao

	when not matched by target then 
	insert (
			IdRota
			,DataReferencia
			,ServiceCenter
			,OrigemSaida
			,TipoOrigemSaida
			,Tipo
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
			,PacotesEntreguesForaAreaEntrega
			,PacotesTransferidos
			,PacotesRecebidos
			,TotalSacas
			,QuantidadeAmbulancia
			,StatusPrazo
			,NomeMotorista
			,DriverId
			,NivelExperienciaMotorista
			,MotoristaArriscado
			,QuantidadeReclamacoesMotorista
			,TaxaDeContatoMotorista
			,IdNivelMotorista
			,NivelMotorista
			,QuantidadePacotesTransportados
			,PercentualEntregasBemSucedidas
			,PercentualEntregasSemRelamacaoes
			,PossuiAjudante
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
			,Excluido
			,DataCriacao
            ,QuantidadeReclamacoesAbertas 
            ,QuantidadeReclamacoesFechadas        
			,IdTrevo
			,DataInicioRota
			,DataFimRota
		--	,DataHoraSaidaEstacao
	)
	values (
		i.IdRota
		,i.DataReferencia
		,i.ServiceCenter
		,i.OrigemSaida
		,i.TipoOrigemSaida
		,i.Tipo
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
		,i.PacotesEntreguesForaAreaEntrega
		,i.PacotesTransferidos
		,i.PacotesRecebidos
		,i.TotalSacas
		,i.QuantidadeAmbulancia
		,i.StatusPrazo
		,i.NomeMotorista
		,i.DriverId
		,i.NivelExperienciaMotorista
		,i.MotoristaArriscado
		,i.QuantidadeReclamacoesMotorista
		,i.TaxaDeContatoMotorista
		,i.IdNivelMotorista
		,i.NivelMotorista
		,i.QuantidadePacotesTransportados
		,i.PercentualEntregasBemSucedidas
		,i.PercentualEntregasSemRelamacaoes
		,i.PossuiAjudante
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
		,0
		,i.DataCriacao
        ,i.QuantidadeReclamacoesAbertas
        ,i.QuantidadeReclamacoesFechadas    
		,0 
		,i.DataInicioRota
		,i.DataFimRota
	--	,i.DataHoraSaidaEstacao
	);

/*
	declare @count int = (select count(1) from #rotas)
	if @count > 0
	begin
		select
			r.IdRota,
			r.DataReferencia,
			r.IdTransportadora
			into #rotas_exclusao
		from
			tb_ml_rotas r
			left join #rotas as i on r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
		where
			i.IdRota is null
			and r.DataReferencia = @DataReferencia
			and r.ServiceCenter = @ServiceCenter
			and r.IdTransportadora = @Transportadora
			and r.PacotesEntregues = 0

		update
			r
		set
			Excluido = 1,
			DataAtualizacao = getdate()
		from
			tb_ml_rotas r
			join #rotas_exclusao as i on r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora

		
		--Parar tratar casos em que a rota apareceu no dia, a rotina que mantém a última rota mais recente (excluido as anteriores) é executada
		--porém a rota do dia para de aparecer. Nesse caso devo considerar a rota do dia anterior como a recente
		select
			r.IdRota,
			r.DataReferencia,
			r.IdTransportadora,
			r2.IdRota IdRotaVoltar,
			r2.DataReferencia DataReferenciaVoltar,
			r2.IdTransportadora IdTransportadoraVoltar
			into #voltar_rota_excluida
		from
			tb_ml_rotas r
			left join #rotas as i on r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
			join tb_ml_rotas r2 on r.IdRota = r2.IdRota and dateadd(day,-1,r.DataReferencia) = r2.DataReferencia and r.IdTransportadora = r2.IdTransportadora
		where
			i.IdRota is null
			and r.DataReferencia = @DataReferencia
			and r.ServiceCenter = @ServiceCenter
			and r.IdTransportadora = @Transportadora
			and r.PacotesEntregues <> 0
			and r2.Excluido = 1

		update
			r
		set
			Excluido = 1,
			DataAtualizacao = getdate()
		from
			tb_ml_rotas r
			join #voltar_rota_excluida as i on r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora

		update
			r
		set
			Excluido = 0,
			DataAtualizacao = getdate()
		from
			tb_ml_rotas r
			join #voltar_rota_excluida as i on r.IdRota = i.IdRotaVoltar and r.DataReferencia = i.DataReferenciaVoltar and r.IdTransportadora = i.IdTransportadoraVoltar
		/*

		select
			*
			into #verifica_rotas_excluidas
		from
			(
				select IdRota from #rotas_exclusao
				union
				select IdRota from #voltar_rota_excluida
				union
				select IdRotaVoltar from #voltar_rota_excluida
				union
				select 
					IdRota
				from
					(
					select
						IdRota,
						IdTransportadora, 
						count(1) qtde 
					from 
						tb_ml_rotas with(nolock)
					where 
						Excluido=0 
					group by 
						IdRota, IdTransportadora 
					having 
						count(1) > 1
					) d
			) t

		while exists (select 1 from #verifica_rotas_excluidas)
		begin

			declare @IdRotaVerificar int = (select top 1 IdRota from #verifica_rotas_excluidas)
			exec [UspMLCorrigeRotasExcluidas] null, @IdRotaVerificar
			delete #verifica_rotas_excluidas where IdRota=@IdRotaVerificar

		end
		*/

	--	--altera para excluido todos os pacotes das rotas excluidas
	--	update
	--		p
	--	set
	--		Excluido = 1,
	--		DataAtualizacao = getdate()
	--	from
	--		tb_ml_rotas r
	--		join tb_ml_pacotes p on r.IdRota = p.IdRota and r.IdTransportadora = p.IdTransportadora and r.DataReferencia = p.DataReferencia
	--	where
	--		r.Excluido = 1
	--		and p.Excluido = 0
	--		and r.DataReferencia = @DataReferencia
	--		and r.ServiceCenter = @ServiceCenter
	--		and r.IdTransportadora = @Transportadora
			
	end
	*/
end
GO
