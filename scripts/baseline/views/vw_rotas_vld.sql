-- ============================================================
-- BASELINE: dbo.vw_rotas_vld
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_vld]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vw_rotas_vld]
as

select 
	r.IdTransportadora,
	r.Id,
	r.IdRota,
	r.DataReferencia DataReferencia,
	r.DataHoraInicio,
	isnull(t2.tds_ds_traducao,r.StatusRota) as StatusRota,
	t4.tds_ds_traducao SubStatusRota,
	t3.tds_ds_traducao StatusPrazo,
	isnull(svc.svc_cd_service_center,r.ServiceCenter) ServiceCenter,
	svc.svc_nm_service_center NomeServiceCenter,
	coalesce(b.dab_nm_base,svc.svc_cd_service_center,r.ServiceCenter) Base,
	isnull(b.dab_nm_cidade,svc.svc_nm_cidade) CidadeBase,
	r.TipoOrigemSaida,
	r.OrigemSaida,
	r.TipoRota,
	r.TipoVeiculo,
	r.NomeMotorista,
	r.Placa,
	t1.tds_ds_traducao NivelExperienciaMotorista,
	r.IdNivelMotorista,
	r.NivelMotorista,
	r.QuantidadePacotesTransportados,
	r.PercentualEntregasBemSucedidas,
	r.PercentualEntregasSemRelamacaoes,
	r.PossuiAjudante,
	case when r.PossuiAjudante = 1 then 'Sim' else 'Não' end Ajudante,
	
	
	--COALESCE(KmColetadoApp,KmColetadoGeo,KmColetado)    AS KmColetado,

	--COALESCE(LinkMapaApp,LinkMapaGeo,LinkMapa) AS LinkMapa,

	
CASE 
		WHEN (ISNULL(r.KmColetadoApp, 0) <= 10 or ISNULL(r.KmColetadoApp, 0) >= 300) 
			THEN (CASE 
					WHEN ISNULL(r.KmColetadoGeo, 0) > ISNULL(r.KmColetado, 0) and ISNULL(r.KmColetadoGeo, 0) between 10 and 300
						THEN ISNULL(r.KmColetadoGeo, 0)
					WHEN ISNULL(r.KmColetado, 0) > ISNULL(r.KmColetadoGeo, 0) or ISNULL(r.KmColetado, 0)  between 10 and 300
						THEN 
							(
							CASE 
								WHEN ISNULL(r.KmColetado, 0) < 300 
									THEN ISNULL(r.KmColetado, 0) 
							else (
								 CASE 
									WHEN ISNULL(r.KmColetadoApp, 0) > ISNULL(r.KmColetadoGeo, 0)
										then 
											(
												case 
													when ISNULL(r.KmColetadoGeo, 0) < 3 
														then 
															(
															case 
																when ISNULL(r.KmColetadoApp, 0) > ISNULL(r.KmColetado, 0)
																	then ISNULL(r.KmColetadoApp, 0)
															else  ISNULL(r.KmColetado, 0) end
															)
												else ISNULL(r.KmColetadoGeo, 0) end
											)
								  else
								  
								  (
						case 
							when ISNULL(r.KmColetadoApp, 0) = 0
								then
									(case 
										when ISNULL(r.KmColetadoGeo, 0) > ISNULL(r.KmColetado, 0) and ISNULL(r.KmColetadoGeo, 0) < 300
											then ISNULL(r.KmColetadoGeo, 0)
										else ISNULL(r.KmColetado, 0) end)
							else ISNULL(r.KmColetadoApp, 0) end 
								  )
								  end
								  )
							END
							)
					ELSE
						(
						case 
							when ISNULL(r.KmColetadoApp, 0) = 0
								then
									(case 
										when ISNULL(r.KmColetadoGeo, 0) > ISNULL(r.KmColetado, 0) and ISNULL(r.KmColetadoGeo, 0) < 300
											then ISNULL(r.KmColetadoGeo, 0)
										else ISNULL(r.KmColetado, 0) end)
							else ISNULL(r.KmColetadoApp, 0) end
										
						)
				END)
		ELSE (
			CASE 
				WHEN ISNULL(r.KmColetadoApp, 0) > ISNULL(r.KmColetado, 0)
					then  (
							case 
								when ISNULL(r.KmColetado, 0) = 0 or ISNULL(r.KmColetado, 0) < 3
									then ISNULL(r.KmColetadoApp, 0)  
							else ISNULL(r.KmColetado, 0) end
							)
				else ISNULL(r.KmColetadoApp, 0) end
			) END    AS KmColetado,

CASE 
		WHEN ISNULL(r.KmColetadoApp, 0) <= 10 or ISNULL(r.KmColetadoApp, 0) >= 300
			THEN (CASE 
					WHEN ISNULL(r.KmColetadoGeo, 0) > ISNULL(r.KmColetado, 0) and ISNULL(r.KmColetadoGeo, 0) < 300
						THEN r.LinkMapaGeo
					WHEN ISNULL(r.KmColetado, 0) > ISNULL(r.KmColetadoGeo, 0) or ISNULL(r.KmColetado, 0) < 300
						THEN 
							(
							CASE 
								WHEN ISNULL(r.KmColetado, 0) < 300 
									THEN r.LinkMapa 
							else (
								 CASE 
									WHEN ISNULL(r.KmColetadoApp, 0) > ISNULL(r.KmColetadoGeo, 0)
										then  
											(
												case 
													when ISNULL(r.KmColetadoGeo, 0) < 3 
														then 
															(
															case 
																when ISNULL(r.KmColetadoApp, 0) > ISNULL(r.KmColetado, 0)
																	then r.LinkMapaApp
															else  r.LinkMapa end
															)
												else r.LinkMapaGeo end
											)
								  else 
						(
						case 
							when ISNULL(r.KmColetadoApp, 0) = 0
								then
									(case 
										when ISNULL(r.KmColetadoGeo, 0) > ISNULL(r.KmColetado, 0) and ISNULL(r.KmColetadoGeo, 0) < 300
											then r.LinkMapaGeo
										else r.LinkMapa end)
							else r.LinkMapaApp end
										
						)
								  end
								  )
							END
							)
					ELSE
						(
						case 
							when ISNULL(r.KmColetadoApp, 0) = 0
								then
									(case 
										when ISNULL(r.KmColetadoGeo, 0) > ISNULL(r.KmColetado, 0) and ISNULL(r.KmColetadoGeo, 0) < 300
											then r.LinkMapaGeo
										else r.LinkMapa end)
							else r.LinkMapaApp end
										
						)
				END)
		ELSE (
			CASE 
				WHEN ISNULL(r.KmColetadoApp, 0) > ISNULL(r.KmColetado, 0)
					then  (
							case 
								when ISNULL(r.KmColetado, 0) = 0 or ISNULL(r.KmColetado, 0) < 3
									then LinkMapaApp  
							else r.LinkMapa end
							)
				else r.LinkMapaApp end
			) END  AS LinkMapa,


	r.TotalPacotes,
	r.PacotesEntregues,
	r.PacotesPendentes,
	r.PacotesNaoEntregue,
	r.PacotesEntreguesForaAreaEntrega,
	r.PacotesTransferidos,
	r.TempoEmRota,
	r.TempoChegadaAreaEntrega,
	r.TempoAreaEntrega,
	r.PercentualProgresso,
	r.KmTotal,
	r.TempoEmRota * 60.0 TempoEmRotaSec,
	case when PacotesEntregues = 0 then 0 else cast(datediff(second, r.DataPrimeiraEntrega, r.DataUltimaAtualizacaoPacote) as float) / cast(r.PacotesEntregues as float) end SegundosEntreEntregas,
	case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end RotaFinalizada,
	case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 'Finalizada' else 'Em andamento' end StatusGeralRota,
	r.QuantidadePontos,
	r.QuantidadeParadas,
	r.QuantidadeReclamacoes,
	r.QuantidadeAmbulancia,
	r.StatusPrimeiraEntrega,
	r.StatusSegundaEntrega,
	r.DataUltimaEntrega,
	r.Cidades,
	r.CidadeReferencia,
	isnull(r.KmColetado,0) KmColetadoMeli,
	r.LinkMapa LinkMapaMeli,
	r.KmColetadoApp KmColetadoAPP,
	r.LinkMapaApp,
	r.Ambulancia,
	r.KmMotorista
from
	tb_ml_rotas r with(nolock)
	left join tb_ml_traducoes t1 on r.NivelExperienciaMotorista = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_ml_rotas' and t1.tds_nm_campo = 'NivelExperienciaMotorista'
	left join tb_ml_traducoes t2 on r.StatusRota = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_rotas' and t2.tds_nm_campo = 'StatusRota'
	left join tb_ml_traducoes t3 on r.StatusPrazo = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_rotas' and t3.tds_nm_campo = 'StatusPrazo'
	left join tb_ml_traducoes t4 on r.SubStatusRota = t4.tds_vl_json and t4.tds_nm_tabela = 'tb_ml_rotas' and t4.tds_nm_campo = 'SubStatusRota'
	left join tb_ml_service_center svc on r.ServiceCenter = svc.svc_cd_service_center

	left join tb_ml_service_center svc2 on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
	left join tb_dra_bases b on isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) = b.dab_cd_service_center and r.IdTransportadora = b.dab_cd_transportadora
where
	r.Excluido = 0
	
GO
