-- ============================================================
-- BASELINE: dbo.vw_fiscal_dados_rotas_shopee_lh
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fiscal_dados_rotas_shopee_lh]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_fiscal_dados_rotas_shopee_lh]
as
select
	c.cli_cd_codigo_cliente TenantId
	,r.CodigoRota
	,r.DataReferencia
	,r.NomeHub
	,r.StationDestino HubDestino
	,r.TotalPacotes
	,r.Motorista
	,r.TipoVeiculo NomeVeiculo
	,r.placa Placa
	,isnull(r.DistanciaTotal,0) DistanciaKM
	,f.bft_vl_frete ValorFrete
	,lote.NomeLote
	,isnull(lst.lst_ds_label,'Não Emitido') StatusLote  
	,case when lote.IdLote is not null 
		then 'https://' + c.cli_ds_sub_dominio + '/fiscal/cte/detalhes-lote/' + cast(lote.IdLote as varchar) 
		else 'https://' + c.cli_ds_sub_dominio + '/fiscal/cte/form?form=line-haul-shopee'
	end LinkLote  
from
	tb_spe_rotas_v5 r with(nolock)
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
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_lotes lote with(nolock) on c.cli_cd_codigo_cliente = lote.TenantId
																			and r.CodigoRota = lote.CodigoPesquisaPacotes
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_lista_fiscal lst with(nolock) on lote.StatusLote = lst.lst_cd_lista  
where
	r.Excluido = 0
	and r.NomeHub <> 'Aguardando informações da rota'
	and r.TipoOperacao = 'LH'

	--considera a partir da ultima quinzena fechada
	and r.DataReferencia >= CASE
								WHEN DAY(GETDATE()) <= 15
									THEN DATEADD(MONTH, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 16))
								ELSE
									DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)
							END
	
GO
