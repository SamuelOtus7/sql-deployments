-- ============================================================
-- BASELINE: dbo.UspGeraResultadoFinanceiro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraResultadoFinanceiro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE   procedure [dbo].[UspGeraResultadoFinanceiro]     (  
 @IdTransportadora int,  
 @Ano int,  
 @Mes tinyint,  
 @Quinzena tinyint,  
 @idrota int = null  
)  
as   
  
  
begin  
  
  
--declare @IdTransportadora int = 1662443209,  
--@Ano int = 2025,  
--@Mes tinyint = 03,  
--@Quinzena tinyint = 1,  
--@idrota int = null  
  
--select tipo,* from tb_ml_rotas where idrota = 221347183  
  
--select * from tb_ml_rotas where servicecenter = 'ssp9' and idtransportadora = 643493085  
  
--select *  from tb_fin_base_frete_transportadora   
--where bft_cd_service_center = 'Arena'  
  
  
-- update tb_fin_base_frete_transportadora   
-- set bft_estado = NULL  
--where bft_cd_service_center = 'Arena'  
  
 SET NOCOUNT on   
  
 declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)  
 declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end  
  
  
 drop table if exists #paradas  
 select   
 IdRota  
 ,count(distinct LatitudeEnderecoParada + LongitudeEnderecoParada) QtdParada  
   
  into #paradas  
  
 from tb_ml_pacotes  
 where 1=1  
 and IdTransportadora = @IdTransportadora  
 and DataReferencia between @data_inicial and @data_final  
 and (@idrota is null or IdRota = @idrota)  
 and SubStatus <> 'transferred'  
 and excluido = 0  
 -- and idrota  147673793  
  
 group by IdRota  
  
  
drop table if exists #origem  
 select  
 a.* ,c.lst_cd_lista  
 into #origem  
 from (   
 select * ,row_number() over(partition by idrota order by datareferencia) rnumber  
 from vw_rotas a with(nolock)   
 where a.IdTransportadora = @IdTransportadora  
   and a.DataReferencia between @data_inicial and @data_final  
   and (@idrota is null or a.idrota = @idrota)  
   and nomemotorista <> ''  
   and tipo = 'LM'  
 union all  
  
 select a.*  
 from (  
  select *  ,row_number() over(partition by idrota order by datareferencia) rnumber  
  from vw_rotas a with(nolock)   
  where a.IdTransportadora = @IdTransportadora  
   and a.DataReferencia between @data_inicial and @data_final  
   and (@idrota is null or a.idrota = @idrota)  
   and nomemotorista <> ''  
   and tipo = 'FM'  
  
  union all  
  
  select *  ,row_number() over(partition by idrota order by datareferencia) rnumber  
  from vw_rotas a with(nolock)   
  where a.IdTransportadora = @IdTransportadora  
   and a.DataReferencia between @data_inicial and @data_final  
   and (@idrota is null or a.idrota = @idrota)  
   and nomemotorista <> ''  
   and tipo = 'MO'  
 ) as a  
 left join   
 (  
  select *   
  from vw_rotas a with(nolock)   
  where a.IdTransportadora = @IdTransportadora  
   and a.DataReferencia between @data_inicial and @data_final  
   and (@idrota is null or a.idrota = @idrota)  
   and nomemotorista <> ''  
   and tipo = 'LM'  
 ) as b  
 on a.idrota  = b.idrota   
 where b.idrota is null  
 and rnumber = 1   
 )as a  
  
inner join tb_clientes as b  
on a.idtransportadora = b.cli_id_logistics  
inner join tb_lista as c  
on b.cli_cd_codigo_cliente = c.lst_cd_cliente  
and lst_nm_lista = 'Clientes transportadoras'  
and lst_ds_label = 'Mercado Livre'  
and cli_cd_codigo_cliente <> 7 ;  
  
  
 drop table if exists #vw_rotas  
 select distinct   
 a.*  
 , b.TipoVeiculo as TipoVeiculoAlterado  
 , null VersaoDA -- versaoapp. precisa corrigir  
 ,cli_cd_codigo_cliente as IdTransportadoraClic  
  
 into #vw_rotas  
  
 from (  
      select   
       cli.cli_id_logistics as [IdTransportadora]  
    --   ,[Id]  
      ,a.[IdRota]  
      ,a.[DataReferencia]  
   ,a.Ciclo CicloPM   
      ,a.[DataHoraInicio]  
      ,a.[StatusRota]  
      ,a.[SubStatusRota]  
      ,a.[StatusPrazo]  
      ,isnull(alt.[ServiceCenter],a.[ServiceCenter]) as [ServiceCenter]  
      ,a.[NomeServiceCenter]  
      ,a.[Base]  
      ,a.[CidadeBase]  
      ,a.[TipoOrigemSaida]  
      ,a.[OrigemSaida]  
      ,a.[TipoRota]  
      ,isnull(alt.[TipoVeiculo],a.TipoVeiculo) as TipoVeiculo  
      ,a.[NomeMotorista]  
      ,a.[Placa]  
      ,a.[NivelExperienciaMotorista]  
      ,a.[IdNivelMotorista]  
      ,a.[NivelMotorista]  
      ,a.[QuantidadePacotesTransportados]  
      ,a.[PercentualEntregasBemSucedidas]  
      ,a.[PercentualEntregasSemRelamacaoes]  
      ,a.[PossuiAjudante]  
      ,a.[Ajudante]  
  
    
      --,case when a.KmColetadoAPP = 0 then KmMapaPacote else a.KmColetado end KmColetado  
      ,case
	      when a.idtransportadora = 288216524 then b.pontosAppRotasTotalKm
		  else KmMapaPacote end as KmColetado  
                  
 --   ,COALESCE(a.LinkMapaApp,LinkPacote)   LinkMapa  
      ,case when a.KmColetadoAPP = 0 then LinkPacote else LinkMapaApp end as LinkMapa  
  
                 --COALESCE(vldmapa.linkmapa,a.LinkMapa,LinkMapaMeli)  end LinkMapa  
  
      ,isnull(alt.QuantidadePacotes,a.[TotalPacotes]) as TotalPacotes  
      ,isnull(alt.PacotesEntregues,a.[PacotesEntregues]) as [PacotesEntregues]  
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
      ,COALESCE(alt.QuantidadePontos,  a.[QuantidadePontos])  /*-[QuantidadeAmbulancia]-[PacotesTransferidos] */ as [QuantidadePontos]  
      ,COALESCE(alt.[QuantidadeParadas], parada.QtdParada, a.[QuantidadeParadas]-[QuantidadeAmbulancia]) /*-[QuantidadeAmbulancia]-[PacotesTransferidos]*/ as [QuantidadeParadas]  
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
      ,a.[Ambulancia]  
      ,[KmMotorista]  
   ,UsuarioDA  
   ,UsouAPP  
      ,FaixaPrimeiroUltimoPacote  
   ,estado   
   --,idtrevo  
  
   ,case when (a.TipoVeiculo in ('Rental Utilitário sem Ajudante','Melione Rental Utilitário com Ajudante',  
         'Rental Utilitário com Ajudante')  
     or  
     a.placa in ( 'SIA7J43','SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10'  
        ,'SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35')  
     )  
  then 1  
  else null end Rental  
  
    ,lst_cd_lista as idmktplace  
  
      from  #origem as a  
  
   left join tb_clientes as cli  
   on cli_id_logistics = a.idtransportadora  
  
   left join #paradas as parada  
   on a.idrota = parada.idrota  
  
      left join tb_ml_processamento_km_rotas as b  
      on a.IdRota = b.idRota  
        
   left join (  
    select   
     vmp_cd_rota  
     ,isnull(vmp_kmrecebimento,vmp_km_total_mapa) as totalkm  
     ,isnull(vmp_linkrecebimento ,vmp_idrota) as linkmapa  
    from tb_validacao_mapas with(nolock)   
    where vmp_cd_rota is not nULL  
   ) as vldmapa  
   on vldmapa.vmp_cd_rota = a.IdRota  
  
   left join (  
                select a.*,b. cli_id_logistics   
                from tb_fin_resultado_financeiro_alteracao as a with(nolock)   
                inner join tb_clientes as b  
                on a.idtransportadora = b.cli_cd_codigo_cliente  
                ) as alt  
 on a.IdTransportadora = alt.cli_id_logistics  
 and a.idrota = alt.idrota  
  
      where a.IdTransportadora = @IdTransportadora  
      and a.DataReferencia between @data_inicial and @data_final  
      and (@idrota is null or a.IdRota = @idrota)  
   --and a.tipo = 'LM'  
     -- and a.tipo = 'last_mile'  
  
        -- and KmColetado > 0   
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
 on a.UsuarioDA = versaoapp.CodigoUsuario  
   
 inner join  tb_clientes as cli  
 on a.idtransportadora  = cli.cli_id_logistics  
  
 where cli.cli_cd_codigo_cliente <> 7  
 AND NOT EXISTS (SELECT 1  -- CONDIÇÃO ADICIONADA DEVIDO AO ERRO DE PK POR DUPLICIDADE PK_tb_fin_pagamento_motorista  
       FROM tb_fin_resultado_financeiro fin  with(nolock)   
      WHERE a.idtransportadora = fin.idtransportadora    
        AND convert(varchar (30),a.idrota) = fin.idrota )   
  
   
  
  
  
 update #vw_rotas   
 set   
 [IdTransportadora] = IdTransportadoraClic   
  
  
 --Incluído por Saulo Barros em 30/04/2025 para considerar o KmColetado o RTT para 50+  
 alter table #vw_rotas add kmRTT int   
 IF (@IdTransportadora = 1726310024) --50mais  
 BEGIN  
  EXEC [dbo].[UspAtualizaFaixaRTT]  
    
  update   
   r  
  set   
   r.KmRTT = case when isnull(rtt.KmTotal,0) < 1 then 1 else cast(rtt.KmTotal as int) end --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa  
  from  
   #vw_rotas r  
   left join tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota   
         and cast(cast(rtt.Ano as varchar(4)) + '-' + cast(rtt.Mes as varchar(2)) + '-' + cast(case when rtt.Quinzena = 1 then 1 else 16 end as varchar(2)) as date) between @data_inicial and @data_final  
  
  update #vw_rotas set KmColetado = KmRTT, LinkMapa = null  
 END  
 --Fim inclusão Saulo Barros  
  
  
  
 -- Incluído em 04/06/2025 por Saulo Barros para considerar o dia da semana (para cálculo de domingo ou feriado) o menor dia em que teve um pacote com status de entregue ou não entrege  
 alter table #vw_rotas add DataInicio date  
 IF (@IdTransportadora = 1726310024) --50mais  
 begin  
  update  
   r  
  set  
   DataInicio = isnull(p.DataInicio, DataReferencia)  
  from  
   #vw_rotas r  
   left join (  
    select  
     r.IdRota,   
     min(cast(p.DataHoraEntrega as date)) DataInicio  
    from  
     #vw_rotas r  
     join tb_clientes c with(Nolock) on r.IdTransportadora = c.cli_cd_codigo_cliente  
     join tb_ml_pacotes p with(nolock) on r.IdRota = p.IdRota and c.cli_id_logistics = p.IdTransportadora  
    where  
     p.StatusEntrega in ('delivered', 'not_delivered')  
    group by  
     r.IdRota  
   ) p on r.IdRota = p.IdRota  
 end  
  
  
 --delete tb_fin_resultado_financeiro   
 --where 1=1   
 --and IdTransportadora in (select distinct [IdTransportadora] from #vw_rotas )  
 --and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena  
 --and (@idrota is null or IdRota = @idrota)  
  
  
 --insert into tb_fin_resultado_financeiro (  
 -- IdTransportadora,  
 -- Ano,  
 -- Mes,  
 -- Quinzena,  
 -- IdRota,  
 -- DataReferencia,  
 -- ServiceCenter,  
 -- XPT,  
 -- Base,  
 -- Placa,  
 -- Motorista,  
 -- Destino,  
 -- Cluster,  
 -- TipoVeiculo,  
 -- CicloPM,  
 -- DomingoOuFeriado,  
 -- TipoPagamentoFrete,  
 -- TipoPagamentoAdicional,  
 -- QuantidadePacotes,  
 -- PacotesEntregues,  
 -- Insucessos,  
 -- Pendentes,  
 -- QuantidadeParadas,  
 -- QuantidadePontos,  
 -- PgtoSaida,  
 -- PgtoParadas,  
 -- Adicional,  
 -- KmColetado,  
 -- LinkMapa,  
 -- FaixaKm,  
 -- RecebMeli,  
 -- RecebimentoParadas,  
 -- RecebimentoDomingo,  
 -- RecebimentoRisco,  
 -- RecebimentoAjudante,  
 -- DescontoCicloPM,  
 -- Pedagio,  
 -- ReceitaTotal,  
 -- PgtoLancamentoManual,  
 -- PgtoValorManual,  
 -- RecebimentoLancamentoManual,  
 -- RecebimentoValorManual,  
 -- RecebMeli0a100,  
 -- FretePreFatura,  
 -- RecebimentoDomingoPrefatura,  
 -- DescontoCicloPMPrefatura,  
 -- ValorAdicional0_60,  
 -- ValorAdicional61_90,  
 -- ValorAdicionalAcima_90,  
 -- DataHoraInicio,  
 -- TxAdicionalDomingo,  
 -- TxAdicionalCiclo_pm,  
 -- TxAdicionalAjudante,  
 -- TxAdicionalRisco,  
 -- UsouAPP,  
 -- VersaoDA,  
 -- kmnovo,  
 -- FaixaPrimeiroUltimoPacote,  
 -- ambulancia,  
 -- RecebimentoPonto,  
 -- ID,  
 -- DataAtualizacao,  
 -- tx_adicional_recarga,  
 -- RecebimentoRecarga,  
 -- Observacao,  
 -- riscov2,  
 -- Regiao,  
 --       idmktplace  
 --)  
  
   
   --declare @IdTransportadora int = 1662443209,  
   -- @Ano int = 2025,  
   -- @Mes tinyint = 03,  
   -- @Quinzena tinyint = 1,  
   -- @idrota int = 214216101  
  
  drop table if exists #tabela   
 SELECT IdTransportadora,  
  Ano,  
  Mes,  
  Quinzena,  
  IdRota,  
  DataReferencia,  
  ServiceCenter,  
  XPT,  
  Base,  
  Placa,  
  Motorista,  
  Destino,  
  Cluster,  
  TipoVeiculo,  
  CicloPM,  
  DomingoOuFeriado,  
  TipoPagamentoFrete,  
  TipoPagamentoAdicional,  
  QuantidadePacotes,  
  PacotesEntregues,  
  Insucessos,  
  Pendentes,  
  QuantidadeParadas,  
  QuantidadePontos ,  
  PgtoSaida,  
  PgtoParadas,  
  Adicional,  
  isnull(KmColetado,0) KmColetado,  
  LinkMapa,  
  
    
  --case when UsouAPP = 'Não' then null else FaixaKm end as FaixaKm,  
  FaixaKm,  
  RecebMeli,  
  RecebimentoParadas,  
  RecebimentoDomingo,  
  RecebimentoRisco,  
  RecebimentoAjudante,  
  DescontoCicloPM,  
  Pedagio,  
  
  /*isnull(RecebMeli,0) + isnull(RecebimentoParadas,0) + isnull(RecebimentoDomingo,0)   
  + isnull(RecebimentoRisco,0) + isnull(RecebimentoAjudante,0)   
  + isnull(Pedagio,0) - isnull(DescontoCicloPM,0) ReceitaTotal,*/  
        ReceitaTotal,  
  
  PgtoLancamentoManual,  
  PgtoValorManual,  
  RecebimentoLancamentoManual,  
  RecebimentoValorManual,  
  RecebMeli0a100,  
  FretePreFatura,  
  RecebimentoDomingoPrefatura,  
  DescontoCicloPMPrefatura,  
  ValorAdicional0_60,  
  ValorAdicional61_90,  
  ValorAdicionalAcima_90,  
  DataHoraInicio,  
  tx_adicional_domingo,  
  tx_adicional_ciclo_pm,  
  tx_adicional_ajudante,  
  tx_adicional_risco,  
  UsouAPP,  
  VersaoDA,  
  KmColetadoNovo,  
        FaixaPrimeiroUltimoPacote,  
  QuantidadeAmbulancia,  
  RecebimentoPonto,  
  id,  
  DataAtualizacao,  
  tx_adicional_recarga,  
  RecebimentoRecarga,  
  Observacao,  
  Riscov2,  
  Regiao,  
        idmktplace  
  
  into #tabela  
  
 FROM (  
 select distinct   
  IdTransportadora,  
  Ano,  
  Mes,  
  Quinzena,  
  IdRota,  
  DataReferencia,  
  ServiceCenter,  
  XPT,  
  Base,  
  Placa,  
  Motorista,  
  Destino,  
  Cluster,  
  TipoVeiculo,  
  CicloPM,  
  DomingoOuFeriado,  
  TipoPagamentoFrete,  
  TipoPagamentoAdicional,  
  QuantidadePacotes,  
  PacotesEntregues,  
  Insucessos,  
  Pendentes,  
  QuantidadeParadas as QuantidadeParadas,  
  QuantidadePontos ,  
  PgtoSaida,  
  PgtoParadas,  
  Adicional,  
  KmColetado,  
  LinkMapa,  
  
    
  --case when UsouAPP = 'Não' then null else FaixaKm end as FaixaKm,  
  FaixaKm,  
  isnull(RecebMeli,0) RecebMeli,  
  isnull(RecebimentoParadas,0) as RecebimentoParadas,  
  isnull(RecebimentoDomingo,0) as RecebimentoDomingo,  
  isnull(RecebimentoRisco,0)  as RecebimentoRisco,  
  isnull(RecebimentoAjudante,0) as RecebimentoAjudante,  
  isnull(DescontoCicloPM,0)       as DescontoCicloPM,  
  isnull(Pedagio,0) Pedagio,  
  
  /*isnull(RecebMeli,0) + isnull(RecebimentoParadas,0) + isnull(RecebimentoDomingo,0)   
  + isnull(RecebimentoRisco,0) + isnull(RecebimentoAjudante,0)   
  + isnull(Pedagio,0) - isnull(DescontoCicloPM,0) ReceitaTotal,*/  
        isnull(RecebMeli,0)  AS ReceitaTotal,  
  
  null PgtoLancamentoManual,  
  0 PgtoValorManual,  
  null RecebimentoLancamentoManual,  
  0 RecebimentoValorManual,  
  isnull(RecebMeli0a100,0) RecebMeli0a100,  
  isnull(FretePreFatura,0) FretePreFatura,  
  isnull(RecebimentoDomingoPrefatura,0) RecebimentoDomingoPrefatura,  
  isnull(DescontoCicloPMPrefatura,0) DescontoCicloPMPrefatura,  
  ValorAdicional0_60,  
  ValorAdicional61_90,  
  ValorAdicionalAcima_90,  
  DataHoraInicio,  
  tx_adicional_domingo,  
  tx_adicional_ciclo_pm,  
  tx_adicional_ajudante,  
  tx_adicional_risco,  
  UsouAPP,  
  VersaoDA,  
  case when UsouAPP = 'Não' then 0 else KmColetado end as KmColetadoNovo,  
        FaixaPrimeiroUltimoPacote,  
  QuantidadeAmbulancia,  
  RecebimentoPonto,  
  null id,  
  getdate() as DataAtualizacao,  
  tx_adicional_recarga,  
  ROW_NUMBER() OVER(PARTITION BY IdTransportadora, IdRota ORDER BY FaixaKm) AS ID_SORT,  
  --Total  
  RecebimentoRecarga,  
  Observacao,  
  Riscov2,  
  Regiao,  
  idmktplace  
  
  
 from  
 (  
  select  
   r.IdTransportadora,  
   @Ano Ano,  
   @Mes Mes,  
   @Quinzena Quinzena,  
   r.IdRota,  
            FaixaPrimeiroUltimoPacote,  
   isnull(alteracao.DataReferencia,r.DataReferencia) as DataReferencia,  
   r.DataHoraInicio,  
  
   --  isnull(alteracao.ServiceCenter,r.IdTransportadora) as ServiceCenter,  
   r.ServiceCenter ServiceCenter,  
   r.OrigemSaida XPT,  
   r.base Base,  
   r.Placa,  
   r.NomeMotorista Motorista,  
   r.CidadeReferencia Destino,  
   r.TipoRota Cluster,  
  
   isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) as TipoVeiculo,  
  
   isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) CicloPM,  
  
   case when r.IdTransportadora = 11 then  
    ISNULL(alteracao.DomingoOuFeriado, case when DATEPART(weekday, r.DataInicio) = 1 or dt2.Feriado = 1 then 'Sim' else 'Não' end)  
   else  
    ISNULL(alteracao.DomingoOuFeriado, case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then 'Sim' else 'Não' end)   
   end DomingoOuFeriado,  
  
   case when frete_diaria.bft_cd_base_frete_transportadora is not null then 'Frete Diária'  
   else case when frete_faixa.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM'  
   else case when frete_faixa_estado.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM por Estado'  
   else case when frete_faixa_svc.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM por SVC'  
   end end end end  TipoPagamentoFrete,  
     
   case isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) when 1 then 'Pagamento por Parada' when 0 then 'Pagamento por Ponto' else null end TipoPagamentoAdicional,  
     
   isnull(alteracao.QuantidadePacotes, r.TotalPacotes) QuantidadePacotes,  
  
   isnull(alteracao.PacotesEntregues,r.PacotesEntregues ) PacotesEntregues,  
  
   r.PacotesNaoEntregue Insucessos,  
   r.PacotesPendentes Pendentes,  
   r.QuantidadeAmbulancia,  
   isnull(alteracao.QuantidadeParadas, r.QuantidadeParadas ) as QuantidadeParadas,  
   isnull(alteracao.QuantidadePontos , r.QuantidadePontos ) as QuantidadePontos ,  
     
   null PgtoSaida,  
   null PgtoParadas,  
  
     
   --Criado por Saulo Barros em 18/06/2025 para adicionar regra pontual (será criado um processo apartado para todos casos assim)  
     
   case when r.IdTransportadora = 11 and r.DataReferencia between '2025-06-14' and '2025-06-15' and nullif(r.PacotesEntregues, 0) / cast(nullif(r.TotalPacotes, 0) AS decimal(9,2)) >= 0.94 and isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) not like '%SDD%' and r.ServiceCenter in ('SBA1', 'SBA2', 'SPA1', 'SAL1', 'SPE1', 'SBA6', 'ECE1') then     
    50  
   end  
   Adicional,  
     
   -- isnull(alteracao.KmColetado, r.KmColetado) as KmColetado,--r.pontosAppRotasTotalVoltaKm as KmColetadoNovo,  
   CAST(ISNULL(alteracao.KmColetado * 1.0, ISNULL(r.KmColetado * 1.0, 0)) AS NUMERIC(18,6)) AS KmColetado,  
  
   isnull(alteracao.LinkMapa  ,r.LinkMapa  ) as LinkMapa,  
     
   cast(COALESCE(frete_faixa.bft_vl_inicio_faixa, frete_faixa_estado.bft_vl_inicio_faixa, frete_faixa_svc.bft_vl_inicio_faixa) as varchar) + '/' +  
   cast(COALESCE(frete_faixa.bft_vl_fim_faixa, frete_faixa_estado.bft_vl_fim_faixa, frete_faixa_svc.bft_vl_fim_faixa) as varchar) FaixaKm,  
    
   -- verificar se a rota e do ciclo AM ou PM, se for PM traga da coluna , frete_faixa_estado.bft_vl_frete_pm, bft_vl_frete_pm.bft_vl_frete_pm)  
             --COALESCE(frete_diaria.bft_vl_frete_pm, frete_faixa.bft_vl_frete_pm  
             --                                       , frete_faixa_estado.bft_vl_frete_pm, frete_faixa_svc.bft_vl_frete_pm)  
               
             --, se nao  COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete  
                 
     --Alterado por Saulo Barros em 04/06/2025 para no cálculo da 50+ não mostrar valor da prefatura caso seja maior que o valor calculado  
     --PS: pra mim não faz sentido ter essa verificação, pois estamos falando que sempre que a prefatura for maior que o calculado, nos calculamos o mesmo valor  
   case when r.IdTransportadora = 11 then  
    case when KmCiclo = 'ambulance' then   
     0   
    else   
     COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete , frete_faixa_estado.bft_vl_frete, frete_faixa_svc_cidade.bft_vl_frete, frete_faixa_svc.bft_vl_frete)  
    end  
   else  
    case   
     when r.CicloPM = 'PM' and r.IdTransportadora  = 37  
      then   
       case   
        when KmCiclo = 'ambulance'  
         then 0  
        else  
         case   
          when pre.Total >= COALESCE(frete_diaria.bft_vl_frete_pm, frete_faixa.bft_vl_frete_pm  
                 , frete_faixa_estado.bft_vl_frete_pm, frete_faixa_svc.bft_vl_frete_pm)  
           then pre.Total  
          else COALESCE( frete_diaria.bft_vl_frete_pm, frete_faixa.bft_vl_frete_pm  
                 , frete_faixa_estado.bft_vl_frete_pm, frete_faixa_svc.bft_vl_frete_pm)  
          end  
        end  
      else    
       case   
        when KmCiclo = 'ambulance'  
         then 0  
        else  
         case   
          when pre.Total >= COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete  
                 , frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete)  
           then pre.Total  
          else COALESCE( frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete  
                 , frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete)  
          end  
        end  
    END   
   end as RecebMeli,  
     
   case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then  
  
    case when r.QuantidadeParadas > 60 then 60 else r.QuantidadeParadas end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)  
    +  
    case when r.QuantidadeParadas > 60 then case when r.QuantidadeParadas >= 90 then 30 else r.QuantidadeParadas - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)  
    +  
    case when r.QuantidadeParadas > 90 then r.QuantidadeParadas - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)  
   else  
    case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)  
    +  
    case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)  
    +  
    case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)  
   end RecebimentoParadas,  
  
    case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)  
    +  
    case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)  
    +  
    case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)  as RecebimentoPonto,  
  
     
  
   case when r.IdTransportadora = 11 then  
    case when KmCiclo = 'ambulance' then   
     0  
    else  
     case when (alteracao.DomingoOuFeriado = 'Sim' or DATEPART(weekday, r.DataInicio) = 1 or dt2.Feriado = 1) then --domingo ou feriado  
      case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem  
       --quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm  
       (  
        COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc_cidade.bft_vl_frete, frete_faixa_svc.bft_vl_frete)   
        -  
        isnull(  
         case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
          case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
           COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc_cidade.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
          else --Valor  
           isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
          end  
         else  
          0  
         end  
        ,0)  
       )  
       *   
       isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100  
      else --Valor  
       isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)  
      end  
     else  
      0  
     end  
    end  
   else  
    case when (alteracao.DomingoOuFeriado = 'Sim' or DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1) then --domingo ou feriado  
     case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem  
      --quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm  
      (  
       COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete)   
       -  
       isnull(  
        case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
         case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
          COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
         else --Valor  
          isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
         end  
        else  
         0  
        end  
       ,0)  
      )  
      *   
      isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100  
     else --Valor  
      isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)  
     end  
    else  
     0  
    end   
   end RecebimentoDomingo,  
  
   case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
    case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
     COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
    else --Valor  
     isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
    end  
   else  
    0  
   end DescontoCicloPM,  
  
   case when  (alteracao.DomingoOuFeriado = 'Sim' or  (r.TipoRota like 'R[_]%'  and r.serviceCenter ='SSP21' and r.IdTransportadora=1491631999) or risco.crt_cd_risco_transportadora is not null) then  
    case when isnull(adicional.bfa_tipo_adicional_risco,adicional_svc.bfa_tipo_adicional_risco) = 1 then --Porcentagem  
     COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco) / 100   
    else  
     isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco)  
    end  
   else  
    0  
   end RecebimentoRisco,  
  
   case when  (alteracao.Ajudante = 'Sim'  or r.PossuiAjudante = 1) then  
    case when isnull(adicional.bfa_tipo_adicional_ajudante,adicional_svc.bfa_tipo_adicional_ajudante) = 1 then --Porcentagem  
     COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete, frete_faixa_estado.bft_vl_frete, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante) / 100   
    else  
     isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante)  
    end  
   else  
    0  
   end as RecebimentoAjudante,  
  
   null Pedagio,  
     
   isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)  
   - --CicloPM  
   isnull(case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
    case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
     isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
    else --Valor  
     isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
    end  
   else  
    0  
   end,0)  
   + --Adicional Domingo  
   isnull(case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado  
    case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem  
     --quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm  
     (  
      isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)  
      -  
      isnull(  
       case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
        case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
         isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)  * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
        else --Valor  
         isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
        end  
       else  
        0  
       end  
      ,0)  
     )  
     *   
     isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100  
    else --Valor  
     isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)  
    end  
   else  
    0  
   end,0) RecebMeli0a100,  
     
   isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) FretePreFatura,  
  
   case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado  
    case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem  
     --quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm  
     (  
      isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete)  
      -  
      isnull(  
       case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
        case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
         isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
        else --Valor  
         isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
        end  
       else  
        0  
       end  
      ,0)  
     )  
     *   
     isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100  
    else --Valor  
     isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)  
    end  
   else  
    0  
   end RecebimentoDomingoPrefatura,  
  
   case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) < 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then  
    case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem  
     isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado  
    else --Valor  
     isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  
    end  
   else  
    0  
   end DescontoCicloPMPrefatura,  
  
  
  
   case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then  
    case when r.QuantidadeParadas > 60 then 60 else r.QuantidadeParadas end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)  
   else  
    case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)  
   end ValorAdicional0_60,    
     
   case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then  
    case when r.QuantidadeParadas > 60 then case when r.QuantidadeParadas >= 90 then 30 else r.QuantidadeParadas - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)  
   else  
    case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)  
   end ValorAdicional61_90,  
  
   case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then  
    case when r.QuantidadeParadas > 90 then r.QuantidadeParadas - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)  
   else  
      
    case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end *isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)  
   end ValorAdicionalAcima_90,  
  
   isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) as tx_adicional_domingo,  
   isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm) as tx_adicional_ciclo_pm,  
   isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante) as tx_adicional_ajudante,  
   isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco)  as tx_adicional_risco,  
   isnull(adicional.bfa_adicional_recarga, adicional_svc.bfa_adicional_recarga)  as tx_adicional_recarga,  
   r.UsouAPP,  
   r.VersaoDA,  
   pre.Total,  
   adicional.bfa_adicional_recarga AS RecebimentoRecarga,  
   alteracao.Observacao,  
   alteracao.Riscov2,  
   alteracao.Regiao,  
   idmktplace  
        
  from  
   #vw_rotas r with(nolock)  
  
   --left join tb_ml_service_center svc2   
   --on r.ServiceCenter = svc2.svc_cd_service_center   
   --and r.IdTransportadora = svc2.IdTransportadora   
     
   left join DimData dt on r.DataReferencia = dt.Data  
  
   --Incluído por Saulo Barros em 04/06 para 50+ considerar essa data de verificação de domingo  
   left join (  
    /*feriado sera controlado pelo cliente na tela https://50mais.irisys.com.br/feriados */  
    select   
      tfd_cd_cliente idtransportadora  
     ,bss_ds_sigla servicecenter  
     ,a.Data  
     ,1 Feriado  
    from DimData as a with (nolock)  
  
    inner join [tb_feriados] as b with (nolock)  
    on a.data = b.tfd_dh_feriado  
  
    left join tb_bases  as c with (nolock)  
    on bss_cod_cliente = tfd_cd_cliente  
    and (  
    bss_ds_estado  = tfd_ds_estado  
    or tfd_ds_municipio = bss_ds_cidade  
    or tfd_tipo_feriado = 'Nacional'  
    )  
    where tfd_in_excluido = 0  
    ) as dt2 on r.DataInicio = dt2.Data  
    and r.IdTransportadora  = dt2.idtransportadora  
    and r.serviceCenter = dt2.servicecenter  
      
  
   --left join DimData dt2 on r.DataInicio = dt2.Data  
     
   --left join tb_ml_service_center svc with(nolock)   
   --on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center   
   --and r.IdTransportadora = svc.IdTransportadora   
              
   --left join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora  
     
  
   left join tb_dra_tipo_veiculo tv with(nolock) on isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) = tv.tvl_nm_tipo_veiculo  
    
   left join vw_fin_prefatura pre with(nolock)  on @IdTransportadora = pre.IdTransportadora  
            and r.IdRota = pre.IdRota  
            --and r.DataReferencia = pre.DataTermino  
            --and pre.Quinzena = @Quinzena  
            --and pre.Ano = @Ano  
            --and pre.Mes = @Mes  
  
   left join tb_fin_cidades_risco_transportadora   as risco with(nolock) on r.IdTransportadora = risco.crt_cd_transportadora  
                 and r.serviceCenter = risco.crt_cd_service_center  
                 and r.CidadeReferencia = risco.crt_nm_cidade  
  
   --frete com valor por dia   
   left join vw_fin_base_frete_transportadora frete_diaria  with(nolock) on tv.tvl_cd_tipo_veiculo = frete_diaria.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_diaria.bft_cd_transportadora  
                 and frete_diaria.bft_cd_service_center is null   
                 and frete_diaria.bft_estado is null  
                 and frete_diaria.bft_vl_inicio_faixa is null  
                 and frete_diaria.bft_vl_fim_faixa is null  
                                                                    and frete_diaria.bft_data_fim is null  
                 and frete_diaria.Operacao = 'LM'  
  
   --frete por faixa (independente de svc e estado)  
   left join vw_fin_base_frete_transportadora frete_faixa with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa.bft_cd_transportadora  
                 and frete_faixa.bft_cd_service_center is null   
                 and frete_faixa.bft_estado is null  
                 and r.KmColetado > (frete_faixa.bft_vl_inicio_faixa - 1)  
                 and r.KmColetado <= frete_faixa.bft_vl_fim_faixa  
                                                                    and frete_faixa.bft_data_fim is null  
                 and frete_faixa.Operacao = 'LM'  
    
   --left join tb_fin_base_km_trevo trevo with(nolock)   
   --          on r.IdTrevo = trevo.bkt_cd_base_km_trevo  
  
  
   ----frete por faixa (independente de svc e estado)  
   --left join vw_fin_base_frete_transportadora frete_trevo  on tv.tvl_cd_tipo_veiculo = frete_trevo.bft_cd_tipo_veiculo   
   --              and r.IdTransportadora = frete_trevo.bft_cd_transportadora  
   --              and frete_trevo.bft_cd_service_center is null   
   --              and frete_trevo.bft_estado is null  
   --              and trevo.bkt_vl_km_ideal > (frete_trevo.bft_vl_inicio_faixa - 1)  
   --              and trevo.bkt_vl_km_ideal <= frete_trevo.bft_vl_fim_faixa  
  
  
   --frete por faixa (independente de svc e estado) considerando km prefautra  
   left join vw_fin_base_frete_transportadora frete_faixa_prefatura with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_prefatura.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_prefatura.bft_cd_transportadora  
                 and frete_faixa_prefatura.bft_cd_service_center is null   
                 and frete_faixa_prefatura.bft_estado is null  
                 and pre.InicioIntervalo >= frete_faixa_prefatura.bft_vl_inicio_faixa  
                 and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= frete_faixa_prefatura.bft_vl_fim_faixa  
                                                                    and frete_faixa_prefatura.bft_data_fim is null  
                 and frete_faixa_prefatura.Operacao = 'LM'  
   --frete por faixa e estado  
   left join vw_fin_base_frete_transportadora frete_faixa_estado with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_estado.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_estado.bft_cd_transportadora  
                 and frete_faixa_estado.bft_cd_service_center is null   
                 and frete_faixa_estado.bft_estado = r.estado  
                 and r.KmColetado > (frete_faixa_estado.bft_vl_inicio_faixa - 1)  
                 and r.KmColetado <= frete_faixa_estado.bft_vl_fim_faixa  
                                                                    and frete_faixa_estado.bft_data_fim is null  
                 and frete_faixa_estado.Operacao = 'LM'  
  
   --frete por faixa e svc  
   left join vw_fin_base_frete_transportadora frete_faixa_svc with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_svc.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_svc.bft_cd_transportadora  
                 and frete_faixa_svc.bft_cd_service_center = r.serviceCenter  
                 and frete_faixa_svc.bft_estado  is null  
                 and r.KmColetado >= (frete_faixa_svc.bft_vl_inicio_faixa - 1)  
                 and r.KmColetado <= frete_faixa_svc.bft_vl_fim_faixa  
                                                                    and frete_faixa_svc.bft_data_fim is null  
                 and frete_faixa_svc.Operacao = 'LM'  
  
   --frete por faixa, svc e cidade  
   left join vw_fin_base_frete_transportadora frete_faixa_svc_cidade with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_cidade.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_svc_cidade.bft_cd_transportadora  
                 and frete_faixa_svc_cidade.bft_cd_service_center = r.serviceCenter  
                 and frete_faixa_svc_cidade.bft_nm_cidade = r.CidadeReferencia  
                 and frete_faixa_svc_cidade.bft_estado  is null  
                 and r.KmColetado >= (frete_faixa_svc_cidade.bft_vl_inicio_faixa - 1)  
                 and r.KmColetado <= frete_faixa_svc_cidade.bft_vl_fim_faixa  
                                                                    and frete_faixa_svc_cidade.bft_data_fim is null  
                 and frete_faixa_svc_cidade.Operacao = 'LM'  
  
   --frete por faixa e svc considerando km prefatura  
   left join vw_fin_base_frete_transportadora frete_faixa_svc_prefatura with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_prefatura.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_svc_prefatura.bft_cd_transportadora  
                 and frete_faixa_svc_prefatura.bft_cd_service_center = r.serviceCenter  
                 and frete_faixa_svc_prefatura.bft_estado  is null  
                 and pre.InicioIntervalo >= frete_faixa_svc_prefatura.bft_vl_inicio_faixa  
                 and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= frete_faixa_svc_prefatura.bft_vl_fim_faixa  
                                                                    and frete_faixa_svc_prefatura.bft_data_fim is null  
                 and frete_faixa_svc_prefatura.Operacao = 'LM'  
  
   --frete por faixa (independente de svc e estado) km 0 a 100  
   left join vw_fin_base_frete_transportadora frete_faixa_Km0a100 with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_Km0a100.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_Km0a100.bft_cd_transportadora  
                 and frete_faixa_Km0a100.bft_cd_service_center is null   
                 and frete_faixa_Km0a100.bft_estado is null  
                 and frete_faixa_Km0a100.bft_vl_inicio_faixa = 1  
                     and frete_faixa_Km0a100.bft_data_fim is null  
                 and frete_faixa_Km0a100.Operacao = 'LM'  
  
   --frete por faixa e svc km 0 a 100  
   left join vw_fin_base_frete_transportadora frete_faixa_svc_Km0a100 with(nolock) on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_Km0a100.bft_cd_tipo_veiculo   
                 and r.IdTransportadora = frete_faixa_svc_Km0a100.bft_cd_transportadora  
                 and frete_faixa_svc_Km0a100.bft_cd_service_center = r.serviceCenter  
                 and frete_faixa_svc_Km0a100.bft_estado  is null  
                 and frete_faixa_svc_Km0a100.bft_vl_inicio_faixa = 1  
                                                                    and frete_faixa_svc_Km0a100.bft_data_fim is null  
                 and frete_faixa_svc_Km0a100.Operacao = 'LM'  
  
     
   left join vw_fin_base_frete_adicional adicional with(nolock) on tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo   
                 and r.IdTransportadora = adicional.bfa_cd_transportadora  
                 and adicional.bfa_cd_service_center is null  
                 and adicional.bfa_estado  is null  
                                                                    and adicional.bfa_data_fim is null  
                 and adicional.Operacao = 'LM'  
  
   left join vw_fin_base_frete_adicional adicional_svc with(nolock) on tv.tvl_cd_tipo_veiculo = adicional_svc.bfa_cd_tipo_veiculo   
                 and r.IdTransportadora = adicional_svc.bfa_cd_transportadora  
                 and adicional_svc.bfa_cd_service_center =  r.ServiceCenter  
                 and adicional_svc.bfa_estado  is null    
                                                                    and adicional_svc.bfa_data_fim is null  
                 and adicional_svc.Operacao = 'LM'  
  
  
   left join   
   
     (  
     select a.*,b. cli_id_logistics   
     from tb_fin_resultado_financeiro_alteracao as a with(nolock)  
     inner join tb_clientes as b  
     on a.idtransportadora = b.cli_cd_codigo_cliente  
     ) as alteracao  
  
   on r.idrota = alteracao.idrota  
   and r.IdTransportadora = alteracao.IdTransportadora  
     
  where 1=1  
   and r.DataReferencia <= cast(getdate() as date)  
  
     
    
 ) rotas  
 ) AS rotas2  
 WHERE ID_SORT = 1  
  
  
 delete from tb_fin_resultado_financeiro   
where 1=1   
--and IdTransportadora in (47)  
--and Ano = @ano and Mes = @mes and Quinzena = @quinzena  
and IdRota in (  
select  cast(idrota as varchar(max)) from #tabela )  
and IdTransportadora in(  
select  cast(idtransportadora as varchar(max)) from #tabela   
)  
  
  
  
 insert into tb_fin_resultado_financeiro (  
  IdTransportadora,  
  Ano,  
  Mes,  
  Quinzena,  
  IdRota,  
  DataReferencia,  
  ServiceCenter,  
  XPT,  
  Base,  
  Placa,  
  Motorista,  
  Destino,  
  Cluster,  
  TipoVeiculo,  
  CicloPM,  
  DomingoOuFeriado,  
  TipoPagamentoFrete,  
  TipoPagamentoAdicional,  
  QuantidadePacotes,  
  PacotesEntregues,  
  Insucessos,  
  Pendentes,  
  QuantidadeParadas,  
  QuantidadePontos,  
  PgtoSaida,  
  PgtoParadas,  
  Adicional,  
  KmColetado,  
  LinkMapa,  
  FaixaKm,  
  RecebMeli,  
  RecebimentoParadas,  
  RecebimentoDomingo,  
  RecebimentoRisco,  
  RecebimentoAjudante,  
  DescontoCicloPM,  
  Pedagio,  
  ReceitaTotal,  
  PgtoLancamentoManual,  
  PgtoValorManual,  
  RecebimentoLancamentoManual,  
  RecebimentoValorManual,  
  RecebMeli0a100,  
  FretePreFatura,  
  RecebimentoDomingoPrefatura,  
  DescontoCicloPMPrefatura,  
  ValorAdicional0_60,  
  ValorAdicional61_90,  
  ValorAdicionalAcima_90,  
  DataHoraInicio,  
  TxAdicionalDomingo,  
  TxAdicionalCiclo_pm,  
  TxAdicionalAjudante,  
  TxAdicionalRisco,  
  UsouAPP,  
  VersaoDA,  
  kmnovo,  
  FaixaPrimeiroUltimoPacote,  
  ambulancia,  
  RecebimentoPonto,  
  ID,  
  DataAtualizacao,  
  tx_adicional_recarga,  
  RecebimentoRecarga,  
  Observacao,  
  riscov2,  
  Regiao,  
        idmktplace  
 )  
  
   
 select  * from #tabela   
  
 --Atualiza Indicadores  
 exec [UspFinanceiroAtualizaIndicadores] @IdTransportadora, @Ano, @Mes, @Quinzena, 'Faturamento'  
 exec [UspFinanceiroAtualizaIndicadores] @IdTransportadora, @Ano, @Mes, @Quinzena, 'Validação'  
 --exec UspGeraResultadoFinanceiro @IdTransportadora, @Ano, @Mes, @Quinzena  
  
end  
  
GO
