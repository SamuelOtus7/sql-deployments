-- ============================================================
-- BASELINE: dbo.UspSPEGetLoadStations
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGetLoadStations]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[UspSPEGetLoadStations] as 

;WITH SRC AS (
    SELECT  
        ausentes.IdStation,
        ausentes.IdTransportadora,
        CAST(0 AS int) AS CodigoStation,
        ausentes.NomeHub AS NomeStation,
        CAST(0 AS int) AS IdCidade,
        CAST(0 AS int) AS IdCidadeReferencia,
        ISNULL(bases.bss_ds_cidade, '') AS Cidade,
        ISNULL(bases.bss_ds_cep, '') AS CEP,
        CAST(CAST(ISNULL(bases.bss_dc_latitude, 0) AS decimal(18,8)) AS varchar(15)) AS Latitude,
        CAST(CAST(ISNULL(bases.bss_dc_longitude, 0) AS decimal(18,8)) AS varchar(15)) AS Longitude,
        ISNULL(bases.bss_ds_endereco, '') AS Endereco,
        '' AS NomeContato,
        '' AS EmailContato,
        '' AS TelefoneContato,
        '' AS PropriaFrota,
        ISNULL(bases.bss_ds_estado, '') AS Estado,
        '' AS NomeAmigavel
    FROM (
        SELECT 
            rotas.IdStation, 
            MAX(rotas.NomeHub) AS NomeHub, 
            MAX(rotas.IdTransportadora) AS IdTransportadora
        FROM tb_spe_rotas_v5 AS rotas
        LEFT JOIN tb_spe_station AS stations 
            ON rotas.IdStation = stations.IdStation
        WHERE stations.IdStation IS NULL
          AND rotas.NomeHub IS NOT NULL
        GROUP BY rotas.IdStation
    ) AS ausentes
    LEFT JOIN tb_bases AS bases 
        ON ausentes.IdTransportadora = bases.bss_cd_idtransportadora
       AND ausentes.NomeHub = bases.bss_ds_nome
)

MERGE dbo.tb_spe_station AS TGT
USING SRC
    ON TGT.NomeStation = SRC.NomeStation
   AND TGT.IdStation   = SRC.IdStation
   and TGT.Idtransportadora = SRC.Idtransportadora

WHEN MATCHED THEN
    UPDATE SET
        TGT.IdTransportadora   = SRC.IdTransportadora,
        TGT.CodigoStation      = SRC.CodigoStation,
        TGT.IdCidade           = SRC.IdCidade,
        TGT.IdCidadeReferencia = SRC.IdCidadeReferencia,
        TGT.Cidade             = SRC.Cidade,
        TGT.CEP                = SRC.CEP,
        TGT.Latitude           = SRC.Latitude,
        TGT.Longitude          = SRC.Longitude,
        TGT.Endereco           = SRC.Endereco,
        TGT.NomeContato        = SRC.NomeContato,
        TGT.EmailContato       = SRC.EmailContato,
        TGT.TelefoneContato    = SRC.TelefoneContato,
        TGT.PropriaFrota       = SRC.PropriaFrota,
        TGT.Estado             = SRC.Estado,
        TGT.NomeAmigavel       = SRC.NomeAmigavel

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        IdStation, IdTransportadora, CodigoStation, NomeStation,
        IdCidade, IdCidadeReferencia, Cidade, CEP,
        Latitude, Longitude, Endereco,
        NomeContato, EmailContato, TelefoneContato, PropriaFrota,
        Estado, NomeAmigavel
    )
    VALUES (
        SRC.IdStation, SRC.IdTransportadora, SRC.CodigoStation, SRC.NomeStation,
        SRC.IdCidade, SRC.IdCidadeReferencia, SRC.Cidade, SRC.CEP,
        SRC.Latitude, SRC.Longitude, SRC.Endereco,
        SRC.NomeContato, SRC.EmailContato, SRC.TelefoneContato, SRC.PropriaFrota,
        SRC.Estado, SRC.NomeAmigavel
    );
GO
