-- ============================================================
-- BASELINE: dbo.AtualizaCEPs
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[AtualizaCEPs]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AtualizaCEPs]
AS
BEGIN



UPDATE tb_ml_pacotes SET CEP = DCG_NR_CEP FROM TB_ML_PACOTES pacotes
left join tb_dra_cidades_geo as geo
on pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
and pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude
where cep is null and datareferencia >= '2024-10-01'
 





    -- Atualiza o campo CEP na tabela TB_PACOTES





    UPDATE TB_ML_PACOTES
    SET CEP = CAST(
        CASE 
            WHEN LEN(CAST(CEP AS VARCHAR(8))) = 3 THEN CAST(CEP AS VARCHAR(8)) + '00000'
            WHEN LEN(CAST(CEP AS VARCHAR(8))) = 4 THEN CAST(CEP AS VARCHAR(8)) + '0000'
            WHEN LEN(CAST(CEP AS VARCHAR(8))) = 5 THEN CAST(CEP AS VARCHAR(8)) + '000'
            WHEN LEN(CAST(CEP AS VARCHAR(8))) = 6 THEN CAST(CEP AS VARCHAR(8)) + '00'
            WHEN LEN(CAST(CEP AS VARCHAR(8))) = 7 THEN CAST(CEP AS VARCHAR(8)) + '0'
            ELSE CEP
        END AS INT) WHERE CEP IS NOT NULL AND  LEN(CAST(CEP AS VARCHAR(8))) <>8 AND DATAREFERENCIA = '2024-11-13'

    -- Atualiza os campos CEP_INICIO_TRATADO e CEP_FIM_TRATADO na tabela TB_AREAS_DE_RISCO
    UPDATE TB_AREAS_DE_RISCO
    SET CEP_INICIO_TRATADO = CAST(
        CASE 
            WHEN LEN(CAST(CEP_INICIO AS VARCHAR(8))) = 3 THEN CAST(CEP_INICIO AS VARCHAR(8)) + '00000'
            WHEN LEN(CAST(CEP_INICIO AS VARCHAR(8))) = 4 THEN CAST(CEP_INICIO AS VARCHAR(8)) + '0000'
            WHEN LEN(CAST(CEP_INICIO AS VARCHAR(8))) = 5 THEN CAST(CEP_INICIO AS VARCHAR(8)) + '000'
            WHEN LEN(CAST(CEP_INICIO AS VARCHAR(8))) = 6 THEN CAST(CEP_INICIO AS VARCHAR(8)) + '00'
            WHEN LEN(CAST(CEP_INICIO AS VARCHAR(8))) = 7 THEN CAST(CEP_INICIO AS VARCHAR(8)) + '0'
            ELSE CEP_INICIO
        END AS INT),
        CEP_FIM_TRATADO = CAST(
        CASE 
            WHEN LEN(CAST(CEP_FIM AS VARCHAR(8))) = 3 THEN CAST(CEP_FIM AS VARCHAR(8)) + '00000'
            WHEN LEN(CAST(CEP_FIM AS VARCHAR(8))) = 4 THEN CAST(CEP_FIM AS VARCHAR(8)) + '0000'
            WHEN LEN(CAST(CEP_FIM AS VARCHAR(8))) = 5 THEN CAST(CEP_FIM AS VARCHAR(8)) + '000'
            WHEN LEN(CAST(CEP_FIM AS VARCHAR(8))) = 6 THEN CAST(CEP_FIM AS VARCHAR(8)) + '00'
            WHEN LEN(CAST(CEP_FIM AS VARCHAR(8))) = 7 THEN CAST(CEP_FIM AS VARCHAR(8)) + '0'
            ELSE CEP_FIM
        END AS INT);

END;
GO
