-- ============================================================
-- BASELINE: dbo.fn_TemPermissao
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_TemPermissao]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_TemPermissao](
@codController int,@codUsuario int)
returns bit
as
begin
     declare @total int

	 select @total = count(aga.aga_cd_grupo_acesso)
	 from tb_action_grupo_acesso aga
	 where
		  aga.aga_cd_grupo_acesso in (select uga.uga_cd_grupo_acesso
									  from tb_usuario_grupo_acesso uga
									  where
										  uga.uga_cd_usuario = @codUsuario) and
		  aga.aga_cd_action_controller in (select ac.acc_cd_action_controller
										   from tb_action_controller ac
										   where
												ac.acc_cd_controller = @codController and
												(ac.acc_cd_action = 29 or ac.acc_cd_action = 30) and
												 ac.acc_in_ativo = 1)

	RETURN CASE WHEN @total >= 1 THEN 1 ELSE 0 END
end
GO
