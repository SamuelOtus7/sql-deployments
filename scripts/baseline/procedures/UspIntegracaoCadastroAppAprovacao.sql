-- ============================================================
-- BASELINE: dbo.UspIntegracaoCadastroAppAprovacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspIntegracaoCadastroAppAprovacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspIntegracaoCadastroAppAprovacao]
(
  @id_cadastro INT,
  @chave_app VARCHAR(30)
)
AS
BEGIN

  DECLARE @email VARCHAR(100) = (SELECT ucp_ds_email FROM tb_usuario_cadastro_app WHERE ucp_cd_usuario_cadastro_app = @id_cadastro);
  DECLARE @cliente INT = (SELECT cli_cd_codigo_cliente FROM tb_clientes WHERE cli_ds_chave_app = @chave_app);

  IF NOT EXISTS (
    SELECT TOP 1 mau_cd_aprovacao
    FROM tb_ml_aprovacao_usuario
    WHERE mau_ds_email = @email
      AND mau_ds_status = 'Em análise'
      AND mau_cd_cliente = @cliente
  )
  BEGIN

    DECLARE @DriverId INT = 0;
    DECLARE @Nome VARCHAR(100) = (SELECT ucp_ds_nome FROM tb_usuario_cadastro_app WHERE ucp_cd_usuario_cadastro_app = @id_cadastro);

    DECLARE @cpf VARCHAR(100) = (
      SELECT dbo.fn_DocumentoValidoFormatado(ucp_ds_documento)
      FROM tb_usuario_cadastro_app
      WHERE ucp_cd_usuario_cadastro_app = @id_cadastro
    );

    IF @cpf IS NOT NULL
    BEGIN
      SET @DriverId = ISNULL(
        (
          SELECT M.IdMotorista
          FROM tb_ml_motoristas m WITH (NOLOCK)
          JOIN (
            SELECT IdTransportadora, CPF, MAX(IdMotorista) IdMotorista
            FROM tb_ml_motoristas WITH (NOLOCK)
            WHERE Ativo = 1
              AND CPF = REPLACE(REPLACE(REPLACE(@cpf, '.', ''), '-', ''), ' ', '')
            GROUP BY IdTransportadora, CPF
          ) m2 ON m.IdTransportadora = m2.IdTransportadora AND m.CPF = m2.CPF AND m.IdMotorista = m2.IdMotorista
          JOIN tb_clientes c WITH (NOLOCK) ON m.IdTransportadora = c.cli_id_logistics
          WHERE c.cli_cd_codigo_cliente <> 7
            AND c.cli_cd_codigo_cliente = @cliente
            AND m.CPF = REPLACE(REPLACE(REPLACE(@cpf, '.', ''), '-', ''), ' ', '')
        ),
        0
      );
    END
    ELSE
    BEGIN
      SET @DriverId = ISNULL(
        (
          SELECT M.IdMotorista
          FROM tb_ml_motoristas m WITH (NOLOCK)
          JOIN (
            SELECT IdTransportadora, CPF, MAX(IdMotorista) IdMotorista
            FROM tb_ml_motoristas WITH (NOLOCK)
            WHERE Ativo = 1
              AND Nome = @Nome
              AND Email = @email
            GROUP BY IdTransportadora, CPF
          ) m2 ON m.IdTransportadora = m2.IdTransportadora AND m.CPF = m2.CPF AND m.IdMotorista = m2.IdMotorista
          JOIN tb_clientes c WITH (NOLOCK) ON m.IdTransportadora = c.cli_id_logistics
          WHERE c.cli_cd_codigo_cliente <> 7
            AND c.cli_cd_codigo_cliente = @cliente
            AND m.Nome = @Nome
            AND m.Email = @email
        ),
        0
      );
    END

    INSERT INTO tb_ml_aprovacao_usuario (
      mau_ds_tipo_documento,
      mau_cd_logistics,
      mau_ds_documento,
      mau_nm_completo,
      mau_in_habilitado,
      mau_ds_email,
      mau_ds_telefone,
      mau_ds_status,
      mau_cd_usuario_aprovacao,
      mau_cd_cliente,
      mau_ds_site,
      mau_dh_aprovacao,
      mau_cd_usuario_gerado,
      mau_in_ativo,
      mau_in_excluido,
      mau_cd_usuario_criacao,
      mau_dh_criacao,
      mau_cd_usuario_modificacao,
      mau_dh_modificacao,
      mau_in_reside_area_risco,
      mau_ds_origem,
      mau_cd_tipo_contrato,
      mau_in_faturamento_motorista_app,
      mau_cd_responsavel_contrato,
      mau_ds_bases_cadastro,
      mau_ds_ajudante,
      mau_in_reativacao,
      mau_cd_usuario_reativacao
    )
    SELECT
      'CPF' AS mau_ds_tipo_documento,
      CASE WHEN clientes.cli_id_logistics > 0 THEN @DriverId ELSE 0 END AS mau_cd_logistics,
      ISNULL(cadastro.ucp_ds_documento, '') AS mau_ds_documento,
      ucp_ds_nome AS mau_nm_completo,
      1 AS mau_in_habilitado,
      ucp_ds_email AS mau_ds_email,
      ucp_ds_telefone AS mau_ds_telefone,
      'Em análise' AS mau_ds_status,
      NULL AS mau_cd_usuario_aprovacao,
      clientes.cli_cd_codigo_cliente,
      'MLB' AS mau_ds_site,
      NULL AS mau_dh_aprovacao,
      NULL AS mau_cd_usuario_gerado,
      1 AS mau_in_ativo,
      0 AS mau_in_excluido,
      4039 AS mau_cd_usuario_criacao,
      GETDATE() AS mau_dh_criacao,
      4039 AS mau_cd_usuario_modificacao,
      GETDATE() AS mau_dh_modificacao,
      NULL AS mau_in_reside_area_risco,
      'App' AS mau_ds_origem,
      NULL AS mau_cd_tipo_contrato,
      NULL AS mau_in_faturamento_motorista_app,
      NULL AS mau_cd_responsavel_contrato,
      cadastro.ucp_ds_base AS mau_ds_bases_cadastro,
      0 AS mau_ds_ajudante,
      0 AS mau_in_reativacao,
      NULL AS mau_cd_usuario_reativacao
    FROM tb_usuario_cadastro_app AS cadastro
    JOIN tb_clientes AS clientes ON cadastro.ucp_ds_parceiro_chave_app = clientes.cli_ds_chave_app
    LEFT JOIN tb_ml_aprovacao_usuario AS aprovacoes
      ON mau_ds_email = ucp_ds_email
      AND mau_cd_cliente = clientes.cli_cd_codigo_cliente
      AND mau_ds_status = 'Aprovado'
    LEFT JOIN tb_usuario AS users
      ON cadastro.ucp_ds_email = users.usr_ds_email
      AND clientes.cli_cd_codigo_cliente = users.cli_cd_codigo_cliente
    WHERE ucp_cd_usuario_cadastro_app = @id_cadastro
      AND aprovacoes.mau_cd_aprovacao IS NULL;
  END

END;
GO
