-- ============================================================
-- BASELINE: dbo.vw_alertas_contas_a_pagar_motoristas_nao_cadastrados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_alertas_contas_a_pagar_motoristas_nao_cadastrados]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_alertas_contas_a_pagar_motoristas_nao_cadastrados]
as
select
	distinct
	per.pgp_cd_cliente IdTenant
	,per.pgp_cd_periodo CodigoPeriodo
	,r.NomeMotorista
	,cast(case when per.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else per.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
from
	tb_pgto_periodo per with(nolock)
	join tb_clientes cli with(nolock) on per.pgp_cd_cliente = cli.cli_cd_codigo_cliente
	join vw_rotas r with(nolock) on cli.cli_id_logistics = r.IdTransportadora 
										and r.DataReferencia between per.pgp_dt_inicio and per.pgp_dt_fim
													
where
	per.pgp_in_excluido = 0
	and per.pgp_dt_inicio >= '2025-03-01'
	and r.UsuarioDA is null
	
GO
