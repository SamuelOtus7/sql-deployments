-- ============================================================
-- BASELINE: dbo.usp_atualiza_parametros
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_atualiza_parametros]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_atualiza_parametros]
    @ClienteMolde int     = 7,
    @Categoria    sysname = N'APP',
    @Debug        bit     = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @LinhasInseridas int;

    ;WITH Molde AS
    (
        SELECT 
            p.prm_nm_parametro,
            p.prm_ds_parametro,
            p.prm_ds_chave,
            p.prm_ds_categoria,
            p.prm_ds_tipo,
            p.prm_cd_usuario_criacao,
            p.prm_dh_criacao,
            p.prm_cd_usuario_modificacao,
            p.prm_dh_modificacao
        FROM dbo.tb_parametros AS p
        WHERE p.prm_ds_categoria = @Categoria
          AND p.prm_cod_cliente  = @ClienteMolde
    ),
    Destino AS
    (
        SELECT 
            c.cli_cd_codigo_cliente
        FROM dbo.tb_clientes AS c
        WHERE c.cli_cd_codigo_cliente <> @ClienteMolde
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.tb_parametros AS p
              WHERE p.prm_cod_cliente  = c.cli_cd_codigo_cliente
                AND p.prm_ds_categoria = @Categoria
          )
    )
    INSERT INTO dbo.tb_parametros
    (
        prm_cod_cliente,
        prm_nm_parametro,
        prm_ds_parametro,
        prm_ds_chave,
        prm_ds_categoria,
        prm_ds_tipo,
        prm_cd_usuario_criacao,
        prm_dh_criacao,
        prm_cd_usuario_modificacao,
        prm_dh_modificacao
    )
    SELECT
        d.cli_cd_codigo_cliente,
        m.prm_nm_parametro,
        m.prm_ds_parametro,
        m.prm_ds_chave,
        m.prm_ds_categoria,
        m.prm_ds_tipo,
        m.prm_cd_usuario_criacao,
        m.prm_dh_criacao,
        m.prm_cd_usuario_modificacao,
        m.prm_dh_modificacao
    FROM Destino AS d
    CROSS JOIN Molde AS m
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.tb_parametros AS e
        WHERE e.prm_cod_cliente  = d.cli_cd_codigo_cliente
          AND e.prm_ds_categoria = m.prm_ds_categoria
          AND e.prm_ds_chave     = m.prm_ds_chave
    );

    SET @LinhasInseridas = @@ROWCOUNT;

    IF @Debug = 1
    BEGIN
        SELECT @LinhasInseridas AS linhas_inseridas;
    END;
END;
GO
