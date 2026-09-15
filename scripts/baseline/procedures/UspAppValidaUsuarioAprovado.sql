-- ============================================================
-- BASELINE: dbo.UspAppValidaUsuarioAprovado
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAppValidaUsuarioAprovado]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAppValidaUsuarioAprovado]
(
	@Email varchar(100)
)
as

--Excluir usuário caso nbão tenha rota nos últimos 45 dias
declare @CodUsuario int,
	    @NomeUsuario varchar(150),
	    @CodCliente int

select @CodUsuario = usr_cd_usuario,
	   @NomeUsuario = usr_nm_usuario,
	   @CodCliente = cli_cd_codigo_cliente 
from tb_usuario 
where usr_ds_email = @Email 
	  and usr_in_ativo = 1
/*
declare @UltimaRotaML date = (select max(DataReferencia) as DataReferencia from tb_ml_rotas as rotas where NomeMotorista = @NomeUsuario)
declare @UltimaRotaSpe date = (
								select max(DataReferencia) as DataReferencia 
								from tb_spe_rotas_v4 as rotas 
									join tb_spe_motoristas as motoristas on rotas.IdMotorista = motoristas.IdMotorista 
								where motoristas.NomeMotorista = @NomeUsuario
							  )

*/

if @CodUsuario is null
begin
	select 'Usuário validado' as retorno
end
else
begin
 select CAST(@CodCliente AS VARCHAR) as retorno
	--select 'O usuário cadastrado já existe na base de dados.' as retorno
end

GO
