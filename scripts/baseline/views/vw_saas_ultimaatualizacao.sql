-- ============================================================
-- BASELINE: dbo.vw_saas_ultimaatualizacao
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_ultimaatualizacao]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_saas_ultimaatualizacao]
as
--select max(DataHoraEntrega) UltimaAtualizacao  from tb_ml_pacotes with(nolock) where DataReferencia = cast(getdate() as date) and Excluido = 0 
select max(DataAtualizacao) UltimaAtualizacao  from tb_ml_rotas with(nolock) where DataReferencia = cast(getdate() as date) and Excluido = 0 and StatusRota <> 'planned' 
GO
