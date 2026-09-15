-- ============================================================
-- BASELINE: dbo.vw_ml_alerta_rotas_faltantes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_alerta_rotas_faltantes]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  view [dbo].[vw_ml_alerta_rotas_faltantes] as     
    
select       
    cli_ds_nome    
    ,cli_id_logistics    
    ,dhr_dt_data    
    ,cli_cd_codigo_cliente TenantId    
    ,dhr_nr_rota IdRota    
    ,count(*) QtdSilos    
    ,sum(case when b.idrota  is null  then 1 else 0 end ) NaoColetadoRota    
    ,sum(case when pacotesFaltantes.idrota  is null  then 1 else 0 end ) NaoColetadoPacote
    ,sum(case when PacoteSemRota.idrota  is not null  then 1 else 0 end ) PacoteSemRota
    ,'insert into tb_rotas_para_reprocessar select ' +  cast(dhr_nr_rota as varchar(50))  + ', ''' + cast( dhr_dt_data  as varchar(50)) + ''' , ' + cast( cli_id_logistics as varchar(50)) InsereNaFila    

from (     
  select      
   dhr_cd_cliente    
  ,dhr_dt_data    
  ,dhr_nr_rota    
  from tb_dra_historico_rotas with(nolock)    
  where dhr_dt_data >= '2026-02-01'    
  group by   dhr_cd_cliente    
  ,dhr_dt_data    
  ,dhr_nr_rota    
) as a    
left join tb_ml_rotas as b with(nolock)    
on a.dhr_nr_rota = cast(b.idrota as varchar(50))    
and excluido = 0     
and statusrota  <> 'planned'    
    
left join tb_clientes as cli    
on cli_id_logistics = dhr_cd_cliente    
    
left join (
select idrota 
from tb_ml_pacotes
where datareferencia  >= '2026-02-01' 
and excluido = 0 
group by idrota 
) as pacotesFaltantes
on a.dhr_nr_rota = pacotesFaltantes.idrota


left join (

        select p.*
        from (
                select 
                    IdTransportadora,
                    idrota,
                    max(datareferencia) as datareferencia
                from tb_ml_pacotes as p with(nolock)
                where datareferencia >= '2026-02-01'
                and excluido = 0
                group by IdTransportadora,
                idrota
        ) as p
        left join tb_ml_rotas as r with(nolock)
        on r.idrota  = p.idrota
        and r.statusrota <> 'planned'
        and r.excluido = 0       

        where r.idrota is null

) as PacoteSemRota
on PacoteSemRota.idrota  = a.dhr_nr_rota



where dhr_dt_data >= '2026-02-01'    
    
group by cli_ds_nome,cli_id_logistics,cli_cd_codigo_cliente ,dhr_dt_data,dhr_nr_rota    
--,rollup(dhr_dt_data)    
    
    
GO
