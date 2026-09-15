-- ============================================================
-- BASELINE: dbo.vw_ml_processa_eventos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_processa_eventos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- dbo.vw_ml_processa_eventos fonte

CREATE view [dbo].[vw_ml_processa_eventos] as   

--SELECT top 200
--      r.IdRota
--    , r.DataReferencia
--    , r.IdTransportadora
--FROM tb_ml_rotas r with(nolock)
--where r.DataReferencia >= cast(getdate()-7 as date) and r.DataReferencia >= cast(getdate()-1 as date) 
--AND r.IdTransportadora = 643493085
--and DataHoraSaidaEstacao  is null

SELECT top 200
      r.IdRota
    , r.DataReferencia
    , r.IdTransportadora
FROM db_Irisys.dbo.tb_ml_rotas r with(nolock)
left join (

            select
                dac_ds_contexto,
                max(dac_dh_escrita) dac_dh_escrita
            from
               [db_Irisys_Json].dbo.tb_dra_coleta tdc
            where
                tdc.dac_ds_tipo_coleta = 'ML_LM_ROUTE_EVENTS'
                and cast(tdc.dac_dh_escrita as date) >= cast(getdate()-1 as date) 
                and ISNULL(tdc.dac_in_processado, 0) = 0


            group by dac_ds_contexto

) as coleta
    on dac_ds_contexto = IdRota

join tb_clientes cli
    on r.IdTransportadora = cli.cli_id_logistics and cli.cli_cd_codigo_cliente <> 7

join tb_parametros pr
    on cli.cli_cd_codigo_cliente = pr.prm_cod_cliente
      and pr.prm_ds_categoria = 'Monitoramento Meli'
      and pr.prm_nm_parametro = 'Habilitar Coleta Hora Saida Estação'
      and pr.prm_ds_valor = 'true'

WHERE 1 = 1
    --AND r.IdTransportadora  in (
    --  ,'643493085'    --Flight Cargo
    --  ,'1387994348'   --Rodoprime
    --  ,'1024706007'   --Hawk Transportes
    --  ,'472463006'    --Parceiro Spot
    --   ,'2130011770'
    --   ,'652375997'
    --   ,'1025381599'
    --  )
    --AND r.IdTransportadora = 1950609251
    AND r.DataReferencia >= cast(getdate()-1 as date) 
    --AND r.DataReferencia >= '2026-06-13' and r.DataReferencia <= '2026-06-14'
    AND r.Excluido = 0
    AND r.statusrota <> 'planned'
    and DataHoraSaidaEstacao  is null
    and (DataHoraSaidaEstacaoAusente is null
            or (datediff(HH,dac_dh_escrita,getdate()) >= 2 and  DataHoraSaidaEstacaoAusente = 1)
        );

GO
