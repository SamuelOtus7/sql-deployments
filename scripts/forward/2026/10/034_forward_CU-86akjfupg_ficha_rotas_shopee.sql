/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akjfupg
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-06
  Descricao    : Suporte a Shopee (SPE) na Ficha de Rotas (/logistics/rotas).
                 1) UpsGeraTelaValidaFinanceiro: corrige @MarketPlace (era VARCHAR
                    sem tamanho e nao utilizado) e passa a resolver a
                    transportadora por cli_id_shopee quando @MarketPlace='Shopee'
                    (antes resolvia sempre por cli_id_logistics, o que retornava
                    lista vazia para Shopee). Adiciona filtro por idmktplace
                    (label tb_lista) para separar rotas SPE das ML do mesmo
                    cli_cd_codigo_cliente. Enriquecimentos ML-only (PNR,
                    Ambulancia/Operacao via vw_rotas) permanecem NULL para SPE
                    neste MVP.
                 2) UspGetSPEFichaDadosBasicos: alinha o result set ao contrato
                    DetalhesRotas do backend (mesmos alias da versao ML),
                    mapeando Base=Servicecenter -> NomeHub. LEFT JOIN na
                    agregacao de pacotes (rota sem pacote nao desaparece) e
                    filtro Excluido=0.
                 3) UspGetSPEFichaDadosPacotes: corrige filtro incorreto
                    (CodigoPacote=@Rota -> CodigoRota=@Rota), corrige join de
                    clientes (cli_id_logistics -> comparacao direta por
                    cli_id_shopee), adiciona Excluido=0 e alinha o result set ao
                    contrato DetalhesRotasPacotes. IdPacote usa a PK identity
                    (CodigoPacote SPE e alfanumerico, ex.: 'BR240000147791O',
                    incompativel com o tipo long do DTO atual).
                 Pre-condicao conhecida: exibicao do financeiro SPE depende de
                 UspSPEGeraResultadoFinanceiro ter rodado para a quinzena.
                 Reprocessar pre-fatura SPE segue bloqueado (fora de escopo).
  Rollback     : scripts/rollback/2026/10/034_rollback_CU-86akjfupg_ficha_rotas_shopee.sql
  Objetos      : dbo.UpsGeraTelaValidaFinanceiro,
                 dbo.UspGetSPEFichaDadosBasicos,
                 dbo.UspGetSPEFichaDadosPacotes
  Dependencias : dbo.tb_clientes (cli_id_shopee/cli_id_logistics),
                 dbo.vw_resultado_financeiro, dbo.tb_lista,
                 dbo.vw_rotas_spe_v4, dbo.tb_spe_pacotes_v4,
                 dbo.tb_spe_motoristas
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UpsGeraTelaValidaFinanceiro'))
        THROW 50001, 'Procedure dbo.UpsGeraTelaValidaFinanceiro nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspGetSPEFichaDadosBasicos'))
        THROW 50002, 'Procedure dbo.UspGetSPEFichaDadosBasicos nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspGetSPEFichaDadosPacotes'))
        THROW 50003, 'Procedure dbo.UspGetSPEFichaDadosPacotes nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_clientes') AND name = 'cli_id_shopee')
        THROW 50004, 'Coluna tb_clientes.cli_id_shopee nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_spe_pacotes_v4') AND name = 'CodigoRota')
        THROW 50005, 'Coluna tb_spe_pacotes_v4.CodigoRota nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL
--    CREATE OR ALTER PROCEDURE precisa ser a primeira instrucao do batch.
--============================================================================


CREATE OR ALTER PROCEDURE [dbo].[UpsGeraTelaValidaFinanceiro]
(
    @MarketPlace    VARCHAR(50),
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

    -- CU-86akjfupg: Shopee resolve por cli_id_shopee; demais por cli_id_logistics
    IF UPPER(ISNULL(@MarketPlace, '')) = 'SHOPEE'
        SELECT @Transportadoraid = cli_cd_codigo_cliente
        FROM dbo.tb_clientes
        WHERE cli_id_shopee = @transportadora
          AND cli_cd_codigo_cliente <> 7;
    ELSE
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
              -- CAST: vrt_cd_rota e INT; IdRota SPE e varchar ('AT...') —
              -- sem o cast o join quebrava por conversao implicita
              CAST([vrt_cd_rota] AS VARCHAR(50)) AS idrota
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
      -- CU-86akjfupg: separa rotas SPE das ML do mesmo cli_cd_codigo_cliente
      AND (
            @MarketPlace IS NULL
            OR (UPPER(@MarketPlace) = 'SHOPEE' AND a.idmktplace = 'Shopee')
            OR (UPPER(@MarketPlace) <> 'SHOPEE' AND ISNULL(a.idmktplace, 'Mercado Livre') <> 'Shopee')
          )
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
            , CAST(pacotes.IdRota AS VARCHAR(50)) AS IdRota
            , COUNT(*) AS QtdPnr
        FROM dbo.vw_pacotes AS pacotes
        INNER JOIN dbo.tb_ml_pnr AS BasePnr
            ON pacotes.IdTransportadora = BasePnr.IdTransportadora
           AND pacotes.identrega = BasePnr.IdPacote
        INNER JOIN #Pag AS pg
            ON pg.IdRota = CAST(pacotes.IdRota AS VARCHAR(50))
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
       -- CAST: IdRota em vw_rotas e int; IdRota SPE e varchar ('AT...')
       AND a.IdRota = CAST(rotas.IdRota AS VARCHAR(50))
    ORDER BY a.IdRota;

    DROP TABLE #Pag;
END;
GO


CREATE OR ALTER PROCEDURE [dbo].[UspGetSPEFichaDadosBasicos]
(
    @Transportadora INT,          -- cli_id_shopee (ex.: 20230024)
    @Rota           VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- CU-86akjfupg: result set alinhado ao contrato DetalhesRotas (mesmos
    -- alias de UspGetMLFichaDadosBasicos). Colunas sem equivalente SPE saem
    -- como NULL para manter o contrato.
    SELECT
         CAST(a.CodigoRota AS VARCHAR(50))          AS IdRota
        ,a.DataReferencia
        ,a.NomeHub                                 AS Servicecenter
        ,a.TipoRota
        ,a.Hub                                     AS OrigemSaida
        ,CAST(NULL AS VARCHAR(100))                AS TipoOrigemSaida
        ,a.CidadeReferencia
        ,a.Motorista                               AS Nomemotorista
        ,a.TipoVeiculo
        ,a.Placa
        ,CAST(NULL AS BIT)                         AS PossuiAjudante
        ,CASE WHEN a.RotaFinalizada = 1
              THEN 'Finalizada' ELSE 'Aberta' END  AS StatusRota
        ,CAST(NULL AS VARCHAR(100))                AS SubStatusRota
        ,CAST(NULL AS INT)                         AS Tempoemrota
        ,CAST(NULL AS INT)                         AS TempoPlanejadoMinutos
        ,CAST(NULL AS INT)                         AS TempoChegadaAreaEntrega
        ,CAST(NULL AS INT)                         AS TempoAreaEntrega
        ,CAST(NULL AS INT)                         AS TempoRetornoCentroDistribuicao
        ,CAST(NULL AS INT)                         AS Tempoinativo
        ,a.DataHoraInicio
        ,a.DataUltimaEntrega                       AS DataHoraFim
        ,a.PerformacePacotes                       AS Percentualprogresso
        ,c.DataPrimeiraEntrega
        ,CAST(NULL AS VARCHAR(100))                AS StatusPrimeiraEntrega
        ,CAST(NULL AS VARCHAR(100))                AS StatusSegundaEntrega
        ,c.DataUltimaAtualizacaoPacote
        ,a.TotalPacotes
        ,a.PacotesEntregues                        AS Pacotesentregues
        ,a.PacotesNaoEntregue
        ,a.PacotesPendentes                        AS Pacotespendentes
        ,CAST(NULL AS SMALLINT)                    AS PacotesEntreguesForaAreaEntrega
        ,CAST(0 AS SMALLINT)                       AS Pacotestransferidos
        ,CAST(NULL AS SMALLINT)                    AS Pacotesrecebidos
        ,a.TotalPacotes                            AS QuantidadePacotesTransportados
        ,CAST(NULL AS SMALLINT)                    AS QuantidadePontos
        ,a.Paradas                                 AS QuantidadeParadas
        ,CAST(0 AS BIT)                            AS Ambulancia
        ,a.PerformacePacotes                       AS PercentualPerformance
        ,CAST(NULL AS VARCHAR(100))                AS StatusPrazo
        ,CAST(NULL AS INT)                         AS QuantidadeReclamacoes
        ,0                                         AS QuantidadePNR
        ,CAST(NULL AS UNIQUEIDENTIFIER)            AS IdRotaGuid
        ,CAST(NULL AS FLOAT)                       AS TotalApp
        ,CAST(NULL AS FLOAT)                       AS TotalPacote
        ,c.IdsPacotesVinculados
        ,a.PacotesNaoEntregue                      AS QuantidadePacotesInsucesso
    FROM dbo.vw_rotas_spe_v4 AS a
    LEFT JOIN
    (
        SELECT
              p.DataReferencia
            , p.IdTransportadora
            , p.CodigoRota
            , MIN(p.DataHoraEntrega)                AS DataPrimeiraEntrega
            , MAX(p.DataAtualizacao)                AS DataUltimaAtualizacaoPacote
            , STRING_AGG(CAST(p.CodigoPacote AS VARCHAR(30)), ',')
                  WITHIN GROUP (ORDER BY p.CodigoPacote) AS IdsPacotesVinculados
        FROM dbo.tb_spe_pacotes_v4 AS p
        WHERE p.Excluido = 0
        GROUP BY
              p.DataReferencia
            , p.IdTransportadora
            , p.CodigoRota
    ) AS c
        ON  a.DataReferencia   = c.DataReferencia
        AND a.CodigoRota       = c.CodigoRota
        AND a.IdTransportadora = c.IdTransportadora
    WHERE a.IdTransportadora = @Transportadora
      AND a.CodigoRota       = @Rota;
END;
GO


CREATE OR ALTER PROCEDURE [dbo].[UspGetSPEFichaDadosPacotes]
(
    @Transportadora INT,          -- cli_id_shopee (ex.: 20230024)
    @Rota           VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    -- CU-86akjfupg: result set alinhado ao contrato DetalhesRotasPacotes.
    -- CodigoPacote SPE e alfanumerico ('BR240000147791O'); IdPacote recebe a
    -- PK identity para caber no tipo long do DTO. CodigoPacote e campos SPE
    -- sem mapeamento no DTO sao emitidos como extras (ignorados pelo EF).
    SELECT
         p.Id                                        AS IdPacote
        ,CAST(p.CodigoPacote AS VARCHAR(30))         AS CodigoPacote
        ,p.DataReferencia
        ,p.DataHoraColeta
        ,p.DataHoraEntrega
        ,CAST(NULL AS VARCHAR(50))                   AS TipoPacote
        ,p.StatusPacote                              AS [Status]
        ,p.SubStatus                                 AS SubStatus
        ,p.StatusEntrega                             AS StatusEntrega
        ,CAST(NULL AS VARCHAR(50))                   AS TipoEndereco
        ,CAST(NULL AS VARCHAR(50))                   AS TipoEnderecoPreferencia
        ,CAST(NULL AS VARCHAR(50))                   AS Transferencia
        ,CAST(NULL AS BIGINT)                        AS IdRotaOrigem
        ,m.NomeMotorista                             AS MotoristaRotaOrigem
        ,CAST(NULL AS BIGINT)                        AS IdRotaDestino
        ,CAST(NULL AS VARCHAR(100))                  AS MotoristaRotaDestino
        ,CAST(NULL AS INT)                           AS QuantidadeReclamacoes
        ,CAST(0 AS BIT)                              AS ForaAreaEntrega
        ,CAST(0 AS BIT)                              AS TemVolumoso
        ,CAST(NULL AS VARCHAR(100))                  AS NomeEtiqueta
        ,CAST(NULL AS VARCHAR(200))                  AS Endereco
        ,CAST(NULL AS BIGINT)                        AS IdParada
        ,CAST(NULL AS INT)                           AS SequenciaParada
        ,CAST(NULL AS VARCHAR(50))                   AS StatusParada
        ,CAST(NULL AS VARCHAR(200))                  AS EnderecoParada
        ,CAST(NULL AS VARCHAR(50))                   AS TipoEnderecoParada
        ,p.Latitude                                  AS LatitudeEnderecoParada
        ,p.Longitude                                 AS LongitudeEnderecoParada
        ,CAST(NULL AS INT)                           AS QuantidadePontosParada
        ,CAST(NULL AS VARCHAR(100))                  AS Cidade
        ,CAST(NULL AS VARCHAR(100))                  AS Reclamacao
        ,CAST(NULL AS VARCHAR(50))                   AS PNR
        ,p.RecebidoPor
        ,p.URLImagem
    -- NOLOCK: leitura de tela operacional (mesmo padrao das demais leituras de
    -- tb_spe_*/tb_ml_* no projeto); dirty read aceitavel, sem custo de lock.
    FROM dbo.tb_spe_pacotes_v4 AS p WITH (NOLOCK)
    LEFT JOIN dbo.tb_spe_motoristas AS m WITH (NOLOCK)
        ON  m.IdMotorista      = p.IdMotorista
        AND m.IdTransportadora = p.IdTransportadora
    WHERE p.CodigoRota       = @Rota
      AND p.IdTransportadora = @Transportadora
      AND p.Excluido         = 0;
END;
GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF CHARINDEX('cli_id_shopee', OBJECT_DEFINITION(OBJECT_ID('dbo.UpsGeraTelaValidaFinanceiro'))) = 0
        THROW 50006, 'UpsGeraTelaValidaFinanceiro nao contem resolucao por cli_id_shopee.', 1;
    IF CHARINDEX('CodigoRota', OBJECT_DEFINITION(OBJECT_ID('dbo.UspGetSPEFichaDadosPacotes'))) = 0
        THROW 50007, 'UspGetSPEFichaDadosPacotes nao contem filtro por CodigoRota.', 1;
    IF CHARINDEX('Nomemotorista', OBJECT_DEFINITION(OBJECT_ID('dbo.UspGetSPEFichaDadosBasicos'))) = 0
        THROW 50008, 'UspGetSPEFichaDadosBasicos nao contem alias Nomemotorista.', 1;

    PRINT 'SUCESSO: Procedures SPE da Ficha de Rotas atualizadas (CU-86akjfupg).';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
