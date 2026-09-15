-- ============================================================
-- BASELINE: dbo.vw_fin_vld_kms
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_vld_kms]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_fin_vld_kms] as 

select 

    r.DataReferencia
  ,cli.cli_cd_codigo_cliente as TenantId
  ,r.idRota  
  ,r.usouapp
  ,r.ServiceCenter
  ,r.OrigemSaida  as XTP
  ,r.TipoVeiculo  

  ,r.Placa
  ,vldKMRTT.ORDEM as OrdemRtt
  ,KMDA.ordem  as OrdemIrisys
  ,KMDA.Ordem - vldKMRTT.ORDEM NivelDiferença

    ,case
        when vldKMRTT.ORDEM = KMDA.Ordem then 1
        when KMDA.Ordem > vldKMRTT.ORDEM then 2
        when vldKMRTT.ORDEM > KMDA.Ordem then 3
        when receb.TipoVeiculo <> pre.Veiculo then 4
        else 0
    end as ComparaFaixaKMId_Irisys_RTT
 
  ,vldKMRTT.FaixaKm as FaixaKmRTT
  ,KMDA.FaixaKm as FaixaKmIrisys
  ,km.pontosAppRotasTotalKm   
  ,km.pontosRotasPacotesKm as KmPacotes
  ,rtt.DistanciaSVC  
  ,rtt.KmTotal as KmRTT
  ,pre.IntervaloFaixa
  ,pre.total
  ,receb.RecebMeli


from tb_ml_rotas as r with(nolock)

left join tb_motorista as mot
on usuarioda  = mot.mot_cd_motorista


join tb_clientes as cli
on cli_id_logistics = r.IdTransportadora

left join tb_ml_processamento_km_rotas as km with(nolock)
on r.idrota  = km.idrota 

left join [tb_ml_bsc_rtt] as rtt with(nolock)
on km.IdRota = rtt.idrota 

left join tb_fin_prefatura as pre with(nolock)
on  km.idRota = pre.idrota 

left join tb_fin_resultado_financeiro as receb
on receb.idtransportadora = cli.cli_cd_codigo_cliente
and cast(r.idrota as varchar(15)) = receb.idrota


left join vw_nivel_faixa_km as KMDA
    on cli.cli_cd_codigo_cliente = KMDA.bfm_cd_transportadora
   and r.servicecenter = KMDA.servicecenter
   and km.pontosRotasPacotesKm between KMDA.bfm_vl_inicio_faixa	and KMDA.bfm_vl_fim_faixa
   and r.TipoVeiculo = KMDA.TipoVeiculo
   --and (mot_ctn_cd_tipo_contrato = KMDA.bmf_cd_tipo_contrato or mot_ctn_cd_tipo_contrato is null)

left join vw_nivel_faixa_km as vldKMRTT
    on  cli.cli_cd_codigo_cliente = vldKMRTT.bfm_cd_transportadora
   and r.servicecenter = vldKMRTT.servicecenter
   and rtt.KmTotal between vldKMRTT.bfm_vl_inicio_faixa	and vldKMRTT.bfm_vl_fim_faixa
   and r.TipoVeiculo = vldKMRTT.TipoVeiculo
    --and (mot_ctn_cd_tipo_contrato = vldKMRTT.bmf_cd_tipo_contrato )

where r.excluido = 0
and r.statusrota <> 'planned'
and r.DataReferencia >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE))
--and cli.cli_cd_codigo_cliente  = 61
and KMDA.ordem is not null
and vldKMRTT.ORDEM  is not null
--and km.IdRota = 320462493
 

 --select *  from vw_nivel_faixa_km
 --where bfm_cd_transportadora = 61
GO
