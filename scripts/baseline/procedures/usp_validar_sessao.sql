-- ============================================================
-- BASELINE: dbo.usp_validar_sessao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_validar_sessao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_validar_sessao]
    @usr_cd_usuario     INT,
    @ssu_tp_login       TINYINT,
    @ssu_ds_sessao_id   VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END AS IsValid
    FROM tb_sessao_usuario
    WHERE usr_cd_usuario = @usr_cd_usuario
      AND ssu_tp_login = @ssu_tp_login
      AND ssu_ds_sessao_id = @ssu_ds_sessao_id
      AND ssu_dh_revogada IS NULL
      AND ssu_dh_expiracao > GETUTCDATE();
END
GO
