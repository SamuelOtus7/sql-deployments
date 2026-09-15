-- ============================================================
-- BASELINE: dbo.UspMLAtualizaRotasPlayTelematicsMLLogistics
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaRotasPlayTelematicsMLLogistics]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLAtualizaRotasPlayTelematicsMLLogistics] (
	@DataInicio date,
	@DataFim date
)
as
begin
select @@version
/*
	--declare @DataReferencia date = '2023-04-01'
	declare @IdTransportadora int = 1359951875

	drop table if exists #rotas
	select 
		r.*,
		isnull(inicio.inicio_rota,inicio.inicio_rota2) inicio_rota,
		isnull(xpt.nm_xpt,r.exp_id) service_center
		into #rotas
	from 
		[PLAYTELEMATICS].ML_Logistics.dbo.ml_log_route r with(nolock) 
		join (
			select
				id_route,
				min(case when des_status='delivered' then delivery_time end) inicio_rota,
				min(delivery_time) inicio_rota2
			from 
				[PLAYTELEMATICS].ML_Logistics.dbo.ml_log_package with(nolock)
			where
				des_status='delivered'
			group by
				id_route
		) inicio on r.id_route = inicio.id_route
		left join (
			select
				id_route,
				min(des_facilityId) nm_xpt
			from 
				[PLAYTELEMATICS].ML_Logistics.dbo.ml_log_package with(nolock)
			where
				des_facilityId like 'e%'
			group by
				id_route
		) xpt on r.id_route = xpt.id_route
	where 
		des_carrier='transitariolog'
		and dt_end_route between @DataInicio and @DataFim


	insert into tb_ml_rotas (IdRota, DataReferencia, DataHoraColeta, ServiceCenter, OrigemSaida, TipoOrigemSaida, Tipo, TipoRota, StatusRota, SubStatusRota, TipoEntrega, IdTransportadora, DataHoraInicio, DataHoraFim, TotalPacotes, PacotesEntregues, PacotesNaoEntregue, PacotesPendentes, PacotesEntreguesForaAreaEntrega, PacotesTransferidos, PacotesRecebidos, TotalSacas, QuantidadeAmbulancia, StatusPrazo, NomeMotorista, NivelExperienciaMotorista, MotoristaArriscado, QuantidadeReclamacoesMotorista, TaxaDeContatoMotorista, IdNivelMotorista, NivelMotorista, QuantidadePacotesTransportados, PercentualEntregasBemSucedidas, PercentualEntregasSemRelamacaoes, PossuiAjudante, TipoVeiculo, Placa, TempoPlanejadoMinutos, PercentualProgresso, KmTotal, TempoEmRota, TempoChegadaAreaEntrega, TempoAreaEntrega, TempoRetornoCentroDistribuicao, TempoInativo, DataAtualizacao, Excluido, QuantidadePontos, QuantidadeParadas, DataUltimaAtualizacaoPacote, DataPrimeiraEntrega, LinkMapa, StatusPrimeiraEntrega, StatusSegundaEntrega, QuantidadeReclamacoes, KmColetado, DataUltimaEntrega, KmColetadoApp, LinkMapaApp, KmColetadoGeo, LinkMapaGeo, Cidades, CidadeReferencia)
	select
		r.id_route
		,r.dt_end_route DataReferencia
		,r.created_at
		,r.exp_id
		,'' OrigemSaida --montar de para para saber se é xpt
		,null TipoOrigemSaida
		,'' Tipo
		,'' TipoRota
		,isnull(t.tds_vl_json,r.des_status) StatusRota
		,'' SubStatusRota
		,'' TipoEntrega
		,@IdTransportadora IdTransportadora
		,r.inicio_rota DataHoraInicio 
		,null DataHoraFim
		,isnull(r.delivered,0) + isnull(r.not_delivered,0) + isnull(r.pending,0) TotalPacotes
		,isnull(r.delivered,0) PacotesEntregues
		,isnull(r.not_delivered,0) PacotesNaoEntregue
		,isnull(r.pending,0) PacotesPendentes
		,0 PacotesEntreguesForaAreaEntrega
		,0 PacotesTransferidos
		,0 PacotesRecebidos
		,0 TotalSacas
		,0 QuantidadeAmbulancia
		,'' StatusPrazo
		,r.des_driver NomeMotorista
		,'' NivelExperienciaMotorista
		,0 MotoristaArriscado
		,0 QuantidadeReclamacoesMotorista
		,null TaxaDeContatoMotorista
		,'' IdNivelMotorista
		,'' NivelMotorista
		,0 QuantidadePacotesTransportados
		,0 PercentualEntregasBemSucedidas
		,0 PercentualEntregasSemRelamacaoe
		,0 PossuiAjudante
		,replace(replace(replace(replace(replace(r.vehicle_type, 'UtilitÃ¡rio', 'Utilitário'), 'Ãºnica', 'única'), 'VeÃ­culo', 'Veículo'), ' â€“ ', ' – '),'MÃ©dio', 'Médio') TipoVeiculo
		,r.license_plate
		,null TempoPlanejadoMinutos
		,0 PercentualProgresso
		,0 KmTotal
		,0 TempoEmRota
		,0 TempoChegadaAreaEntrega
		,0 TempoAreaEntrega
		,0 TempoRetornoCentroDistribuicao
		,null TempoInativo
		,getdate() DataAtualizacao
		,0 Excluido
		,0 QuantidadePontos
		,0 QuantidadeParadas
		,null DataUltimaAtualizacaoPacote
		,null DataPrimeiraEntrega
		,null LinkMapa
		,null StatusPrimeiraEntrega
		,null StatusSegundaEntrega
		,0 QuantidadeReclamacoes
		,0 KmColetado
		,null DataUltimaEntrega
		,null KmColetadoApp
		,null LinkMapaApp
		,null KmColetadoGeo
		,null LinkMapaGeo
		,null Cidades
		,null CidadeReferencia
	from
		#rotas r
		left join tb_ml_traducoes t on r.des_status = t.tds_ds_traducao collate Latin1_General_CI_AS and t.tds_nm_tabela = 'tb_ml_rotas' and t.tds_nm_campo = 'StatusRota'
		left join tb_ml_rotas r2 on r.id_route = r2.IdRota and r2.DataReferencia = r.dt_end_route and r2.IdTransportadora = @IdTransportadora
	where
		r2.idrota is null

END

*/

end
GO
