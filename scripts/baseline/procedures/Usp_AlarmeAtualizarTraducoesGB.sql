-- ============================================================
-- BASELINE: dbo.Usp_AlarmeAtualizarTraducoesGB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeAtualizarTraducoesGB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeAtualizarTraducoesGB]

as

	--set nocount on

	drop table if exists #traducoes
	create table #traducoes (
		tds_nm_tabela varchar(60) not null,
		tds_nm_campo varchar(60) not null,
		qtde_traducoes int not null,
		qtde_tabela int null,
		script varchar(1000) not null
	)

	insert into #traducoes
	select
		tds_nm_tabela, 
		tds_nm_campo, 
		count(1) qtde,
		null qtde_tabela,
		'(select count(distinct ' + tds_nm_campo + ') from ' + tds_nm_tabela + ' with(nolock) where isnull(' + tds_nm_campo + ','''') <> '''')' script
	from
		tb_ml_traducoes with(nolock)
	group by
		tds_nm_tabela, tds_nm_campo

	while exists (select 1 from #traducoes where qtde_tabela is null)
	begin
		declare @script varchar(1000)
		declare @tabela varchar(60)
		declare @campo varchar(60)
		declare @qtde_tabela int

		select
			top 1
			@script = script,
			@tabela = tds_nm_tabela,
			@campo = tds_nm_campo
		from
			#traducoes
		 where 
			qtde_tabela is null

		exec('update #traducoes set qtde_tabela=isnull(' + @script + ',0) where tds_nm_tabela=''' + @tabela + ''' and tds_nm_campo = ''' + @campo + '''')

	end

	if exists (select * from #traducoes where qtde_traducoes < qtde_tabela)
	begin
		declare @traducoes varchar(1000)
		declare @mensagem varchar(2000)
		Select @traducoes = SUBSTRING( 
		( 
			 SELECT + CHAR(10) + tds_nm_tabela + ': ' + tds_nm_campo AS 'data()'
				 FROM #traducoes 
				  where qtde_traducoes < qtde_tabela
				 FOR XML PATH('') 
			 
		), 2 , 9999)
		print @traducoes

	
	
	set @mensagem = '*[Atualizar Traduções]*' + CHAR(10)
		+ 'Os campos campos abaixo não contemplatam todas as opções existentes na tabela e campo correspondente: ' + CHAR(10) + CHAR(10)
		+ @traducoes


		RAISERROR(@mensagem, 16, 1);


end

GO
