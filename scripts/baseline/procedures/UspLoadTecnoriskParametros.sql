-- ============================================================
-- BASELINE: dbo.UspLoadTecnoriskParametros
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadTecnoriskParametros]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspLoadTecnoriskParametros]
(
    @TenantId                  INT,         
    @CodigoClienteTecnorisk    INT,         
    @Usuario                   VARCHAR(30), 
    @Senha                     VARCHAR(30), 
    @DiasRetroativos           INT = 365,         
    @ConsiderarDiasRetroativos BIT = 1,        
    @StatusIntegracao          BIT = 1    
)
AS
BEGIN
    /*********************************************************
      Cria tabela temporária para armazenar os novos registros
    **********************************************************/
    CREATE TABLE #TecnoriskTemp
    (
        prm_nm_parametro        VARCHAR(100),
        prm_ds_parametro        VARCHAR(255),
        prm_ds_chave            VARCHAR(100),
        prm_ds_valor            VARCHAR(200),
        prm_ds_placeholder      VARCHAR(100),
        prm_ds_options          VARCHAR(MAX),
        prm_ds_categoria        VARCHAR(100),
        prm_ds_tipo             VARCHAR(100),
        prm_in_ativo            BIT,
        prm_in_excluido         BIT,
        prm_cd_usuario_criacao  INT,
        prm_dh_criacao          DATETIME,
        prm_cd_usuario_modificacao INT,
        prm_dh_modificacao      DATETIME,
        prm_cod_cliente         INT
    );

    /********************************************************************
      Insere os dados na #TecnoriskTemp com base nos parâmetros recebidos
    *********************************************************************/
    INSERT INTO #TecnoriskTemp
    (
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
        prm_cod_cliente
    )
    VALUES
    -- 1) Usuário Integração
    (
        'Usuário',
        'Usuário integração Tecnorisk',
        'usuario_tecnorisk',
        @Usuario,
        NULL,
        NULL,
        'Integração Tecnorisk',
        'string',
        1,
        0,
        4030,              -- Ajuste conforme necessidade
        GETDATE(),
        4030,              -- Ajuste conforme necessidade
        GETDATE(),
        @TenantId
    ),
    -- 2) Senha Integração
    (
        'Senha',
        'Senha integração Tecnorisk',
        'senha_tecnorisk',
        @Senha,
        NULL,
        NULL,
        'Integração Tecnorisk',
        'password',
        1,
        0,
        4030,
        GETDATE(),
        4030,
        GETDATE(),
        @TenantId
    ),
    -- 3) Habilitar Integração
    (
        'Habilitar Integração',
        'Habilitar a integração Tecnorisk',
        'habilitar_tecnorisk',
        CASE WHEN @StatusIntegracao = 1 THEN 'true' ELSE 'false' END,
        NULL,
        '[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]',
        'Integração Tecnorisk',
        'select',
        1,
        0,
        4030,
        GETDATE(),
        4030,
        GETDATE(),
        @TenantId
    ),
    -- 4) Dias Retroativos
    (
        'Dias Retorativos ',
        'Dias Retroativos a execução do Get de Fichas',
        'dias_retroativos_tecnorisk',
        CAST(@DiasRetroativos AS VARCHAR(10)), 
        NULL,
        NULL,
        'Integração Tecnorisk',
        'number',
        1,
        0,
        4030,
        GETDATE(),
        4030,
        GETDATE(),
        @TenantId
    ),
    -- 5) Código Cliente Target
    (
        'Código Cliente Target',
        'Parâmetros para detalhes das fichas',
        'usuario_tecnorisk_cod',
        CAST(@CodigoClienteTecnorisk AS VARCHAR(10)),
        NULL,
        NULL,
        'Integração Tecnorisk',
        'number',
        1,
        0,
        4030,
        GETDATE(),
        4030,
        GETDATE(),
        @TenantId
    ),
    -- 6) Considerar Dias Retorativos
    (
        'Considerar Dias Retorativos ',
        'Considerar Dias Retorativos ',
        'considerar_dias_retroativos_tecnorisk',
        CASE WHEN @ConsiderarDiasRetroativos = 1 THEN 'true' ELSE 'false' END,
        NULL,
        '[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]',
        'Integração Tecnorisk',
        'select',
        1,
        0,
        4030,
        GETDATE(),
        4030,
        GETDATE(),
        @TenantId
    );

    MERGE tb_parametros AS T
    USING #TecnoriskTemp AS S
        ON  T.prm_nm_parametro = S.prm_nm_parametro
        AND T.prm_cod_cliente   = S.prm_cod_cliente
    WHEN MATCHED THEN
        UPDATE
            SET T.prm_ds_valor             = S.prm_ds_valor,
                T.prm_dh_modificacao       = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT
        (
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
            prm_cod_cliente
        )
        VALUES
        (
            S.prm_nm_parametro,
            S.prm_ds_parametro,
            S.prm_ds_chave,
            S.prm_ds_valor,
            S.prm_ds_placeholder,
            S.prm_ds_options,
            S.prm_ds_categoria,
            S.prm_ds_tipo,
            S.prm_in_ativo,
            S.prm_in_excluido,
            S.prm_cd_usuario_criacao,
            S.prm_dh_criacao,
            S.prm_cd_usuario_modificacao,
            S.prm_dh_modificacao,
            S.prm_cod_cliente
        );
END;
GO
