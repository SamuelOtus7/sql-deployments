-- ============================================================
-- BASELINE: dbo.vw_dim_empresa
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_empresa]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_empresa] AS
SELECT DISTINCT
    m.mot_ds_empresa_cnpj AS CnpjEmpresa,
    m.mot_ds_empresa_razao_social AS RazaoSocial,
    m.mot_ds_empresa_nome_fantasia AS NomeFantasia
FROM dbo.tb_motorista m WITH (NOLOCK)
WHERE m.mot_ds_empresa_cnpj IS NOT NULL;
GO
