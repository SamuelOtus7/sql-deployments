-- ============================================================
-- BASELINE: dbo.vw_erros_rotas_para_reprocesar
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_erros_rotas_para_reprocesar]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_erros_rotas_para_reprocesar] as 

select distinct    
        cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) as IdRota    
        ,tb_clientes.cli_ds_nome
		,tb_dra_erros_coleta.*
    from          
    tb_dra_erros_coleta  with(nolock)        
left join tb_clientes
on dec_cd_transportadora = tb_clientes.cli_id_logistics
    where dec_ds_tipo_coleta = 'ML_SC_ROUTE_HISTORY'          
and (        
dec_ds_erro in (        
'Error: Request failed with status code 404',        
'Error: Request failed with status code 422')     
and dec_dt_referencia > '2026-01-20'         
                or (dec_ds_erro = 'Error: Request failed with status code 401' and DATEDIFF(hour,dec_dh_escrita,GETDATE()) >= 6 )          
 )       
GO
