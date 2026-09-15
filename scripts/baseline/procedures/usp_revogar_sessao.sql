-- ============================================================
-- BASELINE: dbo.usp_revogar_sessao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_revogar_sessao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_revogar_sessao]
    @usr_cd_usuario         INT,
    @ssu_tp_login           TINYINT = NULL,
    @ssu_ds_motivo_revogacao VARCHAR(64)
AS
BEGIN
    SET NOCOUNT ON;
    IF @ssu_tp_login IS NULL
        UPDATE tb_sessao_usuario
        SET ssu_dh_revogada = GETUTCDATE(),
            ssu_ds_motivo_revogacao = @ssu_ds_motivo_revogacao
        WHERE usr_cd_usuario = @usr_cd_usuario
          AND ssu_dh_revogada IS NULL;
    ELSE
        UPDATE tb_sessao_usuario
        SET ssu_dh_revogada = GETUTCDATE(),
            ssu_ds_motivo_revogacao = @ssu_ds_motivo_revogacao
        WHERE usr_cd_usuario = @usr_cd_usuario
          AND ssu_tp_login = @ssu_tp_login
          AND ssu_dh_revogada IS NULL;
END
GO
