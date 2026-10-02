/*==============================================================================
  ROLLBACK SCRIPT
  ==============================================================================
  Task ClickUp : CU-PENDENTE (id da task a definir pelo solicitante)
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-02
  Descrição    : Restaura a versao baseline (14/09/2026) da
                 dbo.UspGeraColetaCidadesDistanteDia, revertendo a refatoracao
                 de performance do forward 030.
  Forward ref  : scripts/forward/2026/10/030_forward_CU-PENDENTE_usp_coleta_cidades_perf.sql
  Objetos      : ALTER PROCEDURE dbo.UspGeraColetaCidadesDistanteDia
  Dependências : dbo.UspGeraAtualizaCidadesDistanteDiaPacote (inalterada)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY

CREATE OR ALTER PROCEDURE [dbo].[UspGeraColetaCidadesDistanteDia]
(
      @datainicio       DATE = NULL
    , @datafim          DATE = NULL
    , @IdTransportadora INT  = NULL
)
AS
BEGIN

IF @datainicio IS NULL BEGIN SET @datainicio = CAST(GETDATE() - 5 AS DATE) END
IF @datafim    IS NULL BEGIN SET @datafim    = CAST(GETDATE() AS DATE) END

--ela identifica quais sao as cidades do pacote e registra qual e o mais disntante

DROP TABLE IF EXISTS #base1;
SELECT 
        a.IdRota
        ,a.IdPacote
        ,a.LatitudeEnderecoParada  AS Latitude
        ,a.LongitudeEnderecoParada AS Longitude
        ,geography::Point(a.LatitudeEnderecoParada, a.LongitudeEnderecoParada, 4326).STDistance(geography::Point(c.bss_dc_latitude, c.bss_dc_longitude, 4326)) AS distancia
        ,CASE
            WHEN LAG(LatitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada) IS NOT NULL
             AND LAG(LongitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada) IS NOT NULL
            THEN geography::Point(LatitudeEnderecoParada, LongitudeEnderecoParada, 4326)
                 .STDistance(geography::Point(
                      LAG(LatitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada),
                      LAG(LongitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada),
                      4326))
            ELSE NULL
        END AS DistanciaDaAnterior
        ,CASE
            WHEN LEAD(LatitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada) IS NOT NULL
             AND LEAD(LongitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada) IS NOT NULL
            THEN geography::Point(LatitudeEnderecoParada, LongitudeEnderecoParada, 4326)
                 .STDistance(geography::Point(
                      LEAD(LatitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada),
                      LEAD(LongitudeEnderecoParada) OVER (PARTITION BY a.idrota ORDER BY SequenciaParada),
                      4326))
            ELSE NULL
        END AS DistanciaDaPosterior
INTO #base1
FROM tb_ml_pacotes AS a WITH (NOLOCK)
INNER JOIN (
            SELECT
                 idrota, datareferencia, idtransportadora
                ,COALESCE(ctb_saida, CASE WHEN (a.ServiceCenter <> a.OrigemSaida AND LEFT(a.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(bss.bss_espelho_xpt, 0) = 1 THEN a.OrigemSaida ELSE a.ServiceCenter END) servicecenter
                ,StatusRota, CidadeDistante
                ,ctb_saida
            FROM tb_ml_rotas AS a WITH (NOLOCK)
            JOIN tb_clientes AS cli ON a.IdTransportadora = cli.cli_id_logistics AND cli.cli_cd_codigo_cliente <> 7
            LEFT JOIN tb_parametros AS prm ON cli.cli_cd_codigo_cliente = prm.prm_cod_cliente AND prm.prm_nm_parametro = 'Service Center Padrão'
            LEFT JOIN tb_bases AS bss ON a.origemsaida = bss.bss_ds_sigla AND bss.bss_cd_idtransportadora = a.IdTransportadora AND bss.bss_espelho_xpt = 1
            LEFT JOIN tb_motorista AS mot ON a.usuarioda = mot.mot_cd_usuario
            LEFT JOIN (
                SELECT
                    cli_id_logistics
                    ,a.*
                FROM tb_fin_contrato_base AS a
                INNER JOIN tb_clientes AS b ON a.ctb_cd_cliente = cli_cd_codigo_cliente
            ) AS b
            ON b.ctb_svc = CASE WHEN (a.ServiceCenter <> a.OrigemSaida AND LEFT(a.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(bss.bss_espelho_xpt, 0) = 1 THEN a.OrigemSaida ELSE a.ServiceCenter END
            AND a.idtransportadora = b.cli_id_logistics
            AND mot_ctn_cd_tipo_contrato = ctb_cd_contrato
            WHERE 1 = 1
            AND datareferencia BETWEEN @datainicio AND @datafim
            AND excluido = 0
            AND StatusRota <> 'planned'
            AND (CidadeDistante IS NULL OR CidadeDistante IN ('Sem pacote entregue', 'Sem base cadastrada'))
) AS b
ON a.IdRota = b.IdRota
AND a.DataReferencia = b.DataReferencia
INNER JOIN tb_bases AS c WITH (NOLOCK)
ON b.idtransportadora = c.bss_cd_idtransportadora
AND b.servicecenter = c.bss_ds_sigla
WHERE a.DataReferencia BETWEEN @datainicio AND @datafim
AND bss_cd_base NOT IN (1, 7)
AND a.excluido = 0
AND StatusEntrega <> 'not_delivered'
AND CAST(bss_dc_longitude AS DECIMAL(14, 10)) BETWEEN -90 AND 90
AND CAST(a.LatitudeEnderecoParada AS DECIMAL(14, 10)) BETWEEN -90 AND 90
AND (b.CidadeDistante IS NULL OR b.CidadeDistante IN ('Sem pacote entregue', 'Sem base cadastrada'))
AND (
    a.IdTransportadora = @IdTransportadora
    OR @IdTransportadora IS NULL
);

--==========================================================================

DROP TABLE IF EXISTS #base2;

SELECT *
INTO #base2
FROM #base1
WHERE (DistanciaDaAnterior > 999 OR DistanciaDaAnterior IS NULL)
AND (DistanciaDaPosterior > 999 OR DistanciaDaPosterior IS NULL);

DELETE
FROM #base1
WHERE (DistanciaDaAnterior > 999 OR DistanciaDaAnterior IS NULL)
AND (DistanciaDaPosterior > 999 OR DistanciaDaPosterior IS NULL);

UPDATE a
-- WHERE no fim do statement: escopo por Excluido, DataReferencia e IdTransportadora
SET a.CidadeDistante = b.ordem
FROM tb_ml_pacotes AS a WITH (ROWLOCK, READPAST, UPDLOCK)
INNER JOIN (
    SELECT
        IdRota,
        idpacote,
        Latitude,
        Longitude,
        ordem
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY distancia DESC) AS ordem
        FROM #base1
    ) AS a
) AS b
ON a.idrota = b.idrota
AND a.IdPacote = b.idpacote
AND a.LongitudeEnderecoParada = b.longitude
AND a.LatitudeEnderecoParada = b.latitude
WHERE a.excluido = 0
AND a.DataReferencia BETWEEN @datainicio AND @datafim
AND (
    a.IdTransportadora = @IdTransportadora
    OR @IdTransportadora IS NULL
);

UPDATE a
-- WHERE no fim do statement: escopo por Excluido, DataReferencia e IdTransportadora
SET a.CidadeDistante = b.ordem
FROM tb_ml_pacotes AS a WITH (ROWLOCK, READPAST, UPDLOCK)
INNER JOIN (
    SELECT
        IdRota,
        idpacote,
        Latitude,
        Longitude,
        ordem
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (PARTITION BY A.idrota ORDER BY A.distancia DESC) AS ordem
        FROM #base2 AS a
        LEFT JOIN #base1 AS b ON a.idrota = b.idrota
        WHERE b.idrota IS NULL
    ) AS a
) AS b
ON a.idrota = b.idrota
AND a.IdPacote = b.idpacote
AND a.LongitudeEnderecoParada = b.longitude
AND a.LatitudeEnderecoParada = b.latitude
WHERE a.excluido = 0
AND a.DataReferencia BETWEEN @datainicio AND @datafim
AND (
    a.IdTransportadora = @IdTransportadora
    OR @IdTransportadora IS NULL
);

-- Correção: INSERT idempotente pela UK completa (lat, lng, cidade_distante)
INSERT INTO dbo.tb_dra_cidades_geo (
    dcg_nr_latitude,
    dcg_nr_longitude,
    dcg_cidade_distante,
    dcg_dh_inclusao
)
SELECT
    fonte.LatitudeEnderecoParada,
    fonte.LongitudeEnderecoParada,
    fonte.dcg_cidade_distante,
    getdate() dcg_dh_inclusao

FROM (
    SELECT
        pacotes.LatitudeEnderecoParada,
        pacotes.LongitudeEnderecoParada,
        MIN(pacotes.CidadeDistante) AS dcg_cidade_distante
    FROM dbo.tb_ml_pacotes AS pacotes WITH (NOLOCK)
    WHERE pacotes.LatitudeEnderecoParada IS NOT NULL
      AND pacotes.LongitudeEnderecoParada IS NOT NULL
      AND pacotes.datareferencia BETWEEN @datainicio AND @datafim
      AND pacotes.CidadeDistante >= 1
      AND (
            pacotes.IdTransportadora = @IdTransportadora
            OR @IdTransportadora IS NULL
          )
    GROUP BY
        pacotes.LatitudeEnderecoParada,
        pacotes.LongitudeEnderecoParada
) AS fonte
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.tb_dra_cidades_geo AS g WITH (UPDLOCK, HOLDLOCK)
    WHERE g.dcg_nr_latitude  = fonte.LatitudeEnderecoParada
      AND g.dcg_nr_longitude = fonte.LongitudeEnderecoParada
      AND g.dcg_cidade_distante = fonte.dcg_cidade_distante
);

---- Ajuste casos sem base cadastrada ---

UPDATE a
SET a.CidadeDistante = 'Sem base cadastrada'
FROM tb_ml_rotas AS a
INNER JOIN tb_clientes AS b ON cli_id_logistics = idtransportadora
LEFT JOIN tb_parametros AS prm ON b.cli_cd_codigo_cliente = prm.prm_cod_cliente AND prm.prm_nm_parametro = 'Service Center Padrão'
LEFT JOIN tb_bases c
ON CASE WHEN (a.ServiceCenter <> a.OrigemSaida AND LEFT(a.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(c.bss_espelho_xpt, 0) = 1 THEN a.OrigemSaida ELSE a.ServiceCenter END = c.bss_ds_sigla
AND a.idtransportadora = bss_cd_idtransportadora
WHERE CidadeDistante IS NULL
AND c.bss_ds_sigla IS NULL
AND a.excluido = 0
AND DataReferencia >= @datainicio
AND DataReferencia <= @datafim
AND statusrota <> 'planned'
AND (
    a.IdTransportadora = @IdTransportadora
    OR @IdTransportadora IS NULL
);

UPDATE a
SET a.CidadeDistante = 'Sem pacote entregue'
FROM tb_ml_rotas AS a
INNER JOIN tb_clientes AS b ON cli_id_logistics = idtransportadora
LEFT JOIN tb_parametros AS prm ON b.cli_cd_codigo_cliente = prm.prm_cod_cliente AND prm.prm_nm_parametro = 'Service Center Padrão'
JOIN tb_bases c
ON CASE WHEN (a.ServiceCenter <> a.OrigemSaida AND LEFT(a.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(c.bss_espelho_xpt, 0) = 1 THEN a.OrigemSaida ELSE a.ServiceCenter END = c.bss_ds_sigla
AND a.idtransportadora = bss_cd_idtransportadora
WHERE CidadeDistante IS NULL
AND PacotesEntregues = 0
AND a.excluido = 0
AND statusrota <> 'planned'
AND DataReferencia >= @datainicio
AND DataReferencia <= @datafim
AND (
    a.IdTransportadora = @IdTransportadora
    OR @IdTransportadora IS NULL
);

EXEC [dbo].[UspGeraAtualizaCidadesDistanteDiaPacote] @datainicio, @datafim, @IdTransportadora;

END

    PRINT 'SUCESSO: UspGeraColetaCidadesDistanteDia restaurada para a versao baseline.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
