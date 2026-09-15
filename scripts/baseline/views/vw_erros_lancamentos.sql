-- ============================================================
-- BASELINE: dbo.vw_erros_lancamentos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_erros_lancamentos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_erros_lancamentos]
AS
SELECT 
	l.lme_id
	,l.lme_cd_lancamento_manual
	,l.lme_nm_tipo
	,l.lme_nm_motorista
	,l.lme_cd_periodo
	,l.lme_cd_cliente_transportadora
	,l.lme_cd_operacao
	,l.lme_ds_erro
	,l.lme_dh_criacao
FROM 
	dbo.tb_lancamentos_manuais_erros l with(nolock)
 
GO
