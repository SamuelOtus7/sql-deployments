/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akjfupg
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-05
  Descricao    : Reclassifica a coluna TipoRotaClassificada da view vw_rotas
                 (que alimenta vw_saas_rotas) pela composicao dos pacotes da
                 rota, via tb_ml_pacotes.TipoPonto:
                   - TipoRota com prefixo 'S' ou 'U'  -> 'Rota Volumosa' (mantido, precede tudo)
                   - somente coletas (pickup)           -> 'Coleta'
                   - coletas + entregas                 -> 'Rota Híbrida'
                   - somente entregas / sem pacotes     -> 'Rota Convencional'
                 Pacote pickup ja efetivado (StatusEntrega='picked_up') em
                 outra rota nao conta como coleta desta rota.
                 Fallback preservado: rota nomeada 'Coleta' sem entregas
                 detectadas continua 'Coleta'.
                 Mudancas de comportamento vs. versao vigente:
                   - TipoRota NULL/vazio passa de '' para 'Rota Convencional';
                   - rota 'Coleta' com entregas vira 'Rota Híbrida' (a linha
                     WHEN TipoRota='Coleta' existia apenas no banco — fora do
                     baseline do repo — e foi mantida como fallback).
                 Exemplo de referencia da task: rota 434538931.
  Rollback     : scripts/rollback/2026/10/033_rollback_CU-86akjfupg_tipo_rota_classificada.sql
  Objetos      : dbo.vw_rotas
  Dependencias : dbo.tb_ml_rotas, dbo.tb_ml_pacotes (TipoPonto), dbo.tb_clientes,
                 dbo.tb_ml_traducoes, dbo.tb_ml_service_center, dbo.tb_bases,
                 dbo.tb_motorista, dbo.tb_veiculos, dbo.tb_lancamentos_manuais,
                 dbo.tb_ml_processamento_km_rotas, dbo.tb_ml_fm_rotas,
                 dbo.tb_ml_mo_rotas, dbo.tb_ml_lh_rotas, dbo.vw_saas_rotas
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID('dbo.vw_rotas'))
        THROW 50001, 'View dbo.vw_rotas nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_ml_pacotes') AND name = 'TipoPonto')
        THROW 50002, 'Coluna tb_ml_pacotes.TipoPonto nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL
--    CREATE OR ALTER VIEW precisa ser a primeira instrucao do batch.
--============================================================================


CREATE OR ALTER view [dbo].[vw_rotas]
as
select 
distinct 
r.IdTransportadora,
r.Id,
r.IdRota,
r.DataReferencia ,
r.DataHoraInicio,
r.TempoPlanejadoMinutos,
isnull(t2.tds_ds_traducao,r.StatusRota) as StatusRota,
t4.tds_ds_traducao SubStatusRota,
t3.tds_ds_traducao StatusPrazo,
isnull(svc.svc_cd_service_center,r.ServiceCenter) ServiceCenter,
svc.svc_nm_service_center NomeServiceCenter,
coalesce(b.bss_ds_nome,svc.svc_cd_service_center,r.ServiceCenter) Base,
--coalesce(b.dab_nm_base,svc.svc_cd_service_center,r.ServiceCenter) Base, -- Matheus 20/10/2025 alterado para pegar da tb_bases
isnull(b.bss_ds_cidade,svc.svc_nm_cidade) CidadeBase,
--isnull(b.dab_nm_cidade,svc.svc_nm_cidade) CidadeBase, -- Matheus 20/10/2025 alterado para pegar da tb_bases
r.TipoOrigemSaida,
--case when svc.svc_in_ambulancia = 1 and r.TipoRota is null then svc.svc_ds_origem_base else r.OrigemSaida end OrigemSaida,
CASE WHEN r.IdTransportadora = '2087146923' and svc.svc_in_ambulancia = 1 and r.TipoRota is null THEN r.OrigemSaida
WHEN svc.svc_in_ambulancia = 1 AND r.TipoRota IS NULL THEN svc.svc_ds_origem_base
    ELSE isnull(r.OrigemSaida,r.ServiceCenter) -- ALTERADO POR MURILO 08/06 SOLICITAÇÃO DA ISADORA PARA QUANDO NÃO HOUVER XPT, APARECER O SVC
END AS OrigemSaida,
r.TipoRota,
r.TipoVeiculo,
COALESCE(NULLIF(LTRIM(RTRIM(r.nomemotorista)), ''), '-') AS NomeMotorista,
mot_cd_motorista as IdMotorista,
mot_cd_usuario as Codigo_usuario_motorista,
CASE 
    WHEN LTRIM(RTRIM(r.Placa)) = '' THEN '-'
    ELSE isnull(r.Placa,'-')
END AS Placa, -- Ajustado para destravar atualização de relatórios. Será necessária tratativa direta nas cargas da tabela para não termos valores nulos e em branco
t1.tds_ds_traducao NivelExperienciaMotorista,
r.IdNivelMotorista,
case 
when r.NivelMotorista = 'Platino' then 'Platina'
when r.NivelMotorista = 'Oro' then 'Ouro'
when r.NivelMotorista = 'Plata' then 'Prata'
when r.NivelMotorista = 'Bronce' then 'Bronze'
else r.NivelMotorista end NivelMotorista,
r.QuantidadePacotesTransportados,
r.PercentualEntregasBemSucedidas,
r.PercentualEntregasSemRelamacaoes,
r.PossuiAjudante,
case when r.PossuiAjudante = 1 then 'Sim' else 'Não' end Ajudante,
    isnull(
case  
when 
case when KmColetadoApp = 0 then kms.pontosRotasPacotesKm else KmColetadoApp end = 0
then 1 
else 
case when KmColetadoApp = 0 then kms.pontosRotasPacotesKm else KmColetadoApp end
end

,1)  AS KmColetado,
--isnull(case when KmColetadoApp = 0 then KmColetado else KmColetadoApp end,1)  AS KmColetado,
    r.LinkAppInterno AS LinkMapa,
r.UsouAPP,
r.UsuarioDA,
CASE WHEN isnull(svc.svc_cd_service_center,r.ServiceCenter) ='SSP45' AND r.idtransportadora = 1491631999 then 'Itaquera'
 WHEN isnull(svc.svc_cd_service_center,r.ServiceCenter) ='SSP21' AND r.idtransportadora = 1491631999 then 'São Paulo' 
else replace(CidadeDistante,'Distrito de ','') end as CidadeDistante,
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
--r.KmTotal, Atualizado para exibir kilometragem correta do Silos.
--CASE 
--    WHEN r.DataReferencia >= '2025-07-15' THEN r.KmLogistics
--    ELSE r.KmTotal
--END AS KmTotal
CAST(
    COALESCE(
        TRY_CONVERT(decimal(18,4), KMLogistics),
        TRY_CONVERT(decimal(18,4), r.KMTotal)
    ) 
AS decimal(18,4)) AS KmTotal

,r.TempoEmRota * 60.0 TempoEmRotaSec,
case when PacotesEntregues = 0 then 0 else cast(datediff(second, r.DataPrimeiraEntrega, r.DataUltimaAtualizacaoPacote) as float) / cast(r.PacotesEntregues as float) end SegundosEntreEntregas,
case when r.TotalPacotes = r.PacotesEntregues+ r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end RotaFinalizada,
case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or (r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 'Finalizada' else 'Em andamento' end StatusGeralRota,
r.QuantidadePontos,
r.QuantidadeParadas,
r.QuantidadeReclamacoes,
--case when r.QuantidadeAmbulancia > 0 then 1 else 0 end QuantidadeAmbulancia,
isnull(r.QuantidadeAmbulancia,0) as QuantidadeAmbulancia ,
r.StatusPrimeiraEntrega,
r.StatusSegundaEntrega,
r.DataPrimeiraEntrega,
r.DataUltimaEntrega,
r.Cidades,
r.CidadeReferencia,
isnull(r.KmColetado,0) KmColetadoMeli,
r.LinkMapa LinkMapaMeli,
kms.pontosAppRotasTotalKm KmColetadoAPP,
--isnull(case when r.KmColetadoApp = 0 then r.KmMapaPacote else r.KmColetadoApp end,1)  AS KmColetadoAPP,
r.LinkMapaApp,
    -- r.Ambulancia
case when r.TipoRota is null or ambulancia = 1  then 'Sim' else 'Não' end AmbulanciaFiltro,

case when r.TipoRota is null or ambulancia = 1 then 1 else 0 end Ambulancia,

r.KmMotorista,
r.QuantidadeApontamento,
r.Apuracao,
format(r.DataPrimeiraEntrega, 'HH:mm') AS HoraInicio,
case when DATEPART(hour,r.DataPrimeiraEntrega) < 12 then 'AM'
  WHEN FORMAT(r.DataPrimeiraEntrega, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
  ELSE 'PM' end Ciclo,

-- inclusão do indicador de tempo desde a ultima rota para corrigir o alerta no monitoramento de entregas
CASE WHEN r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos OR r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue OR (r.StatusRota = 'planned' AND r.DataReferencia < CAST(GETDATE() AS DATE)) THEN 0 
 WHEN DataReferencia = CAST(GETDATE() AS DATE) AND DATEDIFF(MINUTE, DataUltimaEntrega, GETDATE()) > 40 THEN 2 
 WHEN DataReferencia = CAST(GETDATE() AS DATE) AND DATEDIFF(MINUTE, DataUltimaEntrega, GETDATE()) between 30 and 40   THEN 1 ELSE 0 END AS AlarmeRotaEntregaAtraso,

CASE 
    WHEN (r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos 
          OR r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue 
          OR (r.StatusRota = 'planned' AND r.DataReferencia < CAST(GETDATE() AS DATE))) THEN 'Sem Atrasos'
    WHEN r.DataReferencia = CAST(GETDATE() AS DATE) 
         AND DATEDIFF(MINUTE, r.DataUltimaEntrega, GETDATE()) >= 30 THEN 'Atrasos'
    ELSE 'Sem Atrasos'
END AS AlarmeRotaEntregaAtrasoFiltro,

--case when DataReferencia = cast(getdate() as date) and datediff(minute,DataUltimaEntrega,getdate()) > 30 
--and case when r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos or r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue or 
--(r.StatusRota = 'planned' and r.DataReferencia < cast(getdate() as date)) then 1 else 0 end = 0 then 'Atrasos' else 'Sem Atrasos' end AlarmeRotaEntregaAtrasoFiltro,
r.FaixaPrimeiroUltimoPacote,    
r.TempoInativo,
    'LM' tipo,
    'https://envios.adminml.com/logistics/monitoring-distribution/detail/' + cast(r.IdRota as varchar(15)) + 'site=MLB' LogisticsRota
    ,'A: ' + cast(isnull(QuantidadeReclamacoesAbertas,0) as varchar(5)) +  ' | F: ' + cast(isnull(QuantidadeReclamacoesFechadas,0) as varchar(5)) Reclamacores

--Esta condição abaixo é para a visão de alterar o monitoramento MELI de base p/ XPT
--Atualizado. Lógica de XPT incompleta.
   -- ,case when r.OrigemSaida = '' OR r.OrigemSaida is null then isnull(svc.svc_cd_service_center,r.ServiceCenter) else r.OrigemSaida end CodOrigemSaida
  , CASE
  WHEN r.OrigemSaida IS NULL
    OR r.OrigemSaida = ''
    OR r.ServiceCenter <> r.OrigemSaida
  THEN ISNULL(svc.svc_cd_service_center, r.ServiceCenter)
  ELSE r.OrigemSaida
END AS CodOrigemSaida

    ,case when r.OrigemSaida = '' OR r.OrigemSaida is null then svc.svc_nm_service_center else  svc.svc_nm_sigla  end DescOrigemSaida

--Esta condicao é para cria uma classificação para ser utilizado no monitoramento MELI
    ,case
        when r.TempoEmRota - r.TempoAreaEntrega <= 30   then    'Até 30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 60   then    '30m a 1h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 90   then    '1h a 1h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 120  then    '1h30m a 2h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 150  then    '2h a 2h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 180  then    '2h30m a 3h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 210  then    '3h a 3h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 240  then    '3h30m a 4h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 270  then    '4h a 4h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 300  then    '4h30m a 5h'
        when r.TempoEmRota - r.TempoAreaEntrega <= 330  then    '5h a 5h30m'
        when r.TempoEmRota - r.TempoAreaEntrega <= 360  then    '5h30m a 6h'
        when r.TempoEmRota - r.TempoAreaEntrega >  360  then    'Mais que 6h'
            end as ClassificacaoStemOut,
svc.bss_ds_label,
isnull(isnull(svc.svc_cd_service_center,r.ServiceCenter) + ' - ' + svc.svc_nm_cidade
,isnull(svc.svc_cd_service_center,r.ServiceCenter)
) Svc_Cidade,
svc.svc_nm_estado as Estado,
IdTrevo,
--CidadeDistante,
case 
when left(r.tiporota,1) = 'r' then 'Sim' 
when tlm_cd_risco_ajudante = 'risco' then 'Sim' 
else 'Não' end as LancRisco,
    LinkPacote,
    kms.pontosRotasPacotesKm as  KmMapaPacote,
    case 
        when  veiculo.vei_in_frota_fixa = 3     then 'Própria - Veículo da transportadora'
        when  veiculo.vei_in_frota_fixa = 2     then 'Fixa - Veículo alugado'
        when  veiculo.vei_in_frota_fixa = 1     then 'Spot - Veículo do motorista'
        else 'Não informado'        
    end as CategoriaVeiculo,
    TotalPacotes - QuantidadeAmbulancia as PacotesDS,
cast(isnull(QuantidadeReclamacoesAbertas,0) as varchar(5))+ '/' + cast((isnull(QuantidadeReclamacoesFechadas,0)+isnull(QuantidadeReclamacoesAbertas,0)) as varchar(5)) ReclamacoesAbertasPeloTotalReclamacoes
,CASE
        WHEN FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'TRUE'
        ELSE 'FALSE'
    END AS FlagSEMIDAY,
r.TotalSacas,
CASE WHEN ServiceCenter = 'SSP27' THEN OrigemSaida
ELSE ServiceCenter  end AS NovoXPT,
TotalPacotes - TotalSacas as PacotesSemSacas,

ISNULL(tratativas.PacotesComImagem,0) as PacotesComImagem
,vei_Cd_ano
,r.DataAtualizacao -- CAMPO USADO NA API DE MONITORAMENTO
,r.EnderecosVisitados
,r.TeveAcaoGps
,svc.svc_nm_region
,ISNULL(QuantidadeReclamacoesAbertas,0) AS QTD_Reclamacoes_em_aberto
,ISNULL(QuantidadeReclamacoes,0) as QTD_Reclamacoes_total
,vei_dh_criacao
,r.QuantidadePnr
--campos acrescentados para incluir ambulancias looker no relatório de monitoramento
,AmbulanciaStatus
,AmbulanciaPagamento
,AmbulanciaIdMotorista
,TipoFrota
,rtt.KmTotal as KM_Rtt
,cast(trevo.bkt_vl_km_ideal as DECIMAL(10,2)) as KM_Trevo
,     DataHoraSaidaEstacao

    ,CASE 
    WHEN isnull(bss_regra_sd,1) = 1 THEN
        CASE 
            WHEN r.IdTransportadora = 643493085 THEN
                CASE 
                    WHEN LOWER(ISNULL(r.TipoOrigemSaida,'')) = 'nex' THEN
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

    WHEN isnull(bss_regra_sd,1) = 2 THEN
        CASE 
            WHEN r.IdTransportadora = 643493085 THEN
                CASE 
                    WHEN r.TipoRota like '%SD%' THEN 'SD'
                    WHEN LOWER(ISNULL(r.TipoOrigemSaida,'')) = 'nex' THEN
                        CASE WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM' ELSE 'PM' END
                    ELSE
                        CASE WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM' END
                END
            ELSE
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
        END

    WHEN isnull(bss_regra_sd,1) = 3 THEN
        CASE 
            WHEN r.IdTransportadora = 643493085 THEN
                CASE 
                    WHEN LOWER(ISNULL(r.TipoOrigemSaida,'')) = 'nex' THEN
                        CASE
                            WHEN (FORMAT(COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio), 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                    ELSE
                        CASE
                            WHEN (FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                END
            ELSE
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
        END
END AS Ciclo_Novo,


CONVERT(varchar(8), DATEADD(SECOND,
    DATEDIFF(SECOND, DataHoraSaidaEstacao, DataPrimeiraEntrega),
    0), 108) AS StemOutReal
,CASE
    -- CU-86akjfupg: classificacao por composicao dos pacotes da rota.
    -- 'Rota Volumosa' (TipoRota com prefixo 'S' ou 'U') mantem precedencia sobre a composicao.
    WHEN UPPER(LEFT(LTRIM(RTRIM(TipoRota)), 1)) IN ('S', 'U') THEN 'Rota Volumosa'
    WHEN cp.TemColeta = 1 AND ISNULL(cp.TemEntrega, 0) = 0 THEN 'Coleta'
    WHEN TipoRota = 'Coleta' AND ISNULL(cp.TemEntrega, 0) = 0 THEN 'Coleta'
    WHEN cp.TemColeta = 1 AND cp.TemEntrega = 1 THEN 'Rota Híbrida'
    ELSE 'Rota Convencional'
END AS TipoRotaClassificada

,CONVERT(varchar(10), DataHoraSaidaEstacao, 103) + ' ' +
CONVERT(varchar(8), DataHoraSaidaEstacao, 108) AS DataHoraSaidaEstacaoFormatada
,CASE
    WHEN r.IdTransportadora = 1726310024 THEN
        CAST(PacotesEntregues AS decimal(18,6))
        / NULLIF(
            PacotesEntregues
            + PacotesNaoEntregue
            + PacotesPendentes
            + PacotesTransferidos,
            0
        )

    WHEN r.IdTransportadora <> 1726310024
         AND Ambulancia = 0 THEN
        CAST(PacotesEntregues AS decimal(18,6))
        / NULLIF(
            PacotesEntregues
            + PacotesNaoEntregue
            + PacotesPendentes
            + PacotesTransferidos,
            0
        )

    ELSE NULL
END AS PercentualPerformance
,r.DriverId
,CASE 
    WHEN isnull(bss_regra_sd,1) = 1 THEN
        CASE 
            WHEN r.IdTransportadora = 643493085 THEN
                CASE 
                    WHEN LOWER(ISNULL(r.TipoOrigemSaida,'')) = 'nex' THEN
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

    WHEN isnull(bss_regra_sd,1) = 2 THEN
        CASE 
            WHEN r.IdTransportadora = 643493085 THEN
                CASE 
                    WHEN r.TipoRota like '%SD%' THEN 'SD'
                    WHEN LOWER(ISNULL(r.TipoOrigemSaida,'')) = 'nex' THEN
                        CASE WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM' ELSE 'PM' END
                    ELSE
                        CASE WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM' ELSE 'PM' END
                END
            ELSE
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
        END

    WHEN isnull(bss_regra_sd,1) = 3 THEN
        CASE 
            WHEN r.IdTransportadora = 643493085 THEN
                CASE 
                    WHEN LOWER(ISNULL(r.TipoOrigemSaida,'')) = 'nex' THEN
                        CASE
                            WHEN (FORMAT(COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio), 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, COALESCE(r.DataHoraSaidaEstacao, r.DataHoraInicio)) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                    ELSE
                        CASE
                            WHEN (FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30') OR r.TipoRota like '%SD%' THEN 'SD'
                            WHEN DATEPART(HOUR, r.DataHoraInicio) < 12 THEN 'AM'
                            ELSE 'PM'
                        END
                END
            ELSE
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
        END
END AS Ciclo_Novo_fc





from
tb_ml_rotas r with (nolock)
join (select max(id) as id from tb_ml_rotas (nolock) where Excluido = 0 group by IdRota, IdTransportadora) as ultimaPk on r.id = ultimaPk.id
join tb_clientes cli with (nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1 ---and cli.cli_cd_codigo_cliente <> 7
left join tb_ml_traducoes t1 with (nolock) on r.NivelExperienciaMotorista = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_ml_rotas' and t1.tds_nm_campo = 'NivelExperienciaMotorista'
left join tb_ml_traducoes t2 with (nolock) on r.StatusRota = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_ml_rotas' and t2.tds_nm_campo = 'StatusRota'
left join tb_ml_traducoes t3 with (nolock) on r.StatusPrazo = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_rotas' and t3.tds_nm_campo = 'StatusPrazo'
left join tb_ml_traducoes t4 with (nolock) on r.SubStatusRota = t4.tds_vl_json and t4.tds_nm_tabela = 'tb_ml_rotas' and t4.tds_nm_campo = 'SubStatusRota'
left join (
    select 
        idrota,
        idtransportadora,
        COUNT(*) as PacotesComImagem
    from 
        tb_tratativas_entregas with (nolock)
    where Imagem is not null
    group by idrota, idtransportadora
) tratativas
on tratativas.idrota = r.IdRota and tratativas.idtransportadora = r.IdTransportadora
--left join tb_novos_distritos distritos on distritos.nome_distrito = r.cidadedistante

left join tb_ml_service_center svc with (nolock)
on r.ServiceCenter = svc.svc_cd_service_center and r.idtransportadora = svc.idtransportadora

left join (
select 
cli_id_logistics as IdTransportadora
, mot_nm_motorista
, max(mot_cd_motorista) as mot_cd_motorista -- tratamento para evitar duplicidade por erro de cadastro
, max(mot_cd_usuario) as mot_cd_usuario
from tb_motorista as a with (nolock)
inner join tb_clientes as b with (nolock)
on cli_cd_codigo_cliente = mot_cd_cliente
group by cli_id_logistics,
 mot_nm_motorista
) as mot
on r.IdTransportadora = mot.IdTransportadora
and r.nomemotorista = mot.mot_nm_motorista

left join tb_ml_service_center svc2 with (nolock)
on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc2.svc_cd_service_center
and r.idtransportadora = svc2.idtransportadora
LEFT JOIN (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY quinzena DESC) AS rn
        FROM tb_ml_bsc_rtt WITH (NOLOCK)
    ) AS sub
    WHERE rn = 1
) AS rtt ON rtt.idrota = r.idrota

left join (
select* 
from tb_fin_base_km_trevo with (nolock)
where bkt_cd_transportadora = 2087146923
) trevo
  on r.idtrevo = trevo.bkt_cd_base_km_trevo
left join tb_bases b with (nolock) on isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) = b.bss_ds_sigla and r.IdTransportadora = b.bss_cd_idtransportadora
--Inclusão da tabela de parametros para aplicar a regra de Restrição de bases 24/03/2026
left join tb_parametros as par on par.prm_cod_cliente = cli.cli_cd_codigo_cliente and prm_nm_parametro = 'Visibilidade Padrão de Bases'
--- Matheus 20/10/25 -- trocando para tb_bases por conta da cidade base
--left join tb_dra_bases b with (nolock) on isnull(svc2.svc_cd_service_center,svc.svc_cd_service_center) = b.dab_cd_service_center and r.IdTransportadora = b.dab_cd_transportadora

left join (
select 
a.tlm_cd_rota
,a.tlm_cd_risco_ajudante

from tb_lancamentos_manuais as a with (nolock)
inner join (
select 
tlm_cd_lancamento_manual
,tlm_cd_rota
,ROW_NUMBER() over(partition by tlm_cd_rota order by tlm_cd_lancamento_manual desc) ordem
from tb_lancamentos_manuais with (nolock)
where tlm_cd_cliente = 27
and tlm_cd_risco_ajudante = 'Risco'
--and tlm_cd_rota = 'AT202405131ORMZ'
) as b
on a.tlm_cd_lancamento_manual = b.tlm_cd_lancamento_manual
and b.ordem = 1
) as lanc
on cast(r.idrota as varchar(50)) = lanc.tlm_cd_rota

    --Join com tb_veiculo para trazer o campo vei_in_frota_fixa , com ele categorizo o veiculo como Frota Fixa 1 , Agregado 2 ,Não Inforamdo Null
left join (
    select 
        cli_id_logistics,
        vei_ds_placa,
        vei_cd_ano,
        vei_in_frota_fixa,
        vei_dh_criacao,
        TipoFrota
    from (
        select 
             b.cli_id_logistics,
             a.vei_ds_placa,
             a.vei_cd_ano,
             isnull(a.vei_in_tipo_frota,0) as vei_in_frota_fixa,
             a.vei_dh_criacao,
             c.tf_nm_tipo_frota as TipoFrota,
             row_number() over (
                 partition by b.cli_id_logistics, a.vei_ds_placa
                 order by a.vei_dh_criacao desc
             ) as rn
        from tb_veiculos a with (nolock)
        inner join tb_clientes b with (nolock) 
            on a.vei_cd_cliente = b.cli_cd_codigo_cliente
        left join tb_tipo_frota c with (nolock) 
            on a.vei_in_tipo_frota = c.tf_cd_tipo_frota
        where a.vei_in_excluido = 0
    ) x
    where rn = 1
) as veiculo
    on r.idtransportadora = veiculo.cli_id_logistics 
   and r.placa = veiculo.vei_ds_placa



left join [tb_ml_processamento_km_rotas] as kms
on r.idrota = kms.idrota

-- CU-86akjfupg: composicao coleta/entrega da rota (TipoPonto='pickup' = coleta)
OUTER APPLY (
    SELECT
        MAX(v.TemColeta)  AS TemColeta,
        MAX(v.TemEntrega) AS TemEntrega
    FROM (
        SELECT
            -- pickup ja efetivado (picked_up) em outra rota nao conta como coleta desta
            CASE WHEN p.TipoPonto = 'pickup'
                      AND NOT EXISTS (
                          SELECT 1
                          FROM tb_ml_pacotes p2 WITH (NOLOCK)
                          WHERE p2.IdPacote = p.IdPacote
                            AND p2.IdTransportadora = p.IdTransportadora
                            AND p2.IdRota <> p.IdRota
                            AND p2.TipoPonto = 'pickup'
                            AND p2.StatusEntrega = 'picked_up'
                            AND p2.Excluido = 0
                      ) THEN 1 ELSE 0 END AS TemColeta,
            CASE WHEN ISNULL(p.TipoPonto, '') <> 'pickup' THEN 1 ELSE 0 END AS TemEntrega
        FROM tb_ml_pacotes p WITH (NOLOCK)
        WHERE p.IdRota = r.IdRota
          AND p.IdTransportadora = r.IdTransportadora
          AND p.Excluido = 0
    ) v
) cp

--Esta join abaixo é para a visão de alterar o monitoramento MELI de base p/ XPT
-- left join (
--select 
-- bss_ds_sigla
--,bss_ds_label 
--,bss_ds_nome 
--from tb_bases 
--where bss_ds_marketplace = 'Mercado Livre'
--and bss_cd_base <> 7 
--) c 
--on r.servicecenter = c.bss_ds_sigla 

---- Felipe Oliveira - 26/03/2025 - esse Join para trazer dados de ambulancia do Looker 
--LEFT JOIN (
--    SELECT 
--         amb_id_rota,
--         amb_data,
--         amb_status,
--         amb_pagamento,
--         amb_id_motorista
--    FROM (
--SELECT  amb_id_rota,  amb_data, amb_status, amb_pagamento, amb_id_motorista,
--             ROW_NUMBER() OVER (PARTITION BY amb_id_rota ORDER BY amb_data DESC) AS rn
--         FROM [dbo].[tb_looker_ambulancias] WITH (NOLOCK)
--        --WHERE amb_id_rota = 218963480
--    ) AS sub
--    WHERE rn = 1
--) AS ambL
--on r.DataReferencia = ambL.[amb_data]
--and cast(r.idrota as varchar(50)) = ambL.[amb_id_rota][dbo].[tb_ml_processamento_km_rotas]



where r.excluido = 0
and StatusRota <> 'planned'

--Incluído por Saulo Barros em 24/04/2025 para não considerar rotas que foram canceladas
and isnull(SubStatusRota,'') <> 'cancelled'
--and r.idrota not in (----- Efetuado ajuste por conta que estava excluindo rotas que não deveria - Matheus 20/10/25
--    select idrota
--    from (
--        select   
--            idrota,
--            count(*) as qtd
--        from tb_ml_rotas with(nolock)
--        where DataReferencia = cast(getdate() as date)
--          and DataInicioRota between cast(getdate()-15 as date) and cast(getdate() as date)
--          and Excluido = 0
--        group by idrota
--        having count(*) > 1
--    ) as a
--)
--AND (
--       (r.IdTransportadora = 1387994348 AND
--        NOT (
--            r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos -- ESPECÍFICO RODOPRIME. CONSIDERAM APENAS ROTAS ATIVAS
--            OR r.TotalPacotes = r.PacotesEntregues + r.PacotesNaoEntregue
--            OR (r.StatusRota = 'planned' AND r.DataReferencia < cast(getdate() as date))
--        )
--       )
--       OR (r.IdTransportadora <> 1387994348)
--     )
--Fim 

and (TotalPacotes > 0 or PacotesTransferidos > 0)
and (
1 = isnull(par.prm_ds_valor,1)
 or (0 = isnull(par.prm_ds_valor,1)
and isnull(b.bss_visibilidade,0) = 1 )
)
--and DataReferencia >= '2025-03-01'
--and servicecenter  <> 'SC_ZS'
--and r.idrota = 174194637


union all

select distinct 
IdTransportadora
,Id
,IdRota
,DataReferencia
,null DataHoraInicio
,null TempoPlanejadoMinutos
,Status StatusRota
,null SubStatusRota
,null StatusPrazo
,OrigemSaida ServiceCenter
,NomeOrigemSaida NomeServiceCenter
,OrigemSaida Base
,null CidadeBase
,null TipoOrigemSaida
,OrigemSaida
,TipoRota
,TipoVeiculo
,COALESCE(NULLIF(LTRIM(RTRIM(nomemotorista)), ''), '-') AS NomeMotorista

,IdMotorista
,null Codigo_usuario_motorista
,isnull(PlacaVeiculo,'-') as PlacaVeiculo
,null NivelExperienciaMotorista
,null IdNivelMotorista
,null NivelMotorista
,null QuantidadePacotesTransportados
,null PercentualEntregasBemSucedidas
,null PercentualEntregasSemRelamacaoes
,null PossuiAjudante
,'Não' Ajudante
,1 KmColetado
,'-' LinkMapa
,'Não' UsouAPP
,UsuarioDA
,null CidadeDistante
,QuantidadePacotesColetados TotalPacotes
,0 PacotesEntregues
,0 PacotesPendentes
,0 PacotesNaoEntregue
,0 PacotesEntreguesForaAreaEntrega
,null PacotesTransferidos
,0 TempoEmRota
,0 TempoChegadaAreaEntrega
,0 TempoAreaEntrega
,0 PercentualProgresso
,KmPercorrido KmTotal
,0 TempoEmRotaSec
,null SegundosEntreEntregas
,1 RotaFinalizada
,'Finalizada' StatusGeralRota
,0 QuantidadePontos
,QuantidadeParadas
,0 QuantidadeReclamacoes
,0 QuantidadeAmbulancia
,null StatusPrimeiraEntrega
,null StatusSegundaEntrega
,null DataPrimeiraEntrega
,null DataUltimaEntrega
,null Cidades
,null CidadeReferencia
,null KmColetadoMeli
,null LinkMapaMeli
,null KmColetadoAPP
,null LinkMapaApp
,null AmbulanciaFiltro
,null Ambulancia
,null KmMotorista
,null QuantidadeApontamento
,null Apuracao
,null HoraInicio
,null Ciclo
,null AlarmeRotaEntregaAtraso
,null AlarmeRotaEntregaAtrasoFiltro
,null FaixaPrimeiroUltimoPacote
,0 TempoInativo
,'FM' tipo
,null LogisticsRota
,null Reclamacores
,null CodOrigemSaida
,null DescOrigemSaida
,null ClassificacaoStemOut
,null bss_ds_label
,null Svc_Cidade
,null Estado
,null IdTrevo
,null LancRisco
,null LinkPacote
,null KmMapaPacote
,null CategoriaVeiculo
,null PacotesDS
,null ReclamacoesAbertasPeloTotalReclamacoes
,null FlagSEMIDAY
,null TotalSacas
,null NovoXPT
,null PacotesSemSacas
,null PacotesComImagem
,null vei_Cd_ano
,null DataAtualizacao
,null EnderecosVisitados
,null TeveAcaoGps
,null svc_nm_region
,null QTD_Reclamacoes_em_aberto
,null QTD_Reclamacoes_total
,null as vei_dh_criacao
,NULL AS QuantidadePnr
--campos acrescentados para incluir ambulancias looker no relatório de monitoramento
,AmbulanciaStatus= NULL 
,AmbulanciaPagamento= NULL 
,AmbulanciaIdMotorista= NULL 
,null TipoFrota
,null  as KM_Rtt
,null as KM_Trevo
,null as Datahorasaidaestacao
,null as Ciclo_Novo
,null as StemOutReal
,null as  TipoRotaClassificada
,null as DataHoraSaidaEstacaoFormatada
,null AS PercentualPerformance
,null as DriverId
,null as teste

from
tb_ml_fm_rotas as rotas with (nolock)
join tb_clientes cli with (nolock) on rotas.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1
where
Excluido = 0

union all


select distinct 
IdTransportadora
,Id
,IdRota
,DataReferencia
,DataHoraInicio
,null TempoPlanejadoMinutos
,'Close' StatusRota
,null SubStatusRota
,null StatusPrazo
,ServiceCenter ServiceCenter
,ServiceCenter NomeServiceCenter
,ServiceCenter Base
,null CidadeBase
,null TipoOrigemSaida
,ServiceCenter OrigemSaida
,'MeliOne'TipoRota
,TipoVeiculo
,COALESCE(NULLIF(LTRIM(RTRIM(nomemotorista)), ''), '-') AS NomeMotorista

,null IdMotorista
,null Codigo_usuario_motorista
,isnull(PlacaVeiculo,'-') as PlacaVeiculo

,null NivelExperienciaMotorista
,null IdNivelMotorista
,null NivelMotorista
,null QuantidadePacotesTransportados
,null PercentualEntregasBemSucedidas
,null PercentualEntregasSemRelamacaoes
,null Possuijudante
,'Não' Ajudante
,1 KmColetado
,'-' LinkMapa
,'Não' UsouAPP
,UsuarioDA
,null CidadeDistante
,0 TotalPacotes
,0 PacotesEntregues
,0 PacotesPendentes
,0 PacotesNaoEntregue
,0 PacotesEntreguesForaAreaEntrega
,null PacotesTransferidos
,0 TempoEmRota
,0 TempoChegadaAreaEntrega
,0 TempoAreaEntrega
,0 PercentualProgresso
,0 KmTotal
,0 TempoEmRotaSec
,null SegundosEntreEntregas
,1 RotaFinalizada
,'Finalizada' StatusGeralRota
,0 QuantidadePontos
,0 QuantidadeParadas
,0 QuantidadeReclamacoes
,0 QuantidadeAmbulancia
,null StatusPrimeiraEntrega
,null StatusSegundaEntrega
,null DataPrimeiraEntrega
,null DataUltimaEntrega
,null Cidades
,null CidadeReferencia
,null KmColetadoMeli
,null LinkMapaMeli
,null KmColetadoAPP
,null LinkMapaApp
,null AmbulanciaFiltro
,null Ambulancia
,null KmMotorista
,null QuantidadeApontamento
,null Apuracao
,null HoraInicio
,null Ciclo
,null AlarmeRotaEntregaAtraso
,null AlarmeRotaEntregaAtrasoFiltro
,null FaixaPrimeiroUltimoPacote
,0 TempoInativo
,'MO' tipo
,null LogisticsRota
,null Reclamacores
,null CodOrigemSaida
,null DescOrigemSaida
,null ClassificacaoStemOut
,null bss_ds_label
,null Svc_Cidade
,null Estado
,null IdTrevo
,null LancRisco
,null LinkPacote
,null KmMapaPacote
,null CategoriaVeiculo
,null PacotesDS
,null ReclamacoesAbertasPeloTotalReclamacoes
,null FlagSEMIDAY
,null TotalSacas
,null NovoXPT
,null PacotesSemSacas
,null PacotesComImagem
,null vei_Cd_ano
,null DataAtualizacao
,null EnderecosVisitados
,null TeveAcaoGps
,null svc_nm_region
,null QTD_Reclamacoes_em_aberto
,null QTD_Reclamacoes_total
,null as vei_dh_criacao
,NULL AS QuantidadePnr
,null TipoFrota




--campos acrescentados para incluir ambulancias looker no relatório de monitoramento
,AmbulanciaStatus= NULL 
,AmbulanciaPagamento= NULL 
,AmbulanciaIdMotorista= NULL 
,null  as KM_Rtt
,null as KM_Trevo
, null as Datahorasaidaestacao
,null as Ciclo_Novo
,null as StemOutReal
,null as  TipoRotaClassificada
,null as DataHoraSaidaEstacaoFormatada
,null AS PercentualPerformance
,null DriverId
,null 

from
[tb_ml_mo_rotas] as rotas with (nolock)
join tb_clientes cli with (nolock) on rotas.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1
where
Excluido = 0


union all


select distinct 
IdTransportadora
,Id
,IdRota
,DataReferencia
,EtaOrigem DataHoraInicio
,null TempoPlanejadoMinutos
,StatusGeral  StatusRota
,SubStatus SubStatusRota
,null StatusPrazo
,ServiceCenterDestino ServiceCenter
,ServiceCenterDestino NomeServiceCenter
,ServiceCenterDestino Base
,b.bss_ds_cidade CidadeBase
,null TipoOrigemSaida
,null OrigemSaida
,'MeliOne' TipoRota
,TipoVeiculo
,COALESCE(NULLIF(LTRIM(RTRIM(nomemotorista)), ''), '-') AS NomeMotorista

,null IdMotorista
,null Codigo_usuario_motorista
,isnull(PlacaVeiculo1,'-') as PlacaVeiculo

,null NivelExperienciaMotorista
,null IdNivelMotorista
,null NivelMotorista
,null QuantidadePacotesTransportados
,null PercentualEntregasBemSucedidas
,null PercentualEntregasSemRelamacaoes
,null PossuiAjudante
,'Não' Ajudante
,0 KmColetado
,'-' LinkMapa
,'Não' UsouAPP
,UsuarioDA
,null CidadeDistante
,TotalPacotesOrigem TotalPacotes
,TotalPacotesOrigem PacotesEntregues
,0 PacotesPendentes
,0 PacotesNaoEntregue
,0 PacotesEntreguesForaAreaEntrega
,null PacotesTransferidos
,0 TempoEmRota
,0 TempoChegadaAreaEntrega
,0 TempoAreaEntrega
,0 PercentualProgresso
,0 KmTotal
,0 TempoEmRotaSec
,null SegundosEntreEntregas
,1 RotaFinalizada
,'Finalizada' StatusGeralRota
,0 QuantidadePontos
,0 QuantidadeParadas
,0 QuantidadeReclamacoes
,0 QuantidadeAmbulancia
,null StatusPrimeiraEntrega
,null StatusSegundaEntrega
,null DataPrimeiraEntrega
,null DataUltimaEntrega
,null Cidades
,null CidadeReferencia
,null KmColetadoMeli
,null LinkMapaMeli
,null KmColetadoAPP
,null LinkMapaApp
,null AmbulanciaFiltro
,null Ambulancia
,null KmMotorista
,null QuantidadeApontamento
,null Apuracao
,null HoraInicio
,null Ciclo
,null AlarmeRotaEntregaAtraso
,null AlarmeRotaEntregaAtrasoFiltro
,null FaixaPrimeiroUltimoPacote
,0 TempoInativo
,'LH' tipo
,null LogisticsRota
,null Reclamacores
,null CodOrigemSaida
,null DescOrigemSaida
,null ClassificacaoStemOut
,null bss_ds_label
,null Svc_Cidade
,null Estado
,null IdTrevo
,null LancRisco
,null LinkPacote
,null KmMapaPacote
,null CategoriaVeiculo
,null PacotesDS
,null ReclamacoesAbertasPeloTotalReclamacoes
,null FlagSEMIDAY
,null TotalSacas
,null NovoXPT
,null PacotesSemSacas
,null PacotesComImagem
,null vei_Cd_ano
,null DataAtualizacao
,null EnderecosVisitados
,null TeveAcaoGps
,null svc_nm_region
,null QTD_Reclamacoes_em_aberto
,null QTD_Reclamacoes_total
,null as vei_dh_criacao
,NULL AS QuantidadePnr
,null TipoFrota

--campos acrescentados para incluir ambulancias looker no relatório de monitoramento
,AmbulanciaStatus= NULL 
,AmbulanciaPagamento= NULL 
,AmbulanciaIdMotorista= NULL 
,null  as KM_Rtt
,null as KM_Trevo
,null as Datahorasaidaestacao
,null as Ciclo_Novo
,null as StemOutReal
,null as  TipoRotaClassificada
,null as DataHoraSaidaEstacaoFormatada
,null AS PercentualPerformance
,null DriverId
,null 
from
[tb_ml_lh_rotas] r with (nolock)
join tb_clientes cli with (nolock) on r.IdTransportadora = cli.cli_id_logistics and cli.cli_in_ativo = 1
left join tb_bases b with (nolock) on r.ServiceCenterDestino = b.bss_ds_sigla and r.IdTransportadora = b.bss_cd_idtransportadora
where
Excluido = 0
and StatusGeral  <> 'pending'
    and StatusGeral <> 'canceled' --adicionado por Saulo Barros em 23/06/2026 para não aparecer rotas cancelas


GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF OBJECT_ID(N'dbo.vw_rotas') IS NULL
        THROW 50003, 'Falha: view dbo.vw_rotas nao encontrada apos deploy.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.vw_rotas') AND name = 'TipoRotaClassificada')
        THROW 50004, 'Coluna TipoRotaClassificada nao existe em dbo.vw_rotas.', 1;
    IF CHARINDEX('Rota Híbrida', OBJECT_DEFINITION(OBJECT_ID('dbo.vw_rotas'))) = 0
        THROW 50005, 'Nova classificacao nao aplicada em dbo.vw_rotas.', 1;

    PRINT 'SUCESSO: vw_rotas atualizada — TipoRotaClassificada por composicao.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH
GO
