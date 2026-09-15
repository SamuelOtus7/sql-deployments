-- ============================================================
-- BASELINE: dbo.sp_sync_parametros_cliente
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_sync_parametros_cliente]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_sync_parametros_cliente]
(
    @ClienteOrigem INT,
    @ListaClientes VARCHAR(MAX),
    @Preview BIT = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Usuario VARCHAR(100) = SUSER_NAME();

    DECLARE @Clientes TABLE (prm_cod_cliente INT);

    INSERT INTO @Clientes
    SELECT TRY_CAST(value AS INT)
    FROM STRING_SPLIT(@ListaClientes, ',')
    WHERE TRY_CAST(value AS INT) IS NOT NULL;


    DECLARE @Dados TABLE (
        cliente_destino INT,
        prm_cd_parametro SMALLINT,
        prm_nm_parametro VARCHAR(150),
        prm_ds_parametro VARCHAR(100),
        prm_ds_chave VARCHAR(150),
        prm_ds_valor VARCHAR(MAX),
        prm_ds_placeholder VARCHAR(150),
        prm_ds_options VARCHAR(MAX),
        prm_ds_categoria VARCHAR(50),
        prm_ds_tipo VARCHAR(50),
        prm_in_ativo BIT,
        prm_cd_usuario_criacao INT,
        prm_cd_usuario_modificacao INT,
        prm_cod_operacao INT
    );


    INSERT INTO @Dados
    SELECT 
        c.prm_cod_cliente,
        p.prm_cd_parametro,
        p.prm_nm_parametro,
        p.prm_ds_parametro,
        p.prm_ds_chave,
        p.prm_ds_valor,
        p.prm_ds_placeholder,
        p.prm_ds_options,
        p.prm_ds_categoria,
        p.prm_ds_tipo,
        p.prm_in_ativo,
        p.prm_cd_usuario_criacao,
        p.prm_cd_usuario_modificacao,
        p.prm_cod_operacao
    FROM tb_parametros p
    CROSS JOIN @Clientes c
    WHERE p.prm_cod_cliente = @ClienteOrigem
    AND c.prm_cod_cliente <> @ClienteOrigem
    AND ISNULL(p.prm_in_excluido, 0) = 0
    AND NOT EXISTS (
        SELECT 1
        FROM tb_parametros x
        WHERE x.prm_cod_cliente = c.prm_cod_cliente
        AND ISNULL(x.prm_in_excluido, 0) = 0
        AND (
            x.prm_ds_chave = p.prm_ds_chave
            OR x.prm_nm_parametro = p.prm_nm_parametro
        )
    );


    -- PREVIEW
    IF @Preview = 1
    BEGIN

        SELECT *
        FROM @Dados
        ORDER BY cliente_destino;


        INSERT INTO tb_log_sync_parametros (
            cliente_origem,
            cliente_destino,
            prm_ds_chave,
            prm_nm_parametro,
            data_execucao,
            usuario_execucao,
            modo_preview,
            inserido
        )
        SELECT
            @ClienteOrigem,
            cliente_destino,
            prm_ds_chave,
            prm_nm_parametro,
            GETDATE(),
            @Usuario,
            1,
            0
        FROM @Dados;

        RETURN;

    END


    BEGIN TRAN


    INSERT INTO tb_parametros (
        prm_nm_parametro,
        prm_ds_parametro,
        prm_ds_chave,
        prm_ds_valor,
        prm_ds_placeholder,
        prm_ds_options,
        prm_ds_categoria,
        prm_ds_tipo,
        prm_in_ativo,
        prm_in_excluido,
        prm_cd_usuario_criacao,
        prm_dh_criacao,
        prm_cd_usuario_modificacao,
        prm_dh_modificacao,
        prm_cod_cliente,
        prm_cod_operacao
    )
    OUTPUT
        @ClienteOrigem,
        inserted.prm_cod_cliente,
        inserted.prm_ds_chave,
        inserted.prm_nm_parametro,
        GETDATE(),
        @Usuario,
        0,
        1
    INTO tb_log_sync_parametros (
        cliente_origem,
        cliente_destino,
        prm_ds_chave,
        prm_nm_parametro,
        data_execucao,
        usuario_execucao,
        modo_preview,
        inserido
    )
    SELECT
        prm_nm_parametro,
        prm_ds_parametro,
        prm_ds_chave,
        prm_ds_valor,
        prm_ds_placeholder,
        prm_ds_options,
        prm_ds_categoria,
        prm_ds_tipo,
        prm_in_ativo,
        0,
        prm_cd_usuario_criacao,
        GETDATE(),
        prm_cd_usuario_modificacao,
        GETDATE(),
        cliente_destino,
        prm_cod_operacao
    FROM @Dados;


    SELECT @@ROWCOUNT AS inseridos;

    COMMIT

END
GO
