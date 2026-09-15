-- ============================================================
-- BASELINE: dbo.vw_dim_espelhos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dim_espelhos]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_dim_espelhos] AS
SELECT
    mtn_cd_motorista_nfs AS cd_espelho,
    mtn_cd_pgto_periodo AS cd_periodo,
    mtn_cd_motorista AS cd_motorista,
    mtn_cd_status AS Status,
    mtn_dt_prazo_contestacao AS DataContestacao,
    mtn_vl_nfs AS ValorNFS,
    mtn_ds_link_nfs AS LinkNFS,
    mtn_vl_imposto AS ValorImposto,
    mtn_vl_liquido AS ValorLiquido,
    mtn_vl_desconto AS ValorDesconto,
    mtn_cod_cliente AS CodigoCliente,
    mtn_ds_Banco AS Banco,
    mtn_ds_NomeTitular AS NomeTitular,
    mtn_ds_CpfTitular AS CpfTitular,
    mtn_ds_CnpjTitular AS CnpjTitular,
    mtn_ds_Agencia AS Agencia,
    mtn_ds_Conta AS Conta,
    mtn_ds_TipoConta AS TipoConta,
    mtn_ds_TipoChavePix AS TipoChavePix,
    mtn_ds_ChavePix AS ChavePix,
    mtn_ds_CnpjEmpresa AS CnpjEmpresa,
    mtn_ds_RazaoSocial AS RazaoSocial,
    mtn_ds_NomeFantasia AS NomeFantasia
FROM dbo.tb_pag_espelhos WITH (NOLOCK)
WHERE mtn_in_excluido = 0;
GO
