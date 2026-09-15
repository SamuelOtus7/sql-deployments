-- ============================================================
-- BASELINE: dbo.Atualizar_Cidade_Distrito_Limitado
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Atualizar_Cidade_Distrito_Limitado]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Atualizar_Cidade_Distrito_Limitado]
AS
BEGIN
    SET NOCOUNT ON;

    -- Atualizar apenas os registros da tb_dra_cidades_geo que possuem correspondência nos pacotes filtrados
    UPDATE geo
    SET geo.dcg_ds_cidade_distrito = COALESCE(nd.Nome_Microrregião, geo.dcg_ds_cidade)
    FROM tb_dra_cidades_geo geo
    LEFT JOIN tb_novos_distritos nd 
        ON LOWER(LTRIM(RTRIM(nd.Nome_Distrito))) = LOWER(LTRIM(RTRIM(geo.dcg_ds_cidade)))
    WHERE EXISTS (
        SELECT 1
        FROM tb_ml_pacotes pacotes WITH (NOLOCK)
        WHERE 
            pacotes.LatitudeEnderecoParada IS NOT NULL
            AND pacotes.LongitudeEnderecoParada IS NOT NULL
            AND pacotes.datareferencia BETWEEN CAST(GETDATE() - 25 AS DATE) AND CAST(GETDATE() AS DATE)
            AND pacotes.idtransportadora = 643493085
            AND pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
            AND pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude
    );
END;
GO
