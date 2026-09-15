-- ============================================================
-- BASELINE: dbo.UspInsereBaseFreteVeiculos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspInsereBaseFreteVeiculos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--==================================================
-- Autor: Saulo Barros
-- Data de Criação: 05/12/2024
-- Descrição: Insere veículos que não foram cadastrados pelo cliente com base na tabela de valores de outro SVC
--==================================================
CREATE procedure [dbo].[UspInsereBaseFreteVeiculos]
(
	@IdCliente int
)
as
begin

	--declare @IdCliente int = 49
	declare @IdTransportadora int = (select cli_id_logistics from tb_clientes where cli_cd_codigo_cliente=@IdCliente)

	insert into tb_fin_base_frete_motorista
	select
		frete.bfm_cd_transportadora
		,cadastrar.ServiceCenter
		,frete.bfm_nm_cidade
		,frete.bfm_cd_tipo_veiculo
		,frete.bfm_vl_inicio_faixa
		,frete.bfm_vl_fim_faixa
		,frete.bfm_vl_frete
		,frete.bfm_vl_frete_pm
		,frete.bfm_vl_frete_fixo
		,frete.bmf_cd_tipo_contrato
		,frete.bfm_cd_codigo_cliente
		,frete.bfm_vl_domfer_am
		,frete.bfm_vl_domfer_pm
	from
		(
			select
				distinct r.ServiceCenter, r.TipoVeiculo
			from
				tb_ml_rotas r with(nolock)
				left join (
					select
						a.bfm_cd_service_center ServiceCenter
						,b.tvl_nm_tipo_veiculo TipoVeiculo
						,a.bfm_vl_inicio_faixa
						,a.bfm_vl_fim_faixa
						,a.bfm_vl_frete
					from
						tb_fin_base_frete_motorista a
						join dbo.tb_dra_tipo_veiculo b on a.bfm_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo
					where
						bfm_cd_transportadora = @IdCliente
				) tv on r.ServiceCenter = tv.ServiceCenter and r.TipoVeiculo = tv.TipoVeiculo
			where
				r.IdTransportadora = @IdTransportadora
				and r.TipoVeiculo is not null
				and r.TipoVeiculo <> ''
				and tv.ServiceCenter is null
		) cadastrar
		join tb_dra_tipo_veiculo b on cadastrar.TipoVeiculo = b.tvl_nm_tipo_veiculo
		join tb_fin_base_frete_motorista frete on b.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo AND frete.bfm_cd_transportadora = @IdCliente
													and frete.bfm_cd_service_center = (
														select
															max(bfm_cd_service_center)
														from
															tb_fin_base_frete_motorista aux
														where
															aux.bfm_cd_transportadora = @IdCliente
															and frete.bfm_cd_tipo_veiculo = aux.bfm_cd_tipo_veiculo
													)
	order by
		2,4



	insert into tb_fin_base_frete_transportadora
	select
		frete.bft_cd_transportadora
		,cadastrar.ServiceCenter
		,frete.bft_estado
		,frete.bft_cd_tipo_veiculo
		,frete.bft_vl_inicio_faixa
		,frete.bft_vl_fim_faixa
		,frete.bft_vl_frete
		,frete.bft_cd_codigo_cliente
		,frete.bft_data_inicio
		,frete.bft_data_fim
	from
		(
			select
				distinct r.ServiceCenter, r.TipoVeiculo
			from
				tb_ml_rotas r with(nolock)
				left join (
					select
						a.bft_cd_service_center ServiceCenter
						,b.tvl_nm_tipo_veiculo TipoVeiculo
						,a.bft_vl_inicio_faixa
						,a.bft_vl_fim_faixa
						,a.bft_vl_frete
					from
						tb_fin_base_frete_transportadora a
						join dbo.tb_dra_tipo_veiculo b on a.bft_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo
					where
						bft_cd_transportadora = @IdCliente
				) tv on r.ServiceCenter = tv.ServiceCenter and r.TipoVeiculo = tv.TipoVeiculo
			where
				r.IdTransportadora = @IdTransportadora
				and r.TipoVeiculo is not null
				and r.TipoVeiculo <> ''
				and tv.ServiceCenter is null
		) cadastrar
		join tb_dra_tipo_veiculo b on cadastrar.TipoVeiculo = b.tvl_nm_tipo_veiculo
		join tb_fin_base_frete_transportadora frete on b.tvl_cd_tipo_veiculo = frete.bft_cd_tipo_veiculo AND frete.bft_cd_transportadora = @IdCliente
													and frete.bft_data_fim is null
													and frete.bft_cd_service_center = (
														select
															max(bft_cd_service_center)
														from
															tb_fin_base_frete_transportadora aux
														where
															aux.bft_cd_transportadora = @IdCliente
															and frete.bft_cd_tipo_veiculo = aux.bft_cd_tipo_veiculo
															and bft_data_fim is null
													)
	order by
		2,4

end
GO
