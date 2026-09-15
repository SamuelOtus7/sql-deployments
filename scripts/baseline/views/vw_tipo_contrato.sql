-- ============================================================
-- BASELINE: dbo.vw_tipo_contrato
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tipo_contrato]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_tipo_contrato]
as
select
	ttc_cd_tipo_contrato,
	ttc_nm_tipo,
	ttc_cd_cliente
from
	tb_tipo_contrato
where
	ttc_in_excluido = 0
	and ttc_in_ativo = 1
GO
