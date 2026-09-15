-- ============================================================
-- BASELINE: dbo.UpsGeraTelaValidaFinanceiro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UpsGeraTelaValidaFinanceiro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[UpsGeraTelaValidaFinanceiro]
(
    @MarketPlace    VARCHAR,
    @transportadora INT,
    @DataIni        DATE,
    @DataFim        DATE,
    @Motorista      VARCHAR(120) = '',
    @Status         VARCHAR(120) = '', -- em analise (se nao passar, desconsidera)
    @Base           VARCHAR(50)  = '',
    @idorta         VARCHAR(50)  = '',
    @skip           INT,
    @Take           INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Transportadoraid INT;

    SELECT @Transportadoraid = cli_cd_codigo_cliente
    FROM dbo.tb_clientes
    WHERE cli_id_logistics = @transportadora
      AND cli_cd_codigo_cliente <> 7;

    IF LEN(@Motorista) = 0
        SET @Motorista = NULL;

    IF LEN(@Status) = 0
    BEGIN
        SET @Status = NULL;
    END
    ELSE IF @Status = 'Em analise'
    BEGIN
        SET @Status = NULL;
    END;

    IF LEN(@Base) = 0
        SET @Base = NULL;

    IF LEN(@idorta) = 0
        SET @idorta = NULL;

    -- =====================================================================
    -- [OTIMIZACAO] Passo 1: filtra + ordena + pagina ANTES dos joins pesados
    -- So usa vw_resultado_financeiro + tb_validacao_rotas/tb_lista
    -- PNR (vw_pacotes + tb_ml_pnr) e vw_rotas ficaram para o Passo 2
    -- Resultado: ~100 linhas na #Pag em vez de ~28 mil
    -- =====================================================================
    IF OBJECT_ID('tempdb..#Pag') IS NOT NULL
        DROP TABLE #Pag;

    SELECT
          a.*
        , listas_validacoes.lst_ds_valor
    INTO #Pag
    FROM dbo.vw_resultado_financeiro AS a
    LEFT JOIN
    (
        SELECT
              [vrt_cd_rota] AS idrota
            , [vrt_cd_status_validacao]
            , [vrt_cd_usuario_validacao]
            , [vrt_dt_data_hora_validacao]
            , lst_ds_valor
            , ROW_NUMBER() OVER (
                  PARTITION BY vrt_cd_rota
                  ORDER BY [vrt_dt_data_hora_validacao] DESC
              ) AS rn
        FROM dbo.tb_validacao_rotas AS val
        LEFT JOIN dbo.tb_lista AS lst
            ON val.vrt_cd_status_validacao = lst.lst_cd_lista
        WHERE lst.lst_nm_lista = 'Status Validacao Rotas'
    ) AS listas_validacoes
        ON a.idrota = listas_validacoes.idrota
    WHERE 1 = 1
      AND a.IdTransportadora = @Transportadoraid
      AND a.DataReferencia BETWEEN @DataIni AND @DataFim
      AND (@Motorista IS NULL OR a.Motorista = @Motorista)
      AND (@Base IS NULL OR a.ServiceCenter = @Base OR a.xpt = @base)
      AND (@idorta IS NULL OR a.idrota = @idorta)
      AND (@Status IS NULL OR listas_validacoes.lst_ds_valor = @Status)
    ORDER BY a.IdRota
    OFFSET @skip ROWS
    FETCH NEXT @Take ROWS ONLY;

    -- =====================================================================
    -- [OTIMIZACAO] Passo 2: enriquece APENAS as ~100 rotas da #Pag
    -- PNR e vw_rotas agora rodam sobre 100 linhas, nao 28 mil
    -- =====================================================================
    SELECT
          a.DataReferencia AS data
        , a.IdRota
        , ISNULL(a.lst_ds_valor, 'Em analise') AS StatusAnalise
        , CASE
              WHEN a.ServiceCenter <> a.XPT THEN a.xpt
              ELSE a.ServiceCenter
          END AS Base
        , a.Motorista
        , a.QuantidadePacotes AS Pacotes
        , a.PacotesEntregues AS Sucessos
        , a.Insucessos AS Insucessos
        , a.[CicloPM] AS Ciclo
        , CASE
              WHEN [CicloPM] = [CicloPMFatura] THEN 0
              ELSE 1
          END AS FlagCicloDifPreFatura
        , a.[TipoVeiculo]
        , a.[TipoVeiculoCad] AS TipoVeiculoCadastrado
        , CASE
              WHEN a.[TipoVeiculo] = a.[TipoVeiculoCad] THEN 0
              ELSE 1
          END AS FlagVeiculoDifCadastrado
        , CASE
              WHEN a.[TipoVeiculo] = a.[TipoVeiculoPreFatura] THEN 0
              ELSE 1
          END AS FlagVeiculoDifPreFatura
        , a.UsouAPP
        , a.NumeroRota AS QtdRotasMotorista
        , a.[KmColetado] AS KmApp
        , a.[FaixaKm] AS FaixaKmApp
        , a.[KmColetado] AS KmPacote
        , a.[FaixaKm] AS FaixaKmPacote
        , a.[KmColetado] AS KmTrevo
        , a.[FaixaKm] AS FaixaKmTrevo
        , 0 AS Apoio
        , CASE
              WHEN rotas.Ambulancia = 1 THEN 'Sim'
              ELSE 'Nao'
          END AS Ambulância
        , CASE
              WHEN PgtoAjudante > 0 THEN 'Sim'
              ELSE 'Nao'
          END AS Ajudante
        , pnr.QtdPnr AS PNR
        , QuantidadeReclamacoes AS Reclamacao
        , 0 AS Sinistro
        , 0 AS AderenciaAoTrajeto
        , LancRisco AS Risco
        , Observacao
        , Destino AS Cidade
        , a.QuantidadeParadas
        , Regiao
        , RiscoV2
        , ISNULL(AjudanteV2, CASE WHEN PgtoAjudante > 0 THEN 'Sim' ELSE 'Nao' END) AS AjudanteV2
        , DividiuRota
        , IdMotoristaDividiuRota
        , a.QuantidadePontos AS QuantidadePontos
        , rotas.tipo AS Operacao
        , NULL AS KmMeli
        , NULL AS KmRtt
    FROM #Pag AS a
    LEFT JOIN
    (
        -- [OTIMIZACAO] INNER JOIN #Pag limita PNR as rotas da pagina
        SELECT
              pacotes.IdTransportadora
            , pacotes.IdRota
            , COUNT(*) AS QtdPnr
        FROM dbo.vw_pacotes AS pacotes
        INNER JOIN dbo.tb_ml_pnr AS BasePnr
            ON pacotes.IdTransportadora = BasePnr.IdTransportadora
           AND pacotes.identrega = BasePnr.IdPacote
        INNER JOIN #Pag AS pg
            ON pg.IdRota = pacotes.IdRota
        WHERE pacotes.IdTransportadora = @Transportadoraid
          AND pacotes.DataReferencia BETWEEN @DataIni AND @DataFim
        GROUP BY
              pacotes.IdTransportadora
            , pacotes.IdRota
    ) AS pnr
        ON a.IdRota = pnr.idrota
       AND a.cli_id_logistics = pnr.IdTransportadora
    LEFT JOIN dbo.vw_rotas AS rotas
        ON a.cli_id_logistics = rotas.IdTransportadora
       AND a.IdRota = rotas.IdRota
    ORDER BY a.IdRota;

    DROP TABLE #Pag;
END;
GO
