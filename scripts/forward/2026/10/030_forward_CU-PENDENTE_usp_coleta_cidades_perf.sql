/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-PENDENTE (id da task a definir pelo solicitante)
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-02
  Descrição    : Refatoracao de performance da dbo.UspGeraColetaCidadesDistanteDia.
                 Sem mudanca de semantica (validado A/B em QAS):
                 - LAG/LEAD calculados uma unica vez (antes: 2x cada no CASE)
                 - geography::Point da parada/base construido uma vez por linha
                 - elimina #base2 + DELETE + segundo UPDATE em tb_ml_pacotes
                   (flag Isolado + ranking unico por rota; rotas 100% isoladas
                   continuam ranqueando os pontos isolados)
                 - UPDATEs em tb_ml_pacotes deixam de fazer join por lat/lng
                   (par IdRota+IdPacote ja e unico pela uk_ml_pacote_chave_temp)
                 - CAST removido de colunas decimal (bss_dc_latitude/longitude)
                 - TRY_CAST nas coordenadas varchar do pacote (evita abortar a
                   proc com coordenada suja; antes o CAST/Point lancava erro)
                 - unificacao dos dois UPDATEs finais de tb_ml_rotas em um so scan
                 - SET NOCOUNT ON + OPTION (RECOMPILE) nas operacoes pesadas
  Rollback     : scripts/rollback/2026/10/030_rollback_CU-PENDENTE_usp_coleta_cidades_perf.sql
  Objetos      : ALTER PROCEDURE dbo.UspGeraColetaCidadesDistanteDia
  Dependências : dbo.UspGeraAtualizaCidadesDistanteDiaPacote (inalterada);
                 job "DriveAnalytics - Carrega Pacotes - Instance 01"
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

    SET NOCOUNT ON;

    IF @datainicio IS NULL BEGIN SET @datainicio = CAST(GETDATE() - 5 AS DATE) END
    IF @datafim    IS NULL BEGIN SET @datafim    = CAST(GETDATE()     AS DATE) END

    -- ela identifica quais sao as cidades do pacote e registra qual e o mais distante

    DROP TABLE IF EXISTS #base;

    ;WITH rotas AS (
        SELECT
             r.IdRota
            ,r.DataReferencia
            ,r.IdTransportadora
            ,COALESCE(b.ctb_saida,
                CASE WHEN (r.ServiceCenter <> r.OrigemSaida AND LEFT(r.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(bss.bss_espelho_xpt, 0) = 1
                     THEN r.OrigemSaida ELSE r.ServiceCenter END) AS ServiceCenter
        FROM tb_ml_rotas AS r WITH (NOLOCK)  -- NOLOCK intencional: dirty read aceitavel em rotina diaria de ranking
        JOIN tb_clientes AS cli ON r.IdTransportadora = cli.cli_id_logistics AND cli.cli_cd_codigo_cliente <> 7
        LEFT JOIN tb_parametros AS prm ON cli.cli_cd_codigo_cliente = prm.prm_cod_cliente AND prm.prm_nm_parametro = 'Service Center Padrão'
        LEFT JOIN tb_bases AS bss ON r.OrigemSaida = bss.bss_ds_sigla AND bss.bss_cd_idtransportadora = r.IdTransportadora AND bss.bss_espelho_xpt = 1
        LEFT JOIN tb_motorista AS mot ON r.UsuarioDA = mot.mot_cd_usuario
        LEFT JOIN (
            SELECT
                 cli_id_logistics
                ,a.*
            FROM tb_fin_contrato_base AS a
            INNER JOIN tb_clientes AS b ON a.ctb_cd_cliente = b.cli_cd_codigo_cliente
        ) AS b
            ON b.ctb_svc = CASE WHEN (r.ServiceCenter <> r.OrigemSaida AND LEFT(r.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(bss.bss_espelho_xpt, 0) = 1 THEN r.OrigemSaida ELSE r.ServiceCenter END
            AND r.IdTransportadora = b.cli_id_logistics
            AND mot.mot_ctn_cd_tipo_contrato = b.ctb_cd_contrato
        WHERE r.DataReferencia BETWEEN @datainicio AND @datafim
          AND r.Excluido = 0
          AND r.StatusRota <> 'planned'
          AND (r.CidadeDistante IS NULL OR r.CidadeDistante IN ('Sem pacote entregue', 'Sem base cadastrada'))
    ),
    paradas AS (
        SELECT
             p.IdRota
            ,p.IdPacote
            ,TRY_CAST(p.LatitudeEnderecoParada  AS DECIMAL(14,10)) AS Lat
            ,TRY_CAST(p.LongitudeEnderecoParada AS DECIMAL(14,10)) AS Lng
            ,LAG (TRY_CAST(p.LatitudeEnderecoParada  AS DECIMAL(14,10))) OVER (PARTITION BY p.IdRota ORDER BY p.SequenciaParada) AS LatAnt
            ,LAG (TRY_CAST(p.LongitudeEnderecoParada AS DECIMAL(14,10))) OVER (PARTITION BY p.IdRota ORDER BY p.SequenciaParada) AS LngAnt
            ,LEAD(TRY_CAST(p.LatitudeEnderecoParada  AS DECIMAL(14,10))) OVER (PARTITION BY p.IdRota ORDER BY p.SequenciaParada) AS LatPos
            ,LEAD(TRY_CAST(p.LongitudeEnderecoParada AS DECIMAL(14,10))) OVER (PARTITION BY p.IdRota ORDER BY p.SequenciaParada) AS LngPos
            ,c.bss_dc_latitude  AS BaseLat
            ,c.bss_dc_longitude AS BaseLng
        FROM tb_ml_pacotes AS p WITH (NOLOCK)  -- NOLOCK intencional: dirty read aceitavel em rotina diaria de ranking
        INNER JOIN rotas AS r ON p.IdRota = r.IdRota AND p.DataReferencia = r.DataReferencia
        INNER JOIN tb_bases AS c WITH (NOLOCK) -- NOLOCK intencional: dirty read aceitavel em rotina diaria de ranking
            ON r.IdTransportadora = c.bss_cd_idtransportadora
           AND r.ServiceCenter    = c.bss_ds_sigla
        WHERE p.DataReferencia BETWEEN @datainicio AND @datafim
          AND c.bss_cd_base NOT IN (1, 7)
          AND p.Excluido = 0
          AND p.StatusEntrega <> 'not_delivered'
          AND c.bss_dc_latitude  BETWEEN -90  AND 90
          AND c.bss_dc_longitude BETWEEN -90  AND 90
          AND TRY_CAST(p.LatitudeEnderecoParada  AS DECIMAL(14,10)) BETWEEN -90  AND 90
          AND TRY_CAST(p.LongitudeEnderecoParada AS DECIMAL(14,10)) BETWEEN -180 AND 180
          AND (@IdTransportadora IS NULL OR p.IdTransportadora = @IdTransportadora)
    )
    SELECT
         par.IdRota
        ,par.IdPacote
        ,par.Lat AS Latitude
        ,par.Lng AS Longitude
        ,pto.STDistance(ptb) AS distancia
        ,CASE WHEN par.LatAnt IS NOT NULL AND par.LngAnt IS NOT NULL
              THEN pto.STDistance(geography::Point(par.LatAnt, par.LngAnt, 4326))
         END AS DistanciaDaAnterior
        ,CASE WHEN par.LatPos IS NOT NULL AND par.LngPos IS NOT NULL
              THEN pto.STDistance(geography::Point(par.LatPos, par.LngPos, 4326))
         END AS DistanciaDaPosterior
    INTO #base
    FROM paradas AS par
    CROSS APPLY (SELECT geography::Point(par.Lat, par.Lng, 4326))     AS pto(v)
    CROSS APPLY (SELECT geography::Point(par.BaseLat, par.BaseLng, 4326)) AS ptb(v)
    OPTION (RECOMPILE);

    CREATE CLUSTERED INDEX ix_base_rota_pacote ON #base (IdRota, IdPacote);

    --==========================================================================
    -- Ranking unico: pontos nao-isolados primeiro; isolados so recebem ordem
    -- quando a rota inteira e isolada (equivale ao par #base1/#base2 anterior)
    ;WITH ranked AS (
        SELECT
             b.IdRota
            ,b.IdPacote
            ,b.distancia
            ,CASE WHEN (b.DistanciaDaAnterior  > 999 OR b.DistanciaDaAnterior  IS NULL)
                  AND (b.DistanciaDaPosterior > 999 OR b.DistanciaDaPosterior IS NULL)
                  THEN 1 ELSE 0 END AS Isolado
        FROM #base AS b
    ),
    marc AS (
        SELECT
             r.IdRota
            ,r.IdPacote
            ,ROW_NUMBER() OVER (PARTITION BY r.IdRota ORDER BY r.Isolado, r.distancia DESC) AS ordem
            ,MIN(r.Isolado)  OVER (PARTITION BY r.IdRota) AS MinIsolado
            ,r.Isolado
        FROM ranked AS r
    )
    UPDATE p
    SET p.CidadeDistante = m.ordem
    FROM tb_ml_pacotes AS p WITH (ROWLOCK, READPAST, UPDLOCK)
    INNER JOIN marc AS m
        ON m.IdRota   = p.IdRota
       AND m.IdPacote = p.IdPacote
    WHERE (m.Isolado = 0 OR m.MinIsolado = 1)
      AND p.Excluido = 0
      AND p.DataReferencia BETWEEN @datainicio AND @datafim
      AND (@IdTransportadora IS NULL OR p.IdTransportadora = @IdTransportadora)
    OPTION (RECOMPILE);

    -- Correcao: INSERT idempotente pela UK completa (lat, lng, cidade_distante)
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
        GETDATE() AS dcg_dh_inclusao
    FROM (
        SELECT
            pacotes.LatitudeEnderecoParada,
            pacotes.LongitudeEnderecoParada,
            MIN(pacotes.CidadeDistante) AS dcg_cidade_distante
        FROM dbo.tb_ml_pacotes AS pacotes WITH (NOLOCK)  -- NOLOCK intencional: dirty read aceitavel em rotina diaria de ranking
        WHERE pacotes.LatitudeEnderecoParada IS NOT NULL
          AND pacotes.LongitudeEnderecoParada IS NOT NULL
          AND pacotes.DataReferencia BETWEEN @datainicio AND @datafim
          AND pacotes.CidadeDistante >= 1
          AND (@IdTransportadora IS NULL OR pacotes.IdTransportadora = @IdTransportadora)
        GROUP BY
            pacotes.LatitudeEnderecoParada,
            pacotes.LongitudeEnderecoParada
    ) AS fonte
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_dra_cidades_geo AS g WITH (UPDLOCK, HOLDLOCK)
        WHERE g.dcg_nr_latitude      = fonte.LatitudeEnderecoParada
          AND g.dcg_nr_longitude     = fonte.LongitudeEnderecoParada
          AND g.dcg_cidade_distante  = fonte.dcg_cidade_distante
    );

    -- Ajuste casos sem base cadastrada / sem pacote entregue (um unico scan)
    UPDATE r
    SET r.CidadeDistante = CASE WHEN c.bss_ds_sigla IS NULL THEN 'Sem base cadastrada'
                                WHEN r.PacotesEntregues = 0 THEN 'Sem pacote entregue'
                                ELSE r.CidadeDistante END
    FROM tb_ml_rotas AS r
    INNER JOIN tb_clientes AS b ON b.cli_id_logistics = r.IdTransportadora
    LEFT JOIN tb_parametros AS prm ON b.cli_cd_codigo_cliente = prm.prm_cod_cliente AND prm.prm_nm_parametro = 'Service Center Padrão'
    LEFT JOIN tb_bases AS c ON CASE WHEN (r.ServiceCenter <> r.OrigemSaida AND LEFT(r.OrigemSaida, 1) IN ('E', 'M') AND ISNULL(prm.prm_ds_valor, 0) <> 1) OR ISNULL(c.bss_espelho_xpt, 0) = 1 THEN r.OrigemSaida ELSE r.ServiceCenter END = c.bss_ds_sigla
                        AND r.IdTransportadora = c.bss_cd_idtransportadora
    WHERE r.CidadeDistante IS NULL
      AND (c.bss_ds_sigla IS NULL OR r.PacotesEntregues = 0)
      AND r.Excluido = 0
      AND r.StatusRota <> 'planned'
      AND r.DataReferencia BETWEEN @datainicio AND @datafim
      AND (@IdTransportadora IS NULL OR r.IdTransportadora = @IdTransportadora)
    OPTION (RECOMPILE);

    -- Depende dos resultados acima (pacotes.CidadeDistante, tb_dra_cidades_geo
    -- e status de fallback em rotas); manter sempre como ultima etapa.
    EXEC [dbo].[UspGeraAtualizaCidadesDistanteDiaPacote] @datainicio, @datafim, @IdTransportadora;

END

    PRINT 'SUCESSO: UspGeraColetaCidadesDistanteDia atualizada.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
