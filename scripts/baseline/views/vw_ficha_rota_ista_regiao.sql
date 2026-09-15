-- ============================================================
-- BASELINE: dbo.vw_ficha_rota_ista_regiao
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ficha_rota_ista_regiao]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_ficha_rota_ista_regiao] as


select 
bfm_cd_transportadora
,bfm_cd_codigo_cliente
,bfm_nm_regiao 
from tb_fin_base_frete_motorista 
where bfm_nm_regiao is not null
GO
