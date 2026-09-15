-- ============================================================
-- BASELINE: dbo.fn_check_user_access
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_check_user_access]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[fn_check_user_access]
(
	@CodUsuario int,
	@NomeAction varchar(30),
	@Controller varchar(250),
	@TipoModulo varchar(250)
)
returns table
as return
/*
declare
@CodUsuario int = 374,
	@NomeAction varchar(30) = 'GET',
	@Controller varchar(250) = '374',
	@TipoModulo varchar(250) = 'Sistema'

select * from fn_check_user_access(@CodUsuario, @NomeAction,@Controller,@TipoModulo)

*/

        select top 1 1 Verify 
		from vw_admin_acessos with(nolock)
		where Controller = @Controller
			  and (
					(
						CodUsuario = @CodUsuario 
						and Action = @NomeAction 
						and TipoModulo = @TipoModulo
					) or
				    (
						@NomeAction= 'GET' and 
						ctr_in_system = 1
					)
				)
				/*
				and (Controller <> 'DriverInvoiceRoute' or CodUsuario not in (
select distinct e.usr_cd_usuario
from tb_action_grupo_acesso a
	join tb_action_controller c on a.aga_cd_action_controller = c.acc_cd_action_controller
	join tb_grupo_acesso b on a.aga_cd_grupo_acesso = b.gpa_cd_grupo_acesso
	join tb_usuario_grupo_acesso d on b.gpa_cd_grupo_acesso = d.uga_cd_grupo_acesso
	join tb_usuario e on d.uga_cd_usuario = e.usr_cd_usuario
	left join (
				select distinct e.usr_cd_usuario
				from tb_action_grupo_acesso a
					join tb_action_controller c on a.aga_cd_action_controller = c.acc_cd_action_controller
					join tb_grupo_acesso b on a.aga_cd_grupo_acesso = b.gpa_cd_grupo_acesso
					join tb_usuario_grupo_acesso d on b.gpa_cd_grupo_acesso = d.uga_cd_grupo_acesso
					join tb_usuario e on d.uga_cd_usuario = e.usr_cd_usuario
				where cli_cd_codigo_cliente = 27
					  and b.gpa_cd_grupo_acesso <> 123
					  and c.acc_cd_controller = 658
	) as corretos
	on e.usr_cd_usuario = corretos.usr_cd_usuario
where cli_cd_codigo_cliente = 27
	  and b.gpa_cd_grupo_acesso = 123
	  and c.acc_cd_controller = 658
	  and corretos.usr_cd_usuario is null
	  and usr_in_plataforma <> 2
	  and e.usr_cd_usuario <> 9543
				))
*/
GO
