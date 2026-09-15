-- ============================================================
-- BASELINE: dbo.usp_get_user_access
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_get_user_access]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_get_user_access]
    @CodUsuario INT,
    @Action VARCHAR(20),
    @ControllerName VARCHAR(50),
    @Codigo VARCHAR(50)

AS

     -- Configuração do nível de isolamento da transação
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @ActionCod INT
    SET @ActionCod = 0

    DECLARE @ControllerCod INT
    SET @ControllerCod = 0

    DECLARE @AccessController BIT
    SET @AccessController = 0

    DECLARE @Modulo VARCHAR(50)
    SET @Modulo = @ControllerName

    BEGIN TRY
        BEGIN
            SELECT @ActionCod = act_cd_action
            FROM tb_action
            WHERE act_nm_action = @Action
        END

        IF @ControllerName NOT IN ('Crud', 'PowerBI', 'Metabase', 'Upload')
            BEGIN
                SELECT @ControllerCod = ctr_cd_controller, @ControllerName = ctr_nm_controller
                FROM tb_controller
                WHERE ctr_nm_controller = @ControllerName
            END
        ELSE 
            IF @ControllerName IN ('PowerBI', 'MetaBase')
                BEGIN
                    SELECT @ControllerCod = ctr_cd_controller, @ControllerName = CAST(ctr_cd_controller as VARCHAR(50))
                    FROM tb_controller
                    WHERE ctr_nm_rota_params = @Codigo
                END
                    ELSE
            IF @ControllerName IN ('Crud', 'Upload')
                BEGIN
                    SELECT @ControllerCod = ctr_cd_controller, @ControllerName = ctr_nm_controller
                    FROM tb_controller
                    WHERE ctr_cd_controller = CAST(@Codigo as INT)
                END

        IF (@ActionCod > 0 AND @ControllerCod > 0 AND @ControllerName NOT IN ('LogsAcessos', 'Favoritos', 'Notificacoes'))
            BEGIN
                BEGIN TRANSACTION;
                    INSERT INTO tb_logs_acessos
                        (usr_cd_usuario, log_dh_acesso, act_cd_action, ctr_cd_controller)
                    VALUES
                        (@CodUsuario, GETDATE(), @ActionCod, @ControllerCod);
                COMMIT;
            END
    END TRY
    BEGIN CATCH
        select ERROR_MESSAGE();
        IF @@TRANCOUNT > 0
            ROLLBACK;
    END CATCH;


    IF @Modulo NOT IN ('Crud', 'PowerBI', 'Metabase', 'Upload')
    BEGIN
        SET @Modulo = 'Sistema'
    END

    SELECT 
        @AccessController = CAST(Verify as bit)
    FROM fn_check_user_access(@CodUsuario, @Action, @ControllerName, @Modulo)

	SELECT
        TOP 1
        CAST((CASE WHEN tb_parametros.isGrupoAdmin > 0 THEN 1 ELSE 0 END) as bit) as IsAdmin,
        @AccessController as AccessController,
        tb_usuario.usr_cd_usuario,
        tb_usuario.usr_nm_usuario,
        tb_usuario.usr_ds_email,
        tb_usuario.usr_in_ativo,					--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_in_plataforma,				--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_chat_token,					--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_cd_chat,						--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_chat_username,				--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_ds_num_telefone,				--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_cd_tipo_contrato,			--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_cd_usr_modificacao,			--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_in_fat_motorista_valor_app,	--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_in_motorista,				--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO Adicionado 02-01-2025 - Rodrigo - Acesso ao financeiro do app por usuario não motorista 
        tb_usuario.usr_in_registro_gps,				--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_usuario.usr_reset_token,					--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_clientes.cli_cd_codigo_cliente,			--(necessário avaliar) SUBSTITUIR PELO CLIENTE DA TABELA DE USUÁRIOS
        tb_clientes.cli_id_Logistics,				--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
        tb_clientes.cli_id_shopee					--(necessário avaliar) APARENTEMENTE PODE SER REMOVIDO
    FROM tb_usuario WITH (NOLOCK)
        INNER JOIN tb_clientes WITH (NOLOCK) ON tb_clientes.cli_cd_codigo_cliente = tb_usuario.cli_cd_codigo_cliente
        INNER JOIN tb_usuario_grupo_acesso WITH (NOLOCK) ON tb_usuario_grupo_acesso.uga_cd_usuario = tb_usuario.usr_cd_usuario
        INNER JOIN tb_grupo_acesso WITH (NOLOCK) ON tb_grupo_acesso.gpa_cd_grupo_acesso = tb_usuario_grupo_acesso.uga_cd_grupo_acesso
        LEFT JOIN (
            select CAST(prm_ds_valor as int) as isGrupoAdmin
        from tb_parametros WITH (NOLOCK)
        where prm_ds_parametro = 'IdGrupoAdmin'
            ) as tb_parametros on tb_parametros.isGrupoAdmin = tb_grupo_acesso.gpa_cd_grupo_acesso
    WHERE tb_usuario.usr_cd_usuario = @CodUsuario
    ORDER BY tb_parametros.isGrupoAdmin DESC

GO
