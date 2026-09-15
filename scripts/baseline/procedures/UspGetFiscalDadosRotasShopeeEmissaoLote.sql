-- ============================================================
-- BASELINE: dbo.UspGetFiscalDadosRotasShopeeEmissaoLote
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetFiscalDadosRotasShopeeEmissaoLote]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --=============================================
 --Author:		Saulo Barros
 --Create date: 18/08/2026
 --Description:	
 --=============================================
CREATE PROCEDURE [dbo].[UspGetFiscalDadosRotasShopeeEmissaoLote] (
	@IdTenant int
	,@Marketplace varchar(30)
	,@Operacao varchar(2)
	,@TipoHub varchar(3)
	,@DataInicio date
	,@DataFim date
	,@Base varchar(max) = null
	,@Motoristas varchar(max) = null
	,@StatusEmissao varchar(max) = null
	,@CodigoRota varchar(50) = null
)	
AS
BEGIN

	SET NOCOUNT ON;

	/*
	declare @IdTenant int = 67
	declare @Marketplace varchar(30) = 'Shopee'
	declare @Operacao varchar(2) = 'FM'
	declare @TipoHub varchar(3) = 'Hub'
	declare @DataInicio date = '2026-08-01'
	declare @DataFim date = '2026-08-01'
	declare @Base varchar(max) = null
	declare @Motoristas varchar(max) = null
	declare @StatusEmissao varchar(max) = null
	declare @CodigoRota varchar(50) = null
	*/


	drop table if exists #rotas
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
		,c.cli_ds_sub_dominio
		into #rotas
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
	where
		r.Excluido = 0
		and r.NomeHub <> 'Aguardando informações da rota'
		and r.TipoOperacao in ('LM', 'FM')
		and c.cli_cd_codigo_cliente = @IdTenant
		and r.TipoOperacao = @Operacao
		and case when r.NomeHub like '%xpt%' then 'XPT' else 'Hub' end = @TipoHub
		and r.DataReferencia between @DataInicio and @DataFim
		and (@Base is null or r.NomeHub in (select trim(value) from string_split(@Base, ',')))
		and (@Motoristas is null or isnull(e.NomeMotorista,r.Motorista) in (select trim(value) from string_split(@Motoristas, ',')))
		and (@CodigoRota is null or r.CodigoRota = @CodigoRota)


	drop table if exists #fila
	select
		fila.CodigoRota
		,fila.IdLote
		,lote.NomeLote
		,isnull(lst.lst_ds_label,'Não Emitido') StatusLote
		into #fila
	from
		[10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_auto_fila_emissao_rota fila with(nolock)
		left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_lista_fiscal lst with(nolock) on fila.IdStatus = lst.lst_cd_lista
		left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_lotes lote with(nolock) on fila.IdLote = lote.IdLote
	where
		fila.TenantId = @IdTenant
		and fila.CodigoPacote is null
		and fila.Ambiente = 1
		and fila.Excluido = 0
		and fila.CodigoRota in (select CodigoRota from #rotas)


	
	drop table if exists #emitidos
	SELECT
		e.TenantId
		,e.IdLote
		,e.CodigoRota
		,COUNT(DISTINCT e.CodigoPacote) AS QtdePacotesResolvidos
		into #emitidos
	FROM 
		(
			SELECT
				g.IdTenant AS TenantId
				,g.IdLote
				,g.CodigoRota
				,g.PackageId AS CodigoPacote
			FROM 
				[10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_geral g WITH (NOLOCK)
			WHERE 
				g.IdTenant = @IdTenant
				and g.InfCte_TipoAmbiente = 1
				and g.IdLote in (select IdLote from #fila)
				and g.CodigoRota in (select CodigoRota from #rotas)

			UNION

			SELECT
				p.TenantId
				,p.IdLote
				,p.CodigoRota
				,p.CodigoPacote
			FROM 
				[10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_auto_pendencias_pacote p WITH (NOLOCK)
			WHERE 
				TenantId = @IdTenant
				and p.Ambiente = 1
				and p.IdLote in (select IdLote from #fila)
				AND p.RequerAcao = 0
				and p.CodigoRota in (select CodigoRota from #rotas)
		) e
	GROUP BY
		e.TenantId
		,e.IdLote
		,e.CodigoRota


	select
		r.TenantId
		,r.IdTransportadora
		,r.TipoOperacao
		,r.TipoHub
		,r.CodigoRota
		,r.NomeRota
		,r.DataReferencia
		,r.NomeHub
		,r.TotalPacotes
		,r.Motorista
		,r.NomeVeiculo
		,r.Placa
		,r.DistanciaKM
		,r.ValorFrete
		,fila.IdLote
		,fila.NomeLote
		,'https://' + r.cli_ds_sub_dominio + '/fiscal/cte/detalhes-lote/' + cast(fila.IdLote as varchar) LinkLote
		,CAST(
			CASE
				WHEN ISNULL(r.TotalPacotes, 0) <= 0 THEN 0.00
				WHEN fila.IdLote IS NULL THEN 0.00
				ELSE ROUND(100.0 * ISNULL(em.QtdePacotesResolvidos, 0) / r.TotalPacotes, 2)
			END AS DECIMAL(5, 2)
		) PercentualEmissao
		,fila.StatusLote
	from
		#rotas r
		left join #fila fila with(nolock) on r.CodigoRota = fila.CodigoRota
		left join #emitidos em ON em.CodigoRota = r.CodigoRota
								AND em.IdLote = fila.IdLote
	where
		(@StatusEmissao is null or fila.StatusLote in (select trim(value) from string_split(@StatusEmissao, ',')))


end

GO
