-- ============================================================
-- BASELINE: dbo.sp_merge_insucessos_por_ciclo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_merge_insucessos_por_ciclo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_merge_insucessos_por_ciclo]
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabela temporária
    
    DROP TABLE if exists  #TempInsucessos
    CREATE TABLE #TempInsucessos (
        idtransportadora INT,
        servicecenter VARCHAR(100),
        OrigemSaida VARCHAR(100),
        ciclo VARCHAR(2),
        CompradorAusente INT,
        NegocioFechado INT,
        EnderecoRuim INT,
        CompradorRejeitado INT,
        ErroDeRota INT,
        BloqueadoPorPalavraChave INT,
        Bloqueado INT,
        Perdido INT,
        EnderecoNaoVisitado INT,
        EnderecoInacessivel INT,
        Cancelado INT,
        CompradorMudou INT,
        Outros INT,
        insucesso INT,
        DataReferencia DATE
    );

    -- Inserção na tabela temporária
    INSERT INTO #TempInsucessos
    SELECT  
        a.idtransportadora,
        servicecenter,
        isnull(OrigemSaida,'-'),
        CASE WHEN DATEPART(hour, b.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM' END AS ciclo,
        COUNT(CASE WHEN a.SubStatus = 'buyer_absent' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'business_closed' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'bad_address' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'buyer_rejected' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'missrouted' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'blocked_by_keyword' THEN 1 END),
        0,
        COUNT(CASE WHEN a.SubStatus = 'missing' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'unvisited_address' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'inaccessible_address' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'cancelled' THEN 1 END),
        COUNT(CASE WHEN a.SubStatus = 'buyer_moved' THEN 1 END),
        COUNT(CASE WHEN a.StatusEntrega IN ('On_Hold','On Hold','OnHold','Cancelled','not_delivered') AND
                   ISNULL(a.SubStatus,'Não categorizado') NOT IN (
                       'buyer_absent','business_closed','bad_address','buyer_rejected',
                       'missrouted','blocked_by_keyword','missing',
                       'unvisited_address','inaccessible_address','buyer_moved','cancelled','transferred') THEN 1 END),
        COUNT(CASE WHEN a.StatusEntrega IN ('On_Hold','On Hold','OnHold','Cancelled','not_delivered') AND
                   ISNULL(a.SubStatus,'Não categorizado') <> 'transferred' THEN 1 END),
        CAST(DATEADD(HOUR, -2, GETDATE()) AS DATE) DataReferencia

    FROM tb_ml_pacotes AS a with(nolock)
    INNER JOIN tb_ml_rotas AS b  with(nolock)
        ON a.idrota = b.idrota AND a.DataReferencia = b.DataReferencia AND a.IdTransportadora = b.IdTransportadora
    INNER JOIN tb_clientes AS c
        ON a.IdTransportadora = c.cli_id_logistics AND c.cli_in_ativo = 1 AND c.cli_cd_codigo_cliente <> 7

    WHERE 1=1
      AND a.datareferencia = CAST(DATEADD(HOUR, -2, GETDATE()) AS DATE)
      and b.StatusRota <> 'planned'
      AND a.Excluido = 0
      AND b.Excluido = 0
      --AND b.datareferencia = CAST(DATEADD(HOUR, -2, GETDATE()) AS DATE)
    GROUP BY a.idtransportadora, servicecenter, OrigemSaida,
             CASE WHEN DATEPART(hour, b.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM'end ;


    -- MERGE na tabela final
    MERGE dbo.tb_insucessos_por_ciclo AS target
    USING #TempInsucessos AS source
    ON target.idtransportadora = source.idtransportadora
       AND target.servicecenter = source.servicecenter
       AND target.OrigemSaida = source.OrigemSaida
       AND target.ciclo = source.ciclo
       AND target.DataReferencia = source.DataReferencia
    WHEN MATCHED THEN
        UPDATE SET
            CompradorAusente = source.CompradorAusente,
            NegocioFechado = source.NegocioFechado,
            EnderecoRuim = source.EnderecoRuim,
            CompradorRejeitado = source.CompradorRejeitado,
            ErroDeRota = source.ErroDeRota,
            BloqueadoPorPalavraChave = source.BloqueadoPorPalavraChave,
            Bloqueado = source.Bloqueado,
            Perdido = source.Perdido,
            EnderecoNaoVisitado = source.EnderecoNaoVisitado,
            EnderecoInacessivel = source.EnderecoInacessivel,
            Cancelado = source.Cancelado,
            CompradorMudou = source.CompradorMudou,
            Outros = source.Outros,
            insucesso = source.insucesso
    WHEN NOT MATCHED THEN
        INSERT (
            idtransportadora, servicecenter, OrigemSaida, ciclo,
            CompradorAusente, NegocioFechado, EnderecoRuim, CompradorRejeitado,
            ErroDeRota, BloqueadoPorPalavraChave, Bloqueado, Perdido,
            EnderecoNaoVisitado, EnderecoInacessivel, Cancelado, CompradorMudou,
            Outros, insucesso, DataReferencia
        )
        VALUES (
            source.idtransportadora, source.servicecenter, source.OrigemSaida, source.ciclo,
            source.CompradorAusente, source.NegocioFechado, source.EnderecoRuim, source.CompradorRejeitado,
            source.ErroDeRota, source.BloqueadoPorPalavraChave, source.Bloqueado, source.Perdido,
            source.EnderecoNaoVisitado, source.EnderecoInacessivel, source.Cancelado, source.CompradorMudou,
            source.Outros, source.insucesso, source.DataReferencia
        );

    --DROP TABLE #TempInsucessos;
END
GO
