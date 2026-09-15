-- ============================================================
-- BASELINE: dbo.UspCriaParametro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspCriaParametro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[UspCriaParametro]
(
	@Nome varchar(100),
	@Chave varchar(100),
	@Valor varchar(100),
	@Categoria varchar(100),
	@tipo varchar(100),
	@Cliente varchar(100)
)

as begin

	declare @parametro int = (select top 1 prm_cd_parametro from tb_parametros where prm_cod_cliente = @Cliente and (prm_nm_parametro = @Nome or prm_ds_chave = @Chave))
	if(@parametro is not null)
	begin
		print ('Parâmetro já existe na base de dados.')
		print ('SELECT * FROM TB_PARAMETROS WHERE PMR_CD_PARAMETRO = ' + cast(@parametro as varchar(10)))
	end


	else
	begin
		insert into tb_parametros
		values (
			@Nome,
			@Nome,
			@Chave,
			@Valor,
			null,
			null,
			@Categoria,
			@tipo,
			1,
			0,
			7,
			getdate(),
			7,
			getdate(),
			@Cliente
		)
	end

end
GO
