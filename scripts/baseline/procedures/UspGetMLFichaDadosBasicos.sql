-- ============================================================
-- BASELINE: dbo.UspGetMLFichaDadosBasicos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetMLFichaDadosBasicos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspGetMLFichaDadosBasicos]
(
    @Transportadora INT,
    @Rota           VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
         CAST(rotas.IdRota AS VARCHAR(50))              AS IdRota
        ,rotas.DataReferencia
        ,rotas.ServiceCenter                          AS Servicecenter
        ,rotas.TipoRota
        ,rotas.OrigemSaida
        ,rotas.TipoOrigemSaida
        ,rotas.CidadeReferencia
        ,rotas.NomeMotorista                          AS Nomemotorista
        ,rotas.TipoVeiculo
        ,rotas.Placa
        ,rotas.PossuiAjudante
        ,rotas.StatusRota
        ,rotas.SubStatusRota
        ,rotas.TempoEmRota                            AS Tempoemrota
        ,rotas.TempoPlanejadoMinutos
        ,rotas.TempoChegadaAreaEntrega
        ,rotas.TempoAreaEntrega
        ,rotas.TempoRetornoCentroDistribuicao
        ,rotas.TempoInativo                           AS Tempoinativo
        ,rotas.DataHoraInicio
        ,rotas.DataHoraFim
        ,rotas.PercentualProgresso                    AS Percentualprogresso
        ,rotas.DataPrimeiraEntrega
        ,rotas.StatusPrimeiraEntrega
        ,rotas.StatusSegundaEntrega
        ,rotas.DataUltimaAtualizacaoPacote
        ,rotas.TotalPacotes
        ,rotas.PacotesEntregues                       AS Pacotesentregues
        ,rotas.PacotesNaoEntregue
        ,rotas.PacotesPendentes                       AS Pacotespendentes
        ,rotas.PacotesEntreguesForaAreaEntrega
        ,rotas.PacotesTransferidos                    AS Pacotestransferidos
        ,rotas.PacotesRecebidos                       AS Pacotesrecebidos
        ,rotas.QuantidadePacotesTransportados
        ,rotas.QuantidadePontos
        ,rotas.QuantidadeParadas
        ,rotas.Ambulancia
        ,rotas.PercentualEntregasBemSucedidas
        ,rotas.StatusPrazo
        ,rotas.QuantidadeReclamacoes
        ,0                                              AS QuantidadePNR
        ,kmRota.idRotaGuid                              AS IdRotaGuid
        ,kmRota.pontosRotasPacotesKm                    AS TotalPacote
        ,kmRota.pontosAppRotasTotalKm                   AS TotalApp

        /* insucessos - regra operacional */
        ,ISNULL(pac.QuantidadePacotesInsucesso, 0)      AS QuantidadePacotesInsucesso
        ,pac.IdsPacotesInsucesso

        /* todos os pacotes ativos vinculados à rota */
        ,ISNULL(pac.QuantidadePacotesVinculados, 0)     AS QuantidadePacotesVinculados
        ,pac.IdsPacotesVinculados
        ,rotas.PercentualPerformance

    FROM (
        SELECT
             r.IdRota
            ,r.DataReferencia
            ,r.IdTransportadora
            ,r.ServiceCenter
            ,r.TipoRota
            ,r.OrigemSaida
            ,r.TipoOrigemSaida
            ,r.CidadeReferencia
            ,r.NomeMotorista
            ,r.TipoVeiculo
            ,r.Placa
            ,r.PossuiAjudante
            ,r.StatusRota
            ,r.SubStatusRota
            ,r.TempoEmRota
            ,r.TempoPlanejadoMinutos
            ,r.TempoChegadaAreaEntrega
            ,r.TempoAreaEntrega
            ,r.TempoRetornoCentroDistribuicao
            ,r.TempoInativo
            ,r.DataHoraInicio
            ,r.DataHoraFim
            ,r.PercentualProgresso
            ,r.DataPrimeiraEntrega
            ,r.StatusPrimeiraEntrega
            ,r.StatusSegundaEntrega
            ,r.DataUltimaAtualizacaoPacote
            ,r.TotalPacotes
            ,r.PacotesEntregues
            ,r.PacotesNaoEntregue
            ,r.PacotesPendentes
            ,r.PacotesEntreguesForaAreaEntrega
            ,r.PacotesTransferidos
            ,r.PacotesRecebidos
            ,r.QuantidadePacotesTransportados
            ,r.QuantidadePontos
            ,r.QuantidadeParadas
            ,r.Ambulancia
            ,r.PercentualEntregasBemSucedidas
            ,r.StatusPrazo
            ,r.QuantidadeReclamacoes
            ,r.Excluido
            ,CASE 
                WHEN r.IdTransportadora = 1726310024 THEN
                    CAST(r.PacotesEntregues AS DECIMAL(18,6))
                    / NULLIF(
                        r.PacotesEntregues
                        + r.PacotesNaoEntregue
                        + r.PacotesPendentes
                        + r.PacotesTransferidos,
                        0
                    )
                WHEN r.IdTransportadora <> 1726310024
                     AND r.Ambulancia = 0 THEN
                    CAST(r.PacotesEntregues AS DECIMAL(18,6))
                    / NULLIF(
                        r.PacotesEntregues
                        + r.PacotesNaoEntregue
                        + r.PacotesPendentes
                        + r.PacotesTransferidos,
                        0
                    )
                ELSE NULL
             END AS PercentualPerformance
        FROM dbo.tb_ml_rotas r WITH (NOLOCK)

        UNION ALL

        SELECT
             fm.IdRota
            ,fm.DataReferencia
            ,fm.IdTransportadora
            ,fm.OrigemSaida                                   AS ServiceCenter
            ,fm.TipoRota
            ,fm.OrigemSaida
            ,CAST(NULL AS VARCHAR(100))                         AS TipoOrigemSaida
            ,CAST(NULL AS VARCHAR(200))                         AS CidadeReferencia
            ,fm.NomeMotorista
            ,fm.TipoVeiculo
            ,fm.PlacaVeiculo                                    AS Placa
            ,CAST(NULL AS BIT)                                  AS PossuiAjudante
            ,fm.Status                                          AS StatusRota
            ,CAST(NULL AS VARCHAR(100))                         AS SubStatusRota
            ,CAST(NULL AS INT)                                  AS TempoEmRota
            ,CAST(NULL AS INT)                                  AS TempoPlanejadoMinutos
            ,CAST(NULL AS INT)                                  AS TempoChegadaAreaEntrega
            ,CAST(NULL AS INT)                                  AS TempoAreaEntrega
            ,CAST(NULL AS INT)                                  AS TempoRetornoCentroDistribuicao
            ,CAST(NULL AS INT)                                  AS TempoInativo
            ,CAST(fm.DataInicio AS DATETIME)                    AS DataHoraInicio
            ,CAST(fm.DataConclusao AS DATETIME)                 AS DataHoraFim
            ,CAST(fm.Perfomance AS DECIMAL(18,6))               AS PercentualProgresso
            ,CAST(NULL AS DATETIME)                             AS DataPrimeiraEntrega
            ,CAST(NULL AS VARCHAR(100))                         AS StatusPrimeiraEntrega
            ,CAST(NULL AS VARCHAR(100))                         AS StatusSegundaEntrega
            ,CAST(NULL AS DATETIME)                             AS DataUltimaAtualizacaoPacote
            ,CAST(fm.QuantidadePacotesEstimados AS SMALLINT)    AS TotalPacotes
            ,CAST(fm.QuantidadePacotesColetados AS SMALLINT)    AS PacotesEntregues
            ,CAST(NULL AS SMALLINT)                             AS PacotesNaoEntregue
            ,CAST(NULL AS SMALLINT)                             AS PacotesPendentes
            ,CAST(NULL AS SMALLINT)                             AS PacotesEntreguesForaAreaEntrega
            ,CAST(NULL AS SMALLINT)                             AS PacotesTransferidos
            ,CAST(NULL AS SMALLINT)                             AS PacotesRecebidos
            ,CAST(fm.QuantidadePacotesEstimados AS INT)         AS QuantidadePacotesTransportados
            ,CAST(NULL AS SMALLINT)                             AS QuantidadePontos
            ,CAST(fm.QuantidadeParadas AS SMALLINT)             AS QuantidadeParadas
            ,CAST(NULL AS BIT)                                  AS Ambulancia
            ,CAST(NULL AS DECIMAL(18,6))                        AS PercentualEntregasBemSucedidas
            ,CAST(NULL AS VARCHAR(100))                         AS StatusPrazo
            ,CAST(NULL AS INT)                                  AS QuantidadeReclamacoes
            ,fm.Excluido
            ,CAST(NULL AS DECIMAL(18,6))                        AS PercentualPerformance
        FROM dbo.tb_ml_fm_rotas fm WITH (NOLOCK)
    ) AS rotas

    INNER JOIN dbo.tb_clientes AS clientes
        ON rotas.IdTransportadora = clientes.cli_id_logistics

    LEFT JOIN dbo.tb_ml_processamento_km_rotas AS kmRota
        ON CAST(rotas.IdRota AS VARCHAR(50)) = CAST(kmRota.idRota AS VARCHAR(50))

    OUTER APPLY (
        SELECT
             SUM(
                CASE
                    WHEN p.StatusEntrega = 'not_delivered'
                     AND ISNULL(p.SubStatus, '') <> 'transferred'
                    THEN 1 ELSE 0
                END
             ) AS QuantidadePacotesInsucesso

            ,STRING_AGG(
                CASE
                    WHEN p.StatusEntrega = 'not_delivered'
                     AND ISNULL(p.SubStatus, '') <> 'transferred'
                    THEN CAST(p.IdPacote AS VARCHAR(50))
                END
             , ',') WITHIN GROUP (ORDER BY p.IdPacote) AS IdsPacotesInsucesso

            ,COUNT(1) AS QuantidadePacotesVinculados

            ,STRING_AGG(CAST(p.IdPacote AS VARCHAR(50)), ',')
                WITHIN GROUP (ORDER BY p.IdPacote) AS IdsPacotesVinculados

        FROM dbo.tb_ml_pacotes p WITH (NOLOCK)
        WHERE p.IdRota = rotas.IdRota
          AND p.IdTransportadora = rotas.IdTransportadora
          AND p.Excluido = 0
    ) AS pac

    WHERE CAST(rotas.IdRota AS VARCHAR(50)) = @Rota
      AND clientes.cli_cd_codigo_cliente = @Transportadora
      AND rotas.Excluido = 0;
END;
GO
