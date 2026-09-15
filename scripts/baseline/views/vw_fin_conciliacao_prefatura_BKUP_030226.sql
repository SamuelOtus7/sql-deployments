-- ============================================================
-- BASELINE: dbo.vw_fin_conciliacao_prefatura_BKUP_030226
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_conciliacao_prefatura_BKUP_030226]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view  [dbo].[vw_fin_conciliacao_prefatura_BKUP_030226]  as                     
                    
select 
cli_cd_codigo_cliente as TenantId                    
  ,pgp_nm_periodo                    
,a.DataReferencia 
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
,a.idrota                    
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
from vw_fin_prefatura pre


left join tb_ml_rotas as a with(nolock) on a.idrota  = pre.idrota
 
inner join tb_clientes as cli on pre.IdTransportadora = cli.cli_id_logistics
 
left join tb_pgto_periodo_rota as pgto with(nolock) on cast(a.idrota as varchar(50)) = pgto.ppr_cd_rota  
and ppr_in_excluido = 0  
 
left join tb_pgto_periodo as periodo with(nolock)                    
on pgto.ppr_cd_periodo =  periodo.pgp_cd_periodo                    
and pgp_in_excluido = 0  
 
left join tb_pag_espelhos as esp
on ppr_cd_motorista_nfs  = mtn_cd_motorista_nfs
and mtn_in_excluido  = 0
 
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

--and (pgp_in_excluido <> 1)
--and cli_cd_codigo_cliente = 63
--and a.IdTransportadora = 472463006 
--and a.idrota = 298338545

--Adicional por Saulo Barros em 15/01/2026 para incluir os lançamentos que não tiveram rotas para pagamento
--union all
             
--Select 
--	cli_cd_codigo_cliente as TenantId                    
--	,pgp_nm_periodo                    
--	,periodo.pgp_dt_inicio DataReferencia                  
--	,null codreceb    
--	,ppr_cd_periodo    
--	,cast(
--		cast(year(periodo.pgp_dt_inicio) as varchar(4)) + 
--		case when month(periodo.pgp_dt_inicio) < 10 then '0' else '' end + 
--		cast(month(periodo.pgp_dt_inicio) as varchar(2)) + 
--		case when day(periodo.pgp_dt_inicio) <= 15 then '01' else '16' end 
--	as int) IdQuinzena                
--	,case when day(periodo.pgp_dt_inicio) <= 15 then 1 else 2 end Quinzena                      
--	,case                       
--		when case when day(periodo.pgp_dt_inicio) <= 15 then 1 else 2 end = 1 then '1 Qz ' + FORMAT(periodo.pgp_dt_inicio,'MMM', 'pt-BR')                      
--		when case when day(periodo.pgp_dt_inicio) <= 15 then 1 else 2 end = 2 then '2 Qz ' + FORMAT(periodo.pgp_dt_inicio,'MMM', 'pt-BR')                      
--	end QuinzenaFiltro                   
--	,0 idrota                    
--	,ppr_nome_motorista NomeMotorista                    
--	,null placa                    
--	,ppr_base_principal Base                    
--	,null Xpt
--	,null Ambulancia
--	,null Resultado           
--	,null Cluster                    
--	,null TipoVeiculo                    
--	,null TipoVeiculoPreFatura                    
--	,null SVCPreFatura                    
--	,null FaixaPreFatura                    
--	,null Faixa_KM --Mudar para FaixaPagamento                    
--	,null CicloPMFatura                    
--	,null Ciclo                    
--	,ppr_lcto_observacao Observacao                    
--	,null Cidade                    
--	,null Pacotes                    
--	,null PacotesEntregues                    
--	,null PacotesNaoEntregue                     
--	,null Pontos                    
--	,null QuantidadeParadas                    
--	,null ParadaPrefatura                     
--	,null RecebimentoPrefatura                    
--	,ppr_vl_total as Total --Mudar para TotalPagamento                    
--	,ppr_vl_base     as ValorBase -- Mudar para ValorBasePagamento                    
--	,ppr_vl_paradas     as Paradas --...Pagamento   
--	,null ParadaBruta
--	,ppr_vl_risco     as Risco --...Pagamento                    
--	,ppr_vl_ajudante    as Ajudante  --...Pagamento                    
--	,ppr_vl_lancamentos   --...Pagamento                    
--	,ppr_vl_bonus    --...Pagamento                    
--	,ppr_vl_aluguel    --...Pagamento                    
--	,ppr_vl_desconto   --...Pagamento                    
--	,ppr_vl_recarga    --...Pagamento                    
--	,ppr_vl_fer     --...Pagamento                    
--	,ppr_vl_dom     --...Pagamento                    
--	,ppr_vl_bonus_ds   --...Pagamento                    
--	,ppr_vl_bonus_campanha  --...Pagamento                    
--	,ppr_vl_bonus_sla   --...Pagamento                    
--	,ppr_vl_adicional_pct_min --...Pagamento                
--	,ppr_vl_pedagio    --...Pagamento         
--	,ppr_base_principal      
--	,ppr_vl_parada_iss      
--	,ppr_vl_parada_Comercial      
--	,ppr_vl_parada_RDM      
--	,ppr_vl_parada_Gestao      
--	,ppr_vl_iss      
--	,ppr_vl_Comercial      
--	,ppr_vl_RDM      
--	,ppr_vl_Gestao      
                    
--	,null RecebMeli                    
--	,null RecebimentoParadas                    
--	,null RecebimentoRisco                    
--	,null RecebimentoDomingo                    
--	,null ReceitaTotal                    
--	--,recb.ValorFinal                     
                     
--from 
--	tb_pgto_periodo_rota as pgto with(nolock)                    
--	join tb_pgto_periodo as periodo with(nolock) on pgto.ppr_cd_periodo = periodo.pgp_cd_periodo                    
--													and pgp_in_excluido = 0   
--	join tb_clientes as cli with(nolock) on periodo.pgp_cd_cliente = cli.cli_cd_codigo_cliente                                
--where 
--	pgto.ppr_in_excluido = 0
--	and periodo.pgp_in_excluido = 0
--	and periodo.pgp_dt_inicio >= cast(dateadd(month,-4,getdate()) as date)
--	and isnull(pgto.ppr_cd_rota,'') = ''

GO
