-- ============================================================
-- BASELINE: dbo.fn_VaidaAcessoTratativaInsucesso
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_VaidaAcessoTratativaInsucesso]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_VaidaAcessoTratativaInsucesso]
(

	@CodUsuario int,
	@Base varchar(150),
	@IdPacote bigint
)

returns TABLE
as RETURN
select 1 as Acesso

/*
retornar 1 apenas se 
O usuario tiver acesso à base conforme cadastro de service center
O pacote pertencer à base
O pacote pertencer à mesma transportadora do usuário

*/
GO
