-- ============================================================
-- BASELINE: dbo.vw_fin_lista_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_lista_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_fin_lista_motoristas]  as 

select 
     mtn_cd_pgto_periodo
	,mtn_cd_motorista_nfs
	,mtn_nome_motorista
	,isnull(mot_cd_matricula,0) as  mot_cd_matricula

from tb_pag_espelhos as a
inner join tb_motorista as b
on mtn_cd_motorista = mot_cd_usuario

where mtn_in_excluido  = 0 
GO
