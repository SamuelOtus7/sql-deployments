-- ============================================================
-- BASELINE: dbo.usp_registrar_sessao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_registrar_sessao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_registrar_sessao]
    @usr_cd_usuario         INT,
    @ssu_tp_login           TINYINT,
    @ssu_ds_sessao_id       VARCHAR(64),
    @ssu_ds_device_uuid     VARCHAR(128) = NULL,
    @ssu_ds_device_info     VARCHAR(256) = NULL,
    @ssu_ds_app_version     VARCHAR(32)  = NULL,
    @ssu_ds_created_by_ip   VARCHAR(45)  = NULL,
    @ssu_dh_expiracao       DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    -- Revoga sessões ativas anteriores da mesma plataforma (sessão única)
    UPDATE tb_sessao_usuario
    SET ssu_dh_revogada = GETUTCDATE(),
        ssu_ds_motivo_revogacao = 'NOVO_LOGIN'
    WHERE usr_cd_usuario = @usr_cd_usuario
      AND ssu_tp_login = @ssu_tp_login
      AND ssu_dh_revogada IS NULL;

    -- Insere a nova sessão
    INSERT INTO tb_sessao_usuario (
        usr_cd_usuario,
        ssu_tp_login,
        ssu_ds_sessao_id,
        ssu_ds_device_uuid,
        ssu_ds_device_info,
        ssu_ds_app_version,
        ssu_dh_login,
        ssu_dh_ultima_atividade,
        ssu_dh_expiracao,
        ssu_ds_created_by_ip
    )
    VALUES (
        @usr_cd_usuario,
        @ssu_tp_login,
        @ssu_ds_sessao_id,
        @ssu_ds_device_uuid,
        @ssu_ds_device_info,
        @ssu_ds_app_version,
        GETUTCDATE(),
        GETUTCDATE(),
        @ssu_dh_expiracao,
        @ssu_ds_created_by_ip
    );
END
GO
