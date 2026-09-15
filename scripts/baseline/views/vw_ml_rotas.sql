-- ============================================================
-- BASELINE: dbo.vw_ml_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_rotas]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ml_rotas]
as

SELECT r.[Id]
      ,r.[IdRota]
      ,r.[DataReferencia]
      ,r.[DataHoraColeta]
      ,r.[DataColeta]
      ,r.[ServiceCenter]
      ,r.[OrigemSaida]
      ,r.[TipoOrigemSaida]
      ,r.[Tipo]
      ,r.[TipoRota]
      ,r.[StatusRota]
      ,r.[SubStatusRota]
      ,r.[TipoEntrega]
      ,r.[IdTransportadora]
      ,r.[DataHoraInicio]
      ,r.[DataHoraFim]
      ,r.[TotalPacotes]
      ,r.[PacotesEntregues]
      ,r.[PacotesNaoEntregue]
      ,r.[PacotesPendentes]
      ,r.[PacotesEntreguesForaAreaEntrega]
      ,r.[PacotesTransferidos]
      ,r.[PacotesRecebidos]
      ,r.[TotalSacas]
      ,r.[QuantidadeAmbulancia]
      ,r.[StatusPrazo]
      ,r.[NomeMotorista]
      ,r.[NivelExperienciaMotorista]
      ,r.[MotoristaArriscado]
      ,r.[QuantidadeReclamacoesMotorista]
      ,r.[TaxaDeContatoMotorista]
      ,r.[IdNivelMotorista]
      ,r.[NivelMotorista]
      ,r.[QuantidadePacotesTransportados]
      ,r.[PercentualEntregasBemSucedidas]
      ,r.[PercentualEntregasSemRelamacaoes]
      ,r.[PossuiAjudante]
      ,r.[TipoVeiculo]
      ,r.[Placa]
      ,r.[TempoPlanejadoMinutos]
      ,r.[PercentualProgresso]
      ,r.[KmTotal]
      ,r.[TempoEmRota]
      ,r.[TempoChegadaAreaEntrega]
      ,r.[TempoAreaEntrega]
      ,r.[TempoRetornoCentroDistribuicao]
      ,r.[TempoInativo]
      ,r.[DataAtualizacao]
      ,r.[Excluido]
      ,r.[QuantidadePontos]
      ,r.[QuantidadeParadas]
      ,r.[DataUltimaAtualizacaoPacote]
      ,r.[DataPrimeiraEntrega]
      ,r.[LinkMapa]
      ,r.[StatusPrimeiraEntrega]
      ,r.[StatusSegundaEntrega]
      ,r.[QuantidadeReclamacoes]
      ,r.[KmColetado]
      ,r.[DataUltimaEntrega]
      ,r.[KmColetadoApp]
      ,r.[LinkMapaApp]
      ,r.[KmColetadoGeo]
      ,r.[LinkMapaGeo]
      ,r.[Cidades]
      ,r.[CidadeReferencia]
      ,r.[Ambulancia]
      ,r.[OrigemSaidaAmbulancia]
      ,r.[KmMotorista]
      ,r.[DataCriacao]
      ,r.[LinkAppInterno]
      ,r.[UsouAPP]
      ,r.[UsuarioDA]
      ,r.[Apuracao]
      ,r.[QuantidadeApontamento]
      ,r.[FaixaPrimeiroUltimoPacote]
      ,r.[QuantidadeReclamacoesClaims]
      ,r.[StatusReclamacoes]
      ,r.[QuantidadeReclamacoesAbertas]
      ,r.[QuantidadeReclamacoesFechadas]
      ,r.[IdTrevo]
      ,r.[CidadeDistante]
      ,r.[KmMapaPacote]
      ,r.[LinkPacote]
      ,r.[EnderecosVisitados]
      ,r.[TeveAcaoGps]
      ,r.[QuantidadePnr]
      ,r.[Cidade_distrito]
      ,r.[AmbulanciaStatus]
      ,r.[AmbulanciaPagamento]
      ,r.[AmbulanciaIdMotorista]
      ,r.[DataInicioRota]
      ,r.[DataFimRota]
      ,r.[KmLogistics]
      ,r.[IDKmRtt]
      ,r.[EnderecosNaoVisitados]
      ,r.[IdKmProcessado]
      ,r.[DriverId]
      ,r.[DriverUserId]
      ,r.[DataHoraSaidaEstacao]
      ,  
        CASE 
            WHEN isnull(bss_regra_sd,1) = 1 THEN
                
                case when DATEPART(hour,DataHoraInicio) < 12 then 'AM' WHEN FORMAT(DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD' ELSE 'PM' end

            WHEN isnull(bss_regra_sd,1) = 2 THEN
                CASE 
                    WHEN r.DataHoraSaidaEstacao IS NOT NULL THEN
                        CASE 
                            WHEN r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, r.DataHoraSaidaEstacao) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                    ELSE
                        CASE 
                            WHEN r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, r.DataPrimeiraEntrega) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                END
      
            WHEN isnull(bss_regra_sd,1) = 3 THEN
                CASE 
                    WHEN r.DataHoraSaidaEstacao IS NOT NULL THEN
                        CASE 
                            WHEN (FORMAT(r.DataHoraSaidaEstacao, 'HH:mm') BETWEEN '15:40' AND '17:30') or r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, r.DataHoraSaidaEstacao) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                    ELSE
                        CASE 
                            WHEN (FORMAT(r.DataPrimeiraEntrega, 'HH:mm') BETWEEN '15:40' AND '17:30') or r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, r.DataPrimeiraEntrega) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                END 

        END AS ciclo

  FROM 
    tb_ml_rotas r with(nolock)
    join tb_clientes cli with (nolock) on r.IdTransportadora = cli.cli_id_logistics 
                                        and cli.cli_in_ativo = 1 
                                        and cli.cli_cd_codigo_cliente <> 7
    left join tb_ml_service_center svc with (nolock) on r.ServiceCenter = svc.svc_cd_service_center 
                                                    and r.idtransportadora = svc.idtransportadora
    left join tb_ml_service_center svc2 with (nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
                                                 and r.idtransportadora = svc2.idtransportadora
    left join tb_bases b with (nolock) on isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) = b.bss_ds_sigla 
                                        and r.IdTransportadora = b.bss_cd_idtransportadora
    left join tb_parametros as par on par.prm_cod_cliente = cli.cli_cd_codigo_cliente 
                                        and prm_nm_parametro = 'Visibilidade Padrão de Bases'

where 
    r.StatusRota <> 'planned' 
    and r.Excluido = 0 
    and isnull(r.SubStatusRota,'') <> 'cancelled'
    and (
      1 = isnull(par.prm_ds_valor,1)
         or (
                0 = isnull(par.prm_ds_valor,1)
                and isnull(b.bss_visibilidade,0) = 1 
            )
  ) 
GO
