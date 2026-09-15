-- ============================================================
-- BASELINE: dbo.AREA_RISCO_BKUP
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[AREA_RISCO_BKUP]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[AREA_RISCO_BKUP] AS 
SELECT DISTINCT
    pacotes.IdRota
	, CEP
	,CEP_INICIO
	,CEP_FIM
	,CAST(areas.CUSTO AS DECIMAL) AS CUSTO

    ---- Tratamento do campo CEP para sempre ter 8 dígitos e conversão para INT
    --CAST(
    --    CASE
		  --  WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 3 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '00000' 
    --        WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 4 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '0000'
    --        WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 5 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '000'
    --        WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 6 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '00'
    --        WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 7 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '0'
    --        ELSE pacotes.CEP
    --    END AS INT) AS CEP_TRATADO,

    ---- Tratamento dos campos CEP_INICIO e CEP_FIM para sempre terem 8 dígitos e conversão para INT
    --CAST(
    --    CASE 
		  -- WHEN LEN(CAST(areas.CEP_INICIO AS VARCHAR(8))) = 3 THEN CAST(areas.CEP_INICIO AS VARCHAR(8)) + '00000'

    --        WHEN LEN(CAST(areas.CEP_INICIO AS VARCHAR(8))) = 4 THEN CAST(areas.CEP_INICIO AS VARCHAR(8)) + '0000'
    --        WHEN LEN(CAST(areas.CEP_INICIO AS VARCHAR(8))) = 5 THEN CAST(areas.CEP_INICIO AS VARCHAR(8)) + '000'
    --        WHEN LEN(CAST(areas.CEP_INICIO AS VARCHAR(8))) = 6 THEN CAST(areas.CEP_INICIO AS VARCHAR(8)) + '00'
    --        WHEN LEN(CAST(areas.CEP_INICIO AS VARCHAR(8))) = 7 THEN CAST(areas.CEP_INICIO AS VARCHAR(8)) + '0'
    --        ELSE areas.CEP_INICIO
    --    END AS INT) AS CEP_INICIO_TRATADO,

    --CAST(
    --    CASE
	   --    WHEN LEN(CAST(areas.CEP_FIM AS VARCHAR(8))) = 3 THEN CAST(areas.CEP_FIM AS VARCHAR(8)) + '00000'
	
    --        WHEN LEN(CAST(areas.CEP_FIM AS VARCHAR(8))) = 4 THEN CAST(areas.CEP_FIM AS VARCHAR(8)) + '0000'
    --        WHEN LEN(CAST(areas.CEP_FIM AS VARCHAR(8))) = 5 THEN CAST(areas.CEP_FIM AS VARCHAR(8)) + '000'
    --        WHEN LEN(CAST(areas.CEP_FIM AS VARCHAR(8))) = 6 THEN CAST(areas.CEP_FIM AS VARCHAR(8)) + '00'
    --        WHEN LEN(CAST(areas.CEP_FIM AS VARCHAR(8))) = 7 THEN CAST(areas.CEP_FIM AS VARCHAR(8)) + '0'
    --        ELSE areas.CEP_FIM
    --    END AS INT) AS CEP_FIM_TRATADO,

    --areas.STATUS,
    --clientes.cli_cd_codigo_cliente AS IdTransportadora,
    --pacotes.DataReferencia

FROM 
    vw_pacotes AS pacotes

INNER JOIN 
    tb_areas_de_risco AS areas ON 
        CAST(
            CASE 
                WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 3 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '00000'
				WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 4 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '0000'
                WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 5 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '000'
                WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 6 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '00'
                WHEN LEN(CAST(pacotes.CEP AS VARCHAR(8))) = 7 THEN CAST(pacotes.CEP AS VARCHAR(8)) + '0'
                ELSE pacotes.CEP
            END AS INT) BETWEEN 
        CEP_INICIO_tratado and CEP_FIM_TRATADO

INNER JOIN 
   tb_clientes AS clientes ON pacotes.idTransportadora = clientes.cli_id_logistics

WHERE 
    pacotes.LatitudeEnderecoParada IS NOT NULL
    AND pacotes.LongitudeEnderecoParada IS NOT NULL
--AND IDTRANSPORTADORA=1491631999
--	  AND datareferencia = '2024-10-10' --FILTRO TEMPORÁRIO PARA VALIDAÇÕES.

GO
