-- ============================================================
-- BASELINE: dbo.vw_prefatura_espelhos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_prefatura_espelhos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[vw_prefatura_espelhos] as 


SELECT 
        IdTransportadora,
        IdRota,
        Quinzena,
        DataTermino,
        Ano,
        Mes,
        case when Veiculo = 'Packages Delivered' then ContinuacaoVeiculo else case when ContinuacaoVeiculo is not null then Veiculo + ' - ' + ContinuacaoVeiculo else Veiculo end end Veiculo,
        ServiceCenter,
        KmCiclo,
        CicloPM,
        IntervaloFaixa,
        InicioIntervalo,
        case when FimIntervalo > 999 then InicioIntervalo else FimIntervalo end FimIntervalo,
        Dia,
        DataInicio,
        DataTermino AS DataFim,
        Placa,
        Motorista,
        Quantidade,
        PrecoUnitario,
        Total,
        Parada,
        VLParada,
        DataAtualizacao,
        EnderecoNaoVisitado
FROM    tb_fin_prefatura WITH (NOLOCK)
       
GO
