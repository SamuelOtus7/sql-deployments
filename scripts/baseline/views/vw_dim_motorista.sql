-- ============================================================
-- BASELINE: dbo.vw_dim_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_motorista]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_motorista] AS
SELECT
    m.mot_cd_usuario AS cd_motorista_usuario,
    m.mot_cd_motorista AS cd_motorista,
    m.mot_nm_motorista AS Motorista,
    m.mot_cpf AS CpfCnpj,
    m.mot_pag_nm_titular AS NomeTitular,
    m.mot_pag_cpf_titular AS CpfTitular,
    m.mot_pag_cnpj_titular AS CnpjTitular,
    ISNULL(BAN.lst_ds_valor, m.mot_pag_nm_banco) AS Banco,
    m.mot_pag_cd_agencia AS Agencia,
    m.mot_pag_cd_conta AS Conta,
    m.mot_pag_ds_tipo_conta AS TipoConta,
    TipoChavePix.lst_ds_label AS TipoChavePix,
    m.mot_ds_pix_key AS ChavePix,
    m.mot_ds_empresa_cnpj AS CnpjEmpresa,
    m.mot_ds_empresa_razao_social AS RazaoSocial,
    m.mot_ds_empresa_nome_fantasia AS NomeFantasia,
    m.mot_pag_cd_tipo_pagamento
FROM dbo.tb_motorista m WITH (NOLOCK)
LEFT JOIN dbo.tb_lista BAN ON BAN.lst_cd_lista = m.mot_cd_banco AND BAN.lst_nm_lista = 'Bancos'
LEFT JOIN dbo.tb_lista TipoChavePix ON m.mot_ds_pix_key_type = TipoChavePix.lst_ds_valor AND TipoChavePix.lst_nm_lista = 'Tipo Chave Pix';
GO
