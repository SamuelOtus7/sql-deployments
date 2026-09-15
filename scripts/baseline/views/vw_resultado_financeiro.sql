-- ============================================================
-- BASELINE: dbo.vw_resultado_financeiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_resultado_financeiro]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  
  
  
CREATE view [dbo].[vw_resultado_financeiro] as   
  
select  
 fin.codreceb  
 ,fin.IdTransportadora 
 ,c.cli_id_logistics
 ,fin.Ano  
 ,fin.Mes  
 ,fin.Quinzena  
    ,case   
   when fin.Quinzena = 1 then '1 Qz ' + FORMAT(fin.DataReferencia,'MMM', 'pt-BR')  
   when fin.Quinzena = 2 then '2 Qz ' + FORMAT(fin.DataReferencia,'MMM', 'pt-BR')  
  end QuinzenaFiltro  
 ,cast(fin.IdRota as varchar(50)) as IdRota   
 ,fin.DataReferencia  
 ,format(fin.DataHoraInicio,'HH:mm') as HoraInicio  
 ,fin.ServiceCenter  
 ,pre.serviceCenter as serviceCenterPrefatura  
 ,fin.XPT  
 ,fin.Base  
 ,fin.Placa  
 ,fin.Motorista  
 ,fin.Destino  
 ,fin.Cluster  
 ,fin.TipoVeiculo  
 ,pre.Veiculo as TipoVeiculoPreFatura  
 ,fin.CicloPM  
 ,pre.CicloPM as CicloPMFatura  
 ,fin.DomingoOuFeriado  
 ,fin.TipoPagamentoFrete  
 ,fin.TipoPagamentoAdicional  
 ,fin.QuantidadePacotes  
 ,fin.PacotesEntregues  
 ,fin.Insucessos  
 ,fin.Pendentes  
 ,fin.QuantidadeParadas  
 ,fin.QuantidadePontos  
  
 ,isnull(pag.Saida,0) PgtoSaida  
 ,isnull(pag.SaidaKmMotorista,0) PgtoSaidaKmMotorista  
 ,isnull(pag.SaidaKm0a100,0) PgtoSaidaKm0a100  
 ,isnull(pag.SaidaKmPreFatura,0) PgtoSaidaKmPreFatura  
 ,isnull(pag.[ADD],0) PgtoParadas  
 ,isnull(pag.RISCO,0) PgtoRisco  
 ,isnull(pag.AJUDANTE,0) PgtoAjudante  
 ,PgtoLancamentoManual  
 ,null MotivoPgtoLancamentoManual  
 ,isnull(PgtoValorManual,0) PgtoValorManual  
  
 ,isnull(pag.Saida,0) + isnull(pag.[ADD],0) + isnull(pag.RISCO,0) + isnull(pag.AJUDANTE,0) + isnull(PgtoValorManual,0) PgtoTotal  
  
 ,fin.Adicional  
  
 ,isnull(fin.KmColetado,kmnovo) as KmColetado  
 ,fin.LinkMapa  
 ,fin.FaixaKm  
 --,pre.IntervaloFaixa as FaixaKmPreFatura  
  
 --,case   
 -- when (isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0)) < isnull(pre.Total,0)   
 --       then isnull(pre.Total,0) else (isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0)) end RecebMeli  
  
 ,isnull(fin.RecebMeli,0) RecebMeli  
    ,case when pre.KmCiclo = 'ambulance' then 0 else isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) end RecebTotal  
 ,fin.RecebimentoParadas  
 ,fin.RecebimentoDomingo  
 ,fin.RecebimentoRisco  
 ,fin.RecebimentoAjudante  
 ,fin.Pedagio  
 ,RecebimentoLancamentoManual  
 ,isnull(RecebimentoValorManual,0) RecebimentoValorManual  
  
 ,fin.ReceitaTotal + isnull(RecebimentoValorManual,0) + isnull(fin.Adicional,0) ReceitaTotal  
  
 ,isnull(case when  ValorPreFatura > 0 then ValorPreFatura else pre.Total end ,0) TotalPrefatura  
   
 ,case   
  when isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0) > isnull(pre.Total,0)   
 then 'Irisys'   
 else case  
   when isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0) <  isnull(pre.Total,0)   
   then 'Pré-fatura' else 'Iguais' end end MaiorValor  
   
   
 ,case   
 when isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0) > isnull(pre.Total,0)   
 then isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0)   
 else isnull(pre.Total,0) end ValorFinal  
  
 ,isnull(fin.RecebMeli0a100,0) RecebMeli0a100  
 ,isnull(fin.FretePreFatura,0) - isnull(fin.DescontoCicloPMPrefatura,0) FretePreFatura  
 ,isnull(fin.RecebimentoDomingoPrefatura,0) RecebimentoDomingoPrefatura  
 ,pre.IntervaloFaixa as FaixaPreFatura  
 ,isnull(fin.DescontoCicloPM,0) as DescontoCicloPM  
  
 ,fin.ValorAdicional0_60  
 ,fin.ValorAdicional61_90  
 ,fin.ValorAdicionalAcima_90  
  
 ,fin.TxAdicionalDomingo    
 ,fin.TxAdicionalCiclo_pm   
 ,fin.TxAdicionalAjudante   
 ,fin.TxAdicionalRisco    
 ,isnull(fin.RecebMeli,0) RecebimentoBase  
 ,fin.UsouAPP  
 ,case when fin.UsouAPP  = 'Sim' and  (fin.LinkMapa = '0' or fin.LinkMapa is null) then 'Em Apuração' else 'Apurado' end as Apuracao  
 ,case when pre.Total > 0 then 'Preenchido' else 'Não Preenchido' end as CadPreFatura  
  
 ,case   
  when isnull(fin.FretePreFatura,0) - isnull(fin.DescontoCicloPMPrefatura,0) > isnull(pre.Total,0)   
 then 'DA'   
 else case  
   when isnull(fin.FretePreFatura,0) - isnull(fin.DescontoCicloPMPrefatura,0) < isnull(pre.Total,0)   
   then 'Pré-fatura' else 'Iguais' end end MaiorValorKM  
  
 ,CASE   
        WHEN ISNULL(pag.Saida, 0) <= ISNULL(pag.SaidaKmPreFatura, 0) THEN ISNULL(pag.Saida, 0)  
        ELSE ISNULL(pag.SaidaKmPreFatura, 0)  
    END AS ValorPgtoMotorista  
   
    
  
 ,case   
  when isnull(pag.Saida,0) > isnull(pag.SaidaKmPreFatura,0)   
 then 'DA'   
 else case  
   when isnull(pag.Saida,0) < isnull(pag.SaidaKmPreFatura,0)    
   then 'Pré-fatura' else 'Iguais' end end MaiorValorPagamento  
  
    ,case when isnull(pag.Saida,0) = 0 then 1 else 0 end PgtoSaidaZerado   
    ,case when isnull(fin.RecebMeli,0)  = 0 then 1 else 0 end RecebMeliZerado   
    ,case when isnull(pre.Total,0) = 0 then 1 else 0 end PrefaturaZerado  
    ,case when fin.FaixaPrimeiroUltimoPacote = 1 then 'Sim' else 'Não' end UsoDevido  
    ,pag.AdicionalInsucessos  
    ,pag.NumeroRota  
    ,pag.TipoVeiculoCad  
    ,pag.faixakm as FaixaKmPagamento  
    ,pag.Kmcoletado as KmcoletadoPagamento  
    ,fin.Ambulancia as QuantidadeAmbulancia  
 ,fin.id AS IDFINANCEIRO  
    ,DataAtualizacao  
    ,case when fin.ServiceCenter =  pre.serviceCenter then 1 else 0 end ServiceCenterIgual  
    ,case when fin.ServiceCenter =  pre.serviceCenter then 'sim' else 'Não' end ServiceCenterIgualtx  
    ,case when fin.TipoVeiculo = pre.Veiculo then 1 else 0 end TipoVeiculoIgual  
    ,case when fin.TipoVeiculo = pre.Veiculo then 'sim' else 'Não' end TipoVeiculoIgualyx  
    ,case when fin.CicloPM = pre.CicloPM then 1 else 0 end CicloPMIgual  
    ,case when fin.CicloPM = pre.CicloPM then 'sim' else 'Não' end CicloPMIgualtx  
    ,case when isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0) = isnull(pre.Total,0) then 1 else 0 end RecebimentoIgual  
    ,case when isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) + isnull(fin.RecebimentoDomingo,0) = isnull(pre.Total,0) then 'sim' else 'Não' end RecebimentoIgualtx  
    ,case when fin.placa = pre.Placa then 1 else 0 end PlacaIgual  
    ,case when fin.placa = pre.Placa then 'sim' else 'Não' end PlacaIgualtx  
    ,case when isnull(fin.QuantidadeParadas,0) = pre.parada then 1 else 0 end ParadasIgual  
    ,case when isnull(fin.QuantidadeParadas,0) = pre.parada then 'sim' else 'Não' end ParadasIgualtx  
    ,case when isnull(fin.RecebimentoParadas,0) = pre.VLParada then 1 else 0 end ValorParadasIgual  
    ,case when isnull(fin.RecebimentoParadas,0) = pre.VLParada then 'sim' else 'Não' end ValorParadasIgualtx  
    ,pre.Placa as PlacaFatura  
    ,pre.parada as ParadasPreFatura  
    ,pre.VLParada as ValorParadaPreFatura  
 ,cast(cast(fin.Ano as varchar(4)) + case when fin.Mes < 10 then '0' else '' end + cast(fin.Mes as varchar(2)) + case when fin.Quinzena = 1 then '01' else '16' end as int) IdQuinzena  
 -- ,cast(case when fin.DataReferencia >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else fin.DataReferencia end as datetime) DataAtualizacaoControlePowerBI  
 ,cast(case when cast(fin.DataAtualizacao as date) >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else cast(fin.DataAtualizacao as date) end as datetime) DataAtualizacaoControlePowerBI  
 ,fin.Observacao  
 ,fin.Regiao  
 ,RiscoV2  
 ,AjudanteV2  
    ,case when kmciclo = 'AMBULANCE' then 'Sim' else null end Ambulancia   
   
    ,case    
        when (  
            case when pre.KmCiclo = 'ambulance' then 0 else isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) end  
        ) = isnull(pre.Total,0) then 'Valores iguais'  
        when kmciclo = 'AMBULANCE' then 'Ambulancia'  
        when pre.idrota is null then 'Ausente na prefatura'  
        when isnull(pre.Total,0) = 0  then 'Valor zerado na Prefatura'  
       
        when bft.bft_cd_service_center is null  then 'Sem base frete cadastrada'  
        when fin.ServiceCenter <> pre.serviceCenter then 'Service Center diferente'  
        when fin.TipoVeiculo <> pre.Veiculo then 'Tipo de veiculo diferente'  
        when fin.CicloPM <> fin.CicloPM then 'Ciclo diferente'  
        when isnull(pre.IntervaloFaixa,0) <> isnull(fin.FaixaKm,-1) then 'Faixa de KM diferente'  
        when DescontoCicloPM <>  ( (  
            case when pre.KmCiclo = 'ambulance' then 0 else isnull(fin.RecebMeli,0) - isnull(fin.DescontoCicloPM,0) end  
        ) - isnull(pre.Total,0)) then 'Outros'  
        --when a.Adicional <> adicion  
    else   
  'Outros'  
 end as Resultado  
  
    ,lst_ds_label idmktplace  
    ,DividiuRota  
 ,IdMotoristaDividiuRota  
 ,[Quinzena e Mês VW]
  
from   
  
 tb_fin_resultado_financeiro fin with(nolock)  
 left join tb_lista as list  
 on fin.idmktplace = list.lst_cd_lista  
 Inner join tb_clientes C with(nolock)  
 on c.cli_cd_codigo_cliente = fin.idtransportadora  
  
 left join tb_fin_pagamento_motorista pag   
 on c.cli_id_logistics = pag.IdTransportadora  
   and fin.IdRota = pag.IdRota  
   and fin.DataReferencia = pag.Data  
 left join (  
          
select  
    cli_cd_codigo_cliente as IdTransportadora  
    ,Ano  
    ,Mes  
    ,Quinzena  
    ,DataInicio  
    ,Veiculo  
    ,ServiceCenter  
    ,CicloPM  
    ,IntervaloFaixa  
    ,InicioIntervalo  
    ,FimIntervalo  
    ,cast(IdRota as varchar(50)) as IdRota  
    ,Total  
    ,Parada  
    ,VLParada  
    ,Placa  
    ,KmCiclo
	,CONCAT(
    a.Quinzena,
    ' - ',
    FORMAT(
        DATEFROMPARTS(a.Ano, a.Mes, 1),
        'MMM-yy',
        'pt-BR'
    )
) AS [Quinzena e Mês VW]
  
 from vw_fin_prefatura  as a  
 inner join tb_clientes as b  
 on a.IdTransportadora = b.cli_id_logistics  
  
--union all  
  
--select   
--    a.idtransportadora  
--   ,year(DataPrestacaoServico) as Ano  
--   ,month(DataPrestacaoServico) as Mes  
--   ,Quinzena  
--   ,DataPrestacaoServico as data  
--   ,a.TipoVeiculo  
--   ,a.Hub NomeHub  
--   ,null CicloPL  
--   ,null IntervaloFaixa  
--   ,null InicioIntervalo  
--   ,null FimIntervalo  
--   ,Rota idrota  
--   ,sum(FreteCalculado) as FreteCalculado  
--   ,null Parada  
--   ,null VLParada  
--   ,null Placa  
--   ,null KmCiclo  
      
--from [dbo].[tb_fin_spe_prefatura] as a  
  
-- left join vw_rotas_spe_v4 as b  
-- on a.rota = b.CodigoRota  
-- and a.idtransportadora = b.idtransportadora  
  
--group by  a.idtransportadora  
--,DataPrestacaoServico  
--,year(DataPrestacaoServico)   
--,month(DataPrestacaoServico)  
--,Quinzena   
--,Rota  
--,a.Hub  
--,a.TipoVeiculo      
  
    ) pre on fin.IdTransportadora = pre.IdTransportadora  
            and fin.IdRota = pre.IdRota  
            --and fin.DataReferencia = pre.DataTermino  
            and fin.Quinzena = pre.Quinzena  
            and fin.Ano = pre.Ano  
            and fin.Mes = pre.Mes  
  
  
left join  
(  
     select   
      bft_cd_service_center,  
      tvl_nm_tipo_veiculo,  
      bft_cd_transportadora  
     from   
      tb_fin_base_frete_transportadora as a  
      inner join  tb_dra_tipo_veiculo as b on a.bft_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo  
     where   
      bft_vl_frete > 0  
     group by   
      bft_cd_service_center,  
      tvl_nm_tipo_veiculo,  
      bft_cd_transportadora  
     ) as bft on   fin.servicecenter = bft.bft_cd_service_center  
       and fin.tipoveiculo = bft.tvl_nm_tipo_veiculo  
       and fin.idtransportadora = bft.bft_cd_transportadora  
  
 where  
 1=1  
--and  fin.DataReferencia >= '2025-10-01'  
-- and  fin.DataReferencia between '2025-02-01' and '2025-02-16'  
 and fin.DataAtualizacao is not null  
--  and fin.IdTransportadora in (47)  
 ;  
GO
