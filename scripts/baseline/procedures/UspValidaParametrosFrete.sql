-- ============================================================
-- BASELINE: dbo.UspValidaParametrosFrete
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspValidaParametrosFrete]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspValidaParametrosFrete] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin
	
	SET NOCOUNT ON
	
	declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)
	declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end

	
	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		null ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		null Base,
		'Service Center não encontrado' TipoErro
	from
		tb_ml_rotas r with(nolock)
		left join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and svc.svc_cd_service_center is null


	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		null ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		b.dab_nm_base Base,
		'Base não encontrada' TipoErro
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		left join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
		left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and b.dab_cd_base is null
		

	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		cla.cvl_nm_classificacao_veiculo ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		b.dab_nm_base Base,
		'Tipo de Veículo não encontrado' TipoErro
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
		left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_dra_classificacao_veiculo cla on tv.tvl_cd_classificacao_veiculo = cla.cvl_cd_classificacao_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and tv.tvl_cd_tipo_veiculo is null


	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		cla.cvl_nm_classificacao_veiculo ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		b.dab_nm_base Base,
		'Base não cadastrada no frete' TipoErro
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
		join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_dra_classificacao_veiculo cla on tv.tvl_cd_classificacao_veiculo = cla.cvl_cd_classificacao_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
		left join tb_fin_base_frete frete on tv.tvl_cd_tipo_veiculo = frete.fbf_cd_tipo_veiculo
												and r.KmColetado > (frete.fbf_vl_inicio_faixa - 1)
												and r.KmColetado <= frete.fbf_vl_fim_faixa
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and tv.tvl_cd_tipo_pagamento_frete = 1
		and frete.fbf_cd_base_frete is null

	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		cla.cvl_nm_classificacao_veiculo ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		b.dab_nm_base Base,
		'Frete VUC não cadastrado' TipoErro
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
		join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_dra_classificacao_veiculo cla on tv.tvl_cd_classificacao_veiculo = cla.cvl_cd_classificacao_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
		left join tb_fin_base_frete_vuc vuc on tv.tvl_frete_vuc_horas = vuc.bfv_vl_horas_jornada
												and tv.tvl_frete_vuc_tipo = vuc.bfv_tipo_valor
												and (
														(case when b.dab_nm_estado in ('RJ', 'RS', 'SP') then b.dab_nm_estado else 'NA' end = vuc.bfv_estado)
													)
												and r.KmColetado > (vuc.bfv_vl_inicio_faixa - 1)
												and r.KmColetado <= vuc.bfv_vl_fim_faixa
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and tv.tvl_cd_tipo_pagamento_frete = 3
		and vuc.bfv_cd_base_frete_vuc is null


	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		cla.cvl_nm_classificacao_veiculo ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		b.dab_nm_base Base,
		'Valor diária não cadastrada' TipoErro
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
		join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_dra_classificacao_veiculo cla on tv.tvl_cd_classificacao_veiculo = cla.cvl_cd_classificacao_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and tv.tvl_cd_tipo_pagamento_frete = 2
		and tv.tvl_vl_frete_diario_transportadora is null

	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		r.IdRota,
		r.DataReferencia,
		case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end ServiceCenter,
		r.TipoVeiculo,
		cla.cvl_nm_classificacao_veiculo ClassificaoVeiculo,
		tpg.tpf_nm_tipo_pagamento_frete TipoPagamentoFrete,
		r.KmColetado,
		b.dab_nm_base Base,
		'Bonificação não cadastrada no base frete' TipoErro
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
		join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
		join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		left join tb_dra_classificacao_veiculo cla on tv.tvl_cd_classificacao_veiculo = cla.cvl_cd_classificacao_veiculo
		left join tb_fin_tipo_pagamento_frete tpg on tv.tvl_cd_tipo_pagamento_frete =tpg.tpf_cd_tipo_pagamento_frete
		left join tb_fin_base_bonificacao bf with(nolock) on b.dab_cd_base = bf.fbf_cd_base 
										and tv.tvl_cd_tipo_pagamento_frete = 1 --Base Frete
										and bf.fbf_cd_classificacao_veiculo = tv.tvl_cd_classificacao_veiculo
										and r.KmColetado <= bf.fbf_vl_faixa_ate_km 
										and fbf_vl_faixa_ate_km = (
																	select
																		min(fbf_vl_faixa_ate_km) fbf_vl_faixa_ate_km
																	from
																		tb_fin_base_bonificacao frete with(nolock)
																	where
																		frete.fbf_cd_base = bf.fbf_cd_base
																		and frete.fbf_cd_classificacao_veiculo = bf.fbf_cd_classificacao_veiculo
																		and r.KmColetado <= frete.fbf_vl_faixa_ate_km 
																)
	where
		r.Excluido = 0
		and r.IdTransportadora = @IdTransportadora
		and r.DataReferencia between @data_inicial and @data_final
		and r.DataReferencia = (
			select
				max(DataReferencia)
			from
				 tb_ml_rotas r2 with(nolock)
			where
				r.IdRota = r2.IdRota
				and r.IdTransportadora = r2.IdTransportadora
		)
		and tv.tvl_cd_tipo_pagamento_frete = 1
		and bf.fbf_cd_base_frete is null
		
		
 end
GO
