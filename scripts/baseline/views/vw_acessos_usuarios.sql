-- ============================================================
-- BASELINE: dbo.vw_acessos_usuarios
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_acessos_usuarios]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_acessos_usuarios]
as
select
	u.usr_cd_usuario CodigoUsuario,
	u.usr_nm_usuario NomeUsuario,
	u.usr_ds_email EmailUsuario,
	cl.cli_ds_nome as Cliente,
	g.gpa_nm_grupo_acesso Grupo,
	a.act_nm_action Acao,
	c.ctr_cd_controller CodigoTela,
	c.ctr_nm_controller Tela,
	c.ctr_cd_controller_pai CodigoPai
from
	tb_usuario u
	join tb_usuario_grupo_acesso ug on u.usr_cd_usuario = ug.uga_cd_usuario
	join tb_grupo_acesso g on ug.uga_cd_grupo_acesso = g.gpa_cd_grupo_acesso
	join tb_action_grupo_acesso aga on g.gpa_cd_grupo_acesso = aga.aga_cd_grupo_acesso
	join tb_action_controller ac on aga.aga_cd_action_controller = ac.acc_cd_action_controller
	join tb_action a on ac.acc_cd_action = a.act_cd_action
	join tb_controller c on ac.acc_cd_controller = c.ctr_cd_controller
	join tb_clientes cl on u.cli_cd_codigo_cliente = cl.cli_cd_codigo_cliente
GO
