-- ============================================================
-- BASELINE: dbo.UspMergeAudKmRotaUsoDevido
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMergeAudKmRotaUsoDevido]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspMergeAudKmRotaUsoDevido]
    @akr_cd_cliente        INT,
    @akr_id_rota           BIGINT,
    @akr_in_uso_devido     BIT,
    @akr_cd_usuario_edicao INT,
    @akr_nm_usuario_edicao NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF @akr_cd_cliente IS NULL
       OR @akr_id_rota IS NULL
       OR @akr_in_uso_devido IS NULL
       OR @akr_cd_usuario_edicao IS NULL
       OR @akr_nm_usuario_edicao IS NULL
       OR LTRIM(RTRIM(@akr_nm_usuario_edicao)) = N''
    BEGIN
        RAISERROR(N'Parâmetros obrigatórios não informados.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tb_clientes AS c WITH (NOLOCK)
        WHERE c.cli_cd_codigo_cliente = @akr_cd_cliente
    )
    BEGIN
        RAISERROR(N'Cliente %d não encontrado em dbo.tb_clientes.', 16, 1, @akr_cd_cliente);
        RETURN;
    END;

    DECLARE @dh_edicao DATETIME2(3) = SYSDATETIME();

    MERGE dbo.tb_aud_km_rota_uso_devido WITH (HOLDLOCK) AS tgt
    USING (
        SELECT
            @akr_cd_cliente        AS akr_cd_cliente,
            @akr_id_rota           AS akr_id_rota,
            @akr_in_uso_devido     AS akr_in_uso_devido,
            @akr_cd_usuario_edicao AS akr_cd_usuario_edicao,
            @akr_nm_usuario_edicao AS akr_nm_usuario_edicao,
            @dh_edicao             AS akr_dh_edicao
    ) AS src
        ON tgt.akr_cd_cliente = src.akr_cd_cliente
       AND tgt.akr_id_rota = src.akr_id_rota
    WHEN MATCHED AND (
            tgt.akr_in_uso_devido <> src.akr_in_uso_devido
         OR tgt.akr_cd_usuario_edicao <> src.akr_cd_usuario_edicao
         OR tgt.akr_nm_usuario_edicao <> src.akr_nm_usuario_edicao
    ) THEN
        UPDATE SET
            tgt.akr_in_uso_devido     = src.akr_in_uso_devido,
            tgt.akr_cd_usuario_edicao = src.akr_cd_usuario_edicao,
            tgt.akr_nm_usuario_edicao = src.akr_nm_usuario_edicao,
            tgt.akr_dh_edicao         = src.akr_dh_edicao
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            akr_cd_cliente,
            akr_id_rota,
            akr_in_uso_devido,
            akr_cd_usuario_edicao,
            akr_nm_usuario_edicao,
            akr_dh_edicao
        )
        VALUES (
            src.akr_cd_cliente,
            src.akr_id_rota,
            src.akr_in_uso_devido,
            src.akr_cd_usuario_edicao,
            src.akr_nm_usuario_edicao,
            src.akr_dh_edicao
        );

    SELECT
        a.akr_cd_aud_km_rota_uso_devido,
        a.akr_cd_cliente,
        a.akr_id_rota,
        a.akr_in_uso_devido,
        a.akr_cd_usuario_edicao,
        a.akr_nm_usuario_edicao,
        a.akr_dh_edicao
    FROM dbo.tb_aud_km_rota_uso_devido AS a
    WHERE a.akr_cd_cliente = @akr_cd_cliente
      AND a.akr_id_rota = @akr_id_rota;
END;
GO
