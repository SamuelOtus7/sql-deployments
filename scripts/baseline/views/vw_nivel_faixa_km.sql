-- ============================================================
-- BASELINE: dbo.vw_nivel_faixa_km
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_nivel_faixa_km]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE view [dbo].[vw_nivel_faixa_km] as     
  /*
select *    
,ROW_NUMBER() over(partition by bfm_cd_transportadora    ,servicecenter    ,TipoVeiculo     
     order by bfm_vl_inicio_faixa) Ordem    
from     
(    
select distinct    
    bfm_cd_transportadora    
    ,bfm_cd_service_center as servicecenter    
    ,b.tvl_nm_tipo_veiculo as TipoVeiculo    
    ,bfm_vl_inicio_faixa     
    ,bfm_vl_fim_faixa     
    ,cast(bfm_vl_inicio_faixa as varchar(max)) + '/' + cast(bfm_vl_fim_faixa as varchar(max)) as FaixaKm    
    
from tb_fin_base_frete_motorista as a    
    
left join tb_dra_tipo_veiculo as b    
on a.bfm_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo    
    
where  bfm_vl_inicio_faixa is not null    
and bfm_data_fim_vigencia is null  
and (bfm_nm_cidade is null or bfm_nm_cidade = '')  
) as a    
    
 */

select  
    cli_cd_codigo_cliente as bfm_cd_transportadora
    ,ServiceCenter
    ,Veiculo as TipoVeiculo
    ,InicioIntervalo	as bfm_vl_inicio_faixa
    ,FimIntervalo as bfm_vl_fim_faixa
    ,max(DataTermino) Data
     --,cast(InicioIntervalo as varchar(max)) + '/' + cast(FimIntervalo as varchar(max)) as FaixaKm  
	,intervalofaixa as Faixakm 
     ,ROW_NUMBER() over(partition by cli_cd_codigo_cliente    ,servicecenter    ,Veiculo     
     order by InicioIntervalo) Ordem  
from tb_fin_prefatura as a with(nolock)
inner join tb_clientes as b
on a.idtransportadora  = cli_id_logistics
where 1=1 
--and IdTransportadora = 1387994348
and KmCiclo <> 'ambulance'
and InicioIntervalo is not  null 
group by 
    cli_cd_codigo_cliente
    ,ServiceCenter
    ,Veiculo
    ,InicioIntervalo
	,IntervaloFaixa
    ,FimIntervalo 
GO
