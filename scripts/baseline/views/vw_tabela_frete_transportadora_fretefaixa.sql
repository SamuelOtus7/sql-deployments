-- ============================================================
-- BASELINE: dbo.vw_tabela_frete_transportadora_fretefaixa
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tabela_frete_transportadora_fretefaixa]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_tabela_frete_transportadora_fretefaixa]
as
select 
	* 
From 
	vw_tabela_frete_transportadora 
where 
	ServiceCenter is null 
	and Estado is null 
	and InicioFaixa is not null 
	and FimFaixa is not null
GO
