-- ============================================================
-- BASELINE: dbo.UspAtualizaIndices
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaIndices]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspAtualizaIndices] 
as
begin

	SET NOCOUNT ON;

	--Remove o indice atual
	DROP INDEX [idx_ml_rotas_data_atual] ON [dbo].[tb_ml_rotas]
	DROP INDEX [idx_ml_pacotes_data_atual] ON [dbo].[tb_ml_pacotes]

	--Cria os indices com a data atual
	declare @query varchar(300)
	set @query = '
					create index idx_ml_rotas_data_atual
					on tb_ml_rotas(DataReferencia)
					where DataReferencia = ''' + cast(cast(getdate() as date) as varchar(10)) + ''''
	exec(@query)

	set @query = '
					create index idx_ml_pacotes_data_atual
					on tb_ml_pacotes(DataReferencia)
					where DataReferencia = ''' + cast(cast(getdate() as date) as varchar(10)) + ''''
	exec(@query)


end
GO
