-- ============================================================
-- BASELINE: dbo.vw_fiscal_dados_rotas_shopee_emissao_lote
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fiscal_dados_rotas_shopee_emissao_lote]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[vw_fiscal_dados_rotas_shopee_emissao_lote]
as
select
	c.cli_cd_codigo_cliente TenantId
	,r.IdTransportadora
	,r.TipoOperacao
	,case when r.NomeHub like '%xpt%' then 'XPT' else 'Hub' end TipoHub
	,r.CodigoRota
	,r.NomeRota
	,r.DataReferencia
	,r.NomeHub
	,r.TotalPacotes
	,isnull(e.NomeMotorista,r.Motorista) Motorista
	,r.TipoVeiculo NomeVeiculo
	,isnull(e.Placa,r.placa) Placa
	,case when isnull(r.DistanciaTotal, 1) < 1 then 1 else isnull(r.DistanciaTotal, 1) end DistanciaKM
	,f.bft_vl_frete ValorFrete
	,isnull(fila_stage.IdLote,fila.IdLote) IdLote
	,isnull(lote2.NomeLote,lote.NomeLote) NomeLote
	,'https://' + c.cli_ds_sub_dominio + '/fiscal/cte/detalhes-lote/' + cast(isnull(fila_stage.IdLote,fila.IdLote) as varchar) LinkLote
	,CAST(
		CASE
			WHEN ISNULL(r.TotalPacotes, 0) <= 0 THEN 0.00
			WHEN fila.IdLote IS NULL THEN 0.00
			ELSE ROUND(100.0 * ISNULL(em.QtdePacotesResolvidos, 0) / r.TotalPacotes, 2)
		END AS DECIMAL(5, 2)
	) PercentualEmissao
	,case when fila_stage.IdFilaEmissaoRota is not null then 'Pendente' else isnull(lst.lst_ds_label,'Não Emitido') end StatusLote
from
	tb_spe_rotas_v5 r with(nolock)
	left join tb_spe_rotas_edit e on r.CodigoRota = e.CodigoRota
								and r.IdTransportadora = e.IdTransportadora
	join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_shopee
									and c.cli_cd_codigo_cliente <> 7
	left join tb_lista l with(nolock) on c.cli_cd_codigo_cliente = l.lst_cd_cliente 
								and l.lst_nm_lista = 'Clientes transportadoras'
								and l.lst_ds_valor = 'shopee'
	left join tb_lista l2 with(nolock) on c.cli_cd_codigo_cliente = l2.lst_cd_cliente 
										and l2.lst_nm_lista = 'Operações Marketplace'
										and r.TipoOperacao = l2.lst_ds_valor
	left join tb_dra_tipo_veiculo v with(nolock) on r.TipoVeiculo = v.tvl_nm_tipo_veiculo
	left join tb_fin_base_frete_transportadora f with(nolock) on c.cli_cd_codigo_cliente = f.bft_cd_transportadora
															and r.NomeHub = f.bft_cd_service_center
															and v.tvl_cd_tipo_veiculo = f.bft_cd_tipo_veiculo
															and l.lst_cd_lista = f.bft_cd_codigo_cliente
															and l2.lst_cd_lista = f.bft_cd_operacao
															and case when isnull(r.DistanciaTotal, 1) < 1 then 1 else isnull(r.DistanciaTotal, 1) end between f.bft_vl_inicio_faixa and f.bft_vl_fim_faixa
															and r.DataReferencia between f.bft_data_inicio and isnull(f.bft_data_fim,cast(getdate() as date))
															and f.bft_nm_cidade is null
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_auto_fila_emissao_rota fila with(nolock) on c.cli_cd_codigo_cliente = fila.TenantId
																								and r.CodigoRota = fila.CodigoRota
																								and fila.CodigoPacote is null
																								and fila.Ambiente = 1
																								and fila.Excluido = 0
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_lista_fiscal lst with(nolock) on fila.IdStatus = lst.lst_cd_lista
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_lotes lote with(nolock) on fila.IdLote = lote.IdLote
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_auto_controle_emissao_rota em with(nolock) ON em.TenantId = c.cli_cd_codigo_cliente
																									AND em.CodigoRota = r.CodigoRota
																									AND em.IdLote = fila.IdLote
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_auto_fila_emissao_rota_stage fila_stage with(nolock) on c.cli_cd_codigo_cliente = fila_stage.TenantId
																								and r.CodigoRota = fila_stage.CodigoRota
																								and fila_stage.CodigoPacote is null
																								and fila_stage.Ambiente = 1
																								and fila_stage.Excluido = 0
																								and fila_stage.EnviadoFila = 0
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_lista_fiscal lst2 with(nolock) on fila_stage.IdStatus = lst2.lst_cd_lista
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_lotes lote2 with(nolock) on fila_stage.IdLote = lote2.IdLote
where
	r.Excluido = 0
	and r.NomeHub <> 'Aguardando informações da rota'
	and r.TipoOperacao in ('LM', 'FM')
	and (
		(r.TipoOperacao = 'FM' and r.NomeRota not like '%apoio%')
		or
		r.TipoOperacao = 'LM'
	)
	and case when r.NomeHub like '%xpt%' then 'XPT' else 'Hub' end = 'Hub'
	
GO
