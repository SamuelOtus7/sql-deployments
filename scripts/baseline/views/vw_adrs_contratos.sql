-- ============================================================
-- BASELINE: dbo.vw_adrs_contratos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_adrs_contratos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_adrs_contratos] as 

select 
	ttc_cd_cliente CLienteId
	,ttc_cd_tipo_contrato
	,ttc_nm_tipo
	,ttc_in_ativo	
	,ttc_in_excluido
	,1 Qtd
  
from tb_tipo_contrato
GO
