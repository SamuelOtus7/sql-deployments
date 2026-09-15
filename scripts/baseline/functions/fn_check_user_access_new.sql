-- ============================================================
-- BASELINE: dbo.fn_check_user_access_new
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_check_user_access_new]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_check_user_access_new]
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

        select top 1 1 Verify 
		from vw_admin_acessos 
		where (
				CodUsuario = @CodUsuario 
				and Action = @NomeAction 
				and Controller = @Controller
				and TipoModulo = @TipoModulo
			  )
			or EXISTS (
				select 1 Verify from tb_controller (nolock)
					where 
						ctr_nm_controller = @Controller
						and ctr_in_system = 1
						and @NomeAction= 'GET'
			)


GO
