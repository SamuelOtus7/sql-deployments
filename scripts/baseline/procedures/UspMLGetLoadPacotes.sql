-- ============================================================
-- BASELINE: dbo.UspMLGetLoadPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetLoadPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLGetLoadPacotes] as   
  
drop table if exists #pacotes_json    
 select 
  cmr_ds_json,  
  cast(cmr_cd_transportadora as int) cmr_cd_transportadora,  
  cast(cmr_cd_rota as int) cmr_cd_rota,  
  cmr_dh_coleta,  
  cmr_dh_referencia,  
        cmr_cd_coleta,
        ROW_NUMBER() over (partition by cmr_cd_rota order by cmr_cd_coleta desc) as rownum  
  
        into #pacotes_json  

 from  
  db_Irisys_Json.dbo.tb_ml_coleta_rotas with(nolock)  
 where cmr_in_processado=0
  and cmr_dh_referencia >= '2025-04-21'
  --and cmr_cd_rota = 252346452

 --and cmr_dh_escrita between '2025-05-21 14:00:00.000' and '2025-05-21 23:59:00.000'
 --and cast(cmr_dh_escrita as date) = '2025-05-06'
  
--este delete e para garantir que o json sera processado na ordem de chegada  

update db_Irisys_Json.dbo.tb_ml_coleta_rotas   
set cmr_in_processado = 1  
, cmt_dh_processamento = getdate()  
 where cmr_cd_coleta in (select cmr_cd_coleta from #pacotes_json where rownum > 1  )    

delete from #pacotes_json where rownum > 1 

--incluido em 14/02/2026 por Saulo Barros para excluir registros em que o json veio erraod
--delete from #pacotes_json WHERE ISJSON(cmr_ds_json) = 0
delete from #pacotes_json where left(cmr_ds_json,1) not in ('{','[') or cmr_ds_json = '[]'

DROP TABLE IF EXISTS #json_expandido;

SELECT
    aux.cmr_cd_rota AS IdRota,
    aux.cmr_cd_transportadora AS IdTransportadora,
	aux.cmr_dh_coleta as  cmr_dh_coleta,
	aux.cmr_dh_referencia as cmr_dh_referencia,
    j.initDate AS DataInicioRotaInt,
    j.finishDate AS DataFimRotaInt,
    j.dateCreated AS DataCriacaoRotaint,
    j.[flags.ozh] AS Ozh,
    j.[flags.orh] AS Orh,
    j.cluster AS TipoRota,
    ISNULL(j.[driver.driverName], '-') AS NomeMotorista,
    j.license AS Placa,
	driverId,
	driverUserId,
    j.stops
INTO #json_expandido
FROM #pacotes_json aux
CROSS APPLY OPENJSON(aux.cmr_ds_json)
WITH (
    initDate INT '$.initDate',
    finishDate INT '$.finishDate',
    dateCreated INT '$.dateCreated',
    [flags.ozh] VARCHAR(10) '$.flags.ozh',
    [flags.orh] VARCHAR(10) '$.flags.orh',
    cluster VARCHAR(10) '$.cluster',
    [driver.driverName] VARCHAR(100) '$.driver.driverName',
    license VARCHAR(100) '$.license',
    stops NVARCHAR(MAX) '$.stops'   AS JSON,
	driverId int '$.driverId',
	driverUserId bigint '$.driver.driverUserId'
   
) AS j;

DROP TABLE IF EXISTS #pacotes;

SELECT   
    pacote.IdPacote,  
    j.IdRota,  
    j.IdTransportadora,  
    j.cmr_dh_referencia AS DataReferencia,  -- ou substitua se tiver outro campo de referência  
    j.cmr_dh_coleta AS DataHoraColeta,  -- valor mantido como NULL por não existir no JSON atual  
    DATEADD(SECOND, TRY_CAST(pacote.DataHoraEntrega AS INT) - 10800, '1970-01-01') AS DataHoraEntrega,  
    pacote.TipoPacote,  
    pacote.Status,  
    pacote.SubStatus,  
    pacote.StatusEntrega,  
    pacote.TipoEndereco,  
    pacote.TipoEnderecoPreferencia,  
    CASE WHEN pacote.IdRotaOrigem = 'false' THEN NULL ELSE TRY_CAST(pacote.IdRotaOrigem AS BIGINT) END AS IdRotaOrigem,  
    CASE WHEN pacote.IdRotaDestino = 'false' THEN NULL ELSE TRY_CAST(pacote.IdRotaDestino AS BIGINT) END AS IdRotaDestino,  
    pacote.QuantidadeReclamacoes,  
    CASE WHEN pacote.ForaAreaEntrega = 'false' THEN 0 ELSE 1 END AS ForaAreaEntrega,  
    CASE WHEN pacote.TemVolumoso = 'false' THEN 0 ELSE 1 END AS TemVolumoso,  
    pacote.NomeEtiqueta,  
    orderJson.Endereco, 
	orderJson.TipoPonto,
    stop.IdParada,  
    stop.SequenciaParada,  
    stop.StatusParada,  
    stop.EnderecoParada,  
    CASE   
        WHEN stop.addressTypeResidential = 'true' THEN 'residential'  
        WHEN stop.addressTypeBusiness = 'true' THEN 'business'  
        ELSE 'notCategorized'  
    END AS TipoEnderecoParada,  
    stop.LatitudeEnderecoParada AS LatitudeEnderecoParada,  
    stop.LongitudeEnderecoParada  AS LongitudeEnderecoParada,  
    stop.QuantidadePontosParada,  
    GETDATE() AS DataAtualizacao,  
    DATEADD(SECOND, TRY_CAST(pacote.DataCriacao AS INT) - 10800, '1970-01-01') AS DataCriacao,  

    TRY_CAST(j.DataInicioRotaInt AS INT) AS DataInicioRotaInt,  
    TRY_CAST(j.DataFimRotaInt AS INT) AS DataFimRotaInt,  
    TRY_CAST(j.DataCriacaoRotaint AS INT) AS DataCriacaoRotaint,  

    CASE WHEN TRY_CAST(j.DataInicioRotaInt AS INT) IS NOT NULL 
         THEN DATEADD(SECOND, TRY_CAST(j.DataInicioRotaInt AS INT) - 10800, '1970-01-01') 
         ELSE NULL END AS DataInicioRota,

    CASE WHEN TRY_CAST(j.DataFimRotaInt AS INT) IS NOT NULL 
         THEN DATEADD(SECOND, TRY_CAST(j.DataFimRotaInt AS INT) - 10800, '1970-01-01') 
         ELSE NULL END AS DataFimRota,

    CASE WHEN TRY_CAST(j.DataCriacaoRotaint AS INT) > 0 
         THEN DATEADD(SECOND, TRY_CAST(j.DataCriacaoRotaint AS INT) - 10800, '1970-01-01') 
         ELSE NULL END AS DataCriacaoRota,

    j.Ozh,  
    j.Orh,  
    j.TipoRota,  
    j.NomeMotorista,  
    j.Placa,
	--ROW_NUMBER() over ( partition by IdPacote,IdRota,IdTransportadora order by case when status = 'delivered' then 99999 else IdParada end desc) as OrdemExclusao
	ROW_NUMBER() over ( partition by IdPacote,IdRota,IdTransportadora order by case when StatusEntrega = 'delivered' then 1 else case when StatusEntrega = 'not_delivered' then 2 else case when isnull(IdParada,0) < 2 then 3 else IdParada end end end asc) as OrdemExclusao,

	j.driverId,
	j.driverUserId

INTO #pacotes  
FROM #json_expandido AS j  
CROSS APPLY OPENJSON(j.stops)   
WITH (  
    IdParada BIGINT '$.id',  
    SequenciaParada INT '$.sequence',  
    StatusParada VARCHAR(50) '$.status',  
    EnderecoParada VARCHAR(100) '$.stopAddress',  
    addressTypeResidential VARCHAR(5) '$.addressTypeResidential',  
    addressTypeBusiness VARCHAR(5) '$.addressTypeBusiness',  
    LatitudeEnderecoParada VARCHAR(15) '$.address.latitude',  
    LongitudeEnderecoParada VARCHAR(15) '$.address.longitude',  
    QuantidadePontosParada INT '$.ordersAmount',  
    Pontos NVARCHAR(MAX) '$.orders' AS JSON  
) AS stop  
CROSS APPLY OPENJSON(stop.Pontos, '$')  
WITH (  
    Endereco VARCHAR(100) '$.address',
	TipoPonto varchar(60) '$.type',
    transportUnits NVARCHAR(MAX) '$.transportUnits' AS JSON  
) AS orderJson  
CROSS APPLY OPENJSON(orderJson.transportUnits)  
WITH (  
    IdPacote BIGINT '$.relatedEntity.id',  
    DataHoraEntrega INT '$.relatedEntity.timestamp',  
    TipoPacote VARCHAR(50) '$.relatedEntity.type',  
    Status VARCHAR(50) '$.relatedEntity.status',  
    SubStatus VARCHAR(50) '$.relatedEntity.substatus',  
    StatusEntrega VARCHAR(50) '$.relatedEntity.frontStatus',  
    TipoEndereco VARCHAR(30) '$.relatedEntity.addressType',  
    TipoEnderecoPreferencia VARCHAR(30) '$.relatedEntity.receiverInfo.delivery_preference',  
    IdRotaOrigem VARCHAR(30) '$.relatedEntity.fromRoute',  
    IdRotaDestino VARCHAR(30) '$.relatedEntity.toRoute',  
    QuantidadeReclamacoes INT '$.relatedEntity.claimsAmount',  
    ForaAreaEntrega VARCHAR(5) '$.relatedEntity.outRangeDelivery',  
    TemVolumoso VARCHAR(5) '$.relatedEntity.hasBulky',  
    NomeEtiqueta VARCHAR(30) '$.printedLabel',  
    DataCriacao INT '$.dateCreated'  
) AS pacote;


  /* -- comentado por alteração acima por performance.
DROP TABLE IF EXISTS #pacotes;  
  
SELECT   
    pacote.IdPacote,  
    aux.cmr_cd_rota AS IdRota,  
    aux.cmr_cd_transportadora AS IdTransportadora,  
    aux.cmr_dh_referencia AS DataReferencia,  
    aux.cmr_dh_coleta AS DataHoraColeta,  
    DATEADD(SECOND, CAST(pacote.DataHoraEntrega AS BIGINT) - 10800, '1970-01-01') AS DataHoraEntrega,  
    pacote.TipoPacote,  
    pacote.Status,  
    pacote.SubStatus,  
    pacote.StatusEntrega,  
    pacote.TipoEndereco,  
    pacote.TipoEnderecoPreferencia,  
    CASE WHEN pacote.IdRotaOrigem = 'false' THEN NULL ELSE CAST(pacote.IdRotaOrigem AS BIGINT) END AS IdRotaOrigem,  
    CASE WHEN pacote.IdRotaDestino = 'false' THEN NULL ELSE CAST(pacote.IdRotaDestino AS BIGINT) END AS IdRotaDestino,  
    pacote.QuantidadeReclamacoes,  
    CASE WHEN pacote.ForaAreaEntrega = 'false' THEN 0 ELSE 1 END AS ForaAreaEntrega,  
    CASE WHEN pacote.TemVolumoso = 'false' THEN 0 ELSE 1 END AS TemVolumoso,  
    pacote.NomeEtiqueta,  
    orderJson.Endereco,  
    stop.IdParada,  
    stop.SequenciaParada,  
    stop.StatusParada,  
    stop.EnderecoParada,  
    CASE   
        WHEN stop.addressTypeResidential = 'true' THEN 'residential'  
        WHEN stop.addressTypeBusiness = 'true' THEN 'business'  
        ELSE 'notCategorized'  
    END AS TipoEnderecoParada,  
    stop.LatidudeEnderecoParada AS LatitudeEnderecoParada,  
    stop.LongitudeEnderecoParada,  
    stop.QuantidadePontosParada,  
    GETDATE() AS DataAtualizacao,  
    DATEADD(SECOND, CAST(pacote.DataCriacao AS BIGINT) - 10800, '1970-01-01') AS DataCriacao,	  
	 DataInicioRotaInt,																																		--=======================================================================================--
	 DataFimRotaInt,			
	DataCriacaoRotaint,																																		--Adicoioando 10/07/2025 por Matheus Garbin para acompanhar a lógica da coleta de rotas	 --
	 CASE WHEN DataInicioRotaInt IS NOT NULL THEN DATEADD(SECOND, CAST(DataInicioRotaInt AS BIGINT) - 10800, '1970-01-01') ELSE NULL END AS DataInicioRota,	--=======================================================================================--
     CASE WHEN DataFimRotaInt IS NOT NULL THEN DATEADD(SECOND, CAST(DataFimRotaInt AS BIGINT) - 10800, '1970-01-01') ELSE NULL END AS DataFimRota ,		
	 CASE WHEN DataCriacaoRotaint > 0 THEN DATEADD(SECOND, CAST(DataCriacaoRotaint AS BIGINT) - 10800, '1970-01-01') ELSE NULL END AS DataCriacaoRota,		--=======================================================================================--
	 Ozh,																																					--=======================================================================================--
	 Orh,																																					--=======================================================================================--
	 TipoRota,																																				--=======================================================================================--
	 NomeMotorista,																																			--=======================================================================================--
	 Placa,																																					--=======================================================================================--
	 ROW_NUMBER() over ( partition by IdPacote,IdRota,IdTransportadora order by case when status = 'delivered' then 99999 else IdParada end desc) as OrdemExclusao
INTO #pacotes  
  
FROM #pacotes_json AS aux  
  
CROSS APPLY OPENJSON(aux.cmr_ds_json, '$.stops')   
WITH (  
    IdParada bigint '$.id',  
    SequenciaParada INT '$.sequence',  
    StatusParada VARCHAR(50) '$.status',  
    EnderecoParada VARCHAR(100) '$.stopAddress',  
    addressTypeResidential VARCHAR(5) '$.addressTypeResidential',  
    addressTypeBusiness VARCHAR(5) '$.addressTypeBusiness',  
    addressTypeNotCategorized VARCHAR(5) '$.addressTypeNotCategorized',  
    LatidudeEnderecoParada VARCHAR(15) '$.address.latitude',  
    LongitudeEnderecoParada VARCHAR(15) '$.address.longitude',  
    QuantidadePontosParada INT '$.ordersAmount',  
    Pontos NVARCHAR(MAX) '$.orders' AS JSON  
) AS stop  
  
CROSS APPLY OPENJSON(stop.Pontos, '$')  
WITH (  
    Endereco VARCHAR(100) '$.address',  
    transportUnits NVARCHAR(MAX) '$.transportUnits' AS JSON  
) AS orderJson  
  
CROSS APPLY OPENJSON(orderJson.transportUnits)  
WITH (  
    IdPacote BIGINT '$.relatedEntity.id',  
    DataHoraEntrega INT '$.relatedEntity.timestamp',  
    TipoPacote VARCHAR(50) '$.relatedEntity.type',  
    Status VARCHAR(50) '$.relatedEntity.status',  
    SubStatus VARCHAR(50) '$.relatedEntity.substatus',  
    StatusEntrega VARCHAR(50) '$.relatedEntity.frontStatus',  
    TipoEndereco VARCHAR(30) '$.relatedEntity.addressType',  
    TipoEnderecoPreferencia VARCHAR(30) '$.relatedEntity.receiverInfo.delivery_preference',  
    IdRotaOrigem VARCHAR(30) '$.relatedEntity.fromRoute',  
    IdRotaDestino VARCHAR(30) '$.relatedEntity.toRoute',  
    QuantidadeReclamacoes INT '$.relatedEntity.claimsAmount',  
    ForaAreaEntrega VARCHAR(5) '$.relatedEntity.outRangeDelivery',  
    TemVolumoso VARCHAR(5) '$.relatedEntity.hasBulky',  
    NomeEtiqueta VARCHAR(30) '$.printedLabel',  
    DataCriacao INT '$.dateCreated'  
) AS pacote  

--=======================================================================================
--Adicoioando 10/07/2025 por Matheus Garbin para acompanhar a lógica da coleta de rotas
--=======================================================================================
CROSS APPLY OPENJSON(aux.cmr_ds_json)
WITH(		
   DataInicioRotaInt int '$.initDate',	
   DataFimRotaInt int '$.finishDate',
   DataCriacaoRotaint int '$.dateCreated',
   Ozh varchar(10) '$.flags.ozh',
   Orh varchar(10) '$.flags.orh',
   TipoRota varchar(10) '$.cluster',
   NomeMotorista VARCHAR(100) '$.driver.driverName',
   Placa varchar(100) '$.license'

) AS DATAJSON
*/
update aux
set datareferencia = --DataInicioRota
	CASE
		WHEN prmData.prm_ds_valor = 1159 THEN CASE WHEN DataInicioRotaInt = 0 then CAST(DataCriacaoRota AS DATE) ELSE  CAST(DataInicioRota AS DATE) END
		WHEN isnull(prmData.prm_ds_valor,1162) = 1162 THEN CASE WHEN DataFimRotaInt = 0 THEN cast(dateadd(hour,-3,DataHoraColeta) as date) ELSE DataFimRota END
	END
from #pacotes aux
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
    ON prmData.cli_id_logistics = aux.IdTransportadora

delete pacotes 
from #pacotes as pacotes
where OrdemExclusao > 1


--=======================================================================================
--=======================================================================================
--=======================================================================================
  
 merge tb_ml_pacotes as p  
 using (  
   --quando uma rota é "roteada", ou seja, os campos IdRotaOrigem e IdRotaDestino são repetidos porém em registros diferentes, é duplicado  
   --para isso, é feito um max nesses campos considerando o id de menor parada e menor data hora entrega como critério, uma vez que a parada tb é diferente  
   select  
    base.*  
    ,(select top 1 Status from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParadaJoin = p2.IdParada order by case isnull(StatusEntrega,'') when 'delivered' then 1 when 'not_delivered' then 2 else 3 end) Status  
    ,(select top 1 SubStatus from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParadaJoin = p2.IdParada order by case isnull(StatusEntrega,'') when 'delivered' then 1 when 'not_delivered' then 2 else 3 end) SubStatus  
    ,(select top 1 StatusEntrega from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParadaJoin = p2.IdParada order by case isnull(StatusEntrega,'') when 'delivered' then 1 when 'not_delivered' then 2 else 3 end) StatusEntrega  
    ,(select top 1 ForaAreaEntrega from #pacotes p2 where base.IdPacote = p2.IdPacote and base.IdParadaJoin = p2.IdParada order by case isnull(StatusEntrega,'') when 'delivered' then 1 when 'not_delivered' then 2 else 3 end) ForaAreaEntrega  
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
      ,TipoPacote  
      ,max(TipoEndereco) TipoEndereco  
      ,max(TipoEnderecoPreferencia) TipoEnderecoPreferencia  
      ,max(IdRotaOrigem) IdRotaOrigem  
      ,max(IdRotaDestino) IdRotaDestino  
      ,QuantidadeReclamacoes  
      ,TemVolumoso  
      ,max(NomeEtiqueta) NomeEtiqueta  
      ,max(Endereco) Endereco
	  ,max(TipoPonto) TipoPonto
      ,case when min(IdParada) = max(idParada) then min(IdParada) else min(IdParada) + max(idParada) end IdParada  
      ,min(IdParada) IdParadaJoin  
      --,max(DataAtualizacao) DataAtualizacao  
      ,min(DataCriacao) as DataCriacao  
     from   
      #pacotes   
     group by  
      IdPacote  
      ,IdRota  
      ,IdTransportadora  
      ,DataHoraColeta  
      ,TipoPacote  
      --,TipoEndereco  
      --,TipoEnderecoPreferencia  
      ,QuantidadeReclamacoes  
      ,TemVolumoso  
      --,NomeEtiqueta  
      --,Endereco  
    ) base  
    join (select   
       distinct   
       IdPacote  
       ,IdParada  
       ,StatusParada  
       ,LatitudeEnderecoParada  
       ,LongitudeEnderecoParada  
       ,QuantidadePontosParada   
       ,SequenciaParada  
       ,EnderecoParada  
       ,TipoEnderecoParada  
      from   
       #pacotes  
      ) p on base.IdPacote = p.IdPacote and base.IdParadaJoin = p.IdParada  
  ) as i ON p.IdRota = i.IdRota and p.IdPacote = i.IdPacote  --and p.DataReferencia = i.DataReferencia --- comentado 10/07/2025 por Matheus Garbin para acompanhar a lógica da coleta de rotas
	and p.IdTransportadora = i.IdTransportadora  
 when matched then  
 update set  
  p.DataHoraEntrega = i.DataHoraEntrega  
  ,p.TipoPacote = i.TipoPacote  
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
  ,p.TipoPonto = i.TipoPonto
  ,p.IdParada = i.IdParada  
  ,p.SequenciaParada = i.SequenciaParada  
  ,p.StatusParada = i.StatusParada  
  ,p.EnderecoParada = i.EnderecoParada  
  ,p.TipoEnderecoParada = i.TipoEnderecoParada  
  ,p.LatitudeEnderecoParada = i.LatitudeEnderecoParada  
  ,p.LongitudeEnderecoParada = i.LongitudeEnderecoParada  
  ,p.QuantidadePontosParada = i.QuantidadePontosParada  
  ,p.DataHoraColeta = i.DataHoraColeta  
  ,p.DataAtualizacao = getdate()
  ,p.Excluido = 0  
  ,p.DataCriacao = i.DataCriacao  
  ,p.datareferencia = i.datareferencia
  
 when not matched by target then   
 insert (  
   IdPacote  
   ,IdRota  
   ,IdTransportadora  
   ,DataReferencia  
   ,DataHoraColeta  
   ,DataHoraEntrega  
   ,TipoPacote  
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
   ,Excluido  
   ,DataCriacao  
   ,TipoPonto
 )  
 values (  
   i.IdPacote  
   ,i.IdRota  
   ,i.IdTransportadora  
   ,i.DataReferencia  
   ,i.DataHoraColeta  
   ,i.DataHoraEntrega  
   ,i.TipoPacote  
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
   ,getdate()
   ,0  
   ,i.DataCriacao  
   ,i.TipoPonto
 );  

 
--=======================================================================================
--Adicioando 10/07/2025 por Matheus Garbin para acompanhar a lógica da coleta de rotas
--=======================================================================================

MERGE tb_ml_rotas  AS R
USING  ( select        
			  IdRota  
			  ,idtransportadora
			  ,TipoRota
			  ,Orh
			  ,Ozh
			  ,NomeMotorista
			  ,Placa
			  ,DataReferencia
			  ,driverId
			  ,driverUserId
			from   
			 #pacotes   
		group by  
			 IdRota  
			 ,idtransportadora
			 ,TipoRota
			 ,Orh
			 ,Ozh
			 ,NomeMotorista
			 ,Placa
			 ,DataReferencia
			 ,driverId
			 ,driverUserId
    ) as i  
	  ON r.IdRota = i.IdRota  and r.IdTransportadora = i.IdTransportadora  

WHEN MATCHED AND 
    (
         ISNULL(r.tiporota, '')					<>		ISNULL(i.tiporota, '')		 OR
		 ISNULL(r.TempoEmRota, '')				<>		ISNULL(i.Orh, '')			 OR
		 ISNULL(r.TempoAreaEntrega, '')			<>		ISNULL(i.Ozh, '')			 OR
		 ISNULL(r.NomeMotorista, '')			<>		ISNULL(i.NomeMotorista, '')  OR
		 ISNULL(r.Placa, '')					<>		ISNULL(i.Placa, '')			 OR
		 ISNULL(r.DataReferencia, '')			<>		ISNULL(i.DataReferencia, '') OR
		 ISNULL(r.driverId, 0)					<>		ISNULL(i.driverId, 0) OR
		 ISNULL(r.driverUserId, 0)				<>		ISNULL(i.driverUserId, 0)

    )
THEN
    UPDATE SET 
        r.tiporota				= i.tiporota,
		r.TempoEmRota			= i.Orh, 		
		r.TempoAreaEntrega		= i.Ozh, 		
		r.NomeMotorista			= i.NomeMotorista, 
		r.Placa					= i.Placa,
		r.DataReferencia		= i.DataReferencia,
		r.driverId				= i.driverId,
		r.driverUserId			= i.driverUserId
;
		
--=========================================================================================================

-- Adicionado por Saulo Barros em 05/06/2025 para poder excluir os pacotes que não fazem mais parte da rota
declare @count int = (select count(1) from #pacotes)
if @count > 0
begin
	
	drop table if exists #rotas
	select 
		distinct 
		IdRota, 
		DataReferencia, 
		IdTransportadora 
		into #rotas
	from 
		#pacotes

	--Diminui 5 dias como margem pois pacotes que foram excluidos podem ter datas anteriores aos pacotes atuais pois não foram atualizados por não aparecer mais no json
	declare @DataReferencia date = (select dateadd(day,-5,min(DataReferencia)) from #rotas)

	drop table if exists #pacotes_exclusao
	select
		p.Id
		into #pacotes_exclusao
	from
		tb_ml_pacotes p with(nolock)
		--Join para considerar apenas os pacotes das rotas que foram coletadas referente ao pacote
		join #rotas r on p.IdRota = r.IdRota 
					--and p.DataReferencia = r.DataReferencia
					and p.IdTransportadora = r.IdTransportadora
		left join #pacotes i on p.IdRota = i.IdRota 
							and p.IdPacote = i.IdPacote 
							--and p.DataReferencia = i.DataReferencia 
							and p.IdTransportadora = i.IdTransportadora
	where
		i.IdPacote is null
		and p.DataReferencia >= @DataReferencia --filtro para melhorar performance
		and p.Excluido = 0

	update
		p
	set
		Excluido = 1,
		DataAtualizacao = GETDATE()
	from
		tb_ml_pacotes p
		join #pacotes_exclusao p2 on p.Id = p2.Id
		
end


  
update db_Irisys_Json.dbo.tb_ml_coleta_rotas   
set cmr_in_processado = 1  
, cmt_dh_processamento = getdate()  
 where cmr_cd_coleta in (select cmr_cd_coleta from #pacotes_json)  
GO
