-- ============================================================
-- BASELINE: dbo.usp_sync_tb_dim_faixa_km
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_sync_tb_dim_faixa_km]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_sync_tb_dim_faixa_km]
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.tb_dim_faixa_km (ds_faixa_original, km_inicio, km_fim, ds_descricao)
    SELECT DISTINCT
        ppr_cd_faixa_km AS ds_faixa_original,
        CASE
            WHEN ppr_cd_faixa_km LIKE '%/%' AND ISNUMERIC(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 1)) = 1
                THEN CAST(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 1) AS INT)
            WHEN ISNUMERIC(ppr_cd_faixa_km) = 1 THEN CAST(ppr_cd_faixa_km AS INT)
            WHEN ppr_cd_faixa_km LIKE '/%' THEN 0
            ELSE NULL
        END AS km_inicio,
        CASE
            WHEN ppr_cd_faixa_km LIKE '%/%' AND ISNUMERIC(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 2)) = 1
                THEN CAST(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 2) AS INT)
            WHEN ISNUMERIC(ppr_cd_faixa_km) = 1 THEN CAST(ppr_cd_faixa_km AS INT)
            WHEN ppr_cd_faixa_km LIKE '%/' AND ISNUMERIC(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 1)) = 1
                THEN CAST(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 1) AS INT)
            ELSE NULL
        END AS km_fim,
        CASE
            WHEN ppr_cd_faixa_km = '0/0' THEN 'Sem faixa definida'
            WHEN ppr_cd_faixa_km LIKE '%/%' THEN 'De ' + 
                CASE WHEN ISNUMERIC(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 1)) = 1 
                     THEN PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 1) ELSE '?' END + 
                ' a ' + 
                CASE WHEN ISNUMERIC(PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 2)) = 1 
                     THEN PARSENAME(REPLACE(ppr_cd_faixa_km, '/', '.'), 2) ELSE '?' END
            WHEN ISNUMERIC(ppr_cd_faixa_km) = 1 THEN ppr_cd_faixa_km + ' KM'
            ELSE ppr_cd_faixa_km
        END AS ds_descricao
    FROM dbo.tb_pgto_periodo_rota WITH (NOLOCK)
    WHERE ppr_cd_faixa_km IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM dbo.tb_dim_faixa_km 
          WHERE ds_faixa_original = ppr_cd_faixa_km
      );
    
    UPDATE dbo.tb_dim_faixa_km
    SET dt_atualizacao = GETDATE()
    WHERE dt_atualizacao < DATEADD(hour, -8, GETDATE());
    
    PRINT 'Sync de faixa_km concluído.';
END;
GO
