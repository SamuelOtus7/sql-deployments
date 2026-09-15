-- ============================================================
-- BASELINE: dbo.vw_rotas_para_reprocessar
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_para_reprocessar]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vw_rotas_para_reprocessar]                        
as                        
    
select distinct                       
--distinct top 50                      
        reprocessar.IdRota,                           
        reprocessar.DataReferencia,                          
        reprocessar.IdTransportadora                          
--count(distinct reprocessar.idrota )                      
    
    from                        
        tb_rotas_para_reprocessar reprocessar with(nolock)                       
  --(select IdRota, DataReferencia, IdTransportadora from tb_ml_rotas (nolock) where DataReferencia = '2025-04-19'  and Excluido = 0 and IdTransportadora = 643493085) reprocessar                      
        join tb_clientes as cli on reprocessar.IdTransportadora = cli.cli_id_logistics                         
        or reprocessar.IdTransportadora = cli.cli_id_logistics                         
        left join db_Irisys_Json.dbo.tb_ml_coleta_rotas coleta with(nolock) on reprocessar.IdTransportadora = coleta.cmr_cd_transportadora                        
                                    and reprocessar.DataReferencia = coleta.cmr_dh_referencia                        
                                    and reprocessar.IdRota = coleta.cmr_cd_rota                        
                                    and coleta.cmr_dh_escrita >= cast(getdate() as date)                        
        left join (                        
                    select distinct                       
                        cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) as IdRota                        
                    from                        
                    tb_dra_erros_coleta  with(nolock)                        
                    where dec_ds_tipo_coleta = 'ML_SC_ROUTE_HISTORY'                        
                        and (                      
           dec_ds_erro in (                      
         'Error: Request failed with status code 404',                      
         'Error: Request failed with status code 422'                      
        )                       
                                or (dec_ds_erro = 'Error: Request failed with status code 401' and DATEDIFF(hour,dec_dh_escrita,GETDATE()) >= 6 )                        
                            )                        
        ) as erro_definitivo                        
        on reprocessar.IdRota = erro_definitivo.IdRota                         
    
    
    
---============================================================================                      
-- Bloco adicionado em 28/04/25 para minimizar impscto de bug de                       
-- rotas entrarem com id de transportadora errado                      
---============================================================================                      
  left join tb_ml_rotas as rotas  with(nolock)                      
  on reprocessar.IdRota = rotas.IdRota                       
  and rotas.Excluido = 0                      
  and rotas.StatusRota <> 'planned'                          
  and reprocessar.DataReferencia >= '2026-08-13'    

where 1=1                        
  --and reprocessar.IdRota = 392564642    
  and   (coleta.cmr_cd_coleta is null)    
--and  reprocessar.IdTransportadora  = 2116113832
--and reprocessar.idrota in ( 424087861
--,424775163 
--,424135391
--,424777179
--)



--and  reprocessar.DataReferencia = '2026-06-14'
--  and reprocessar.IdTransportadora  in( 1024706007,1726310024    
--,643493085    
--,1788092343    
--,678279205    
--,1871738758    
--,2130011770    
--,472463006    
--,1731064496    
--,288216524    
--,1688052280    
--,652375997    
--,1387994348)       
    
  and erro_definitivo.IdRota is null                        
  and cli_in_ativo = 1                      
  --and reprocessar.IdRota = 340202297    
        --and reprocessar.idrota  in (select dhr_nr_rota from [dbo].[tb_dra_historico_rotas] where dhr_ds_service_center = 'SC_ZS' and dhr_dt_data = '2026-01-28')                      
  --and reprocessar.IdTransportadora not in(288216524) 
GO
