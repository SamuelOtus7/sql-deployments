-- ============================================================
-- BASELINE: dbo.vw_fin_conciliacao_prefatura_coomap
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_conciliacao_prefatura_coomap]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_fin_conciliacao_prefatura_coomap] as

select 
cli_cd_codigo_cliente as TenantId                    
  ,pgp_nm_periodo
,coalesce(lanc.tlm_dh_referencia,a.DataReferencia ) as DataReferencia
,pre.DataTermino datatermino
,recb.codreceb    
,ppr_cd_periodo    
,cast(                
cast(recb.Ano as varchar(4)) + case when recb.Mes < 10 then '0' else ''                 
  end                 
   + cast(recb.Mes as varchar(2)) + case                
            when recb.Quinzena = 1 then '01' else '16' end as int) IdQuinzena                
,recb.Quinzena                      
  ,case                       
when recb.Quinzena = 1 then '1 Qz ' + FORMAT(recb.DataReferencia,'MMM', 'pt-BR')                      
when recb.Quinzena = 2 then '2 Qz ' + FORMAT(recb.DataReferencia,'MMM', 'pt-BR')                      
  end QuinzenaFiltro                   
,Cast(a.idrota as varchar (20)) Idrota 
,Concat(a.idrota,coalesce(lanc.tlm_dh_referencia,a.DataReferencia )) as KeyPnr
,a.NomeMotorista                    
,a.placa                    
,case            
  when a.servicecenter <> OrigemSaida             
  then OrigemSaida else a.servicecenter             
  end             
  as  Base                    
,OrigemSaida as Xpt
,case 
when 
Pre.Kmciclo = 'ambulance' then pre.Kmciclo
else null end Ambulancia
,case                
        when (              
            case when pre.KmCiclo = 'ambulance' then 0 else isnull(recb.RecebMeli,0) - isnull(recb.DescontoCicloPM,0) end              
        ) = isnull(pre.Total,0) then 'Valores iguais'              
        when kmciclo = 'AMBULANCE' then 'Ambulancia'              
        when pre.idrota is null then 'Ausente na prefatura'              
        when isnull(pre.Total,0) = 0  then 'Valor zerado na Prefatura'              
        when bft.bft_cd_service_center is null  then 'Sem base frete cadastrada'              
        when recb.ServiceCenter <> pre.serviceCenter then 'Service Center diferente'              
        when recb.TipoVeiculo <> pre.Veiculo then 'Tipo de veiculo diferente'              
        when recb.CicloPM <> recb.CicloPM then 'Ciclo diferente'              
        when isnull(pre.IntervaloFaixa,0) <> isnull(recb.FaixaKm,-1) then 'Faixa de KM diferente'              
        when DescontoCicloPM <>  ( (              
            case when pre.KmCiclo = 'ambulance' then 0 else isnull(recb.RecebMeli,0) - isnull(recb.DescontoCicloPM,0) end              
        ) - isnull(pre.Total,0)) then 'Outros'              
    else               
  'Outros'              
end as Resultado           
,a.TipoRota as Cluster                    
,a.TipoVeiculo                    
,pre.Veiculo + case when pre.ContinuacaoVeiculo is not null then ' - ' + pre.ContinuacaoVeiculo else '' end TipoVeiculoPreFatura                    
,pre.ServiceCenter as SVCPreFatura                    
,pre.IntervaloFaixa as FaixaPreFatura                    
,ppr_cd_faixa_km as Faixa_KM                    
,pre.CicloPM as CicloPMFatura                    
,ppr_ds_ciclo as Ciclo                    
,ppr_lcto_observacao Observacao                    
,a.CidadeDistante as Cidade                    
,a.TotalPacotes     as Pacotes                    
,a.PacotesEntregues as PacotesEntregues                    
,a.PacotesNaoEntregue                     
,a.QuantidadePontos     as Pontos                    
,a.QuantidadeParadas    as QuantidadeParadas                    
,pre.Parada as ParadaPrefatura                     
,pre.total as RecebimentoPrefatura                    
,ppr_vl_total as Total                    
,ppr_vl_base     as ValorBase                    
,ppr_vl_paradas     as Paradas   
,pre.VLparada as ParadaBruta
,ppr_vl_risco     as Risco                    
,ppr_vl_ajudante    as Ajudante                    
,ppr_vl_lancamentos                   
,ppr_vl_bonus                    
,ppr_vl_aluguel                    
,ppr_vl_desconto                   
,ppr_vl_recarga                    
,ppr_vl_fer                     
,ppr_vl_dom                     
,ppr_vl_bonus_ds                   
,ppr_vl_bonus_campanha                  
,ppr_vl_bonus_sla                   
,ppr_vl_adicional_pct_min                 
,ppr_vl_pedagio             
,ppr_base_principal      
,ppr_vl_parada_iss      
,ppr_vl_parada_Comercial      
,ppr_vl_parada_RDM      
,ppr_vl_parada_Gestao      
,ppr_vl_iss      
,ppr_vl_Comercial      
,ppr_vl_RDM      
,ppr_vl_Gestao      
,recb.RecebMeli        as RecebMeli                    
,recb.RecebimentoParadas as RecebimentoParadas                    
,recb.RecebimentoRisco as RecebimentoRisco                    
,recb.RecebimentoDomingo as RecebimentoDomingo                    
,recb.ReceitaTotal      
, 0 as [Vehicle Daily Not]
, 0 as [Pnr Packages Penalty:]
, 0 as [Lost Packages Penalty:]
, 0 as LancManual
, null as OBS


from vw_fin_prefatura pre

left join tb_ml_rotas as a with(nolock) on a.idrota  = pre.idrota

inner join tb_clientes as cli on pre.IdTransportadora = cli.cli_id_logistics

left join tb_pgto_periodo_rota as pgto with(nolock) on cast(a.idrota as varchar(50)) = pgto.ppr_cd_rota   and a.DataReferencia = ppr_data_referencia

left join tb_pgto_periodo as periodo with(nolock)                    
on pgto.ppr_cd_periodo =  periodo.pgp_cd_periodo                    


left join tb_pag_espelhos as esp
on ppr_cd_motorista_nfs  = mtn_cd_motorista_nfs


left join tb_pgto_rotas_lanc_manuais as codlanc
on pgto.ppr_lcto_cd_lancamento = codlanc.plm_cd_lancamentos

left join (
    select
    tlm_dh_referencia
    ,tlm_cd_rota
    ,tlm_cd_cliente
    from vw_lancamentos_manuais_aprovados 
    group by tlm_dh_referencia
    ,tlm_cd_rota
    ,tlm_cd_cliente
)as lanc
on codlanc.plm_cd_rota = lanc.tlm_cd_rota
and lanc.tlm_dh_referencia = periodo.pgp_dt_inicio
and tlm_cd_cliente = pgp_cd_cliente


left join tb_fin_resultado_financeiro as recb with(nolock)                    
on cast(pre.idrota as varchar(50))= recb.idrota                    
and cli.cli_cd_codigo_cliente = recb.IdTransportadora       

left join              
(              
     select               
      bft_cd_service_center,              
      tvl_nm_tipo_veiculo,              
      bft_cd_transportadora              
     from tb_fin_base_frete_transportadora as a              
      inner join tb_dra_tipo_veiculo as b 
        on a.bft_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo              
     where bft_vl_frete > 0              
     group by               
      bft_cd_service_center,              
      tvl_nm_tipo_veiculo,              
      bft_cd_transportadora              
) as bft 
  on recb.servicecenter = bft.bft_cd_service_center              
and recb.tipoveiculo = bft.tvl_nm_tipo_veiculo              
and recb.idtransportadora = bft.bft_cd_transportadora   

where a.excluido = 0                    
and a.statusrota <> 'planned'                    
and a.DataReferencia >= cast(dateadd(month,-4,getdate()) as date)
and pgp_in_excluido = 0  
and ppr_in_excluido = 0  
and mtn_in_excluido  = 0

--and pre.Ano = 2025
--and pre.Mes = 12
--and pre.Quinzena = 2
and cli_cd_codigo_cliente = 63
--and pre.idrota = 316444521

UNION ALL

SELECT 
     TenantId
    ,null pgp_nm_periodo
    , DATEFROMPARTS(
      Ano,
      Mes,
      CASE WHEN Quinzena = 1 THEN 1 ELSE 16 END
  ) AS DataReferencia
  ,null datatermino
  ,null codreceb
  ,null ppr_cd_periodo
  ,concat(Ano,Mes,Quinzena) as Idquinzena
  ,Quinzena
  ,null QuinzenaFiltro
  ,Cast(IdRota as varchar(20)) Idrota
  ,Concat(idrota, DATEFROMPARTS(Ano,Mes,CASE WHEN Quinzena = 1 THEN 1 ELSE 16 END)) as KeyPnr
  , null NomeMotorista
  , null placa
  , null Base
  , null Xpt
  , null Ambulancia
  , null Resultado
  , null Cluster
  , null Tipoveiculo
  , null TipoVeiculoPreFatura
  , null SVCPreFatura
  , null FaixaPreFatura
  , null Faixa_KM
  , null CicloPMFatura
  , null Ciclo
  , null Observacao
  , null Cidade
  , null Pacotes
  , null PacotesEntregues
  , null PacoteNaoEntregue
  , null Pontos
  , null QuantidadeParadas
  , null ParadaPrefatura
  , null RecebimentoPrefatura
  , null Total
  , null ValorBase
  , null Paradas
  , null ParadaBruta
  , null Risco
  , null Ajudante
  , null ppr_vl_lancamentos
  , null ppr_vl_bonus                    
  , null ppr_vl_aluguel                    
  , null ppr_vl_desconto                   
  , null ppr_vl_recarga                    
  , null ppr_vl_fer                     
  , null ppr_vl_dom                     
  , null ppr_vl_bonus_ds                   
  , null ppr_vl_bonus_campanha                  
  , null ppr_vl_bonus_sla                   
  , null ppr_vl_adicional_pct_min                 
  , null ppr_vl_pedagio             
  , null ppr_base_principal      
  , null ppr_vl_parada_iss      
  , null ppr_vl_parada_Comercial      
  , null ppr_vl_parada_RDM      
  , null ppr_vl_parada_Gestao      
  , null ppr_vl_iss      
  , null ppr_vl_Comercial      
  , null ppr_vl_RDM      
  , null ppr_vl_Gestao 
  , null RecebMeli
  , null RecebimentoParadas
  , null RecebimentoRisco
  , null RecebimentoDomingo
  , null ReceitaTotal
    , [Vehicle Daily Not]
    , [Pnr Packages Penalty:]
    , [Lost Packages Penalty:]
  , null LancManual
  , 'PNR' as OBS

FROM (
    SELECT 
        IdTransportadora,
        cli_cd_codigo_cliente TenantId,
        Ano,
        Mes,
        quinzena,
        IdRota,
        DataReferencia,
        SUBSTRING(Descricao, 1,
            CHARINDEX(' ', Descricao + ' ', 
                CHARINDEX(' ', Descricao + ' ', 
                    CHARINDEX(' ', Descricao + ' ') + 1
                ) + 1
            ) - 1
        ) AS Descricao,
        Total
    FROM tb_fin_prefatura_descontos pnr
    INNER JOIN tb_clientes AS cli   
        ON pnr.IdTransportadora = cli_id_logistics
    WHERE cli_cd_codigo_cliente = 63 
      --AND Ano = 2025
      --AND Mes = 12
      --AND Quinzena = 2
) AS src
PIVOT (
    SUM(Total)
    FOR Descricao IN ([Vehicle Daily Not], [Pnr Packages Penalty:], [Lost Packages Penalty:])
) AS pvt

Union all

   select    
        63 as TenantId,
    null as pgp_nm_periodo,
        ppr_data_referencia Datareferencia
    ,null datatermino
    ,null codreceb,
    ppr_cd_periodo,
    null Idquinzena,
    null Quinzena,
    null QuinzenaFiltro,
        cast(ppr_cd_rota as varchar(20)) Idrota,
    null KeyPnr,
    mtn_nome_motorista as NomeMotorista,
    ppr_ds_placa as placa,
    mtn_base_principal as Base
     ,null Xpt
     ,null Ambulancia
       ,null Resultado
       ,null Cluster
       ,null Tipoveiculo
       ,null TipoVeiculoPreFatura
       ,null SVCPreFatura
       ,null FaixaPreFatura
       ,null Faixa_KM
       ,null CicloPMFatura
       ,null Ciclo
       ,null Observacao
       ,null Cidade
       ,null Pacotes
       ,null PacotesEntregues
       ,null PacoteNaoEntregue
       ,null Pontos
       ,null QuantidadeParadas
       ,null ParadaPrefatura
       ,null RecebimentoPrefatura
       ,null Total
       ,null ValorBase
       ,null Paradas
       ,null ParadaBruta
       ,null Risco
       ,null Ajudante
       ,null ppr_vl_lancamentos
       ,null ppr_vl_bonus                    
       ,null ppr_vl_aluguel                    
       ,null ppr_vl_desconto                   
       ,null ppr_vl_recarga                    
       ,null ppr_vl_fer                     
       ,null ppr_vl_dom                     
       ,null ppr_vl_bonus_ds                   
       ,null ppr_vl_bonus_campanha                  
       ,null ppr_vl_bonus_sla                   
       ,null ppr_vl_adicional_pct_min                 
       ,null ppr_vl_pedagio             
       ,null ppr_base_principal      
       ,null ppr_vl_parada_iss      
       ,null ppr_vl_parada_Comercial      
       ,null ppr_vl_parada_RDM      
       ,null ppr_vl_parada_Gestao      
       ,null ppr_vl_iss      
       ,null ppr_vl_Comercial      
       ,null ppr_vl_RDM      
       ,null ppr_vl_Gestao 
       ,null RecebMeli
       ,null RecebimentoParadas
       ,null RecebimentoRisco
       ,null RecebimentoDomingo
       ,null ReceitaTotal
       ,null [Vehicle Daily Not]
       ,null [Pnr Packages Penalty:]
       ,null [Lost Packages Penalty:]
        ,sum(  
            case   
                when isnull(lanc.tlm_cd_tipo,lancr.tlm_cd_tipo) = 489   
                    then isnull(ppr_vl_base,0) * -1   
                else coalesce(lanc.tlm_vl_valor_descontos,lancr.tlm_vl_valor_descontos,0)   
            end  
        ) + sum(coalesce(lanc.tlm_vl_valor_adicional,lancr.tlm_vl_valor_adicional,0)) as LancManual,
    plm_nm_tipo OBS

    from tb_pgto_periodo_rota as a  
          inner join tb_pgto_periodo as pgto  
            on a.ppr_cd_periodo = pgto.pgp_cd_periodo  


        inner join tb_pag_espelhos as pag  
            on ppr_cd_pgto_espelho = pag.mtn_cd_motorista_nfs  
        left join tb_pgto_rotas_lanc_manuais as cod  
            on a.ppr_lcto_cd_lancamento = plm_cd_lancamentos  
        left join tb_lancamentos_manuais as lanc  
            on lanc.tlm_cd_lancamento_manual = cod.plm_cd_lancamento  
        left join (  
            select    
                 cast(tlm_dh_referencia as date)  as tlm_dh_referencia,  
                tlm_cd_rota,  
                tlm_cd_tipo,  
                sum(tlm_vl_valor_adicional) as tlm_vl_valor_adicional,  
                sum(tlm_vl_valor_descontos) * -1 as tlm_vl_valor_descontos  
            from vw_lancamentos_manuais_aprovados  
            group by tlm_cd_rota, tlm_cd_tipo,  cast(tlm_dh_referencia as date)  
        ) as lancr  
            on lancr.tlm_cd_rota = ppr_cd_rota  
             and lancr.tlm_dh_referencia between pgp_dt_inicio and pgp_dt_fim  


        left join tb_tipos_lancamentos_manuais as t   
            on isnull(lanc.tlm_cd_tipo,lancr.tlm_cd_tipo) = t.plm_cd_tipo_lancamento_manual  

        left join tb_usuario as cad  
         on pag.mtn_cd_motorista  = cad.usr_cd_usuario  

        left join tb_usuario as cadResp  
         on cad.usr_cd_usr_responsavel_contrato = cadResp.usr_cd_usuario  


  --Incluido em 11/03/2026 por Saulo Barros para verificar qual marketplace do periodo  
  left join tb_lista mkt with(nolock) on pgto.pgp_cd_cliente_transportadora = mkt.lst_cd_lista  



    where 1=1  
    and ppr_in_excluido = 0  
    and plm_nm_tipo is not null
  --and ppr_data_referencia > '2026-01-01'
  and ppr_data_referencia >= cast(dateadd(month,-4,getdate()) as date)
    and pgp_cd_cliente = 63
    and left(plm_nm_tipo,2) <> 'PF'
  and isnull(mkt.lst_ds_valor,'') <> 'Administrativo' --Adicionado por Saulo Barros em 11/03/2026 para não considerar períodos de pagamento administrativo

      --and ppr_cd_rota = '314776183'  
      --and ppr_cd_periodo = 2546
      --and ppr_cd_motorista_nfs = 880736  
      --and ppr_cd_rota  <> '302875497'  
      --and t.plm_nm_tipo in ('PF - Pacote Perdido','PF - Endereço não visitado','PF - PNR','Ambulância','Backup','Abastecimento')  
  group by
    ppr_data_referencia,
    ppr_cd_periodo,
    ppr_cd_rota,
    mtn_nome_motorista,
    ppr_ds_placa,
    mtn_base_principal,
  plm_nm_tipo


GO
