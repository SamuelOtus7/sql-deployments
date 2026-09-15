-- ============================================================
-- BASELINE: dbo.UspGeraPagamentoMotorista_BKP
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraPagamentoMotorista_BKP]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[UspGeraPagamentoMotorista_BKP] (
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

	delete tb_fin_pagamento_motorista where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena

	insert into tb_fin_pagamento_motorista
	SELECT
		*,
		SAIDA+[ADD]+RISCO+AJUDANTE+ASCRESC AS CUSTO_TOTAL
	FROM
	(
		SELECT
			@IdTransportadora IdTransportadora,
			@Ano Ano,
			@Mes Mes,
			@Quinzena Quinzena,
			r.dataReferencia AS Data,
			r.serviceCenter ,
			r.CidadeReferencia,
			r.Placa,
			TipoVeiculo,
			r.NomeMotorista,
			r.idRota as IdRota,
			case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end CicloPM,
			TotalPacotes,
			QuantidadePontos,
			
			ISNULL(case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					frete.bfm_vl_frete + adicional.bfa_vl_adicional_domingo
				end
			else
				frete.bfm_vl_frete
			END
			-
			case when  
				case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
					adicional.bfa_vl_adicional_ciclo_pm 
				end 
			ELSE
				0
			end  
			,0) Saida,
			

			CASE WHEN adicional.bfa_calcula_por_parada = 0
			THEN CASE 
					WHEN r.QuantidadePontos <= 60
						THEN r.QuantidadePontos * adicional.bfa_vl_paradas0_60
					WHEN r.QuantidadePontos <= 75
						THEN 60 * adicional.bfa_vl_paradas0_60 + (r.QuantidadePontos - 60) * adicional.bfa_vl_paradas61_75
					WHEN r.QuantidadePontos <= 85
						THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + (r.QuantidadePontos - 75) * adicional.bfa_vl_paradas76_85
					WHEN r.QuantidadePontos <= 90
						THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + (r.QuantidadePontos - 85) * adicional.bfa_vl_paradas86_90
					ELSE 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + 5 * adicional.bfa_vl_paradas86_90 + (r.QuantidadePontos - 90) * adicional.bfa_vl_paradas_acima_90
					END
			END AS 'ADD',

			ISNULL(case 
			when (r.TipoRota like 'R[_]%' and r.serviceCenter ='SSP21') or risco.crt_cd_risco_transportadora is not null  then
				case when adicional.bfa_tipo_adicional_risco = 2 then 
					 adicional.bfa_vl_adicional_risco 
				else
					0
				end end , 0) AS RISCO,

			ISNULL(case when r.TipoVeiculo = 'VUC' then
				case when bfa_tipo_adicional_ajudante = 2 then 
					adicional.bfa_vl_adicional_ajudante
				else
					0
				end
			else
				0
			end,0) AS AJUDANTE,

			ISNULL(NULL,0) AS ASCRESC
		FROM
			vw_rotas r with(nolock)
			left join tb_ml_service_center svc2 on r.ServiceCenter = svc2.svc_cd_service_center
			left join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
			left join DimData dt on r.DataReferencia = dt.Data
			left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		
			left join tb_fin_cidades_risco_transportadora as risco on r.IdTransportadora = risco.crt_cd_risco_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = risco.crt_cd_service_center
																	and r.CidadeReferencia = risco.crt_nm_cidade
		
			left join tb_fin_base_frete_motorista frete on r.IdTransportadora = frete.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = frete.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo
																	and r.CidadeReferencia = frete.bfm_nm_cidade		

			left join tb_fin_base_frete_adicional_motorista adicional on r.IdTransportadora = adicional.bfa_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional.bfa_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo
																	and r.CidadeReferencia = adicional.bfa_nm_cidade						
		where
			r.IdTransportadora = @IdTransportadora
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
			and isnull(r.SubStatusRota,'') <> 'Cancelada'

	) AS ROTAS

end
GO
