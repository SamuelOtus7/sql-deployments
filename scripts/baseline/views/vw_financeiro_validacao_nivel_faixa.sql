-- ============================================================
-- BASELINE: dbo.vw_financeiro_validacao_nivel_faixa
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_validacao_nivel_faixa]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_financeiro_validacao_nivel_faixa]    
as    
  

select
    a.IdQuinzena,
    a.IdTransportadora,
    a.DataAtualizacaoControlePowerBI,
    a.DataReferencia,
    a.FaixaKm,
    b.IntervaloFaixa,
    a.IdRota,
    a.KmColetado,
    rtt.KmTotal as KmRTT,
    a.TipoVeiculo,
    a.TotalPrefatura,
    ValorFinal as Recebimento,
    a.ServiceCenter,
    b.Veiculo as VeiculoPF,
    KMDA.Ordem as idkmDA,
    kmprefatura.Ordem as idkmprefatura,
    KMDA.Ordem - vldKMRTT.ORDEM as NivelDiferenca,
    vldKMRTT.ORDEM as IdkmRTT,
    vldKMRTT.FaixaKm as FaixaKmrTT,
	--kmprefatura.Ordem - vldKMRTT.ORDEM as NivelDif_Pre_RTT, 


    -- Comparação entre km rtt, incluir na validacao abaixo
    
    case
        when rtt.KmTotal between b.iniciointervalo and b.fimintervalo then 'Dentro da faixa'
        else 'Fora da faixa'
    end as ComparacaoKmTotal,
    
    case
        when KMDA.Ordem is null and kmprefatura.Ordem is null then 'Sem base frete'
        when KMDA.Ordem is null then 'Sem base frete'
        when kmprefatura.Ordem is null then 'Sem Prefatura'
        else 'Base cadastrada'
    end as BaseFrete,

    b.ServiceCenter as SVCPrefatura,
    
    case
        when KmCiclo = 'AMBULANCE' then 'Ambulancia'
        when (RecebMeli) > 0 then 'Sim'
        else 'Não'
    end as DimRecebeuProcessamento,

    
    case
        when KMDA.Ordem = kmprefatura.Ordem then 1
        when kmprefatura.Ordem > KMDA.Ordem then 2
        when KMDA.Ordem > kmprefatura.Ordem then 3
        when a.TipoVeiculo <> b.Veiculo then 4
        else 0
    end as ComparaFaixaKMId,

	--validacao para o km RTT
	  case
        when vldKMRTT.ORDEM = KMDA.Ordem then 1
        when KMDA.Ordem > vldKMRTT.ORDEM then 2
        when vldKMRTT.ORDEM > KMDA.Ordem then 3
        when a.TipoVeiculo <> b.Veiculo then 4
        else 0
    end as ComparaFaixaKMId_Irisys_RTT,

    case when a.UsouAPP = 'Sim' then 1 else 0 end as UsouAppId



from (
    SELECT VRF.*
    FROM vw_resultado_financeiro AS VRF
    JOIN tb_clientes AS CLI ON CLI.cli_cd_codigo_cliente = IdTransportadora
) as a

left join vw_fin_prefatura as b
    on a.idrota = b.idrota
   and a.cli_id_logistics = b.IdTransportadora

left  join tb_ml_bsc_rtt as rtt
     on a.IdRota = rtt.IdRota

left join vw_nivel_faixa_km as KMDA
    on a.idtransportadora = KMDA.bft_cd_transportadora
   and a.servicecenter = KMDA.servicecenter
   and a.FaixaKm = KMDA.FaixaKm
   and a.TipoVeiculo = KMDA.TipoVeiculo

left join vw_nivel_faixa_km as kmprefatura
    on a.idtransportadora = kmprefatura.bft_cd_transportadora
   and a.servicecenter = kmprefatura.servicecenter
   and case when a.FaixaPreFatura = '301/99999' then '301/999999' else a.FaixaPreFatura end = kmprefatura.FaixaKm
   and a.TipoVeiculo = kmprefatura.TipoVeiculo



--  Novo JOIN com a tabela RTT. 

left join vw_nivel_faixa_km as vldKMRTT
    on a.idtransportadora = vldKMRTT.bft_cd_transportadora
   and a.servicecenter = vldKMRTT.servicecenter
   and rtt.KmTotal between vldKMRTT.bft_vl_inicio_faixa	and vldKMRTT.bft_vl_fim_faixa
   and a.TipoVeiculo = vldKMRTT.TipoVeiculo
   
    

where DataReferencia >= '2025-11-01'
  and b.iniciointervalo is not null
  --AND A.IDROTA  = 308935838
GO
