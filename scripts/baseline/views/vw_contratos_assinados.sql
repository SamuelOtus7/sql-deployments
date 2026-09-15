-- ============================================================
-- BASELINE: dbo.vw_contratos_assinados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_contratos_assinados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_contratos_assinados]
as
select 
	a.cta_cd_contrato CodigoContrato
	,a.cta_cd_usuario CodigoUsuario
	,cli.cli_cd_codigo_cliente CodigoCliente
	,c.ctt_nm_contrato Contrato
	,c.ctt_cd_cliente Cliente
	,cli.cli_ds_logo_path LogoCliente
	,u.usr_nm_usuario Motorista
	,c.ctt_ds_texto TextoContrato
	,a.cta_ds_codigo_assinatura CodigoAssinatura
	,a.cta_ds_hash_assinatura HashAssinatura
from 
	tb_contratos c with(nolock)
	join tb_clientes cli with(nolock) on c.ctt_cd_cliente = cli.cli_cd_codigo_cliente
	join tb_contratos_assinados a with(nolock) on c.ctt_cd_contrato = a.cta_cd_contrato
	join tb_usuario u with(nolock) on a.cta_cd_usuario = u.usr_cd_usuario
where
	c.ctt_in_ativo = 1
	and c.ctt_in_excluido = 0
	and cli.cli_in_ativo = 1


GO
