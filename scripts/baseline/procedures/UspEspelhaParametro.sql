-- ============================================================
-- BASELINE: dbo.UspEspelhaParametro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspEspelhaParametro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspEspelhaParametro]
(
	@NomeBase varchar(100),
	@ClienteBase int,
	@Nome varchar(100),
	@Cliente int,
	@Valor varchar(100),
	@Chave varchar(100)
)

as begin

	select *
	into #parametro
	from tb_parametros
	where prm_nm_parametro = @NomeBase
		  and prm_cod_cliente = @ClienteBase

	if not exists(select prm_cd_parametro from #parametro)
	begin
		print ('Parâmetro base não encontrado.')
		print ('SELECT * FROM TB_PARAMETROS WHERE PRM_NM_PARAMETRO = ''' + @NomeBase + ''' and PRM_COD_CLIENTE = ' + cast(@ClienteBase as varchar(10)))
	end

	else
	begin
		declare @parametro int = (select top 1 prm_cd_parametro from tb_parametros where prm_cod_cliente = @Cliente and prm_nm_parametro = @Nome)
		if(@parametro is not null)
		begin
			print ('Parâmetro já existe na base de dados.')
			print ('SELECT * FROM TB_PARAMETROS WHERE PMR_CD_PARAMETRO = ' + cast(@parametro as varchar(10)))
		end


		else
		begin
			alter table #parametro drop column prm_cd_parametro
			update #parametro 
			set prm_cod_cliente = @Cliente, prm_ds_valor = @Valor, prm_nm_parametro = @Nome, prm_ds_parametro = @Nome, prm_ds_chave = @Chave
			insert into tb_parametros select * from #parametro
		end
	end

end
GO
