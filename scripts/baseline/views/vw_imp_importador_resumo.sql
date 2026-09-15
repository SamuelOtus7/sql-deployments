-- ============================================================
-- BASELINE: dbo.vw_imp_importador_resumo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_imp_importador_resumo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_imp_importador_resumo]
AS
SELECT
    imp.imp_cd_importador,
    imp.cli_cd_codigo_cliente,
    cli.cli_ds_nome                AS nome_cliente,
    imp.imp_ds_nome,
    imp.imp_ds_descricao,
    grp.grp_cd_grupo,
    grp.grp_ds_nome                AS nome_grupo,
    imp.imp_ds_nome_script,
    imp.imp_in_script_disponivel,
    imp.imp_ds_nome_arquivo_modelo,
    imp.imp_ds_caminho_arquivo_modelo,
    imp.imp_ds_caminho_pasta_destino,
    imp.imp_in_ativo,
    ultimo.ilg_cd_log               AS ultima_importacao_log_id,
    ultimo.ilg_dh_inicio             AS ultima_importacao_data,
    ultimo.ist_cd_status              AS ultimo_status_id,
    ist.ist_ds_codigo                  AS ultimo_status_codigo,
    ist.ist_ds_descricao               AS ultimo_status_descricao,
    usr.usr_nm_usuario                  AS ultimo_usuario_nome
FROM dbo.tb_imp_importador imp
JOIN dbo.tb_imp_grupo grp
    ON grp.grp_cd_grupo = imp.grp_cd_grupo
JOIN dbo.tb_clientes cli
    ON cli.cli_cd_codigo_cliente = imp.cli_cd_codigo_cliente
OUTER APPLY (
    SELECT TOP (1) l.*
    FROM dbo.tb_imp_log l
    WHERE l.imp_cd_importador = imp.imp_cd_importador
    ORDER BY l.ilg_dh_inicio DESC
) AS ultimo
LEFT JOIN dbo.tb_imp_status ist
    ON ist.ist_cd_status = ultimo.ist_cd_status
LEFT JOIN dbo.tb_usuario usr
    ON usr.usr_cd_usuario = ultimo.usr_cd_usuario;
GO
