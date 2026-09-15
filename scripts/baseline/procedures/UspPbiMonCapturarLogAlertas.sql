-- ============================================================
-- BASELINE: dbo.UspPbiMonCapturarLogAlertas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspPbiMonCapturarLogAlertas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspPbiMonCapturarLogAlertas]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dh_evento DATETIME2(3) = SYSDATETIME();

    ;WITH UltimoLog AS
    (
        SELECT
            l.id_transportadora,
            l.processo_id,
            l.cd_status AS cd_status_ultimo_log,
            ROW_NUMBER() OVER (
                PARTITION BY l.id_transportadora, l.processo_id
                ORDER BY l.log_id DESC
            ) AS rn
        FROM dbo.tb_pbi_mon_log_alertas AS l
    )
    INSERT INTO dbo.tb_pbi_mon_log_alertas
    (
        dh_evento,
        id_transportadora,
        processo_id,
        cd_status,
        ds_status,
        ds_mensagem_erro
    )
    SELECT
        @dh_evento,
        f.id_transportadora,
        f.processo_id,
        f.cd_status,
        f.ds_status,
        CASE WHEN f.cd_status = 1 THEN f.ds_acao_recomendada END
    FROM dbo.tb_pbi_mon_alertas_fato AS f
    LEFT JOIN UltimoLog AS ul
        ON ul.id_transportadora = f.id_transportadora
       AND ul.processo_id = f.processo_id
       AND ul.rn = 1
    WHERE f.in_elegivel_monitoramento = 1
      AND f.cd_status IN (0, 1)
      AND (
            (f.cd_status = 1 AND ISNULL(ul.cd_status_ultimo_log, 0) = 0)
         OR (f.cd_status = 0 AND ul.cd_status_ultimo_log IN (1, 2))
      );
END;
GO
