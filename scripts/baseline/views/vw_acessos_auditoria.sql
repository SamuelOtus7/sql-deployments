-- ============================================================
-- BASELINE: dbo.vw_acessos_auditoria
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_acessos_auditoria]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_acessos_auditoria]

as

select distinct 
		a.cod_usuario as CodigoUsuario,
		a.Usuario,
		a.Nome,
		a.Email,
		STRING_AGG(d.nome,CHAR(13)) as GruposAcesso,
		h.label as Item,
		h.router as Caminho,
		e.nome as Acao,
		'Tela' as Tipo
from PortalSiimBI..tb_pf_usuarios a
	join PortalSiimBI..tb_pf_grupos_usuarios b on a.cod_usuario = b.cod_usuario
	join PortalSiimBI..tb_pf_grupo_actions c on b.cod_grupo_acesso = c.cod_grupo_acesso
	join PortalSiimBI..tb_pf_grupos_acesso d on c.cod_grupo_acesso = d.cod_grupo_acesso
	join PortalSiimBI..tb_pf_actions e on c.cod_action = e.cod_action
	join PortalSiimBI..tb_pf_controllers h on c.cod_controller =h.cod_controller
where a.status = 'Ativo'
		and h.cod_modulo <> 2  -- Sistema
group by a.cod_usuario,
			a.Usuario,
			a.Nome,
			a.Email,
			h.label,
			h.router,
			e.nome
union all

select distinct 
		a.cod_usuario as CodigoUsuario,
		a.Usuario,
		a.Nome,
		a.Email,
		STRING_AGG(d.nome,CHAR(13)) as GruposAcesso,
		g.nome as Item,
		g.caminho as Caminho,
		'Get' as Acao,
		'Relatório' as Tipo
from PortalSiimBI..tb_pf_usuarios a
	join PortalSiimBI..tb_pf_grupos_usuarios b on a.cod_usuario = b.cod_usuario
	join PortalSiimBI..tb_pf_grupos_acesso d on b.cod_grupo_acesso = d.cod_grupo_acesso
	join PortalSiimBI..tb_pf_grupos_permissoes_relatorios f on b.cod_grupo_acesso = f.cod_grupo
	join PortalSiimBI..tb_pf_relatorios g on f.id_report = g.id_report
where a.status = 'Ativo'
		and g.cod_status <> 2 -- Inativos
		and g.caminho is not null -- Pastas
group by a.cod_usuario,
		 a.Usuario,
		 a.Nome,
		 a.Email,
		 g.nome,
		 g.caminho
		 
GO
