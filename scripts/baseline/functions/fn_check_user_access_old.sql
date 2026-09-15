-- ============================================================
-- BASELINE: dbo.fn_check_user_access_old
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_check_user_access_old]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_check_user_access_old]
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
@CodUsuario int = 4037,
	@NomeAction varchar(30) = 'GET',
	@Controller varchar(250) = 'BaseFreteAdicionalMotorista',
	@TipoModulo varchar(250) = 'Sistema'
*/

        SELECT TOP 1 1 Verify FROM tb_usuario_grupo_acesso (nolock)
        INNER JOIN tb_action_grupo_acesso (nolock) ON tb_action_grupo_acesso.aga_cd_grupo_acesso = tb_usuario_grupo_acesso.uga_cd_grupo_acesso and tb_action_grupo_acesso.aga_in_ativo = 1
        INNER JOIN tb_action_controller (nolock) ON tb_action_grupo_acesso.aga_cd_action_controller = tb_action_controller.acc_cd_action_controller and tb_action_controller.acc_in_ativo = 1
        INNER JOIN tb_action (nolock) ON tb_action_controller.acc_cd_action = tb_action.act_cd_action and tb_action.act_in_ativo = 1
        INNER JOIN tb_controller (nolock) ON tb_action_controller.acc_cd_controller = tb_controller.ctr_cd_controller and tb_controller.ctr_in_ativo = 1
        where 
        (tb_usuario_grupo_acesso.uga_cd_usuario = @CodUsuario
        and tb_usuario_grupo_acesso.uga_in_ativo = 1
		and tb_usuario_grupo_acesso.uga_in_ativo = 1
        and tb_action.act_nm_action = @NomeAction
        and tb_controller.ctr_ds_modulo =  @TipoModulo
        and case 
				when @TipoModulo = 'Sistema' then tb_controller.ctr_nm_controller
				else cast(tb_controller.ctr_cd_controller as varchar(100)) 
			end = @Controller
        )
        or EXISTS (
            select 1 Verify from tb_controller (nolock)
                where 
                    ctr_nm_controller = @Controller
                    and ctr_in_system = 1
                    and @NomeAction= 'GET'
        )


GO
