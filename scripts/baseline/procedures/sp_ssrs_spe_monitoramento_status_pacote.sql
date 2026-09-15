-- ============================================================
-- BASELINE: dbo.sp_ssrs_spe_monitoramento_status_pacote
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_ssrs_spe_monitoramento_status_pacote]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_ssrs_spe_monitoramento_status_pacote] as 

-- 1. Cria a tabela temporária
IF OBJECT_ID('tempdb..#ocorrencias_tmp') IS NOT NULL
    DROP TABLE #ocorrencias_tmp;

CREATE TABLE #ocorrencias_tmp (
    DataReferencia date,
    idtransportadora INT,
    servicecenter NVARCHAR(150),
    CompradorAusente INT,
    NegocioFechado INT,
    EnderecoRuim INT,
    Compradorrejeitado INT,
    ForaRota INT,
    ProblemasMecanicos INT,
    MotoristaSemTempo INT,
    FalhaAplicativo INT,
    AreaRisco INT,
    ClienteMudou INT,
    Outros INT,
    Perdido INT
);

-- 2. Insere os dados na tabela temporária
INSERT INTO #ocorrencias_tmp (
    DataReferencia,idtransportadora, servicecenter,
    CompradorAusente, NegocioFechado, EnderecoRuim, Compradorrejeitado,
    ForaRota, ProblemasMecanicos, MotoristaSemTempo, FalhaAplicativo,
    AreaRisco, ClienteMudou, Outros, Perdido
)
SELECT
    a.DataReferencia,
    a.idtransportadora,
    NomeHub AS servicecenter,
    COUNT(CASE WHEN a.SubStatus = 'O comprador não está em casa' THEN 1 END) AS CompradorAusente,
    COUNT(CASE WHEN a.SubStatus = 'Comércio Fechado' THEN 1 END) AS NegocioFechado,
    COUNT(CASE WHEN a.SubStatus = 'Endereço não encontrado' THEN 1 END) AS EnderecoRuim,
    COUNT(CASE WHEN a.SubStatus = 'Rejeitado pelo usuário' THEN 1 END) AS Compradorrejeitado,
    COUNT(CASE WHEN a.SubStatus = 'Fora de Rota' THEN 1 END) AS ForaRota,
    COUNT(CASE WHEN a.SubStatus = 'Problemas Mecânicos' THEN 1 END) AS ProblemasMecanicos,
    COUNT(CASE WHEN a.SubStatus = 'O motorista não tem tempo suficiente' THEN 1 END) AS MotoristaSemTempo,
    COUNT(CASE WHEN a.SubStatus = 'Falha de aplicativo/Internet' THEN 1 END) AS FalhaAplicativo,
    COUNT(CASE WHEN a.SubStatus = 'Área de Risco' THEN 1 END) AS AreaRisco,
    COUNT(CASE WHEN a.SubStatus = 'Cliente se Mudou' THEN 1 END) AS ClienteMudou,
    COUNT(CASE WHEN a.StatusEntrega = 'Não Entregue' THEN 1 END) AS Outros,
    COUNT(CASE WHEN a.SubStatus = 'Item perdido' THEN 1 END) AS Perdido
FROM
    vw_pacotes_spe_v4 AS a
    INNER JOIN vw_rotas_spe_v4 AS b ON a.codigorota = b.codigorota
WHERE
    CAST(b.DataHoraInicio AS DATE) = CAST(DATEADD(HOUR, -2, GETDATE()) AS DATE)
    AND a.DataReferencia = CAST(DATEADD(HOUR, -2, GETDATE()) AS DATE)
GROUP BY
    a.DataReferencia, a.idtransportadora, NomeHub;

-- 3. Faz o MERGE dos dados na tabela final
MERGE tb_ssrs_spe_monitoramento_status_pacote AS tgt
USING #ocorrencias_tmp AS src
    ON tgt.idtransportadora = src.idtransportadora
    AND tgt.servicecenter = src.servicecenter
    and tgt.DataReferencia = src.DataReferencia 

WHEN MATCHED THEN
    UPDATE SET
        tgt.CompradorAusente     = src.CompradorAusente,
        tgt.NegocioFechado       = src.NegocioFechado,
        tgt.EnderecoRuim         = src.EnderecoRuim,
        tgt.CompradorRejeitado   = src.Compradorrejeitado,
        tgt.ForaRota             = src.ForaRota,
        tgt.ProblemasMecanicos   = src.ProblemasMecanicos,
        tgt.MotoristaSemTempo    = src.MotoristaSemTempo,
        tgt.FalhaAplicativo      = src.FalhaAplicativo,
        tgt.AreaRisco            = src.AreaRisco,
        tgt.ClienteMudou         = src.ClienteMudou,
        tgt.Outros               = src.Outros,
        tgt.Perdido              = src.Perdido
WHEN NOT MATCHED THEN
    INSERT (
        DataReferencia , idtransportadora, servicecenter,
        CompradorAusente, NegocioFechado, EnderecoRuim, CompradorRejeitado,
        ForaRota, ProblemasMecanicos, MotoristaSemTempo, FalhaAplicativo,
        AreaRisco, ClienteMudou, Outros, Perdido
    )
    VALUES (
        src.DataReferencia , src.idtransportadora, src.servicecenter,
        src.CompradorAusente, src.NegocioFechado, src.EnderecoRuim, src.Compradorrejeitado,
        src.ForaRota, src.ProblemasMecanicos, src.MotoristaSemTempo, src.FalhaAplicativo,
        src.AreaRisco, src.ClienteMudou, src.Outros, src.Perdido
    );
GO
