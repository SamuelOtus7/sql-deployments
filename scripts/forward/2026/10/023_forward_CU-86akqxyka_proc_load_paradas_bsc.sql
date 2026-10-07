/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-02
  Descrição    : Cria a procedure dbo.USPTrataStagingParadasBSC, que carrega
                 dbo.tb_ml_bsc_paradas a partir da staging
                 dbo.tb_stg_looker_ds_secao_6 (mesmo padrao dos loaders Looker:
                 janela de 30 dias a partir da ultima extracao + dedup rn=1 por
                 (cliente, rota) + MERGE por (IdCliente, IdRota)).

                 A procedure tambem expurga o historico da staging, mantendo
                 apenas 30 dias de DataExtracao (delete em lotes de 50 mil).

                 Amplia dbo.tb_ml_bsc_paradas com as colunas de negocio da
                 staging (data da rota parseada, motorista, veiculo, horarios,
                 KM, ORH e motivos de insucesso), todas nullable para nao quebrar
                 consumidores existentes (vw_pbi_mon_alertas_processos_calc,
                 UspFinGeraRotasPagamentosMeliLM).
  Rollback     : scripts/rollback/2026/10/023_rollback_CU-86akqxyka_proc_load_paradas_bsc.sql
  Objetos      : dbo.tb_ml_bsc_paradas (ALTER TABLE ADD),
                 dbo.USPTrataStagingParadasBSC (CREATE PROCEDURE)
  Dependências : dbo.tb_stg_looker_ds_secao_6, dbo.tb_ml_bsc_paradas
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_stg_looker_ds_secao_6'))
        THROW 50040, 'Tabela dbo.tb_stg_looker_ds_secao_6 nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas'))
        THROW 50041, 'Tabela dbo.tb_ml_bsc_paradas nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--==========================================================================
-- 2. ALTER TABLE — novas colunas de negocio (todas nullable)
--==========================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas') AND name = 'DataRota')
BEGIN
    ALTER TABLE dbo.tb_ml_bsc_paradas ADD
        DataRota                    date         NULL,
        DataExtracao                datetime     NULL,
        Regional                    varchar(50)  NULL,
        SVC                         varchar(50)  NULL,
        XPT                         varchar(50)  NULL,
        MLP                         varchar(50)  NULL,
        PerfilVeiculoExecutado      varchar(100) NULL,
        Ciclo                       varchar(20)  NULL,
        Cluster                     varchar(50)  NULL,
        IdMotorista                 bigint       NULL,
        ExperienciaDriver           varchar(50)  NULL,
        Placa                       varchar(20)  NULL,
        IdVeiculo                   bigint       NULL,
        Veiculo                     varchar(100) NULL,
        HoraInicio                  time(0)      NULL,
        HoraFim                     time(0)      NULL,
        ORH_PLAN                    float        NULL,
        ORH_HOURS                   float        NULL,
        KM_PLAN                     float        NULL,
        KM_REAL                     float        NULL,
        STEM_OUT                    float        NULL,
        QuantidadePacotes           bigint       NULL,
        QuantidadeEntregue          bigint       NULL,
        QuantidadeDS                bigint       NULL,
        QuantidadeAtStation         bigint       NULL,
        QuantidadeInsucessos        bigint       NULL,
        InsucessoInaccessibleAddress bigint      NULL,
        InsucessoBuyerRejected      bigint       NULL,
        InsucessoBuyerMoved         bigint       NULL,
        InsucessoBuyerAbsent        bigint       NULL,
        InsucessoBusinessClosed     bigint       NULL,
        InsucessoBlockedByKeyword   bigint       NULL,
        InsucessoBadAddress         bigint       NULL,
        InsucessoNotAttempted       bigint       NULL,
        InsucessoOutrosMotivos      bigint       NULL;
END
GO

--==========================================================================
-- 3. PROCEDURE
--==========================================================================
CREATE OR ALTER PROCEDURE [dbo].[USPTrataStagingParadasBSC]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    /* Janela: ultima extracao -30 dias; dedup por (cliente, rota) mantendo a extracao mais recente */
    ;WITH limite AS
    (
        SELECT MAX(DataExtracao) AS MaxExtracao
        FROM dbo.tb_stg_looker_ds_secao_6 WITH (NOLOCK)
    ),
    src AS
    (
        SELECT
            s.CodigoCliente,
            s.Rotas,
            s.DataExtracao,
            DataRota = CASE
                WHEN s.Data LIKE '% de % de %' THEN TRY_CAST(CONCAT(
                    RIGHT(s.Data, 4), '-',
                    RIGHT('0' + CAST(CASE LOWER(REPLACE(SUBSTRING(s.Data, CHARINDEX(' de ', s.Data) + 4, 4), '.', ''))
                        WHEN 'jan' THEN 1 WHEN 'fev' THEN 2 WHEN 'mar' THEN 3
                        WHEN 'abr' THEN 4 WHEN 'mai' THEN 5 WHEN 'jun' THEN 6
                        WHEN 'jul' THEN 7 WHEN 'ago' THEN 8 WHEN 'set' THEN 9
                        WHEN 'out' THEN 10 WHEN 'nov' THEN 11 WHEN 'dez' THEN 12
                    END AS varchar(2)), 2), '-',
                    RIGHT('0' + CAST(TRY_CAST(LEFT(s.Data, CHARINDEX(' de ', s.Data) - 1) AS int) AS varchar(2)), 2)
                ) AS date)
            END,
            s.REGIONAL_AJUST,
            s.SVC,
            s.XPT,
            s.MLP,
            s.Perfil_Veiculo_Executado,
            s.Ciclo,
            s.Cluster,
            s.Driver,
            s.Experiencia_Driver,
            s.Placa,
            s.ID_VEICULO,
            s.Veiculo,
            HoraInicio = TRY_CAST(s.HORA_INICIO AS time(0)),
            HoraFim    = TRY_CAST(s.HORA_FIM AS time(0)),
            s.ORH_PLAN,
            s.ORH_HOURS,
            s.KM_PLAN,
            s.KM_REAL,
            s.STEM_OUT,
            s.Parada,
            s.Pacotes,
            s.Entregue,
            s.DS,
            s.AT_STATION,
            s.Insucessos,
            s.INACCESSIBLE_ADDRESS,
            s.BUYER_REJECTED,
            s.BUYER_MOVED,
            s.BUYER_ABSENT,
            s.BUSINESS_CLOSED,
            s.BLOCKED_BY_KEYWORD,
            s.BAD_ADDRESS,
            s.NOT_ATTEMPTED,
            s.Outros_Motivos,
            rn = ROW_NUMBER() OVER (PARTITION BY s.CodigoCliente, s.Rotas ORDER BY s.DataExtracao DESC)
        FROM dbo.tb_stg_looker_ds_secao_6 AS s WITH (NOLOCK)
        CROSS JOIN limite AS lm
        WHERE s.Rotas IS NOT NULL
          AND s.CodigoCliente IS NOT NULL
          AND s.DataExtracao >= DATEADD(DAY, -30, lm.MaxExtracao)
    )
    MERGE dbo.tb_ml_bsc_paradas WITH (HOLDLOCK) AS dst
    USING (SELECT * FROM src WHERE rn = 1) AS s
        ON dst.IdCliente = s.CodigoCliente
       AND dst.IdRota = s.Rotas
    WHEN MATCHED AND ISNULL(s.DataExtracao, '1900-01-01') > ISNULL(dst.DataExtracao, '1900-01-01') THEN
        UPDATE SET
            /* WHERE implicito: escopo limitado pelo ON do MERGE (IdCliente, IdRota) */
            dst.QuantidadeParadas           = s.Parada,
            dst.DataRota                    = s.DataRota,
            dst.DataExtracao                = s.DataExtracao,
            dst.Regional                    = s.REGIONAL_AJUST,
            dst.SVC                         = s.SVC,
            dst.XPT                         = s.XPT,
            dst.MLP                         = s.MLP,
            dst.PerfilVeiculoExecutado      = s.Perfil_Veiculo_Executado,
            dst.Ciclo                       = s.Ciclo,
            dst.Cluster                     = s.Cluster,
            dst.IdMotorista                 = s.Driver,
            dst.ExperienciaDriver           = s.Experiencia_Driver,
            dst.Placa                       = s.Placa,
            dst.IdVeiculo                   = s.ID_VEICULO,
            dst.Veiculo                     = s.Veiculo,
            dst.HoraInicio                  = s.HoraInicio,
            dst.HoraFim                     = s.HoraFim,
            dst.ORH_PLAN                    = s.ORH_PLAN,
            dst.ORH_HOURS                   = s.ORH_HOURS,
            dst.KM_PLAN                     = s.KM_PLAN,
            dst.KM_REAL                     = s.KM_REAL,
            dst.STEM_OUT                    = s.STEM_OUT,
            dst.QuantidadePacotes           = s.Pacotes,
            dst.QuantidadeEntregue          = s.Entregue,
            dst.QuantidadeDS                = s.DS,
            dst.QuantidadeAtStation         = s.AT_STATION,
            dst.QuantidadeInsucessos        = s.Insucessos,
            dst.InsucessoInaccessibleAddress = s.INACCESSIBLE_ADDRESS,
            dst.InsucessoBuyerRejected      = s.BUYER_REJECTED,
            dst.InsucessoBuyerMoved         = s.BUYER_MOVED,
            dst.InsucessoBuyerAbsent        = s.BUYER_ABSENT,
            dst.InsucessoBusinessClosed     = s.BUSINESS_CLOSED,
            dst.InsucessoBlockedByKeyword   = s.BLOCKED_BY_KEYWORD,
            dst.InsucessoBadAddress         = s.BAD_ADDRESS,
            dst.InsucessoNotAttempted       = s.NOT_ATTEMPTED,
            dst.InsucessoOutrosMotivos      = s.Outros_Motivos
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            IdCliente, IdRota, QuantidadeParadas, DataRota, DataExtracao,
            Regional, SVC, XPT, MLP, PerfilVeiculoExecutado, Ciclo, Cluster,
            IdMotorista, ExperienciaDriver, Placa, IdVeiculo, Veiculo,
            HoraInicio, HoraFim, ORH_PLAN, ORH_HOURS, KM_PLAN, KM_REAL, STEM_OUT,
            QuantidadePacotes, QuantidadeEntregue, QuantidadeDS, QuantidadeAtStation,
            QuantidadeInsucessos, InsucessoInaccessibleAddress, InsucessoBuyerRejected,
            InsucessoBuyerMoved, InsucessoBuyerAbsent, InsucessoBusinessClosed,
            InsucessoBlockedByKeyword, InsucessoBadAddress, InsucessoNotAttempted,
            InsucessoOutrosMotivos
        )
        VALUES
        (
            s.CodigoCliente, s.Rotas, s.Parada, s.DataRota, s.DataExtracao,
            s.REGIONAL_AJUST, s.SVC, s.XPT, s.MLP, s.Perfil_Veiculo_Executado,
            s.Ciclo, s.Cluster, s.Driver, s.Experiencia_Driver, s.Placa,
            s.ID_VEICULO, s.Veiculo, s.HoraInicio, s.HoraFim,
            s.ORH_PLAN, s.ORH_HOURS, s.KM_PLAN, s.KM_REAL, s.STEM_OUT,
            s.Pacotes, s.Entregue, s.DS, s.AT_STATION,
            s.Insucessos, s.INACCESSIBLE_ADDRESS, s.BUYER_REJECTED,
            s.BUYER_MOVED, s.BUYER_ABSENT, s.BUSINESS_CLOSED,
            s.BLOCKED_BY_KEYWORD, s.BAD_ADDRESS, s.NOT_ATTEMPTED,
            s.Outros_Motivos
        );

    /* Expurgo do historico da staging em lotes (retencao: 30 dias de extracao) */
    DECLARE @afetadas INT = 1;

    WHILE @afetadas > 0
    BEGIN
        DELETE TOP (50000) FROM dbo.tb_stg_looker_ds_secao_6
        WHERE DataExtracao < DATEADD(DAY, -30, GETDATE());

        SET @afetadas = @@ROWCOUNT;
    END
END
GO

--==========================================================================
-- 4. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.USPTrataStagingParadasBSC'))
        THROW 50042, 'Procedure dbo.USPTrataStagingParadasBSC nao foi criada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas') AND name = 'DataExtracao')
        THROW 50043, 'Coluna DataExtracao nao foi criada em tb_ml_bsc_paradas.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_paradas') AND name = 'QuantidadeInsucessos')
        THROW 50044, 'Colunas de insucesso nao foram criadas em tb_ml_bsc_paradas.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
