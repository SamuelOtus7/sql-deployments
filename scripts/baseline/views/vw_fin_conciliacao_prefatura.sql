-- ============================================================
-- BASELINE: dbo.vw_fin_conciliacao_prefatura
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_conciliacao_prefatura]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view  [dbo].[vw_fin_conciliacao_prefatura]  as          

WITH PgtoUnico AS (  
    SELECT *  
    FROM (  
        SELECT  
            ppr.*,  
            ROW_NUMBER() OVER (  
                PARTITION BY ppr.ppr_cd_rota  
                ORDER BY ppr_dh_criacao  
            ) AS rn  
        FROM tb_pgto_periodo_rota ppr  
        WHERE ppr.ppr_in_excluido = 0  
    ) x  
    WHERE rn = 1  
)

select   
    cli_cd_codigo_cliente as TenantId,                     
    pgp_nm_periodo,                     
    a.DataReferencia,  
    pre.DataTermino as datatermino,  
    recb.codreceb,      
    ppr_cd_periodo,      
    cast(
        cast(recb.Ano as varchar(4)) 
        + case when recb.Mes < 10 then '0' else '' end
        + cast(recb.Mes as varchar(2)) 
        + case when pre.Quinzena = 1 then '01' else '16' end
    as int) as IdQuinzena,                  
    pre.Quinzena,                        
    case                         
        when pre.Quinzena = 1 then '1 Qz ' + FORMAT(pre.DataTermino,'yyyy/MMM', 'pt-BR')                        
        when pre.Quinzena = 2 then '2 Qz ' + FORMAT(pre.DataTermino,'yyyy/MMM', 'pt-BR')                        
    end as QuinzenaFiltro,                    
    a.idrota,                      
    a.NomeMotorista,                      
    a.placa,                      
    case              
        when a.servicecenter <> OrigemSaida and left(OrigemSaida,1) <> 'B'
        then OrigemSaida 
        else a.servicecenter               
    end as Base,                      
    OrigemSaida as Xpt,  
    case   
        when Pre.Kmciclo = 'ambulance' then pre.Kmciclo  
        else null 
    end as Ambulancia,  
    case                  
        when bft.bft_cd_service_center is null then 'Sem base frete cadastrada'                
        when (
            case when pre.KmCiclo = 'ambulance' then 0 else isnull(recb.RecebMeli,0) - isnull(recb.DescontoCicloPM,0) end
        ) = isnull(pre.Total,0) then 'Valores iguais'                
        when kmciclo = 'AMBULANCE' then 'Ambulancia'                
        when pre.idrota is null then 'Ausente na prefatura'                
        when isnull(pre.Total,0) = 0 then 'Valor zerado na Prefatura'                
        when recb.ServiceCenter <> pre.serviceCenter then 'Service Center diferente'                
        when recb.TipoVeiculo <> pre.Veiculo then 'Tipo de veiculo diferente'                
        when recb.CicloPM <> recb.CicloPM then 'Ciclo diferente'                
        when isnull(pre.IntervaloFaixa,0) <> isnull(recb.FaixaKm,-1) and pre.InicioIntervalo is not null then 'Faixa de KM diferente'                
        when DescontoCicloPM <> (
            (
                case when pre.KmCiclo = 'ambulance' then 0 else isnull(recb.RecebMeli,0) - isnull(recb.DescontoCicloPM,0) end
            ) - isnull(pre.Total,0)
        ) then 'Outros'                
        else 'Outros'                
    end as Resultado,             
    a.TipoRota as Cluster,                      
    a.TipoVeiculo,                      
    pre.Veiculo + case when pre.ContinuacaoVeiculo is not null then ' - ' + pre.ContinuacaoVeiculo else '' end as TipoVeiculoPreFatura,                      
    pre.ServiceCenter as SVCPreFatura,                      
    pre.IntervaloFaixa as FaixaPreFatura,                      
    ppr_cd_faixa_km as Faixa_KM,                      
    pre.CicloPM as CicloPMFatura,                      
    ppr_ds_ciclo as Ciclo,                      
    ppr_lcto_observacao as Observacao,                      
    a.CidadeDistante as Cidade,                      
    a.TotalPacotes as Pacotes,                      
    a.PacotesEntregues as PacotesEntregues,                      
    a.PacotesNaoEntregue,                       
    a.QuantidadePontos as Pontos,                      
    pre.Parada as QuantidadeParadas,                      
    pre.Parada as ParadaPrefatura,                       
    pre.VLParada as ValorParadasPrefatura,                       
    pre.total as RecebimentoPrefatura,                      
    ppr_vl_total as Total,                      
    ppr_vl_base as ValorBase,                      
    ppr_vl_paradas as Paradas,     
    pre.VLparada as ParadaBruta,  
    ppr_vl_risco as Risco,                      
    ppr_vl_ajudante as Ajudante,                      
    case when cli_cd_codigo_cliente = 27 then null else ppr_vl_lancamentos end as ppr_vl_lancamentos,                     
    ppr_vl_bonus,                      
    ppr_vl_aluguel,                      
    ppr_vl_desconto,                     
    ppr_vl_recarga,                      
    ppr_vl_fer,                       
    ppr_vl_dom,                       
    ppr_vl_bonus_ds,                     
    ppr_vl_bonus_campanha,                   
    ppr_vl_bonus_sla,                     
    ppr_vl_adicional_pct_min,                   
    ppr_vl_pedagio,               
    ppr_base_principal,       
    ppr_vl_parada_iss,       
    ppr_vl_parada_Comercial,       
    ppr_vl_parada_RDM,       
    ppr_vl_parada_Gestao,       
    ppr_vl_iss,       
    ppr_vl_Comercial,       
    ppr_vl_RDM,       
    ppr_vl_Gestao,       
    recb.RecebMeli as RecebMeli,                      
    recb.RecebimentoParadas as RecebimentoParadas,                      
    recb.RecebimentoRisco as RecebimentoRisco,                      
    recb.RecebimentoDomingo as RecebimentoDomingo,                      
    recb.ReceitaTotal,  
    recb.ServiceCenter,  
    pre.Ano as anovw,  
    pre.Mes as mesvw,  
    pre.Quinzena as quinzenavw,  
    CONCAT(
        pre.Quinzena,
        ' - ',
        FORMAT(DATEFROMPARTS(pre.Ano, pre.Mes, 1), 'MMM-yy', 'pt-BR')
    ) AS [Quinzena e Mês VW],  
    PnrPackagesPenalty,
    LostPackagesPenalty,
    VehicleDailyNotVisited
from vw_fin_prefatura pre  
left join tb_ml_rotas as a with(nolock) 
    on a.idrota = pre.idrota  
   and a.excluido = 0                      
   and a.statusrota <> 'planned'  
inner join tb_clientes as cli 
    on pre.IdTransportadora = cli.cli_id_logistics  
left join PgtoUnico as pgto with(nolock) 
    on cast(a.idrota as varchar(50)) = pgto.ppr_cd_rota    
left join tb_pgto_periodo as periodo with(nolock)                      
    on pgto.ppr_cd_periodo = periodo.pgp_cd_periodo  
left join tb_pag_espelhos as esp  
    on ppr_cd_motorista_nfs = mtn_cd_motorista_nfs  
left join tb_pgto_rotas_lanc_manuais as codlanc  
    on pgto.ppr_lcto_cd_lancamento = codlanc.plm_cd_lancamentos  
left join (
    select  
        tlm_dh_referencia,  
        tlm_cd_rota,  
        tlm_cd_cliente  
    from vw_lancamentos_manuais_aprovados   
    group by tlm_dh_referencia, tlm_cd_rota, tlm_cd_cliente
) as lanc  
    on codlanc.plm_cd_rota = lanc.tlm_cd_rota  
   and lanc.tlm_dh_referencia = periodo.pgp_dt_inicio  
   and tlm_cd_cliente = pgp_cd_cliente  
left join tb_fin_resultado_financeiro as recb with(nolock)                      
    on cast(pre.idrota as varchar(50)) = recb.idrota                      
   and cli.cli_cd_codigo_cliente = recb.IdTransportadora         
left join (                
    select                 
        bft_cd_service_center,                
        tvl_nm_tipo_veiculo,                
        bft_cd_transportadora                
    from tb_fin_base_frete_transportadora as a                
    inner join tb_dra_tipo_veiculo as b   
        on a.bft_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo                
    where bft_vl_frete > 0     
    group by bft_cd_service_center, tvl_nm_tipo_veiculo, bft_cd_transportadora                
) as bft   
    on pre.servicecenter = bft.bft_cd_service_center                
   and pre.Veiculo = bft.tvl_nm_tipo_veiculo                
   and cli.cli_cd_codigo_cliente = bft.bft_cd_transportadora     
left join (
    SELECT
        IdTransportadora,
        Ano,
        Mes,
        Quinzena,
        IdRota,
        sum(CASE WHEN Descricao LIKE '%Pnr Packages Penalty%' THEN Total END)      AS PnrPackagesPenalty,
        sum(CASE WHEN Descricao LIKE '%Lost Packages Penalty%' THEN Total END)     AS LostPackagesPenalty,
        sum(CASE WHEN Descricao LIKE '%Vehicle Daily Not Visited%' THEN Total END) AS VehicleDailyNotVisited
    FROM tb_fin_prefatura_descontos WITH (NOLOCK)
    GROUP BY IdTransportadora, Ano, Mes, Quinzena, IdRota
) as dsc
    on dsc.IdTransportadora = pre.IdTransportadora
   and dsc.Ano = pre.Ano
   and dsc.Mes = pre.Mes
   and dsc.Quinzena = pre.Quinzena
   and dsc.IdRota = pre.IdRota
where 
a.DataReferencia >= DATEADD(MONTH, -5, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
--and a.idrota = 311545760

UNION ALL

select
    cli_cd_codigo_cliente as TenantId,  
    NULL as pgp_nm_periodo,
    a.datareferencia as DataReferencia,
    NULL as datatermino,
    NULL as codreceb,
    NULL as ppr_cd_periodo,
    NULL as IdQuinzena,
    NULL as Quinzena,
  case                         
    when a.Quinzena = 1 then 
        '1 Qz ' + FORMAT(DATEFROMPARTS(a.Ano, a.Mes, 1),'yyyy/MMM','pt-BR')
    when a.Quinzena = 2 then 
        '2 Qz ' + FORMAT(DATEFROMPARTS(a.Ano, a.Mes, 1),'yyyy/MMM','pt-BR')
end as QuinzenaFiltro,
    a.idrota,
    NULL as NomeMotorista,
    NULL as placa,
    NULL as Base,
    NULL as Xpt,
    NULL as Ambulancia,
    NULL as Resultado,
    NULL as Cluster,
    NULL as TipoVeiculo,
    NULL as TipoVeiculoPreFatura,
    NULL as SVCPreFatura,
    NULL as FaixaPreFatura,
    NULL as Faixa_KM,
    NULL as CicloPMFatura,
    NULL as Ciclo,
    NULL as Observacao,
    NULL as Cidade,
    NULL as Pacotes,
    NULL as PacotesEntregues,
    NULL as PacotesNaoEntregue,
    NULL as Pontos,
    NULL as QuantidadeParadas,
    NULL as ParadaPrefatura,
    NULL as ValorParadasPrefatura,
    NULL as RecebimentoPrefatura,
    NULL as Total,
    NULL as ValorBase,
    NULL as Paradas,
    NULL as ParadaBruta,
    NULL as Risco,
    NULL as Ajudante,
    NULL as ppr_vl_lancamentos,
    NULL as ppr_vl_bonus,
    NULL as ppr_vl_aluguel,
    NULL as ppr_vl_desconto,
    NULL as ppr_vl_recarga,
    NULL as ppr_vl_fer,
    NULL as ppr_vl_dom,
    NULL as ppr_vl_bonus_ds,
    NULL as ppr_vl_bonus_campanha,
    NULL as ppr_vl_bonus_sla,
    NULL as ppr_vl_adicional_pct_min,
    NULL as ppr_vl_pedagio,
    NULL as ppr_base_principal,
    NULL as ppr_vl_parada_iss,
    NULL as ppr_vl_parada_Comercial,
    NULL as ppr_vl_parada_RDM,
    NULL as ppr_vl_parada_Gestao,
    NULL as ppr_vl_iss,
    NULL as ppr_vl_Comercial,
    NULL as ppr_vl_RDM,
    NULL as ppr_vl_Gestao,
    NULL as RecebMeli,
    NULL as RecebimentoParadas,
    NULL as RecebimentoRisco,
    NULL as RecebimentoDomingo,
    NULL as ReceitaTotal,
    NULL as ServiceCenter,
    NULL as anovw,
    NULL as mesvw,
    NULL as quinzenavw,
    NULL as [Quinzena e Mês VW],
    sum(CASE WHEN a.Descricao LIKE '%Pnr Packages Penalty%' THEN a.Total END) as PnrPackagesPenalty,
    sum(CASE WHEN a.Descricao LIKE '%Lost Packages Penalty%' THEN a.Total END) as LostPackagesPenalty,
    sum(CASE WHEN a.Descricao LIKE '%Vehicle Daily Not Visited%' THEN a.Total END) as VehicleDailyNotVisited
  from tb_fin_prefatura_descontos as a
  left join tb_fin_prefatura as b
  on   a.IdTransportadora = b.IdTransportadora
  and  a.idrota  = b.idrota 
  and  a.Ano = b.Ano
  and  a.Mes = b.Mes
  and  a.Quinzena = b.Quinzena
inner join 
tb_clientes as cli 
    on a.IdTransportadora = cli.cli_id_logistics 
  where  
  1=1 
  and a.DataReferencia >= DATEADD(MONTH, -5, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
  and b.idrota is null
  --and a.idrota = 311545760
  group  by a.idrota,cli_cd_codigo_cliente,a.datareferencia,a.quinzena,a.ano,a.mes
GO
