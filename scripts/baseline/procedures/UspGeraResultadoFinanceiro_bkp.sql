-- ============================================================
-- BASELINE: dbo.UspGeraResultadoFinanceiro_bkp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraResultadoFinanceiro_bkp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraResultadoFinanceiro_bkp]   (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint,
	@idrota int = null
)
as 

begin

	  --declare @IdTransportadora int = 1726310024,
 	 -- @Ano int = 2024,
 	 -- @Mes tinyint = 05,
 	 -- @Quinzena tinyint = 1,
 	 -- @idrota int = null

	SET NOCOUNT ON	

	declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)
	declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end


	drop table if exists #paradas
	select 
	IdRota
	,count(distinct LatitudeEnderecoParada + LongitudeEnderecoParada) QtdParada
	
		into #paradas

	from tb_ml_pacotes
	where 1=1
	and IdTransportadora = @IdTransportadora
	and DataReferencia between @data_inicial and @data_final
	and (@idrota is null or IdRota = @idrota)
	and SubStatus <> 'transferred'
	and excluido = 0
	-- and idrota  147673793

	group by IdRota



	drop table if exists #vw_rotas
	select distinct 
	a.*
	,b.TipoVeiculo as TipoVeiculoAlterado
	,versaoapp.VersaoDA
	,cli_cd_codigo_cliente as IdTransportadoraClic

	into #vw_rotas

	from (
      select 
       cli.cli_id_logistics as [IdTransportadora]
    --   ,[Id]
      ,a.[IdRota]
      ,a.[DataReferencia]
      ,a.[DataHoraInicio]
      ,a.[StatusRota]
      ,a.[SubStatusRota]
      ,a.[StatusPrazo]
      ,isnull(alt.[ServiceCenter],a.[ServiceCenter]) as [ServiceCenter]
      ,a.[NomeServiceCenter]
      ,a.[Base]
      ,a.[CidadeBase]
      ,a.[TipoOrigemSaida]
      ,a.[OrigemSaida]
      ,a.[TipoRota]
      ,isnull(alt.[TipoVeiculo],a.TipoVeiculo) as TipoVeiculo
      ,a.[NomeMotorista]
      ,a.[Placa]
      ,a.[NivelExperienciaMotorista]
      ,a.[IdNivelMotorista]
      ,a.[NivelMotorista]
      ,a.[QuantidadePacotesTransportados]
      ,a.[PercentualEntregasBemSucedidas]
      ,a.[PercentualEntregasSemRelamacaoes]
      ,a.[PossuiAjudante]
      ,a.[Ajudante]

		
      ,case when a.KmColetadoAPP = 0 then KmMapaPacote else a.KmColetado end KmColetado

                
	--   ,COALESCE(a.LinkMapaApp,LinkPacote)   LinkMapa
      ,case when a.KmColetadoAPP = 0 then LinkPacote else LinkMapaApp end as LinkMapa

                 --COALESCE(vldmapa.linkmapa,a.LinkMapa,LinkMapaMeli)  end LinkMapa

      ,isnull(alt.QuantidadePacotes,a.[TotalPacotes]) as TotalPacotes
      ,isnull(alt.PacotesEntregues,a.[PacotesEntregues]) as [PacotesEntregues]
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
      ,COALESCE(alt.QuantidadePontos,  a.[QuantidadePontos])  /*-[QuantidadeAmbulancia]-[PacotesTransferidos] */ as [QuantidadePontos]
      ,COALESCE(alt.[QuantidadeParadas], parada.QtdParada, a.[QuantidadeParadas]-[QuantidadeAmbulancia]) /*-[QuantidadeAmbulancia]-[PacotesTransferidos]*/ as [QuantidadeParadas]
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
	  ,UsouAPP
      ,FaixaPrimeiroUltimoPacote
	  ,estado 
	  --,idtrevo

	  ,case when (a.TipoVeiculo in ('Rental Utilitário sem Ajudante','Melione Rental Utilitário com Ajudante',
									'Rental Utilitário com Ajudante')
					or
					a.placa in ( 'SIA7J43','SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10'
								,'SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35')
					)
		then 1
		else null end Rental

      from  vw_rotas as a

	  left join tb_clientes as cli
	  on cli_id_logistics = a.idtransportadora

	  left join #paradas as parada
	  on a.idrota = parada.idrota

      left join tb_ml_processamento_km_rotas as b
      on a.IdRota = b.idRota
      
	  left join (
				select 
					vmp_cd_rota
					,isnull(vmp_kmrecebimento,vmp_km_total_mapa) as totalkm
					,isnull(vmp_linkrecebimento	,vmp_idrota) as linkmapa
				from tb_validacao_mapas
				where vmp_cd_rota is not nULL
	  ) as vldmapa
	  on vldmapa.vmp_cd_rota = a.IdRota

	  left join (
                select a.*,b. cli_id_logistics 
                from tb_fin_resultado_financeiro_alteracao as a
                inner join tb_clientes as b
                on a.idtransportadora = b.cli_cd_codigo_cliente
                ) as alt
	on a.IdTransportadora = alt.cli_id_logistics
	and a.idrota = alt.idrota

      where a.IdTransportadora = @IdTransportadora
      and a.DataReferencia between @data_inicial and @data_final
      and (@idrota is null or a.IdRota = @idrota)
      and a.tipo = 'last_mile'

        -- and KmColetado > 0 
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
	on a.UsuarioDA = versaoapp.CodigoUsuario
	
	inner join  tb_clientes as cli
	on a.idtransportadora  = cli.cli_id_logistics

	where cli.cli_cd_codigo_cliente <> 7



	update #vw_rotas 
	set 
	[IdTransportadora] = IdTransportadoraClic 

	delete tb_fin_resultado_financeiro 
	where 1=1 
	and IdTransportadora in (select distinct [IdTransportadora] from #vw_rotas )
	and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	and (@idrota is null or IdRota = @idrota)

	insert into tb_fin_resultado_financeiro 
	
	
	select distinct 
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		IdRota,
		DataReferencia,
		ServiceCenter,
		XPT,
		Base,
		Placa,
		Motorista,
		Destino,
		Cluster,
		TipoVeiculo,
		CicloPM,
		DomingoOuFeriado,
		TipoPagamentoFrete,
		TipoPagamentoAdicional,
		QuantidadePacotes,
		PacotesEntregues,
		Insucessos,
		Pendentes,
		QuantidadeParadas as QuantidadeParadas,
		QuantidadePontos	,
		PgtoSaida,
		PgtoParadas,
		Adicional,
		KmColetado,
		LinkMapa,

		
		--case when UsouAPP = 'Não' then null else FaixaKm end as FaixaKm,
		FaixaKm,
		isnull(RecebMeli,0) RecebMeli,
		isnull(RecebimentoParadas,0)	as RecebimentoParadas,
		isnull(RecebimentoDomingo,0)	as RecebimentoDomingo,
		isnull(RecebimentoRisco,0)		as RecebimentoRisco,
		isnull(RecebimentoAjudante,0)	as RecebimentoAjudante,
		isnull(DescontoCicloPM,0)       as DescontoCicloPM,
		isnull(Pedagio,0) Pedagio,

		/*isnull(RecebMeli,0) + isnull(RecebimentoParadas,0) + isnull(RecebimentoDomingo,0) 
		+ isnull(RecebimentoRisco,0) + isnull(RecebimentoAjudante,0) 
		+ isnull(Pedagio,0) - isnull(DescontoCicloPM,0) ReceitaTotal,*/
        isnull(RecebMeli,0)  AS ReceitaTotal,

		null PgtoLancamentoManual,
		0 PgtoValorManual,
		null RecebimentoLancamentoManual,
		0 RecebimentoValorManual,
		isnull(RecebMeli0a100,0) RecebMeli0a100,
		isnull(FretePreFatura,0) FretePreFatura,
		isnull(RecebimentoDomingoPrefatura,0) RecebimentoDomingoPrefatura,
		isnull(DescontoCicloPMPrefatura,0) DescontoCicloPMPrefatura,
		ValorAdicional0_60,
		ValorAdicional61_90,
		ValorAdicionalAcima_90,
		DataHoraInicio,
		tx_adicional_domingo,
		tx_adicional_ciclo_pm,
		tx_adicional_ajudante,
		tx_adicional_risco,
		UsouAPP,
		VersaoDA,
		case when UsouAPP = 'Não' then 0 else KmColetado end as KmColetadoNovo,
        FaixaPrimeiroUltimoPacote,
		QuantidadeAmbulancia,
		RecebimentoPonto
		--Total

	from
	(
		select
			r.IdTransportadora,
			@Ano Ano,
			@Mes Mes,
			@Quinzena Quinzena,
			r.IdRota,
            FaixaPrimeiroUltimoPacote,
			isnull(alteracao.DataReferencia,r.DataReferencia) as DataReferencia,
			r.DataHoraInicio,

			--  isnull(alteracao.ServiceCenter,r.IdTransportadora) as ServiceCenter,
			r.ServiceCenter ServiceCenter,
			r.OrigemSaida XPT,
			r.base Base,
			r.Placa,
			r.NomeMotorista Motorista,
			r.CidadeReferencia Destino,
			r.TipoRota Cluster,

			isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) as TipoVeiculo,

			isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) CicloPM,
			ISNULL(alteracao.DomingoOuFeriado, case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then 'Sim' else 'Não' end) DomingoOuFeriado,

			case when frete_diaria.bft_cd_base_frete_transportadora is not null then 'Frete Diária'
			else case when frete_faixa.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM'
			else case when frete_faixa_estado.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM por Estado'
			else case when frete_faixa_svc.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM por SVC'
			end end end end  TipoPagamentoFrete,
			
			case isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) when 1 then 'Pagamento por Parada' when 0 then 'Pagamento por Ponto' else null end TipoPagamentoAdicional,
			
			isnull(alteracao.QuantidadePacotes, r.TotalPacotes) QuantidadePacotes,

			isnull(alteracao.PacotesEntregues,r.PacotesEntregues ) PacotesEntregues,

			r.PacotesNaoEntregue Insucessos,
			r.PacotesPendentes Pendentes,
			r.QuantidadeAmbulancia,
			isnull(alteracao.QuantidadeParadas, r.QuantidadeParadas ) as QuantidadeParadas,
			isnull(alteracao.QuantidadePontos , r.QuantidadePontos ) as QuantidadePontos ,
			
			null PgtoSaida,
			null PgtoParadas,
			null Adicional,
			r.KmColetado,
			--r.pontosAppRotasTotalVoltaKm as KmColetadoNovo,

			isnull(alteracao.LinkMapa  ,r.LinkMapa  ) as LinkMapa,
			
			cast(COALESCE(frete_faixa.bft_vl_inicio_faixa, frete_faixa_estado.bft_vl_inicio_faixa, frete_faixa_svc.bft_vl_inicio_faixa) as varchar) + '/' +
			cast(COALESCE(frete_faixa.bft_vl_fim_faixa, frete_faixa_estado.bft_vl_fim_faixa, frete_faixa_svc.bft_vl_fim_faixa) as varchar) FaixaKm,
		
			
			case 
				when pre.Total >= COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete
											, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete)
					then pre.Total
				else COALESCE( frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete
											, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete)
				end as RecebMeli,
			
			case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then

				case when r.QuantidadeParadas > 60 then 60 else r.QuantidadeParadas end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
				+
				case when r.QuantidadeParadas > 60 then case when r.QuantidadeParadas >= 90 then 30 else r.QuantidadeParadas - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
				+
				case when r.QuantidadeParadas > 90 then r.QuantidadeParadas - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)
			else
				case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
				+
				case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
				+
				case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)
			end RecebimentoParadas,

				case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
				+
				case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
				+
				case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)  as RecebimentoPonto,

			
			case when (alteracao.DomingoOuFeriado = 'Sim' or DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1) then --domingo ou feriado
				case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem
					--quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm
					(
						COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) 
						-
						isnull(
							case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
								case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
									COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
								else --Valor
									isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
								end
							else
								0
							end
						,0)
					)
					* 
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100
				else --Valor
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)
				end
			else
				0
			end RecebimentoDomingo,

			case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
				case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
					COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
				else --Valor
					isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
				end
			else
				0
			end DescontoCicloPM,

			case when  (alteracao.DomingoOuFeriado = 'Sim' or  (r.TipoRota like 'R[_]%'  and r.serviceCenter ='SSP21' and r.IdTransportadora=1491631999) or risco.crt_cd_risco_transportadora is not null) then
				case when isnull(adicional.bfa_tipo_adicional_risco,adicional_svc.bfa_tipo_adicional_risco) = 1 then --Porcentagem
					COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco) / 100 
				else
					isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco)
				end
			else
				0
			end RecebimentoRisco,

			case when  (alteracao.Ajudante = 'Sim'  or r.PossuiAjudante = 1) then
				case when isnull(adicional.bfa_tipo_adicional_ajudante,adicional_svc.bfa_tipo_adicional_ajudante) = 1 then --Porcentagem
					COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante) / 100 
				else
					isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante)
				end
			else
				0
			end as RecebimentoAjudante,

			null Pedagio,
			
			isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)
			- --CicloPM
			isnull(case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
				case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
					isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
				else --Valor
					isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
				end
			else
				0
			end,0)
			+ --Adicional Domingo
			isnull(case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem
					--quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm
					(
						isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)
						-
						isnull(
							case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
								case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
									isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)  * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
								else --Valor
									isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
								end
							else
								0
							end
						,0)
					)
					* 
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100
				else --Valor
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)
				end
			else
				0
			end,0) RecebMeli0a100,
			
			isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) FretePreFatura,

			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem
					--quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm
					(
						isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete)
						-
						isnull(
							case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
								case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
									isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
								else --Valor
									isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
								end
							else
								0
							end
						,0)
					)
					* 
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100
				else --Valor
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)
				end
			else
				0
			end RecebimentoDomingoPrefatura,

			case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
				case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
					isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
				else --Valor
					isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
				end
			else
				0
			end DescontoCicloPMPrefatura,



			case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then
				case when r.QuantidadeParadas > 60 then 60 else r.QuantidadeParadas end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
			else
				case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
			end ValorAdicional0_60,		
			
			case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then
				case when r.QuantidadeParadas > 60 then case when r.QuantidadeParadas >= 90 then 30 else r.QuantidadeParadas - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
			else
				case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
			end ValorAdicional61_90,

			case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then
				case when r.QuantidadeParadas > 90 then r.QuantidadeParadas - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)
			else
				
				case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end *isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)
			end ValorAdicionalAcima_90,

			isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)	as tx_adicional_domingo,
			isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm) as tx_adicional_ciclo_pm,
			isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante) as tx_adicional_ajudante,
			isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco)		as tx_adicional_risco,
			r.UsouAPP,
			r.VersaoDA,
			pre.Total
						
		from
			#vw_rotas r with(nolock)

			--left join tb_ml_service_center svc2 
			--on r.ServiceCenter = svc2.svc_cd_service_center 
			--and r.IdTransportadora = svc2.IdTransportadora 
			
			left join DimData dt on r.DataReferencia = dt.Data
			
			--left join tb_ml_service_center svc with(nolock) 
			--on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center 
			--and r.IdTransportadora = svc.IdTransportadora 
            
			--left join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
			

			left join tb_dra_tipo_veiculo tv with(nolock) on isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) = tv.tvl_nm_tipo_veiculo
		
			left join tb_fin_prefatura pre on @IdTransportadora = pre.IdTransportadora
												and r.IdRota = pre.IdRota
												--and r.DataReferencia = pre.DataTermino
												--and pre.Quinzena = @Quinzena
												--and pre.Ano = @Ano
												--and pre.Mes = @Mes

			left join tb_fin_cidades_risco_transportadora as risco on r.IdTransportadora = risco.crt_cd_transportadora
																	and r.serviceCenter = risco.crt_cd_service_center
																	and r.CidadeReferencia = risco.crt_nm_cidade

			--frete com valor por dia 
			left join tb_fin_base_frete_transportadora frete_diaria on tv.tvl_cd_tipo_veiculo = frete_diaria.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_diaria.bft_cd_transportadora
																	and frete_diaria.bft_cd_service_center is null 
																	and frete_diaria.bft_estado is null
																	and frete_diaria.bft_vl_inicio_faixa is null
																	and frete_diaria.bft_vl_fim_faixa is null

			--frete por faixa (independente de svc e estado)
			left join tb_fin_base_frete_transportadora frete_faixa on tv.tvl_cd_tipo_veiculo = frete_faixa.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa.bft_cd_transportadora
																	and frete_faixa.bft_cd_service_center is null 
																	and frete_faixa.bft_estado is null
																	and r.KmColetado > (frete_faixa.bft_vl_inicio_faixa - 1)
																	and r.KmColetado <= frete_faixa.bft_vl_fim_faixa
		
			--left join tb_fin_base_km_trevo trevo with(nolock) 
			--										on r.IdTrevo = trevo.bkt_cd_base_km_trevo


			----frete por faixa (independente de svc e estado)
			--left join tb_fin_base_frete_transportadora frete_trevo  on tv.tvl_cd_tipo_veiculo = frete_trevo.bft_cd_tipo_veiculo 
			--														and r.IdTransportadora = frete_trevo.bft_cd_transportadora
			--														and frete_trevo.bft_cd_service_center is null 
			--														and frete_trevo.bft_estado is null
			--														and trevo.bkt_vl_km_ideal > (frete_trevo.bft_vl_inicio_faixa - 1)
			--														and trevo.bkt_vl_km_ideal <= frete_trevo.bft_vl_fim_faixa


			--frete por faixa (independente de svc e estado) considerando km prefautra
			left join tb_fin_base_frete_transportadora frete_faixa_prefatura on tv.tvl_cd_tipo_veiculo = frete_faixa_prefatura.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_prefatura.bft_cd_transportadora
																	and frete_faixa_prefatura.bft_cd_service_center is null 
																	and frete_faixa_prefatura.bft_estado is null
																	and pre.InicioIntervalo >= frete_faixa_prefatura.bft_vl_inicio_faixa
																	and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= frete_faixa_prefatura.bft_vl_fim_faixa

			--frete por faixa e estado
			left join tb_fin_base_frete_transportadora frete_faixa_estado on tv.tvl_cd_tipo_veiculo = frete_faixa_estado.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_estado.bft_cd_transportadora
																	and frete_faixa_estado.bft_cd_service_center is null 
																	and frete_faixa_estado.bft_estado = r.estado
																	and r.KmColetado > (frete_faixa_estado.bft_vl_inicio_faixa - 1)
																	and r.KmColetado <= frete_faixa_estado.bft_vl_fim_faixa

			--frete por faixa e svc
			left join tb_fin_base_frete_transportadora frete_faixa_svc on tv.tvl_cd_tipo_veiculo = frete_faixa_svc.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_svc.bft_cd_transportadora
																	and frete_faixa_svc.bft_cd_service_center = r.serviceCenter
																	and frete_faixa_svc.bft_estado  is null
																	and r.KmColetado > (frete_faixa_svc.bft_vl_inicio_faixa - 1)
																	and r.KmColetado <= frete_faixa_svc.bft_vl_fim_faixa

			--frete por faixa e svc considerando km prefatura
			left join tb_fin_base_frete_transportadora frete_faixa_svc_prefatura on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_prefatura.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_svc_prefatura.bft_cd_transportadora
																	and frete_faixa_svc_prefatura.bft_cd_service_center = r.serviceCenter
																	and frete_faixa_svc_prefatura.bft_estado  is null
																	and pre.InicioIntervalo >= frete_faixa_svc_prefatura.bft_vl_inicio_faixa
																	and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= frete_faixa_svc_prefatura.bft_vl_fim_faixa

			--frete por faixa (independente de svc e estado) km 0 a 100
			left join tb_fin_base_frete_transportadora frete_faixa_Km0a100 on tv.tvl_cd_tipo_veiculo = frete_faixa_Km0a100.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_Km0a100.bft_cd_transportadora
																	and frete_faixa_Km0a100.bft_cd_service_center is null 
																	and frete_faixa_Km0a100.bft_estado is null
																	and frete_faixa_Km0a100.bft_vl_inicio_faixa = 1

			--frete por faixa e svc km 0 a 100
			left join tb_fin_base_frete_transportadora frete_faixa_svc_Km0a100 on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_Km0a100.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_svc_Km0a100.bft_cd_transportadora
																	and frete_faixa_svc_Km0a100.bft_cd_service_center = r.serviceCenter
																	and frete_faixa_svc_Km0a100.bft_estado  is null
																	and frete_faixa_svc_Km0a100.bft_vl_inicio_faixa = 1

			
			left join tb_fin_base_frete_adicional adicional with(nolock) on tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo 
																	and r.IdTransportadora = adicional.bfa_cd_transportadora
																	and adicional.bfa_cd_service_center is null
																	and adicional.bfa_estado  is null


			left join tb_fin_base_frete_adicional adicional_svc with(nolock) on tv.tvl_cd_tipo_veiculo = adicional_svc.bfa_cd_tipo_veiculo 
																	and r.IdTransportadora = adicional_svc.bfa_cd_transportadora
																	and adicional_svc.bfa_cd_service_center =  r.ServiceCenter
																	and adicional_svc.bfa_estado  is null  


			left join 
	
					(
					select a.*,b. cli_id_logistics 
					from tb_fin_resultado_financeiro_alteracao as a
					inner join tb_clientes as b
					on a.idtransportadora = b.cli_cd_codigo_cliente
					) as alteracao

			on r.idrota = alteracao.idrota
			and r.IdTransportadora = alteracao.cli_id_logistics
			
		where 1=1
			--r.IdTransportadora = @IdTransportadora
			--and isnull(r.TipoOrigemSaida,'') <> 'delivery_cell'
			--and r.DataReferencia between @data_inicial and @data_final
			and r.DataReferencia < cast(getdate() as date)
			--and r.DataReferencia = (
			--	select
			--		max(DataReferencia)
			--	from
			--		 tb_ml_rotas r2 with(nolock)
			--	where
			--		r.IdRota = r2.IdRota
			--		and r.IdTransportadora = r2.IdTransportadora
			--		and r2.Excluido = 0
			--)
			--and isnull(r.SubStatusRota,'') not in ('Cancelada','Planejada')
			--and StatusRota <> 'Planejada'
			
		
	) rotas

	

	--Atualiza Indicadores
	exec [UspFinanceiroAtualizaIndicadores] @IdTransportadora, @Ano, @Mes, @Quinzena, 'Faturamento'
	exec [UspFinanceiroAtualizaIndicadores] @IdTransportadora, @Ano, @Mes, @Quinzena, 'Validação'

end

GO
