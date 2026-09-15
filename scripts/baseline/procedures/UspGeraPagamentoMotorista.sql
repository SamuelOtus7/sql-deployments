-- ============================================================
-- BASELINE: dbo.UspGeraPagamentoMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraPagamentoMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[UspGeraPagamentoMotorista]  (  
 @IdTransportadora int,  
 @Ano int,  
 @Mes tinyint,  
 @Quinzena tinyint,  
 @idrota int = null  
)  
as  
begin  
  
   
  --declare @IdTransportadora int = 2087146923 ,  
  --@Ano int = 2024,  
  --@Mes tinyint = 04,  
  --@Quinzena tinyint = 2,  
  --@idrota int = null   
  
 --- remover o filtro and adicional.bfa_cd_base_frete_adicional_motorista <> 1308 das tabelas tb_fin_base_frete_adicional_motorista  
  
 SET NOCOUNT ON  
   
 declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)  
 declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end  
  
  
drop table if exists #NumeroRota  
select   
    IdTransportadora  
    ,DataReferencia  
    ,IdRota  
    ,NomeMotorista
    ,UsuarioDA
    ,ROW_NUMBER() OVER(partition by NomeMotorista,IdTransportadora order by IdRota  ) NumeroRota  
    into #NumeroRota  
from vw_rotas  with(nolock)  
order by 1  
  
  
  
 drop table if exists #vw_rotas  
 select    
  a.*  
  ,cli_cd_codigo_cliente as IdTransportadoraClic  
  ,b.TipoVeiculo as TipoVeiculoAlterado  
  ,versaoapp.VersaoDA  
  ,VeiculoCad.vei_ds_tipo as TipoVeiculoCad  
 into #vw_rotas  
  
 from (  
      select   
       [IdTransportadora]  
  
    --   ,[Id]  
      ,a.[IdRota]  
      ,[DataReferencia]  
      ,[DataHoraInicio]  
      ,[StatusRota]  
      ,[SubStatusRota]  
      ,[StatusPrazo]  
      ,[ServiceCenter]  
      ,[NomeServiceCenter]  
      ,[Base]  
      ,[CidadeBase]  
      ,[TipoOrigemSaida]  
      ,[OrigemSaida]  
      ,[TipoRota]  
      ,[TipoVeiculo]  
      ,[NomeMotorista]  
      ,[Placa]  
      ,[NivelExperienciaMotorista]  
      ,[IdNivelMotorista]  
      ,[NivelMotorista]  
      ,[QuantidadePacotesTransportados]  
      ,[PercentualEntregasBemSucedidas]  
      ,[PercentualEntregasSemRelamacaoes]  
      ,[PossuiAjudante]  
      ,[Ajudante]  
  
   ,case   
   --when IdTransportadora  in (1950609251) and KmColetado > 100  
   -- then KmColetado-100  
   --when IdTransportadora  in (1950609251) and KmColetado <= 100  
   -- then 0  
   when IdTransportadora  in (643493085,1788092343,1726310024)  
                then   
     case   
      when KmColetado = 0   
       then 1  
      else KmColetado end  
            else  
                case   
     when KmColetado = 0  
      then case   
        when IdTransportadora = 834780814   
         then cast(pontosRotasPacotesKm  as decimal(10,2))  
        else 1 end   
     else KmColetado end    
   end KmColetado  
                  
   ,case when IdTransportadora  in (643493085,1788092343,1726310024)  
                then  case   
        when IdTransportadora = 834780814   
         then LinkMapa  
        else LinkMapa end    
            else  
                LinkMapa  end LinkMapa  
  
  
    --   ,[LinkMapa]  
      ,[TotalPacotes]  
      ,[PacotesEntregues]  
      ,[PacotesPendentes]  
      ,[PacotesNaoEntregue]  
      ,[PacotesEntreguesForaAreaEntrega]  
      ,[PacotesTransferidos]  
      ,[TempoEmRota]  
      ,[TempoChegadaAreaEntrega]  
      ,[TempoAreaEntrega]  
      ,[PercentualProgresso]  
      ,[KmTotal]  
      ,[TempoEmRotaSec]  
      ,[SegundosEntreEntregas]  
      ,[RotaFinalizada]  
      ,[StatusGeralRota]  
      ,[QuantidadePontos]-[QuantidadeAmbulancia]  as [QuantidadePontos]  
      ,[QuantidadeParadas]-[QuantidadeAmbulancia] as [QuantidadeParadas]  
      ,[QuantidadeReclamacoes]  
      ,[QuantidadeAmbulancia]  
      ,[StatusPrimeiraEntrega]  
      ,[StatusSegundaEntrega]  
      ,[DataUltimaEntrega]  
      ,[Cidades]  
      ,[CidadeReferencia]  
      ,[KmColetadoMeli]  
      ,[LinkMapaMeli]  
      ,[KmColetadoAPP]  
      ,[LinkMapaApp]  
      ,[Ambulancia]  
      ,[KmMotorista]  
   ,UsuarioDA  
  
      from  vw_rotas as a with(nolock)  
      left join tb_ml_processamento_km_rotas as b with(nolock)  
      on a.IdRota = b.idRota  
        
        where a.IdTransportadora = @IdTransportadora  
        and a.DataReferencia between @data_inicial and @data_final  
        and (@idrota is null or a.IdRota = @idrota)  
        and a.tipo = 'lm'  
     ) as a  
   
 left join (  
                select a.*,b. cli_id_logistics   
                from tb_fin_resultado_financeiro_alteracao as a with(nolock)  
                inner join tb_clientes as b  
                on a.idtransportadora = b.cli_cd_codigo_cliente  
                ) as b  
 on a.IdTransportadora = b.cli_id_logistics  
 and a.idrota = b.idrota  
   
 left join   
 (  
   select   
    CodigoUsuario   
    ,NomeUsuario  
    ,VersaoDA  
  
   from [vw_dados_aparelhos] with(nolock)  
  
 ) as versaoapp  
 --on a.NomeMotorista = versaoapp.NomeUsuario  
 on a.UsuarioDA = versaoapp.CodigoUsuario  
  
    left join (  
  
    SELECT    
        [vei_cd_veiculo]  
        ,[vei_cd_cliente]  
        ,[vei_ds_placa]  
        ,[vei_ds_tipo]  
  
  FROM [tb_veiculos] as a with(nolock)  
  
    ) as VeiculoCad  
    on a.Placa = VeiculoCad.vei_ds_placa  
  
 inner join  tb_clientes as cli  
 on a.idtransportadora  = cli.cli_id_logistics  
  
 where cli.cli_cd_codigo_cliente <> 7  
  
  
  update #vw_rotas   
 set   
  [IdTransportadora] = IdTransportadoraClic   
  
  
 --Adicionado por Saulo Barros em 14/07/2025 para que se for AC2, considerar o KmColetado a mesma regra do que é feito no pagamento  
   
 if @IdTransportadora = 1950609251  
 begin  
    
  drop table if exists #tb_pgto_periodo_rota_edit  
  select  
   r.edit_rota  
   ,r.edit_Total_KM  
   into #tb_pgto_periodo_rota_edit  
  from  
   tb_pgto_periodo_rota_edit r  
   join tb_pgto_periodo p on r.edit_cd_periodo = p.pgp_cd_periodo  
  where  
   p.pgp_cd_cliente = 45  
   and r.edit_Total_KM is not null  
    
  update   
   r  
  set   
   r.KmColetado = isnull(edit.edit_Total_KM, case when rtt.KmTotal is null then 100 else case when isnull(rtt.KmTotal,0) < 1 then 1 else rtt.KmTotal end end) --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa  
  from  
   #vw_rotas r  
   left join tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota   
   left join #tb_pgto_periodo_rota_edit as edit on CONVERT(VARCHAR,r.IdRota) = edit.edit_rota  
  --where  
  -- r.NomeMotorista = 'Diego de Souza Lopes'  
 end  
   
  
  
 delete tb_fin_pagamento_motorista   
 where 1=1   
 and IdTransportadora in (select distinct [IdTransportadora] from #vw_rotas )  
 and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena  
   
 insert into tb_fin_pagamento_motorista  
 SELECT  DISTINCT  
  rotas.idTransportadora,  
  rotas.Ano,  
  rotas.Mes,  
  rotas.Quinzena,  
  rotas.Data,  
  rotas.serviceCenter ,  
  rotas.CidadeReferencia,  
  rotas.Placa,  
  rotas.TipoVeiculo,  
  rotas.NomeMotorista,  
  rotas.IdRota,  
  rotas.CicloPM,  
  rotas.TotalPacotes,  
  rotas.QuantidadePontos,  
  rotas.Saida,  
  rotas.[ADD],  
  rotas.RISCO,  
  rotas.AJUDANTE,  
  rotas.ASCRESC,  
  rotas.SAIDA+[ADD]+RISCO+AJUDANTE+ASCRESC AS CUSTO_TOTAL ,  
  rotas.SaidaKmMotorista,  
  rotas.SaidaKm0a100,  
  rotas.SaidaKmPreFatura,  
        rotas.AdicionalInsucessos,  
        nrotas.NumeroRota,  
        rotas.TipoVeiculoCad,  
        rotas.FaixaKm,  
        rotas.KmColetado  
  
 FROM  
 (  
  SELECT  
   -- @IdTransportadora IdTransportadora,  
   r.idTransportadora,  
   @Ano Ano,  
   @Mes Mes,  
   @Quinzena Quinzena,  
   r.dataReferencia AS Data,  
   r.serviceCenter ,  
   r.CidadeReferencia,  
   r.Placa,  
   TipoVeiculo,  
   r.NomeMotorista,  
   r.idRota as IdRota,  
   case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end CicloPM,  
   TotalPacotes,  
   QuantidadePontos,  
   --KmColetado,  
     
     
   isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) is not null then  
     isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)  
    else  
     isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)  
   end,0)  
   +  
   /*calculo saida domingo */  
   isnull(  
   case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado  
    case when adicional.bfa_tipo_adicional_domingo = 2 then  
     adicional.bfa_vl_adicional_domingo  
    else  
   case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) is not null then  
     isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)  
    else  
     isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)  
   end   
   *  
     adicional.bfa_vl_adicional_domingo / 100  
   end  
    end,0)  
   Saida,  
  
   /*calculo adicional */  
   isnull(  
    case when r.IdTransportadora = 1491631999 and r.Ambulancia = 1 then  
     0  
    else  
     CASE   
     WHEN adicional.bfa_calcula_por_parada = 0  
      THEN   
       CASE   
        WHEN r.QuantidadePontos <= 60  
         THEN r.QuantidadePontos * adicional.bfa_vl_paradas0_60  
        WHEN r.QuantidadePontos <= 75  
         THEN 60 * adicional.bfa_vl_paradas0_60 + (r.QuantidadePontos - 60) * adicional.bfa_vl_paradas61_75  
        WHEN r.QuantidadePontos <= 85  
         THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + (r.QuantidadePontos - 75) * adicional.bfa_vl_paradas76_85  
        WHEN r.QuantidadePontos <= 90  
         THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + (r.QuantidadePontos - 85) * adicional.bfa_vl_paradas86_90  
       ELSE 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + 5 * adicional.bfa_vl_paradas86_90 + (r.QuantidadePontos - 90) * adicional.bfa_vl_paradas_acima_90  
       END  
     WHEN adicional.bfa_calcula_por_parada = 1  
      THEN  
      CASE   
        WHEN r.QuantidadeParadas <= 60  
         THEN r.QuantidadeParadas * adicional.bfa_vl_paradas0_60  
        WHEN r.QuantidadeParadas <= 75  
         THEN 60 * adicional.bfa_vl_paradas0_60 + (r.QuantidadeParadas - 60) * adicional.bfa_vl_paradas61_75  
        WHEN r.QuantidadeParadas <= 85  
         THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + (r.QuantidadeParadas - 75) * adicional.bfa_vl_paradas76_85  
        WHEN r.QuantidadeParadas <= 90  
         THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + (r.QuantidadeParadas - 85) * adicional.bfa_vl_paradas86_90  
       ELSE 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + 5 * adicional.bfa_vl_paradas86_90 + (r.QuantidadeParadas - 90) * adicional.bfa_vl_paradas_acima_90  
       END  
     END   
    end  
            +     
   /*calculo adicional pool */     
   case   
   when ADICIONAL_POOL.bfa_vl_adicional is not null    
    then  
     ADICIONAL_POOL.bfa_vl_adicional  
    else  
     0  
     end  
     +  
    /*calculo adicional fixo */     
            case   
   when adicional_fixo.bfm_vl_frete_fixo is not null    
    then  
     adicional_fixo.bfm_vl_frete_fixo  
    else  
     0  
     end,0) AS [ADD],       
     
   ISNULL(case   
   when (r.TipoRota like 'R[_]%' and r.serviceCenter ='SSP21' and r.IdTransportadora=1491631999) or risco.crt_cd_risco_transportadora is not null  then  
    case when adicional.bfa_tipo_adicional_risco = 2 then   
      adicional.bfa_vl_adicional_risco   
    else  
     0  
    end end , 0) AS RISCO,  
  
   ISNULL(case when r.TipoVeiculo = 'VUC' then  
    case when adicional.bfa_tipo_adicional_ajudante = 2 then   
     adicional.bfa_vl_adicional_ajudante  
    else  
     0  
    end  
   else  
    0  
   end,0) AS AJUDANTE,  
  
   ISNULL(NULL,0) AS ASCRESC,  
  
  
  
  
   isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when freteKmMotorista.bfm_vl_frete_pm is not null then  
     freteKmMotorista.bfm_vl_frete_pm  
    else  
     freteKmMotorista.bfm_vl_frete  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      freteKmMotorista.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    freteKmMotorista.bfm_vl_frete  
   end,0)  
   +  
   /*calculo saida domingo */  
   isnull(  
   case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado  
    case when adicional.bfa_tipo_adicional_domingo = 2 then  
     adicional.bfa_vl_adicional_domingo  
    else  
   case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when freteKmMotorista.bfm_vl_frete_pm is not null then  
     freteKmMotorista.bfm_vl_frete_pm  
    else  
     freteKmMotorista.bfm_vl_frete  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      freteKmMotorista.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    freteKmMotorista.bfm_vl_frete  
   end   
   *  
     adicional.bfa_vl_adicional_domingo / 100  
   end  
    end,0)  
   SaidaKmMotorista,  
  
    
  isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when freteKm0a100.bfm_vl_frete_pm is not null then  
     freteKm0a100.bfm_vl_frete_pm  
    else  
     freteKm0a100.bfm_vl_frete  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      freteKm0a100.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    freteKm0a100.bfm_vl_frete  
   end,0)  
   +  
   /*calculo saida domingo */  
   isnull(  
   case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado  
    case when adicional.bfa_tipo_adicional_domingo = 2 then  
     adicional.bfa_vl_adicional_domingo  
    else  
   case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when freteKm0a100.bfm_vl_frete_pm is not null then  
     freteKm0a100.bfm_vl_frete_pm  
    else  
     freteKm0a100.bfm_vl_frete  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      freteKm0a100.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    freteKm0a100.bfm_vl_frete  
   end   
   *  
     adicional.bfa_vl_adicional_domingo / 100  
   end  
    end,0)  
   SaidaKm0a100,  
  
  
   isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when freteKmPreFatura.bfm_vl_frete_pm is not null then  
     freteKmPreFatura.bfm_vl_frete_pm  
    else  
     freteKmPreFatura.bfm_vl_frete  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      freteKmPreFatura.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    freteKmPreFatura.bfm_vl_frete  
   end,0)  
   +  
   /*calculo saida domingo */  
   isnull(  
   case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado  
    case when adicional.bfa_tipo_adicional_domingo = 2 then  
     adicional.bfa_vl_adicional_domingo  
    else  
   case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then  
    case when freteKmPreFatura.bfm_vl_frete_pm is not null then  
     freteKmPreFatura.bfm_vl_frete_pm  
    else  
     freteKmPreFatura.bfm_vl_frete  
     -  
     case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM  
      adicional.bfa_vl_adicional_ciclo_pm   
     else  
      freteKmPreFatura.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100  
     end   
    end  
   else  
    freteKmPreFatura.bfm_vl_frete  
   end   
   *  
     adicional.bfa_vl_adicional_domingo / 100  
   end  
    end,0)  
   SaidaKmPreFatura,  
              
            case /*bfa_tipo_insucesso: coluna de insucesso  
                   bfa_cd_insucesso quantidade de insucesso */  
                when adicional.bfa_tipo_insucesso = 0   
                    and CHARINDEX(right(calendario.PeriodoSemana,3), adicional.bfa_cd_dias_insentos)  = 0   
                    and r.PacotesNaoEntregue <= adicional.bfa_cd_insucesso    
                     then adicional.bfa_vl_insucesso   
                else 0 end  as AdicionalInsucessos  
  
        ,r.TipoVeiculoCad  
        ,cast(freteKm2.bfm_vl_inicio_faixa as varchar) + '/' + cast(freteKm2.bfm_vl_fim_faixa as varchar) FaixaKm  
        ,r.kmcoletado  
  -- Retirar Duplicidades  
  ,ROW_NUMBER() OVER(PARTITION BY r.idTransportadora, r.idRota ORDER BY ISNULL(freteKm2.bfm_vl_inicio_faixa,0) ASC) AS ID  
  
  FROM  
   #vw_rotas r with(nolock)  
          
        left join DimData as calendario  
        on r.DataReferencia = calendario.[Data]  
  
   left join tb_fin_prefatura pre on @IdTransportadora = pre.IdTransportadora  
            and r.IdRota = pre.IdRota  
   --         --and r.DataReferencia = pre.DataTermino  
   --         and pre.Quinzena = @Quinzena  
   --         and pre.Ano = @Ano  
   --         and pre.Mes = @Mes  
   left join   
   (  
    select  
     usr_cd_usuario CodigoUsuario,
     usr_nm_usuario NomeMotorista,  
     c.cli_id_logistics IdTransportadora,  
     u.usr_cd_tipo_contrato TipoContrato  
    from  
     tb_usuario u with(nolock)  
     join tb_clientes c on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente  
     --join tb_ml_aprovacao_usuario a on u.usr_cd_usuario = a.mau_cd_usuario_gerado and a.mau_ds_status = 'Aprovado'  
    where  
     usr_in_ativo = 1  
     and c.cli_id_logistics <> 0  
   ) m --on r.NomeMotorista = m.NomeMotorista and r.IdTransportadora = m.IdTransportadora  
        on r.UsuarioDA = m.CodigoUsuario and r.IdTransportadora = m.IdTransportadora  
   left join tb_ml_service_center svc2 on r.ServiceCenter = svc2.svc_cd_service_center  
   left join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center  
   left join DimData dt on r.DataReferencia = dt.Data  
   left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo  
    
   left join tb_fin_cidades_risco_transportadora as risco on r.IdTransportadora = risco.crt_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = risco.crt_cd_service_center  
                 and r.CidadeReferencia = risco.crt_nm_cidade  
    
  
  left join tb_fin_base_km_trevo trevo with(nolock) on r.IdTransportadora = trevo.bkt_cd_transportadora  
            and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = trevo.bkt_cd_service_center  
            and r.Cidades = trevo.bkt_nm_cidades  
  
     
   left join tb_fin_base_frete_motorista frete on r.IdTransportadora = frete.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = frete.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo  
                 and r.CidadeReferencia = frete.bfm_nm_cidade   
                 --and isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)  
                   or 1=1 )  
  
   left join tb_fin_base_frete_adicional_motorista adicional on r.IdTransportadora = adicional.bfa_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional.bfa_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo  
                 and (r.CidadeReferencia = adicional.bfa_nm_cidade or adicional.bfa_nm_cidade is null)  
                 --and isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)  
                   or 1=1 )  
  
  
  
            left join (  
   SELECT   
   *   
   FROM   
   tb_fin_base_frete_adicional_motorista     
   with(nolock)   
   WHERE bfa_cd_tipo_veiculo IN (1,4)  
   and bfa_cd_base_frete_adicional_motorista <> 1309  
   ) adicional_pool  on r.IdTransportadora = adicional_pool.bfa_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_pool.bfa_cd_service_center  
                                                                    and tv.tvl_cd_tipo_veiculo = adicional_pool.bfa_cd_tipo_veiculo   
                 and (r.CidadeReferencia = adicional_pool.bfa_nm_cidade or adicional_pool.bfa_nm_cidade is null)                                        
                 --and isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)  
                   or 1=1 )  
  
   left join tb_fin_base_frete_motorista freteKm with(nolock)  on r.IdTransportadora = freteKm.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = freteKm.bfm_cd_tipo_veiculo  
                 and isnull(m.TipoContrato,-1) = freteKm.bmf_cd_tipo_contrato  
                 and freteKm.bfm_nm_cidade is null  
                 and trevo.bkt_vl_km_ideal > (freteKm.bfm_vl_inicio_faixa - 1)  
                 --and isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)  
                   or 1=1 )  
  
  left join tb_fin_base_frete_motorista freteKm2 with(nolock)  on r.IdTransportadora = freteKm2.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm2.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = freteKm2.bfm_cd_tipo_veiculo  
                 and freteKm2.bfm_nm_cidade is null  
                 and r.KmColetado > (freteKm2.bfm_vl_inicio_faixa - 1)  
                 and r.KmColetado <= freteKm2.bfm_vl_fim_faixa  
                 and (isnull(m.TipoContrato,-1) = isnull(freteKm2.bmf_cd_tipo_contrato,-1)  
                 or 1=1)  
                   
  
        left join tb_fin_base_frete_motorista adicional_fixo with(nolock) on adicional_fixo.bfm_vl_frete_fixo is NOT null   
                 AND r.IdTransportadora = adicional_fixo.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_fixo.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = adicional_fixo.bfm_cd_tipo_veiculo  
                 --and isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)  
                 or 1=1)  
                 and r.Cidades = r.CidadeReferencia  
                 --and r.cidades = adicional_fixo.bfm_nm_cidade  
                 and r.CidadeReferencia = adicional_fixo.bfm_nm_cidade  
  
  left join tb_fin_base_frete_motorista freteKmMotorista with(nolock)  on r.IdTransportadora = freteKmMotorista.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmMotorista.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = freteKmMotorista.bfm_cd_tipo_veiculo  
                 --and isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)  
                   or 1=1 )  
                 and freteKmMotorista.bfm_nm_cidade is null  
                 and r.KmMotorista > (freteKmMotorista.bfm_vl_inicio_faixa - 1)  
                 and r.KmMotorista <= freteKmMotorista.bfm_vl_fim_faixa  
  
  left join tb_fin_base_frete_motorista freteKm0a100 with(nolock)  on r.IdTransportadora = freteKm0a100.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm0a100.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = freteKm0a100.bfm_cd_tipo_veiculo  
                 --and isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)  
                   or 1=1 )  
                 and freteKm0a100.bfm_nm_cidade is null  
                 and freteKm0a100.bfm_vl_inicio_faixa = 1  
  
  left join tb_fin_base_frete_motorista freteKmPreFatura with(nolock)  on r.IdTransportadora = freteKmPreFatura.bfm_cd_transportadora  
                 and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmPreFatura.bfm_cd_service_center  
                 and tv.tvl_cd_tipo_veiculo = freteKmPreFatura.bfm_cd_tipo_veiculo  
                 --and isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)  
                 and (isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)  
                   or 1=1 )  
                 and freteKmPreFatura.bfm_nm_cidade is null  
                 and pre.InicioIntervalo >= freteKmPreFatura.bfm_vl_inicio_faixa  
                 and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= freteKmPreFatura.bfm_vl_fim_faixa  
  
                                          
  where 1=1  
  --r.IdTransportadora = @IdTransportadora  
  -- and r.DataReferencia between @data_inicial and @data_final  
   and r.DataReferencia < cast(getdate() as date)  
   --and r.DataReferencia = (  
   -- select  
   --  max(DataReferencia)  
   -- from  
   --   tb_ml_rotas r2 with(nolock)  
   -- where  
   --  r.IdRota = r2.IdRota  
   --  and r.IdTransportadora = r2.IdTransportadora  
   --  and r2.excluido = 0  
   --)  
   --and isnull(r.SubStatusRota,'') not in ('Cancelada','Planejada')  
   --and r.StatusRota <> 'Planejada'  
   --and adicional.bfa_cd_base_frete_adicional_motorista <> 1308  
 ) AS ROTAS  
  
    LEFT join #NumeroRota as Nrotas  
    on rotas.IdRota = Nrotas.IdRota  
    and rotas.IdTransportadora = Nrotas.IdTransportadora  
 -- Retirar Duplicidades  
 WHERE ROTAS.ID = 1  
    AND NOT EXISTS (SELECT 1  -- CONDIÇÃO ADICIONADA DEVIDO AO ERRO DE PK POR DUPLICIDADE PK_tb_fin_pagamento_motorista  
       FROM tb_fin_pagamento_motorista fin  with(nolock)   
      WHERE rotas.idtransportadora = fin.idtransportadora    
        AND convert(varchar (50),rotas.idrota) = fin.idrota )   
end  
GO
