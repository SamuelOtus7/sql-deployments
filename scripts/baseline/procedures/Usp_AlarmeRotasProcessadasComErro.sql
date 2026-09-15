-- ============================================================
-- BASELINE: dbo.Usp_AlarmeRotasProcessadasComErro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeRotasProcessadasComErro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_AlarmeRotasProcessadasComErro]

as

	set nocount on

	drop table if exists #aux
	
	select
		cmt_cd_coleta,
		cmt_cd_transportadora,
		cmt_cd_servicecenter
		into #aux
	from
		db_Irisys_Json.dbo.tb_ml_coleta_totalizador with(nolocK)
	where 
		cmt_in_erro = 1
		and cmt_dh_escrita >= cast(getdate() as date)


	if exists (select * from #aux)
	begin
		declare @mensagem varchar(2000)
		
	
	
		set @mensagem = '*[Rotas com erro]*\n'
		+ 'Existem rotas que foram processadas com erro. Verifique a tabela db_Irisys_Json.dbo.tb_ml_coleta_totalizador'

	exec Usp_SendSlackMessage @mensagem
	--print @mensagem

	end

GO
