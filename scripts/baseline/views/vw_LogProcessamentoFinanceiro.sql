-- ============================================================
-- BASELINE: dbo.vw_LogProcessamentoFinanceiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_LogProcessamentoFinanceiro]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_LogProcessamentoFinanceiro] as

select 
   Id
  ,cli_ds_nome
  ,pgp_nm_periodo
  ,CodPeriodoPagamento
  ,DataLog
  ,MensagemLog
  ,Severidade
  ,Estado
  ,TempoExecucao
  ,idrota
  ,avulso
	,Case when idrota is not null then 'Edição da Rota'
		  when avulso is not null and  avulso <> 0 then 'Edição Avulsa'
		  when idrota is null and ( avulso is null or  avulso = 0 ) then 'Processamento Geral'
		  else 'Processamento não encontrado' end as Status_Processo
	,cast(case when DataLog >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else DataLog end as datetime)  as DataAtualizacaoControlePowerBI
	,COALESCE(
    CONVERT(VARCHAR(15), idrota),
    CONVERT(VARCHAR(15), avulso),
    'Geral'
) AS Identificador

from [LogProcessamentoFinanceiro] as a  with(nolock)
left join tb_pgto_periodo as b
on a.CodPeriodoPagamento = b.pgp_cd_periodo
left join tb_clientes as cli
on cli.cli_cd_codigo_cliente = b.pgp_cd_cliente
--order by id desc 
 

GO
