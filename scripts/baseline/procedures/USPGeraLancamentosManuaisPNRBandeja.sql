-- ============================================================
-- BASELINE: dbo.USPGeraLancamentosManuaisPNRBandeja
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPGeraLancamentosManuaisPNRBandeja]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USPGeraLancamentosManuaisPNRBandeja]
(
      @DataIni    DATE = NULL
    , @DataFim    DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
           @DataInicial  DATE = isnull(@DataIni,CAST(GETDATE() AS DATE))
          ,@DataFinalEff DATE = isnull(@DataFim,DATEADD(DAY, -15, CAST(GETDATE() AS DATE)));

    DECLARE @Resultado TABLE
    (
          Cliente           INT           NOT NULL
        , IdTransportadora  INT           NOT NULL
        , DataInicial       DATE          NOT NULL
        , DataFinal         DATE          NOT NULL
        , LinhasLancamentos INT           NOT NULL
        , LinhasAprovacoes  INT           NOT NULL
        , AprovaAuto        BIT           NOT NULL
        , Status            VARCHAR(10)   NOT NULL
        , Mensagem          VARCHAR(4000) NULL
    );

    CREATE TABLE #ClientesParam
    (
          Cliente          INT NOT NULL PRIMARY KEY
        , IdTransportadora INT NOT NULL
    );

    INSERT INTO #ClientesParam (Cliente, IdTransportadora)
    SELECT DISTINCT
          prm.prm_cod_cliente
        , cli.cli_id_logistics
    FROM dbo.tb_parametros AS prm WITH (NOLOCK)
    INNER JOIN dbo.tb_clientes AS cli WITH (NOLOCK)
            ON cli.cli_cd_codigo_cliente = prm.prm_cod_cliente
    WHERE prm.prm_ds_categoria = N'PNR Bandeja'
      AND prm.prm_nm_parametro = N'Habilitar PNR Bandeja'
      AND prm.prm_ds_valor = N'1'
      AND ISNULL(prm.prm_in_ativo, 0) = 1
      AND ISNULL(prm.prm_in_excluido, 0) = 0
      AND cli.cli_id_logistics IS NOT NULL
      AND cli.cli_id_logistics > 0;

    -- ============================================================================
    -- ALTERAÇÃO 1: #ConfigClientes agora inclui ParamUtilizaSVC
    --   Lê parâmetro "Service Center Padrão" (mesma lógica da UspFinGeraRotasPagamentosMeliLM).
    --   Default 0 quando não existir (cliente não usa SVC fixo ? fallback OrigemSaida ativo).
    -- ============================================================================
    CREATE TABLE #ConfigClientes
    (
          Cliente                 INT  NOT NULL
        , IdTransportadora        INT  NOT NULL
        , Operacao                INT  NULL
        , TipoLancamentoManual    INT  NULL
        , ClienteTransportadora   INT  NULL
        , AprovaAuto              BIT  NOT NULL
        , ParamUtilizaSVC         INT  NOT NULL
        , PRIMARY KEY (Cliente)
    );

    INSERT INTO #ConfigClientes
    (
          Cliente
        , IdTransportadora
        , Operacao
        , TipoLancamentoManual
        , ClienteTransportadora
        , AprovaAuto
        , ParamUtilizaSVC
    )
    SELECT
          cp.Cliente
        , cp.IdTransportadora
        , l.lst_cd_lista
        , COALESCE(plm_b.plm_cd_tipo_lancamento_manual, plm_p.plm_cd_tipo_lancamento_manual)
        , COALESCE(plm_b.plm_cd_cliente_transportadora, plm_p.plm_cd_cliente_transportadora)
        , CASE
              WHEN ISNULL(prm_apr.prm_ds_valor, N'0') = N'1' THEN CAST(1 AS BIT)
              ELSE CAST(0 AS BIT)
          END
        , ISNULL(prm_svc.prm_ds_valor, 0)
    FROM #ClientesParam AS cp
    LEFT JOIN dbo.tb_parametros AS prm_apr WITH (NOLOCK)
           ON prm_apr.prm_cod_cliente = cp.Cliente
          AND prm_apr.prm_ds_categoria = N'PNR Bandeja'
          AND prm_apr.prm_nm_parametro = N'Aprovação Automática Bandeja'
          AND ISNULL(prm_apr.prm_in_ativo, 0) = 1
          AND ISNULL(prm_apr.prm_in_excluido, 0) = 0
    -- ALTERAÇÃO 1a: leitura do parâmetro "Service Center Padrão"
    LEFT JOIN dbo.tb_parametros AS prm_svc WITH (NOLOCK)
           ON prm_svc.prm_cod_cliente = cp.Cliente
          AND prm_svc.prm_nm_parametro = N'Service Center Padrão'
          AND ISNULL(prm_svc.prm_in_ativo, 0) = 1
          AND ISNULL(prm_svc.prm_in_excluido, 0) = 0
    LEFT JOIN dbo.tb_lista AS l WITH (NOLOCK)
           ON l.lst_cd_cliente = cp.Cliente
          AND l.lst_nm_lista COLLATE Latin1_General_CI_AI = N'Operacoes Marketplace'
          AND l.lst_ds_valor = N'LM'
    OUTER APPLY
    (
        SELECT TOP (1)
              plm.plm_cd_tipo_lancamento_manual
            , plm.plm_cd_cliente_transportadora
        FROM dbo.tb_tipos_lancamentos_manuais AS plm WITH (NOLOCK)
        WHERE plm.plm_cd_cliente = cp.Cliente
          AND plm.plm_nm_tipo = N'PNR - Bandeja'
          AND ISNULL(plm.plm_in_ativo, 1) = 1
        ORDER BY plm.plm_cd_tipo_lancamento_manual DESC
    ) AS plm_b
    OUTER APPLY
    (
        SELECT TOP (1)
              plm.plm_cd_tipo_lancamento_manual
            , plm.plm_cd_cliente_transportadora
        FROM dbo.tb_tipos_lancamentos_manuais AS plm WITH (NOLOCK)
        WHERE plm.plm_cd_cliente = cp.Cliente
          AND plm.plm_nm_tipo = N'PF - PNR'
          AND ISNULL(plm.plm_in_ativo, 1) = 1
        ORDER BY plm.plm_cd_tipo_lancamento_manual DESC
    ) AS plm_p;

    INSERT INTO @Resultado
    (
          Cliente, IdTransportadora, DataInicial, DataFinal
        , LinhasLancamentos, LinhasAprovacoes, AprovaAuto, Status, Mensagem
    )
    SELECT
          cfg.Cliente
        , cfg.IdTransportadora
        , @DataInicial
        , @DataFinalEff
        , 0
        , 0
        , cfg.AprovaAuto
        , 'ERRO'
        , CASE
              WHEN cfg.Operacao IS NULL
                  THEN N'Operacao LM nao encontrada para o cliente da transportadora.'
              ELSE N'Tipo de lancamento manual PNR nao encontrado para o cliente.'
          END
    FROM #ConfigClientes AS cfg
    WHERE cfg.Operacao IS NULL
       OR cfg.TipoLancamentoManual IS NULL;

    -- ============================================================================
    -- ALTERAÇÃO 2: #ConfigValidos agora inclui ParamUtilizaSVC
    -- ============================================================================
    CREATE TABLE #ConfigValidos
    (
          Cliente                 INT  NOT NULL PRIMARY KEY
        , IdTransportadora        INT  NOT NULL
        , Operacao                INT  NOT NULL
        , TipoLancamentoManual    INT  NOT NULL
        , ClienteTransportadora   INT  NULL
        , AprovaAuto              BIT  NOT NULL
        , ParamUtilizaSVC         INT  NOT NULL
    );

    INSERT INTO #ConfigValidos
    (
          Cliente
        , IdTransportadora
        , Operacao
        , TipoLancamentoManual
        , ClienteTransportadora
        , AprovaAuto
        , ParamUtilizaSVC
    )
    SELECT
          cfg.Cliente
        , cfg.IdTransportadora
        , cfg.Operacao
        , cfg.TipoLancamentoManual
        , cfg.ClienteTransportadora
        , cfg.AprovaAuto
        , cfg.ParamUtilizaSVC
    FROM #ConfigClientes AS cfg
    WHERE cfg.Operacao IS NOT NULL
      AND cfg.TipoLancamentoManual IS NOT NULL;

    IF EXISTS (SELECT 1 FROM #ConfigValidos)
    BEGIN
        CREATE TABLE #ChavesExistentes
        (
              chave_transportadora INT         NOT NULL
            , chave_data           DATE        NOT NULL
            , chave_rota           VARCHAR(50) NOT NULL
            , chave_pacote         VARCHAR(50) NOT NULL
            , PRIMARY KEY (chave_transportadora, chave_data, chave_rota, chave_pacote)
        );

        INSERT INTO #ChavesExistentes
        (
              chave_transportadora
            , chave_data
            , chave_rota
            , chave_pacote
        )
        SELECT DISTINCT
              lm.tlm_cd_transportadora
            , CONVERT(DATE, lm.tlm_dh_referencia)
            , ISNULL(lm.tlm_cd_rota, '')
            , ISNULL(lm.tlm_ds_valor_referencia, '')
        FROM dbo.tb_lancamentos_manuais AS lm WITH (NOLOCK)
        INNER JOIN #ConfigValidos AS cv
                ON cv.IdTransportadora = lm.tlm_cd_transportadora
        WHERE lm.tlm_in_excluido = 0
          AND lm.tlm_dh_referencia >= @DataInicial
          AND lm.tlm_dh_referencia < DATEADD(DAY, 1, @DataFinalEff);

        CREATE TABLE #NovosLancamentos
        (
              tlm_cd_lancamento_manual INT NOT NULL PRIMARY KEY
            , tlm_cd_cliente           INT NOT NULL
            , tlm_cd_transportadora    INT NOT NULL
        );

        ;
        WITH pnr_base AS
        (
            SELECT
                  cfg.Cliente
                , cfg.IdTransportadora
                , cfg.Operacao
                , cfg.TipoLancamentoManual
                , cfg.ClienteTransportadora
                , cfg.AprovaAuto
                -- ALTERAÇÃO 3a: propagar ParamUtilizaSVC para uso em pnr_dedup
                , cfg.ParamUtilizaSVC
                , pac.IdRota
                , DataReclamacao = pnr.DataReclamacao
                , pnr.IdPacote
                , pnr.IdReclamacao
                , MotoristaPnr =
                      CASE
                          WHEN pnr.Motorista IS NULL THEN NULL
                          WHEN LTRIM(RTRIM(pnr.Motorista)) = N'' THEN NULL
                          WHEN LOWER(LTRIM(RTRIM(pnr.Motorista))) IN (N'undefined', N'null', N'n/a') THEN NULL
                          ELSE LTRIM(RTRIM(pnr.Motorista))
                      END
                , ServiceCenterPnr =
                      CASE
                          WHEN pnr.ServiceCenter IS NULL THEN NULL
                          WHEN LTRIM(RTRIM(pnr.ServiceCenter)) = N'' THEN NULL
                          WHEN LOWER(LTRIM(RTRIM(pnr.ServiceCenter))) IN (N'undefined', N'null', N'n/a') THEN NULL
                          ELSE LTRIM(RTRIM(pnr.ServiceCenter))
                      END
                , Valor = CAST(pnr.Valor AS DECIMAL(18, 2))
                , pnr.DataColeta
                , rot.NomeMotorista
                , rot.ServiceCenter
                , rot.OrigemSaida
                , rot.TotalPacotes
                , rot.QuantidadePontos
                , rot.Placa
                , TemBaseEspelhoXpt = CASE WHEN bss.bss_cd_base IS NOT NULL THEN 1 ELSE 0 END
                , rn = ROW_NUMBER() OVER (
                      PARTITION BY cfg.IdTransportadora, pac.IdRota, pnr.DataReclamacao, pnr.IdPacote
                      ORDER BY pnr.DataColeta DESC, pnr.IdReclamacao DESC
                  )
            FROM dbo.vw_pnr AS pnr WITH (NOLOCK)
            INNER JOIN #ConfigValidos AS cfg
                    ON pnr.IdTransportadora = CAST(cfg.IdTransportadora AS VARCHAR(20))
            INNER JOIN dbo.tb_ml_pacotes AS pac WITH (NOLOCK)
                    ON pac.IdPacote = pnr.IdPacote
                   AND ISNULL(pac.Excluido, 0) = 0
            LEFT JOIN dbo.tb_ml_rotas AS rot WITH (NOLOCK)
                   ON rot.IdRota = pac.IdRota
                  AND rot.IdTransportadora = pac.IdTransportadora
                  AND rot.DataReferencia = pac.DataReferencia
                  AND ISNULL(rot.Excluido, 0) = 0
            LEFT JOIN dbo.tb_bases AS bss WITH (NOLOCK)
                   ON bss.bss_ds_sigla = rot.OrigemSaida
                  AND bss.bss_cd_idtransportadora = rot.IdTransportadora
                  AND ISNULL(bss.bss_espelho_xpt, 0) = 1
                  AND ISNULL(bss.bss_in_excluido, 0) = 0
            WHERE pnr.DataReclamacao BETWEEN @DataInicial AND @DataFinalEff
              AND pnr.IdPacote IS NOT NULL
              AND pnr.Status = N'Enviado para faturamento'
        ),
        pnr_dedup AS
        (
            SELECT
                  b.Cliente
                , b.IdTransportadora
                , b.Operacao
                , b.TipoLancamentoManual
                , b.ClienteTransportadora
                , b.DataReclamacao
                , NomeMotoristaFinal =
                      COALESCE(
                          NULLIF(LTRIM(RTRIM(ISNULL(b.NomeMotorista, N''))), N''),
                          b.MotoristaPnr,
                          N'N/A'
                      )
                -- ====================================================================
                -- ALTERAÇÃO 3b: ServiceCenterFinal agora inclui fallback OrigemSaida
                --   Replica regra da UspFinGeraRotasPagamentosMeliLM:
                --   1. OrigemSaida se base XPT (bss_espelho_xpt = 1)  [prioridade original]
                --   2. OrigemSaida se left(OrigemSaida,1) in ('E','M'),
                --      OrigemSaida <> ServiceCenter e ParamUtilizaSVC = 0  [NOVO fallback]
                --   3. ServiceCenter da rota                            [prioridade original]
                --   4. ServiceCenter do PNR                              [prioridade original]
                --   5. 'N/A'                                             [prioridade original]
                -- ====================================================================
                , ServiceCenterFinal =
                      COALESCE(
                          CASE WHEN b.TemBaseEspelhoXpt = 1 THEN NULLIF(LTRIM(RTRIM(ISNULL(b.OrigemSaida, N''))), N'') END,
                          CASE WHEN b.ParamUtilizaSVC = 0
                                    AND NULLIF(LTRIM(RTRIM(ISNULL(b.OrigemSaida, N''))), N'') IS NOT NULL
                                    AND NULLIF(LTRIM(RTRIM(ISNULL(b.ServiceCenter, N''))), N'') IS NOT NULL
                                    AND LTRIM(RTRIM(b.OrigemSaida)) <> LTRIM(RTRIM(b.ServiceCenter))
                                    AND LEFT(LTRIM(RTRIM(b.OrigemSaida)), 1) IN (N'E', N'M')
                               THEN NULLIF(LTRIM(RTRIM(ISNULL(b.OrigemSaida, N''))), N'')
                          END,
                          NULLIF(LTRIM(RTRIM(ISNULL(b.ServiceCenter, N''))), N''),
                          b.ServiceCenterPnr,
                          N'N/A'
                      )
                , QtPacotes = ISNULL(TRY_CAST(b.TotalPacotes AS INT), 0)
                , QtPontos  = ISNULL(TRY_CAST(b.QuantidadePontos AS INT), 0)
                , PlacaFinal = NULLIF(LTRIM(RTRIM(ISNULL(b.Placa, N''))), N'')
                , b.Valor
                , Observacao = CONCAT(N'PNR Bandeja - Reclamacao ', b.IdReclamacao, N' - Pacote ', b.IdPacote)
                , ChaveRota   = CAST(b.IdRota AS VARCHAR(50))
                , ChavePacote = LEFT(CAST(b.IdPacote AS VARCHAR(100)), 50)
            FROM pnr_base AS b
            WHERE b.rn = 1
        )
        INSERT INTO dbo.tb_lancamentos_manuais
        (
              tlm_cd_rota, tlm_cd_service_center, tlm_cd_motorista, tlm_cd_tipo, tlm_cd_periodo
            , tlm_cd_risco_ajudante, tlm_cd_quantidade_pacotes, tlm_cd_pontos, tlm_ds_observacao, tlm_cd_cliente
            , tlm_in_ativo, tlm_in_excluido, tlm_cd_usuario_criacao, tlm_dh_criacao, tlm_cd_usuario_modificacao, tlm_dh_modificacao
            , tlm_cd_transportadora, tlm_in_marketplace, tlm_ds_motorista_apoio, tlm_tipo_valor_apoio, tlm_vl_valor_apoio
            , tlm_cd_tipo_veiculo_nao_utilizado, tlm_dh_nao_utilizado, tlm_dh_referencia, tlm_cd_arquivo, tlm_cd_cliente_transportadora
            , tlm_vl_valor_rota, tlm_vl_valor_adicional, tlm_ds_motorista_secundario, tlm_vl_valor_descontos, tlm_ds_matricula, tlm_ds_placa
            , tlm_cd_mot, tlm_cd_mot_apoio, tlm_tp_credito_debito, tlm_cd_operacao, tlm_ds_valor_referencia
        )
        OUTPUT
              INSERTED.tlm_cd_lancamento_manual
            , INSERTED.tlm_cd_cliente
            , INSERTED.tlm_cd_transportadora
        INTO #NovosLancamentos
        (
              tlm_cd_lancamento_manual
            , tlm_cd_cliente
            , tlm_cd_transportadora
        )
        SELECT
              p.ChaveRota
            , LEFT(CAST(p.ServiceCenterFinal AS VARCHAR(200)), 150)
            , LEFT(CAST(p.NomeMotoristaFinal AS VARCHAR(200)), 100)
            , CAST(p.TipoLancamentoManual AS VARCHAR(30))
            , N'-'
            , CAST(NULL AS VARCHAR(10))
            , p.QtPacotes
            , p.QtPontos
            , LEFT(CAST(p.Observacao AS VARCHAR(800)), 600)
            , p.Cliente
            , CAST(1 AS BIT)
            , CAST(0 AS BIT)
            , 7
            , GETDATE()
            , 7
            , GETDATE()
            , p.IdTransportadora
            , CAST(NULL AS VARCHAR(10))
            , CAST(NULL AS VARCHAR(100))
            , CAST(NULL AS VARCHAR(30))
            , CAST(NULL AS DECIMAL(18, 2))
            , CAST(NULL AS INT)
            , CAST(NULL AS DATE)
            , CAST(p.DataReclamacao AS DATETIME)
            , CAST(NULL AS BIGINT)
            , p.ClienteTransportadora
            , CAST(NULL AS DECIMAL(18, 2))
            , CAST(NULL AS DECIMAL(18, 2))
            , CAST(NULL AS VARCHAR(255))
            , p.Valor
            , CAST(NULL AS VARCHAR(100))
            , LEFT(CAST(ISNULL(p.PlacaFinal, N'') AS NVARCHAR(400)), 255)
            , ISNULL(usr.usr_cd_usuario, -1)
            , CAST(NULL AS INT)
            , CAST(NULL AS NVARCHAR(20))
            , p.Operacao
            , p.ChavePacote
        FROM pnr_dedup AS p
        OUTER APPLY
        (
            SELECT TOP (1)
                  u.usr_cd_usuario
            FROM dbo.tb_usuario AS u WITH (NOLOCK)
            WHERE u.usr_nm_usuario = p.NomeMotoristaFinal
              AND u.usr_in_ativo = 1
            ORDER BY u.usr_cd_usuario
        ) AS usr
        WHERE NOT EXISTS (
            SELECT 1
            FROM #ChavesExistentes AS ex
            WHERE ex.chave_transportadora = p.IdTransportadora
              AND ex.chave_data             = p.DataReclamacao
              AND ex.chave_rota             = p.ChaveRota
              AND ex.chave_pacote           = p.ChavePacote
        );

        INSERT INTO dbo.tb_aprovacao_lancamento_manual
        (
              alm_cd_lancamento_manual, alm_ds_status, alm_ds_motivo, alm_cd_usuario_aprovacao, alm_dh_aprovacao, alm_cd_cliente
            , alm_in_ativo, alm_in_excluido, alm_cd_usuario_criacao, alm_dh_criacao, alm_cd_usuario_modificacao, alm_dh_modificacao
            , alm_cd_chave_reprovacao, alm_ds_observacao_reprovacao
        )
        SELECT
              n.tlm_cd_lancamento_manual
            , CASE
                  WHEN cfg.AprovaAuto = 1 THEN N'Aprovado'
                  ELSE N'Aguardando Aprovação'
              END
            , CAST(NULL AS VARCHAR(150))
            , CASE WHEN cfg.AprovaAuto = 1 THEN 7 ELSE NULL END
            , CASE WHEN cfg.AprovaAuto = 1 THEN GETDATE() ELSE NULL END
            , n.tlm_cd_cliente
            , CAST(1 AS BIT)
            , CAST(0 AS BIT)
            , 7
            , GETDATE()
            , CASE WHEN cfg.AprovaAuto = 1 THEN 7 ELSE NULL END
            , CASE WHEN cfg.AprovaAuto = 1 THEN GETDATE() ELSE NULL END
            , CAST(NULL AS INT)
            , CAST(NULL AS VARCHAR(500))
        FROM #NovosLancamentos AS n
        INNER JOIN #ConfigValidos AS cfg
                ON cfg.Cliente = n.tlm_cd_cliente
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.tb_aprovacao_lancamento_manual AS a WITH (NOLOCK)
            WHERE a.alm_cd_lancamento_manual = n.tlm_cd_lancamento_manual
              AND ISNULL(a.alm_in_excluido, 0) = 0
        );

    --    INSERT INTO @Resultado
    --    (
    --          Cliente, IdTransportadora, DataInicial, DataFinal
    --        , LinhasLancamentos, LinhasAprovacoes, AprovaAuto, Status, Mensagem
    --    )
    --    SELECT
    --          cfg.Cliente
    --        , cfg.IdTransportadora
    --        , @DataInicial
    --        , @DataFinalEff
    --        , COUNT(n.tlm_cd_lancamento_manual)
    --        , COUNT(apr.alm_cd_lancamento_manual)
    --        , cfg.AprovaAuto
    --        , 'OK'
    --        , NULL
    --    FROM #ConfigValidos AS cfg
    --    LEFT JOIN #NovosLancamentos AS n
    --           ON n.tlm_cd_cliente = cfg.Cliente
    --    LEFT JOIN dbo.tb_aprovacao_lancamento_manual AS apr WITH (NOLOCK)
    --           ON apr.alm_cd_lancamento_manual = n.tlm_cd_lancamento_manual
    --          AND ISNULL(apr.alm_in_excluido, 0) = 0
    --    GROUP BY
    --          cfg.Cliente
    --        , cfg.IdTransportadora
    --        , cfg.AprovaAuto;
    END;

    --SELECT
    --      Cliente
    --    , IdTransportadora
    --    , DataInicial
    --    , DataFinal
    --    , LinhasLancamentos
    --    , LinhasAprovacoes
    --    , AprovaAuto
    --    , Status
    --    , Mensagem
    --FROM @Resultado
    --ORDER BY Cliente;


END;
GO
