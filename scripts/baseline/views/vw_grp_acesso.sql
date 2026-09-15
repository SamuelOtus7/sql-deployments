-- ============================================================
-- BASELINE: dbo.vw_grp_acesso
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_grp_acesso]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_grp_acesso] as 

select 
    e.gpa_cd_grupo_acesso as CodGrupoAcesso,
    e.gpa_nm_grupo_acesso as GrupoAcesso,
    d.act_nm_action as PermissaoAcao ,
    ctr_cd_controller_pai as PastaPai,
    ctr_cd_controller as PastaFilho,
    ctr_nm_controller as NomeMenu,
    ctr_nm_rota as Caminho,
    ctr_in_ativo as Ativo
     
from tb_controller as a

inner join tb_action_controller as b
on a.ctr_cd_controller = b.acc_cd_controller

inner join tb_action_grupo_acesso as c
on b.acc_cd_action_controller = c.aga_cd_action_controller

left join tb_action as d
on b.acc_cd_action = d.act_cd_action  

left join tb_grupo_acesso as e
on c.aga_cd_grupo_acesso = e.gpa_cd_grupo_acesso
-- inner join tb_action_grupo_acesso as d


-- where aga_cd_grupo_acesso = 19 
GO
