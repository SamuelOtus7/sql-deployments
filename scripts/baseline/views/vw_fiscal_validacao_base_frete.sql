-- ============================================================
-- BASELINE: dbo.vw_fiscal_validacao_base_frete
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fiscal_validacao_base_frete]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_fiscal_validacao_base_frete]
as
select
	distinct
	'Shopee' Marketplace
	,c.cli_cd_codigo_cliente IdTenant
	,c.cli_ds_nome Cliente
	,r.TipoOperacao Operacao
	,r.NomeHub Hub
	,r.TipoVeiculo Veiculo
	,case 
		when b.bss_cd_base is null and bft_cd_base_frete_transportadora is null then 'Hub e Frete não cadastrados'
		when b.bss_cd_base is null then 'Hub não cadastrado'
		when f.bft_cd_base_frete_transportadora is null then 'Frete não cadastrado'
		else 'Ok'
	end Validacao
	,f.bft_vl_inicio_faixa InicioFaixa
	,f.bft_vl_fim_faixa FimFaixa
	,isnull(f.bft_vl_frete,0) ValorFrete
from
	tb_clientes c with(nolock)
	left join tb_lista l with(nolock) on c.cli_cd_codigo_cliente = l.lst_cd_cliente 
								and l.lst_nm_lista = 'Clientes transportadoras'
								and l.lst_ds_valor = 'shopee'
	join tb_spe_rotas_v5 r with(nolock) on c.cli_id_shopee = r.IdTransportadora
										and r.Excluido = 0
										and r.TipoOperacao in ('LM', 'FM')
										and r.NomeHub not in ('Informação não enviada pela Shopee', 'Aguardando informações da rota')
	left join tb_lista l2 with(nolock) on c.cli_cd_codigo_cliente = l2.lst_cd_cliente 
										and l2.lst_nm_lista = 'Operações Marketplace'
										and r.TipoOperacao = l2.lst_ds_valor
	left join tb_dra_tipo_veiculo v with(nolock) on r.TipoVeiculo = v.tvl_nm_tipo_veiculo
	left join tb_bases b with(nolock) on r.IdTransportadora = b.bss_cd_idtransportadora
										and (r.NomeHub = b.bss_ds_sigla or r.NomeHub = b.bss_ds_nome)
										and b.bss_in_excluido = 0
	left join tb_fin_base_frete_transportadora f with(nolock) on c.cli_cd_codigo_cliente = f.bft_cd_transportadora
															and r.NomeHub = f.bft_cd_service_center
															and v.tvl_cd_tipo_veiculo = f.bft_cd_tipo_veiculo
															and l.lst_cd_lista = f.bft_cd_codigo_cliente
															and l2.lst_cd_lista = f.bft_cd_operacao
															and case when isnull(r.DistanciaTotal, 1) < 1 then 1 else isnull(r.DistanciaTotal, 1) end between f.bft_vl_inicio_faixa and f.bft_vl_fim_faixa
															and f.bft_data_fim is null
															and f.bft_nm_cidade is null

where
	c.cli_in_ativo = 1
	and c.cli_id_shopee > 0
	and r.DataReferencia >= dateadd(day,-15,cast(getdate() as date))
	
GO
