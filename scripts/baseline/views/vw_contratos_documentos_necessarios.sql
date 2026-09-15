-- ============================================================
-- BASELINE: dbo.vw_contratos_documentos_necessarios
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_contratos_documentos_necessarios]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_contratos_documentos_necessarios]
as 
select contratos.ctn_cd_contrato_tipo_contrato * 100000 + users.usr_cd_usuario as cdn_cd_contrato_documento_necessario,
	   contratos.ctn_cd_contrato as cdn_cd_contrato,
	   users.cli_cd_codigo_cliente as cdn_cd_cliente,
	   'Assinatura' as cdn_nm_documento
from tb_usuario as users
	join tb_contratos_tipo_contrato as contratos on users.usr_cd_tipo_contrato = contratos.ctn_cd_tipo_contrato
	join tb_contratos as cad on contratos.ctn_cd_contrato = cad.ctt_cd_contrato and users.cli_cd_codigo_cliente = cad.ctt_cd_cliente
where cad.ctt_in_ativo = 1 and cad.ctt_in_excluido = 0

union all

select contratos.ctn_cd_contrato_tipo_contrato * 100000 + users.usr_cd_usuario as cdn_cd_contrato_documento_necessario,
	   contratos.ctn_cd_contrato as cdn_cd_contrato,
	   users.cli_cd_codigo_cliente as cdn_cd_cliente,
	   'Selfie' as cdn_nm_documento
from tb_usuario as users
	join tb_contratos_tipo_contrato as contratos on users.usr_cd_tipo_contrato = contratos.ctn_cd_tipo_contrato
	join tb_contratos as cad on contratos.ctn_cd_contrato = cad.ctt_cd_contrato and users.cli_cd_codigo_cliente = cad.ctt_cd_cliente
where cad.ctt_in_ativo = 1 and cad.ctt_in_excluido = 0

GO
