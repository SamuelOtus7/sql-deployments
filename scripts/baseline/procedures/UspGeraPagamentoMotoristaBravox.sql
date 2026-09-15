-- ============================================================
-- BASELINE: dbo.UspGeraPagamentoMotoristaBravox
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraPagamentoMotoristaBravox]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
CREATE procedure [dbo].[UspGeraPagamentoMotoristaBravox]  (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint,
	@idrota varchar(50) ,
    @prazo varchar(150) ,
    @Tipoderota varchar(15),
	@TipodeContrato varchar(15),
    @faixakmIni  varchar(50) 
)
as
begin
	

    -- declare @IdTransportadora int = 834780814,
	-- @Ano int = 2024,
	-- @Mes tinyint = 03,
	-- @Quinzena tinyint = 02,
	-- @idrota int = 139514152,
    -- @prazo varchar(15) = 'Antigo',
	-- @Tipoderota varchar(15) = 'Inteira',
    -- @TipodeContrato varchar(15) = 'Motorista'


-- select * from tb_fin_ficha_motorista

	--- remover o filtro and adicional.bfa_cd_base_frete_adicional_motorista <> 1308 das tabelas tb_fin_base_frete_adicional_motorista

	SET NOCOUNT ON
	
	declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)
	declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end


    drop table if exists #tb_fin_base_frete_motorista_bravox 
    select * 
    into #tb_fin_base_frete_motorista_bravox
    from tb_fin_base_frete_motorista_bravox
    where bfm_cd_transportadora = 834780814
    and bfm_cd_prazo =  @prazo
    and bfm_tipo_motorista = @TipodeContrato


	drop table if exists #vw_rotas
	select  a.*
	,b.TipoVeiculo as TipoVeiculoAlterado
	,versaoapp.VersaoDA

	into #vw_rotas

	from (
      select 
       a.[IdTransportadora]
    --   ,[Id]
      ,cast(a.[IdRota] as varchar(50)) as IdRota
      ,[DataReferencia]
      ,[DataHoraInicio]
      ,[StatusRota]
      ,[SubStatusRota]
      ,[StatusPrazo]
    --   ,[ServiceCenter]
      ,isnull(c.[Service Center],ServiceCenter) as ServiceCenter
      ,[NomeServiceCenter]
      ,[Base]
      ,[CidadeBase]
      ,[TipoOrigemSaida]
      ,[OrigemSaida]
      ,[TipoRota]
      ,[TipoVeiculo]
      ,[NomeMotorista]
      ,a.[Placa]
      ,[NivelExperienciaMotorista]
      ,[IdNivelMotorista]
      ,[NivelMotorista]
      ,[QuantidadePacotesTransportados]
      ,[PercentualEntregasBemSucedidas]
      ,[PercentualEntregasSemRelamacaoes]
      ,[PossuiAjudante]
      ,[Ajudante]
	  ,case when isnull(@faixakmIni, KmColetado) = 0 then 1 else isnull(@faixakmIni, KmColetado) end KmColetado
      ,[LinkMapa]
      ,[TotalPacotes]
      ,[PacotesEntregues]
      ,[PacotesPendentes]
      ,[PacotesNaoEntregue]
      ,[PacotesEntreguesForaAreaEntrega]
      ,[PacotesTransferidos]
      ,[TempoEmRota]
      ,[TempoChegadaAreaEntrega]
      ,[TempoAreaEntrega]
      ,[PercentualProgresso]
      ,[KmTotal]
      ,[TempoEmRotaSec]
      ,[SegundosEntreEntregas]
      ,[RotaFinalizada]
      ,[StatusGeralRota]
      ,[QuantidadePontos]
      ,[QuantidadeParadas]
      ,[QuantidadeReclamacoes]
      ,[QuantidadeAmbulancia]
      ,[StatusPrimeiraEntrega]
      ,[StatusSegundaEntrega]
      ,[DataUltimaEntrega]
      ,[Cidades]
      ,[CidadeReferencia]
      ,[KmColetadoMeli]
      ,[LinkMapaMeli]
      ,[KmColetadoAPP]
      ,[LinkMapaApp]
      ,[Ambulancia]
      ,[KmMotorista]
	  ,UsuarioDA

      from  vw_rotas as a
      left join tb_ml_processamento_km_rotas as b
      on a.IdRota = b.idRota

      left join (
                select a.*,b. cli_id_logistics 
                from tb_fin_ficha_motorista as a
                inner join tb_clientes as b
                on a.idtransportadora = b.cli_cd_codigo_cliente
                ) as c
	on a.IdTransportadora = c.cli_id_logistics
	and a.idrota = c.id
      
        where a.IdTransportadora = @IdTransportadora
        and a.DataReferencia between @data_inicial and @data_final
        and cast(a.IdRota as varchar(50)) = @idrota
     ) as a
	
	left join (
                select a.*,b. cli_id_logistics 
                from tb_fin_resultado_financeiro_alteracao as a
                inner join tb_clientes as b
                on a.idtransportadora = b.cli_cd_codigo_cliente
                ) as b
	on a.IdTransportadora = b.cli_id_logistics
	and a.idrota = b.idrota
	

	left join 
	(
			select 
				CodigoUsuario	
				,NomeUsuario
				,VersaoDA

			from [vw_dados_aparelhos]

	) as versaoapp
	on a.NomeMotorista = versaoapp.NomeUsuario

-- select * from tb_fin_ficha_motorista where id = 134992537

	-- delete tb_fin_pagamento_motorista where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena and idrota = @idrota
	-- insert into tb_fin_pagamento_motorista


    drop table if exists #tb_fin_ficha_motorista
	SELECT  DISTINCT
		serviceCenter ,
		Placa, 
        Saida,
        IdRota as ID,
        TipoVeiculo as Categoria,
        @TipodeContrato as TipoContrato,
        @Tipoderota as Tipoderota,
        KmColetado
        
    into #tb_fin_ficha_motorista
    
	FROM
	(
		SELECT
			-- @IdTransportadora IdTransportadora,
			r.idTransportadora,
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
			KmColetado,
			
			
			isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) is not null then
					isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)
				else
					isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
			end,0)
			+
			/*calculo saida domingo */
			isnull(
			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) is not null then
					isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)
				else
					isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0)
			Saida,

			/*calculo adicional */
			isnull(
				case when r.IdTransportadora = 1491631999 and r.Ambulancia = 1 then
					0
				else
					CASE 
					WHEN adicional.bfa_calcula_por_parada = 0
						THEN 
							CASE 
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
					WHEN adicional.bfa_calcula_por_parada = 1
						THEN
						CASE 
								WHEN r.QuantidadeParadas <= 60
									THEN r.QuantidadeParadas * adicional.bfa_vl_paradas0_60
								WHEN r.QuantidadeParadas <= 75
									THEN 60 * adicional.bfa_vl_paradas0_60 + (r.QuantidadeParadas - 60) * adicional.bfa_vl_paradas61_75
								WHEN r.QuantidadeParadas <= 85
									THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + (r.QuantidadeParadas - 75) * adicional.bfa_vl_paradas76_85
								WHEN r.QuantidadeParadas <= 90
									THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + (r.QuantidadeParadas - 85) * adicional.bfa_vl_paradas86_90
							ELSE 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + 5 * adicional.bfa_vl_paradas86_90 + (r.QuantidadeParadas - 90) * adicional.bfa_vl_paradas_acima_90
							END
					END 
				end
            +			
			/*calculo adicional pool */			
			case 
			when ADICIONAL_POOL.bfa_vl_adicional is not null  
				then
					ADICIONAL_POOL.bfa_vl_adicional
				else
					0
				 end
				 +
		  /*calculo adicional fixo */			
            case 
			when adicional_fixo.bfm_vl_frete_fixo is not null  
				then
					adicional_fixo.bfm_vl_frete_fixo
				else
					0
				 end,0) AS [ADD],     
			
			ISNULL(case 
			when (r.TipoRota like 'R[_]%' and r.serviceCenter ='SSP21' and r.IdTransportadora=1491631999) or risco.crt_cd_risco_transportadora is not null  then
				case when adicional.bfa_tipo_adicional_risco = 2 then 
					 adicional.bfa_vl_adicional_risco 
				else
					0
				end end , 0) AS RISCO,

			ISNULL(case when r.TipoVeiculo = 'VUC' then
				case when adicional.bfa_tipo_adicional_ajudante = 2 then 
					adicional.bfa_vl_adicional_ajudante
				else
					0
				end
			else
				0
			end,0) AS AJUDANTE,

			ISNULL(NULL,0) AS ASCRESC,




			isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKmMotorista.bfm_vl_frete_pm is not null then
					freteKmMotorista.bfm_vl_frete_pm
				else
					freteKmMotorista.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKmMotorista.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKmMotorista.bfm_vl_frete
			end,0)
			+
			/*calculo saida domingo */
			isnull(
			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKmMotorista.bfm_vl_frete_pm is not null then
					freteKmMotorista.bfm_vl_frete_pm
				else
					freteKmMotorista.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKmMotorista.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKmMotorista.bfm_vl_frete
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0)
			SaidaKmMotorista,

		
		isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKm0a100.bfm_vl_frete_pm is not null then
					freteKm0a100.bfm_vl_frete_pm
				else
					freteKm0a100.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKm0a100.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKm0a100.bfm_vl_frete
			end,0)
			+
			/*calculo saida domingo */
			isnull(
			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKm0a100.bfm_vl_frete_pm is not null then
					freteKm0a100.bfm_vl_frete_pm
				else
					freteKm0a100.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKm0a100.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKm0a100.bfm_vl_frete
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0)
			SaidaKm0a100,


			isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKmPreFatura.bfm_vl_frete_pm is not null then
					freteKmPreFatura.bfm_vl_frete_pm
				else
					freteKmPreFatura.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKmPreFatura.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKmPreFatura.bfm_vl_frete
			end,0)
			+
			/*calculo saida domingo */
			isnull(
			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKmPreFatura.bfm_vl_frete_pm is not null then
					freteKmPreFatura.bfm_vl_frete_pm
				else
					freteKmPreFatura.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKmPreFatura.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKmPreFatura.bfm_vl_frete
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0)
			SaidaKmPreFatura


		FROM
			#vw_rotas r with(nolock)
			left join tb_fin_prefatura pre on r.IdTransportadora = pre.IdTransportadora
												and r.IdRota = pre.IdRota
												--and r.DataReferencia = pre.DataTermino
												and pre.Quinzena = @Quinzena
												and pre.Ano = @Ano
												and pre.Mes = @Mes
			left join 
			(
				select
					usr_nm_usuario NomeMotorista,
					c.cli_id_logistics IdTransportadora,
					u.usr_cd_tipo_contrato TipoContrato
				from
					tb_usuario u
					join tb_clientes c on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
					--join tb_ml_aprovacao_usuario a on u.usr_cd_usuario = a.mau_cd_usuario_gerado and a.mau_ds_status = 'Aprovado'
				where
					usr_in_ativo = 1
					and c.cli_id_logistics <> 0
			) m on r.NomeMotorista = m.NomeMotorista and r.IdTransportadora = m.IdTransportadora
			left join tb_ml_service_center svc2 on r.ServiceCenter = svc2.svc_cd_service_center
			left join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
			left join DimData dt on r.DataReferencia = dt.Data
			left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		
			left join tb_fin_cidades_risco_transportadora as risco on r.IdTransportadora = risco.crt_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = risco.crt_cd_service_center
																	and r.CidadeReferencia = risco.crt_nm_cidade
		

		left join tb_fin_base_km_trevo trevo with(nolock) on r.IdTransportadora = trevo.bkt_cd_transportadora
												and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = trevo.bkt_cd_service_center
												and r.Cidades = trevo.bkt_nm_cidades

			
			left join #tb_fin_base_frete_motorista_bravox frete on r.IdTransportadora = frete.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = frete.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo
																	and r.CidadeReferencia = frete.bfm_nm_cidade	
																	--and isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)
                                                                    

			left join tb_fin_base_frete_adicional_motorista adicional on r.IdTransportadora = adicional.bfa_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional.bfa_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo
																	and (r.CidadeReferencia = adicional.bfa_nm_cidade or adicional.bfa_nm_cidade is null)
																	--and isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)
																		 or 1=1	)

            left join (
                SELECT 
                * 
                FROM 
                tb_fin_base_frete_adicional_motorista  
                with(nolock) 
                WHERE bfa_cd_tipo_veiculo IN (1,4)
                and bfa_cd_base_frete_adicional_motorista <> 1309
			) adicional_pool  on r.IdTransportadora = adicional_pool.bfa_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_pool.bfa_cd_service_center
                                                                    and tv.tvl_cd_tipo_veiculo = adicional_pool.bfa_cd_tipo_veiculo 
																	and (r.CidadeReferencia = adicional_pool.bfa_nm_cidade or adicional_pool.bfa_nm_cidade is null)                                      
																	--and isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)
																		 or 1=1	)

			left join #tb_fin_base_frete_motorista_bravox freteKm with(nolock)  on r.IdTransportadora = freteKm.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKm.bfm_cd_tipo_veiculo
																	and isnull(m.TipoContrato,-1) = freteKm.bmf_cd_tipo_contrato
																	and freteKm.bfm_nm_cidade is null
																	and trevo.bkt_vl_km_ideal > (freteKm.bfm_vl_inicio_faixa - 1)
																	--and isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)

		left join #tb_fin_base_frete_motorista_bravox freteKm2 with(nolock)  on r.IdTransportadora = freteKm2.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm2.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKm2.bfm_cd_tipo_veiculo
																	and freteKm2.bfm_nm_cidade is null
																	and r.KmColetado > (freteKm2.bfm_vl_inicio_faixa - 1)
																	and r.KmColetado <= freteKm2.bfm_vl_fim_faixa
																	and (isnull(m.TipoContrato,-1) = isnull(freteKm2.bmf_cd_tipo_contrato,-1)
																	or 1=1)
																	

        left join #tb_fin_base_frete_motorista_bravox adicional_fixo with(nolock) on adicional_fixo.bfm_vl_frete_fixo is NOT null 
																	AND r.IdTransportadora = adicional_fixo.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_fixo.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = adicional_fixo.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)
																	or 1=1)
																	and r.Cidades = r.CidadeReferencia
																	--and r.cidades = adicional_fixo.bfm_nm_cidade
																	and r.CidadeReferencia = adicional_fixo.bfm_nm_cidade

		left join #tb_fin_base_frete_motorista_bravox freteKmMotorista with(nolock)  on r.IdTransportadora = freteKmMotorista.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmMotorista.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKmMotorista.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)
																	and freteKmMotorista.bfm_nm_cidade is null
																	and r.KmMotorista > (freteKmMotorista.bfm_vl_inicio_faixa - 1)
																	and r.KmMotorista <= freteKmMotorista.bfm_vl_fim_faixa

		left join #tb_fin_base_frete_motorista_bravox freteKm0a100 with(nolock)  on r.IdTransportadora = freteKm0a100.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm0a100.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKm0a100.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)
																	and freteKm0a100.bfm_nm_cidade is null
																	and freteKm0a100.bfm_vl_inicio_faixa = 1

		left join #tb_fin_base_frete_motorista_bravox freteKmPreFatura with(nolock)  on r.IdTransportadora = freteKmPreFatura.bfm_cd_transportadora
																	and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmPreFatura.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKmPreFatura.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)
																	and freteKmPreFatura.bfm_nm_cidade is null
																	and pre.InicioIntervalo >= freteKmPreFatura.bfm_vl_inicio_faixa
																	and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= freteKmPreFatura.bfm_vl_fim_faixa
																	

		where
		r.IdTransportadora = @IdTransportadora
			and r.DataReferencia between @data_inicial and @data_final
			and r.DataReferencia < cast(getdate() as date)
			and r.DataReferencia = (
				select
					max(DataReferencia)
				from
					 tb_ml_rotas r2 with(nolock)
				where
					r.IdRota = r2.IdRota
					and r.IdTransportadora = r2.IdTransportadora
					and r2.excluido = 0
			)
			and isnull(r.SubStatusRota,'') not in ('Cancelada','Planejada')
			and r.StatusRota <> 'Planejada'
			--and adicional.bfa_cd_base_frete_adicional_motorista <> 1308
	) AS ROTAS


MERGE INTO tb_fin_ficha_motorista AS target
USING #tb_fin_ficha_motorista AS source
ON target.id = source.id
WHEN MATCHED THEN
    UPDATE SET
        target.[Service Center] = source.serviceCenter,
        target.Placa = source.Placa,
        target.[Valor Saida] = source.[Saida],
        target.Categoria = source.Categoria,
        target.[Tipo de Contrato] = source.[TipoContrato],
        target.[Tipo de rota] = source.[Tipoderota],
        target.[KM] = source.[kmcoletado]

WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Service Center], Placa, [Valor Saida], id, Categoria, [Tipo de Contrato], [Tipo de rota])
    VALUES (serviceCenter, 		Placa, Saida,  ID, Categoria, TipoContrato, Tipoderota);



end
GO
