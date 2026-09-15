-- ============================================================
-- BASELINE: dbo.vw_contratos_assinados_eventos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_contratos_assinados_eventos]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_contratos_assinados_eventos]
as
select 
	a.cta_cd_contrato CodigoContrato
	,a.cta_cd_usuario CodigoUsuario
	,cli.cli_cd_codigo_cliente CodigoCliente
	,e.cte_ds_tipo Tipo
	,e.cte_ds_nome Nome
	,e.cte_ds_cpf Cpf
	,e.cte_dh_criacao DataAssinatura
	,e.cte_ds_ip IP
	,e.cte_ds_hash_assinatura HashValidacao
	,e.cte_link_assinatura Assinatura
	,e.cte_link_selfie Selfie
from 
	tb_contratos c with(nolock)
	join tb_clientes cli with(nolock) on c.ctt_cd_cliente = cli.cli_cd_codigo_cliente
	join tb_contratos_assinados a with(nolock) on c.ctt_cd_contrato = a.cta_cd_contrato
	join tb_contratos_assinados_eventos e with(nolock) on a.cta_cd_usuario = e.cte_cd_usuario and a.cta_cd_contrato = e.cte_cd_contrato
where
	c.ctt_in_ativo = 1
	and c.ctt_in_excluido = 0
	and cli.cli_in_ativo = 1
GO
