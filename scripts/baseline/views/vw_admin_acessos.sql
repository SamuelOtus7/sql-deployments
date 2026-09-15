-- ============================================================
-- BASELINE: dbo.vw_admin_acessos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_admin_acessos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_admin_acessos]
with SchemaBinding
as
SELECT ga.uga_cd_usuario as CodUsuario,
	   a.act_nm_action as Action,
	   c.ctr_ds_modulo as TipoModulo,
	   case 
			when c.ctr_ds_modulo = 'Sistema' then c.ctr_nm_controller
			else cast(c.ctr_cd_controller as varchar(100)) 
	   end as Controller,
	   ctr_in_system,
	   COUNT_BIG(*) as Qtde
FROM dbo.tb_usuario_grupo_acesso ga
        INNER JOIN dbo.tb_action_grupo_acesso aa ON aa.aga_cd_grupo_acesso = ga.uga_cd_grupo_acesso and aa.aga_in_ativo = 1
        INNER JOIN dbo.tb_action_controller ac ON aa.aga_cd_action_controller = ac.acc_cd_action_controller and ac.acc_in_ativo = 1
        INNER JOIN dbo.tb_action a ON ac.acc_cd_action = a.act_cd_action and a.act_in_ativo = 1
        INNER JOIN dbo.tb_controller c ON ac.acc_cd_controller = c.ctr_cd_controller and c.ctr_in_ativo = 1
where ga.uga_in_ativo = 1
	  and ( c.ctr_in_system = 0 or a.act_nm_action <> 'GET')
group by ga.uga_cd_usuario,
		   a.act_nm_action,
		   c.ctr_ds_modulo,
		   case 
				when c.ctr_ds_modulo = 'Sistema' then c.ctr_nm_controller
				else cast(c.ctr_cd_controller as varchar(100)) 
		   end,
		   ctr_in_system

union all

select 0 as CodUsuario,
	   'Get' as Action,
	   'Publico' as TipoModulo,
	   case 
			when c.ctr_ds_modulo = 'Sistema' then c.ctr_nm_controller
			else cast(c.ctr_cd_controller as varchar(100)) 
	   end as Controller,
	   ctr_in_system,
	   COUNT_BIG(*) as Qtde	   
from dbo.tb_controller c
where ctr_in_system = 1
group by case 
			when c.ctr_ds_modulo = 'Sistema' then c.ctr_nm_controller
			else cast(c.ctr_cd_controller as varchar(100)) 
	     end,
	     ctr_in_system
GO
