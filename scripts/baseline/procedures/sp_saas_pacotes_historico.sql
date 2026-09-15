-- ============================================================
-- BASELINE: dbo.sp_saas_pacotes_historico
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_saas_pacotes_historico]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_saas_pacotes_historico] as

-- Cria a tabela temporária
IF OBJECT_ID('tempdb..#entregas_tmp') IS NOT NULL
    DROP TABLE #entregas_tmp;

CREATE TABLE #entregas_tmp (
 IdEntrega	bigint
,IdInternoRota	int
,DataReferencia	date
,StatusEntrega	varchar(60)
,SubStatus	varchar(60)
,TipoEndereco	varchar(60)
,Ambulancia	int
,StatusGeralEntrega	varchar(12)
,DataHoraEntrega	datetime
,QuantidadeReclamacoes	int
,EnderecoParada	varchar(100)
,idtransportadora int
);

-- Popula a tabela temporária
INSERT INTO #entregas_tmp
SELECT 
    
    IdEntrega,  
    IdInternoRota,
    CAST(DataReferencia AS DATE) AS DataReferencia,
    StatusEntrega,
    SubStatus,
    TipoEndereco,
    Ambulancia,
    StatusGeralEntrega,
    DATEADD(MINUTE, DATEDIFF(MINUTE, 0, DataHoraEntrega), 0) AS DataHoraEntrega,
    QuantidadeReclamacoes,
    EnderecoParada,
    IdTransportadora
FROM
    vw_pacotes
WHERE
    DataReferencia >= DATEADD(DAY, -5, CAST(GETDATE() AS DATE));



-- Merge de dados na tabela final
MERGE tb_saas_pacotes AS tgt
USING #entregas_tmp AS src
    ON tgt.IdEntrega = src.IdEntrega
    and tgt.DataReferencia = src.DataReferencia
    and tgt.idtransportadora = src.IdTransportadora

WHEN MATCHED THEN
    UPDATE SET
        tgt.IdInternoRota         = src.IdInternoRota,
        tgt.StatusEntrega         = src.StatusEntrega,
        tgt.SubStatus             = src.SubStatus,
        tgt.TipoEndereco          = src.TipoEndereco,
        tgt.Ambulancia            = src.Ambulancia,
        tgt.StatusGeralEntrega    = src.StatusGeralEntrega,
        tgt.DataHoraEntrega       = src.DataHoraEntrega,
        tgt.QuantidadeReclamacoes = src.QuantidadeReclamacoes,
        tgt.EnderecoParada        = src.EnderecoParada

WHEN NOT MATCHED THEN
    INSERT (
        IdEntrega, IdInternoRota, DataReferencia, StatusEntrega,
        SubStatus, TipoEndereco, Ambulancia, StatusGeralEntrega,
        DataHoraEntrega, QuantidadeReclamacoes, EnderecoParada,idtransportadora
    )
    VALUES (
        src.IdEntrega, src.IdInternoRota, src.DataReferencia, src.StatusEntrega,
        src.SubStatus, src.TipoEndereco, src.Ambulancia, src.StatusGeralEntrega,
        src.DataHoraEntrega, src.QuantidadeReclamacoes, src.EnderecoParada,src.idtransportadora
    );
GO
