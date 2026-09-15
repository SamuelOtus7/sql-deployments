-- ============================================================
-- BASELINE: dbo.fn_get_dados_dashboard
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_dados_dashboard]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_get_dados_dashboard]
(
	@TipoDashboard varchar(100),
	@Cliente int,
	@Usuario int
)

-- Data: 10/12/2024
-- Autor: Joice Souza
-- Descrição: Função criada para ser chamada pela tela "Alarmes".

returns table
as return

select alarmes.Id as IdAlarme,
	   alarmes.Label as LabelAlarme,
	   alarmes.Icone as IconeAlarme,
	   alarmes.CorIcone as CorIconeAlarme,
	   alarmes.Ordem as OrdemAlarme,
	   alarmes.IconePadrao as IconePadraoAlarme,
	   case when alarmes.Descricao is null then Label else alarmes.Descricao end as DescricaoAlarme,
	   grupos.Nome as Labelgrupo,
	   grupos.Icone as Iconegrupo,
	   grupos.CorIcone as CorIconegrupo,
	   grupos.Ordem as Ordemgrupo
from tb_alarmes as alarmes
	join tb_grupos_alarmes as grupos
	on alarmes.IdGrupo = grupos.Id
	join tb_cliente_alarmes as permissoes
	on permissoes.id_alarme = alarmes.id 
	and isnull(permissoes.tenant,@Cliente) = @Cliente
where alarmes.Status = 1
	  and grupos.Tipo = @TipoDashboard

GO
