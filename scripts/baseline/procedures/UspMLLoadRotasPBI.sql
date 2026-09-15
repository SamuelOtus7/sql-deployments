-- ============================================================
-- BASELINE: dbo.UspMLLoadRotasPBI
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadRotasPBI]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLLoadRotasPBI] (
	@QtdeDiasRetroativo int = 5
)
as
begin

	SET NOCOUNT ON;

	delete tb_ml_rotas_pbi where DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))

	insert into tb_ml_rotas_pbi
	SELECT 
		rotas.Id
		,rotas.IdRota
		,rotas.DataReferencia
		,rotas.DataHoraColeta
		,rotas.DataColeta
		,rotas.ServiceCenter
		,rotas.OrigemSaida
		,rotas.TipoOrigemSaida
		,rotas.Tipo
		,rotas.TipoRota
		,rotas.StatusRota
		,rotas.SubStatusRota
		,rotas.TipoEntrega
		,rotas.IdTransportadora
		,rotas.DataHoraInicio
		,rotas.DataHoraFim
		,rotas.TotalPacotes
		,rotas.PacotesEntregues
		,rotas.PacotesNaoEntregue
		,rotas.PacotesPendentes
		,rotas.PacotesEntreguesForaAreaEntrega
		,rotas.PacotesTransferidos
		,rotas.PacotesRecebidos
		,rotas.TotalSacas
		,rotas.QuantidadeAmbulancia
		,rotas.StatusPrazo
		,rotas.NomeMotorista
		,rotas.NivelExperienciaMotorista
		,rotas.MotoristaArriscado
		,rotas.QuantidadeReclamacoesMotorista
		,rotas.TaxaDeContatoMotorista
		,rotas.IdNivelMotorista
		,rotas.NivelMotorista
		,rotas.QuantidadePacotesTransportados
		,rotas.PercentualEntregasBemSucedidas
		,rotas.PercentualEntregasSemRelamacaoes
		,rotas.PossuiAjudante
		,rotas.TipoVeiculo
		,rotas.Placa
		,rotas.TempoPlanejadoMinutos
		,rotas.PercentualProgresso
		,rotas.KmTotal
		,rotas.TempoEmRota
		,rotas.TempoChegadaAreaEntrega
		,rotas.TempoAreaEntrega
		,rotas.TempoRetornoCentroDistribuicao
		,rotas.TempoInativo
		,rotas.DataAtualizacao
		,rotas.Excluido
		,0 MarcadasACaminho
		,0.0000 KmPlayPop
		,svc.svc_nm_service_center NomeServiceCenter
		,svc.svc_nm_sigla SiglaServiceCenter
		,svc.svc_nm_service_center Região
		,case when PercentualProgresso = 1 then convert(varchar,tempos.UltimaEntrega,108) else '' end as HorarioSaida
		,convert(varchar,dateadd(minute,-TempoEmRota,rotas.DataHoraInicio),108) as HorarioEntrada
		,StatusPrimeirasEntregas.StatusPrimeiraEntrega
		,StatusPrimeirasEntregas.StatusSegundaEntrega
		,SegundosEntreEntregas
		,case when rotas.PacotesEntregues= 0 then 0
				  when StatusRota = 'Ativa' 
					   and PercentualProgresso <> 1
					   and rotas.DataReferencia = cast(getdate() as date)
					   and SegundosUltimaEntrega > 1200 
				  then 20
				  when StatusRota = 'Ativa' 
					   and PercentualProgresso <> 1
					   and rotas.DataReferencia = cast(getdate() as date)
					   and SegundosUltimaEntrega > 900 
				  then 15
				  when StatusRota = 'Ativa' 
					   and PercentualProgresso <> 1
					   and rotas.DataReferencia = cast(getdate() as date)
					   and SegundosUltimaEntrega > 600 
				  then 10
				  else 0 
			  end as Alarme10Minutos
		,TempoEmRota * 60.0 TempoEmRotaSec
		,case when TempoAreaEntrega = 0 then null
				  when PrimeiraEntrega < dateadd(minute,-TempoAreaEntrega,rotas.DataHoraInicio) then 0
				  else datediff(second, dateadd(minute,-TempoAreaEntrega, rotas.DataHoraInicio), primeiraEntrega)
			 end as TempoPrimeiraEntregaSec
		,isnull(tempos.MediaDeEntrega,'') as MediaDeEntrega
		,isnull(tempos.EntregasHora,'') as EntregasHora
		,isnull(tempos.Previsao,'') as Previsao
		,null Ajudante
	FROM 
		tb_ml_rotas rotas with(nolock)
		left join tb_ml_service_center_teste svc on rotas.ServiceCenter = svc.svc_cd_service_center and rotas.idtransportadora = svc.idtransportadora
		left join (
					select 
						IdRota,
						DataReferencia,
						max(case when Ordem = 1 then case when StatusEntrega <> '#EANF#' then StatusEntrega else 'Pendente' end else null end) as StatusPrimeiraEntrega,
						max(case when Ordem = 2 then case when StatusEntrega <> '#EANF#' then StatusEntrega else 'Pendente' end else null end) as StatusSegundaEntrega,
						case when 
							Datediff(second, cast(max(HoraEvento) as datetime),cast(convert(varchar,getdate(),108) as datetime)) is null
						then 9999
						else Datediff(second, cast(max(HoraEvento) as datetime),cast(convert(varchar,getdate(),108) as datetime))
						end as SegundosUltimaEntrega
					from (
							select 
								IdRota,
								DataReferencia,
								t.tds_ds_traducao StatusEntrega,
								left(cast(cast(DataHoraEntrega as time) as varchar),5) HoraEvento,
								ROW_NUMBER() over(partition by IdRota order by isnull(left(cast(cast(DataHoraEntrega as time) as varchar),5),'00:00'), IdPacote) as Ordem
							from 
								tb_ml_pacotes p with(nolock)
								left join tb_ml_traducoes t on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
							where 
								DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date)) 
								and (isdate(left(cast(cast(DataHoraEntrega as time) as varchar),5)) = 1 or left(cast(cast(DataHoraEntrega as time) as varchar),5) is null)
						) as base
					group by 
						IdRota,
						DataReferencia
				  ) as StatusPrimeirasEntregas on rotas.IdRota = StatusPrimeirasEntregas.IdRota
												and rotas.DataReferencia = StatusPrimeirasEntregas.DataReferencia
		left join (
				select IdRota,
					   DataReferencia,
					   convert(varchar,dateadd(second,MediaEntregaMin,0),108) as MediaDeEntrega,
					   round(case when MediaEntregaMin = 0 then 0 else 3600.0 / MediaEntregaMin end,0) as EntregasHora,
					   convert(varchar,dateadd(second,Pendentes * MediaEntregaMin,LastUpdate),108) as Previsao,
					   PrimeiraEntregaDt as PrimeiraEntrega,
					   SegundosEntreEntregas,
					   UltimaEntrega
				from (
						select 
							*,	
							case when Entregues =  0 then 0 else cast(datediff(minute, PrimeiraEntregaDt, LastUpdate) as float) / cast(Entregues as float) * 60.0 end as MediaEntregaMin,
							case when Entregues =  0 then 0 else cast(datediff(second, PrimeiraEntregaDt, LastUpdate) as float) / cast(Entregues as float) end as SegundosEntreEntregas
						from (
								select 
									dateadd(minute,cast(right(PrimeiraEntrega,2) as int) + cast(left(PrimeiraEntrega,2) as int) * 60.0,0) as PrimeiraEntregaDt,
									case when rotas.StatusRota = 'Concluída' then cast(UltimaEntrega as datetime)
									else dateadd(minute,datepart(hour,base.LastUpdate) * 60 + datepart(minute,base.LastUpdate),0)
									end as LastUpdate,
									base.IdRota,
									TotalEntregas,
									base.Pendentes,
									TotalEntregas - base.Pendentes as Entregues,
									rotas.DataReferencia,
									cast(UltimaEntrega as datetime) as UltimaEntrega
								from (
										select  
											rotas.idrota,
											rotas.DataReferencia,
											min(case when left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) = '' then '23:59' else left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) end) as PrimeiraEntrega,
											max(case when left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) = '' then '00:00' else left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) end) as UltimaEntrega,
											count(*) as TotalEntregas,
											sum(case when t.tds_ds_traducao in ('Chegando ao Destino','Pendente','Em rota de entrega','Para expedir') then 1 else 0 end) as Pendentes,
											max(pacotes.DataAtualizacao) as LastUpdate
										from 
											tb_ml_rotas as rotas  with(nolock)
											join tb_ml_pacotes as pacotes  with(nolock) on rotas.IdRota = pacotes.IdRota
											left join tb_ml_traducoes t on pacotes.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
										where
											rotas.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date)) 
											and (isdate(left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5)) = 1 or left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) is null)
										group by 
											rotas.idrota,
											rotas.DataReferencia
										having 
											min(case when left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) = '' then '23:59' else left(cast(cast(pacotes.DataHoraEntrega as time) as varchar),5) end) <> '23:59'
									) as base 
									join tb_ml_rotas as rotas with(nolock)
									on base.IdRota = rotas.IdRota
									and base.DataReferencia = rotas.DataReferencia
							) as base
					) as base
					where MediaEntregaMin > 0
					and Entregues > 0
			) as tempos
			on rotas.IdRota = tempos.IdRota and rotas.DataReferencia = tempos.DataReferencia
	where 
		rotas.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))

end
GO
