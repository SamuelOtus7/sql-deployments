-- ============================================================
-- BASELINE: dbo.UspMLLoadPacotes_old
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadPacotes_old]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLLoadPacotes_old] (
	@JSON VARCHAR(max),
	@Transportadora varchar(20),
	@IdRota int,
	@DataColeta datetime,
	@DataReferencia date
)
as
begin

	SET NOCOUNT ON;
	
	--declare @JSON VARCHAR(max)
	--declare @Transportadora varchar(20)
	--declare @IdRota int
	--declare @DataColeta datetime
	
	--select
	--	@JSON = cmr_ds_json,
	--	@Transportadora = cmr_cd_transportadora,
	--	@IdRota = cmr_cd_rota,
	--	@DataColeta = cmr_dh_coleta
	--from
	--	tb_ml_coleta_rotas
	--where
	--	cmr_cd_coleta=9134


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
		[DataAtualizacao] datetime not null
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

	merge tb_ml_pacotes as p
	using (
			--quando uma rota é "roteada", ou seja, os campos IdRotaOrigem e IdRotaDestino são repetidos porém em registros diferentes, é duplicado
			--para isso, é feito um max nesses campos considerando o id de menor parada e menor data hora entrega como critério, uma vez que a parada tb é diferente
			select
				base.*
				,(select top 1 Status from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParada = p2.IdParada) Status
				,(select top 1 SubStatus from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParada = p2.IdParada) SubStatus
				,(select top 1 StatusEntrega from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParada = p2.IdParada) StatusEntrega
				,(select top 1 ForaAreaEntrega from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParada = p2.IdParada) ForaAreaEntrega
				,p.StatusParada --busca os dados da idparada retornada
				,p.LatitudeEnderecoParada
				,p.LongitudeEnderecoParada
				,p.QuantidadePontosParada
				,p.SequenciaParada
				,p.EnderecoParada
				,p.TipoEnderecoParada
			from
				(
					select 
						IdPacote
						,IdRota
						,IdTransportadora
						,min(DataReferencia) DataReferencia
						,DataHoraColeta
						,min(DataHoraEntrega) DataHoraEntrega
						,TipoEndereco
						,TipoEnderecoPreferencia
						,max(IdRotaOrigem) IdRotaOrigem
						,max(IdRotaDestino) IdRotaDestino
						,QuantidadeReclamacoes
						,TemVolumoso
						,NomeEtiqueta
						,Endereco
						,min(IdParada) IdParada
						,max(DataAtualizacao) DataAtualizacao
					from 
						#pacotes 
					group by
						IdPacote
						,IdRota
						,IdTransportadora
						,DataHoraColeta
						,TipoEndereco
						,TipoEnderecoPreferencia
						,QuantidadeReclamacoes
						,TemVolumoso
						,NomeEtiqueta
						,Endereco
				) base
				join #pacotes p on base.IdPacote = p.IdPacote and base.IdParada = p.IdParada
		) as i ON p.IdRota = i.IdRota and p.IdPacote = i.IdPacote and p.DataReferencia = i.DataReferencia and p.IdTransportadora = i.IdTransportadora
	when matched then
	update set
		p.DataHoraEntrega = i.DataHoraEntrega
		,p.Status = i.Status
		,p.SubStatus = i.SubStatus
		,p.StatusEntrega = i.StatusEntrega
		,p.TipoEndereco = i.TipoEndereco
		,p.TipoEnderecoPreferencia = i.TipoEnderecoPreferencia
		,p.IdRotaOrigem = i.IdRotaOrigem
		,p.IdRotaDestino = i.IdRotaDestino
		,p.QuantidadeReclamacoes = i.QuantidadeReclamacoes
		,p.ForaAreaEntrega = i.ForaAreaEntrega
		,p.TemVolumoso = i.TemVolumoso
		,p.NomeEtiqueta = i.NomeEtiqueta
		,p.Endereco = i.Endereco
		,p.IdParada = i.IdParada
		,p.SequenciaParada = i.SequenciaParada
		,p.StatusParada = i.StatusParada
		,p.EnderecoParada = i.EnderecoParada
		,p.TipoEnderecoParada = i.TipoEnderecoParada
		,p.LatitudeEnderecoParada = i.LatitudeEnderecoParada
		,p.LongitudeEnderecoParada = i.LongitudeEnderecoParada
		,p.QuantidadePontosParada = i.QuantidadePontosParada
		,p.DataHoraColeta = i.DataHoraColeta
		,p.DataAtualizacao = i.DataAtualizacao
	when not matched by target then 
	insert (
			IdPacote
			,IdRota
			,IdTransportadora
			,DataReferencia
			,DataHoraColeta
			,DataHoraEntrega
			,Status
			,SubStatus
			,StatusEntrega
			,TipoEndereco
			,TipoEnderecoPreferencia
			,IdRotaOrigem
			,IdRotaDestino
			,QuantidadeReclamacoes
			,ForaAreaEntrega
			,TemVolumoso
			,NomeEtiqueta
			,Endereco
			,IdParada
			,SequenciaParada
			,StatusParada
			,EnderecoParada
			,TipoEnderecoParada
			,LatitudeEnderecoParada
			,LongitudeEnderecoParada
			,QuantidadePontosParada
			,DataAtualizacao
	)
	values (
			i.IdPacote
			,i.IdRota
			,i.IdTransportadora
			,i.DataReferencia
			,i.DataHoraColeta
			,i.DataHoraEntrega
			,i.Status
			,i.SubStatus
			,i.StatusEntrega
			,i.TipoEndereco
			,i.TipoEnderecoPreferencia
			,i.IdRotaOrigem
			,i.IdRotaDestino
			,i.QuantidadeReclamacoes
			,i.ForaAreaEntrega
			,i.TemVolumoso
			,i.NomeEtiqueta
			,i.Endereco
			,i.IdParada
			,i.SequenciaParada
			,i.StatusParada
			,i.EnderecoParada
			,i.TipoEnderecoParada
			,i.LatitudeEnderecoParada
			,i.LongitudeEnderecoParada
			,i.QuantidadePontosParada
			,i.DataAtualizacao
	);
end
GO
