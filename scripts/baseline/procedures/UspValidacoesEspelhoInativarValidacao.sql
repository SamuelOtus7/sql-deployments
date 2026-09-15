-- ============================================================
-- BASELINE: dbo.UspValidacoesEspelhoInativarValidacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspValidacoesEspelhoInativarValidacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[UspValidacoesEspelhoInativarValidacao]    (
    @CodigoValidacao int,
	@CodigoUsuarioValidacao int
)
as
begin

	set nocount on

	update 
		tb_validacoes_espelho_resultados 
	set
		ver_cd_usuario_inativacao = @CodigoUsuarioValidacao
		,ver_dh_inativacao = getdate()
	where
		ver_cd_validacao_resultado = @CodigoValidacao


end
GO
