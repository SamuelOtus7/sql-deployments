-- ============================================================
-- BASELINE: dbo.vw_grp_acesso_usuario
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_grp_acesso_usuario]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_grp_acesso_usuario] as 

select
     cli_cd_codigo_cliente as CodCliente
    ,uga_cd_grupo_acesso as CodGrupoAcesso
    ,gp.gpa_nm_grupo_acesso as GrupoAcesso
    ,uga_cd_usuario as CodUsuario
    ,b.usr_nm_usuario as NomeUsuario
    ,b.usr_ds_email as Email
    ,uga_in_ativo as Ativo

--  into #base

-- delete a 
from  [dbo].[tb_usuario_grupo_acesso] as a

inner join tb_usuario as b
on a.uga_cd_usuario = b.usr_cd_usuario

inner join tb_grupo_acesso as gp
on a.uga_cd_grupo_acesso = gp.gpa_cd_grupo_acesso


where 1=1
GO
