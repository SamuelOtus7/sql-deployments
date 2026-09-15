-- ============================================================
-- BASELINE: dbo.vw_ml_rotas_financeiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_rotas_financeiro]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_ml_rotas_financeiro]
AS
SELECT
    CAST(r.IdRota AS varchar(50)) IdRota
    ,r.DataReferencia
    ,r.ServiceCenter
    ,r.OrigemSaida
    ,'LM' TipoRota
    ,r.TipoRota TipoRotaDetalhe
    ,r.StatusRota
    ,r.SubStatusRota
    ,r.IdTransportadora
    ,r.DataHoraInicio
    ,r.TotalPacotes
    ,r.PacotesEntregues
    ,r.PacotesNaoEntregue
    ,r.PacotesPendentes
    ,r.PacotesTransferidos
    ,case when r.TotalPacotes = r.TotalSacas and r.TotalPacotes > 0 then 1 else 0 end RotaTipoSaca
    ,r.NomeMotorista
    ,r.TipoVeiculo
    ,r.Placa
    ,r.KmTotal
    ,r.QuantidadePontos
    ,r.QuantidadeParadas
    ,r.KmColetado
    ,r.KmColetadoApp
    ,r.Ambulancia
    ,r.UsouAPP
    ,r.UsuarioDA
    ,r.IdTrevo
    ,r.CidadeDistante
    ,r.KmMapaPacote
    ,r.EnderecosVisitados
    ,r.AmbulanciaStatus
    ,r.AmbulanciaPagamento
    ,r.KmLogistics
    ,r.EnderecosNaoVisitados
    ,r.IdKmProcessado
    ,r.DriverId
    ,r.DataHoraSaidaEstacao
    ,CASE 
        WHEN ISNULL(b.bss_regra_sd, 1) = 1 THEN
            CASE 
                WHEN r.IdTransportadora = 643493085 THEN
                    CASE 
                        WHEN LOWER(ISNULL(r.TipoOrigemSaida, '')) = 'nex' THEN
                            CASE 
                                WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM'
                                WHEN FORMAT(COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio), 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
                                ELSE 'PM'
                            END
                        ELSE
                            CASE 
                                WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM'
                                WHEN FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
                                ELSE 'PM'
                            END
                    END
                ELSE
                    CASE 
                        WHEN r.DataHoraSaidaEstacao IS NOT NULL THEN
                            CASE 
                                WHEN DATEPART(HOUR, r.DataHoraSaidaEstacao) < 12 THEN 'AM'
                                WHEN FORMAT(r.DataHoraSaidaEstacao, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
                                ELSE 'PM'
                            END
                        ELSE
                            CASE 
                                WHEN DATEPART(HOUR, r.DataPrimeiraEntrega) < 12 THEN 'AM'
                                WHEN FORMAT(r.DataPrimeiraEntrega, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
                                ELSE 'PM'
                            END
                    END
            END

        WHEN ISNULL(b.bss_regra_sd, 1) = 2 THEN
            CASE 
                WHEN r.IdTransportadora = 643493085 THEN
                    CASE 
                        WHEN r.TipoRota LIKE '%SD%' THEN 'SD'
                        WHEN LOWER(ISNULL(r.TipoOrigemSaida, '')) = 'nex' THEN
                            CASE WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM' ELSE 'PM' END
                        ELSE
                            CASE WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM' END
                    END
                ELSE
                    CASE 
                        WHEN r.DataHoraSaidaEstacao IS NOT NULL THEN
                            CASE 
                                WHEN r.TipoRota LIKE '%SD%' THEN 'SD'
                                WHEN DATEPART(HOUR, r.DataHoraSaidaEstacao) < 12 THEN 'AM'
                                ELSE 'PM'
                            END
                        ELSE
                            CASE 
                                WHEN r.TipoRota LIKE '%SD%' THEN 'SD'
                                WHEN DATEPART(HOUR, r.DataPrimeiraEntrega) < 12 THEN 'AM'
                                ELSE 'PM'
                            END
                    END
            END

        WHEN ISNULL(b.bss_regra_sd, 1) = 3 THEN
            CASE 
                WHEN r.IdTransportadora = 643493085 THEN
                    CASE 
                        WHEN LOWER(ISNULL(r.TipoOrigemSaida, '')) = 'nex' THEN
                            CASE
                                WHEN (FORMAT(COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio), 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota LIKE '%SD%' THEN 'SD'
                                WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM'
                                ELSE 'PM'
                            END
                        ELSE
                            CASE
                                WHEN (FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota LIKE '%SD%' THEN 'SD'
                                WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM'
                                ELSE 'PM'
                            END
                    END
                ELSE
                    CASE 
                        WHEN r.DataHoraSaidaEstacao IS NOT NULL THEN
                            CASE 
                                WHEN (FORMAT(r.DataHoraSaidaEstacao, 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota LIKE '%SD%' THEN 'SD'
                                WHEN DATEPART(HOUR, r.DataHoraSaidaEstacao) < 12 THEN 'AM'
                                ELSE 'PM'
                            END
                        ELSE
                            CASE 
                                WHEN (FORMAT(r.DataPrimeiraEntrega, 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota LIKE '%SD%' THEN 'SD'
                                WHEN DATEPART(HOUR, r.DataPrimeiraEntrega) < 12 THEN 'AM'
                                ELSE 'PM'
                            END
                    END
            END

         WHEN ISNULL(b.bss_regra_sd, 1) = 4 THEN 
            CASE 
                WHEN r.IdTransportadora = 643493085 THEN 
                    CASE 
                        WHEN LOWER(ISNULL(r.TipoOrigemSaida, '')) = 'nex' THEN 
                            CASE 
                                WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM' ELSE 'PM' 
                            END 
                        ELSE 
                            CASE 
                                WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM' END 
                            END 
                        ELSE 
                            CASE 
                                WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM' END 
                            END 
         END AS Ciclo_Novo

FROM
    tb_ml_rotas r WITH (NOLOCK)
    LEFT JOIN tb_ml_service_center svc WITH (NOLOCK)
        ON r.ServiceCenter = svc.svc_cd_service_center
       AND r.IdTransportadora = svc.IdTransportadora
    LEFT JOIN tb_ml_service_center svc2 WITH (NOLOCK)
        ON CASE WHEN ISNULL(r.OrigemSaida, '') <> '' THEN r.OrigemSaida ELSE r.ServiceCenter END = svc2.svc_cd_service_center
       AND r.IdTransportadora = svc2.IdTransportadora
    LEFT JOIN tb_bases b WITH (NOLOCK)
        ON ISNULL(svc2.svc_cd_service_center, svc.svc_cd_service_center) = b.bss_ds_sigla
       AND r.IdTransportadora = b.bss_cd_idtransportadora
WHERE
    r.Excluido = 0
    AND r.StatusRota <> 'planned'
    AND r.TotalPacotes > 0

UNION ALL

SELECT
    CAST(IdRota AS varchar(50)) IdRota
    ,DataReferencia
    ,OrigemSaida ServiceCenter
    ,NULL OrigemSaida
    ,'FM' TipoRota
    ,NULL TipoRotaDetalhe
    ,Status StatusRota
    ,NULL SubStatusRota
    ,IdTransportadora
    ,DataInicio DataHoraInicio
    ,NULL TotalPacotes
    ,NULL PacotesEntregues
    ,NULL PacotesNaoEntregue
    ,NULL PacotesPendentes
    ,NULL PacotesTransferidos
    ,null RotaTipoSaca
    ,NomeMotorista
    ,TipoVeiculo
    ,PlacaVeiculo Placa
    ,KmPercorrido KmTotal
    ,NULL QuantidadePontos
    ,NULL QuantidadeParadas
    ,NULL KmColetado
    ,NULL KmColetadoApp
    ,NULL Ambulancia
    ,NULL UsouAPP
    ,UsuarioDA
    ,NULL IdTrevo
    ,NULL CidadeDistante
    ,NULL KmMapaPacote
    ,NULL EnderecosVisitados
    ,NULL AmbulanciaStatus
    ,NULL AmbulanciaPagamento
    ,NULL KmLogistics
    ,NULL EnderecosNaoVisitados
    ,NULL IdKmProcessado
    ,IdMotorista DriverId
    ,DataInicio DataHoraSaidaEstacao
    ,NULL Ciclo_Novo
FROM
    tb_ml_fm_rotas WITH (NOLOCK)
WHERE
    Excluido = 0
GO
