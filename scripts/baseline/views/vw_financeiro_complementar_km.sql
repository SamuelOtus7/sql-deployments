-- ============================================================
-- BASELINE: dbo.vw_financeiro_complementar_km
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_complementar_km]    Script Date: 14/09/2026 12:12:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_financeiro_complementar_km]
as


select
    b.codreceb
    ,atp_dt_data
    ,atp_ds_rota
    ,'Pedágio' as MotivoContestado
    ,atp_ds_base + '- PEDÁGIO' as ObsGeral
    ,b.TipoVeiculo
    ,b.CicloPM Ciclo 
    ,0 as PagoPreFatura
    ,atp_dc_valor as ValorCorretoMLP
    ,atp_dc_valor as Diferenca
    ,'https://' + cli_ds_sub_dominio + '/comprovante-pedagio?route=' + atp_ds_hash_rota  as LinkEvidencia
    ,null TipoErro
    ,cast(case when b.DataReferencia >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else b.DataReferencia end as datetime) DataAtualizacaoControlePowerBI


from [dbo].[tb_atm_pedagios] as a 
inner join tb_fin_resultado_financeiro as b
on atp_cd_codigo_cliente = b.idtransportadora
and  a.atp_ds_rota = b.idrota

left join tb_clientes as cli
on atp_cd_codigo_cliente = cli.cli_cd_codigo_cliente

where atp_cd_codigo_status = 1
-- and atp_cd_codigo_cliente = 47

union ALL

select
    financeiro.codreceb,
  financeiro.DataReferencia Data,
    financeiro.idrota,
  --p.pontosAppRotasTotalKm,
  --prefatura.IntervaloFaixa FaixaPreFatura,
  --financeiro.FaixaKm FaixaIrisys,
    case when (financeiro.TipoVeiculo <> prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end) then
    'Diferença de tarifa Negociado x Cadastrado'
        when financeiro.CicloPM <> prefatura.CicloPM and financeiro.ServiceCenter = XPT then
        'Ciclo PM para SVC'
        when financeiro.CicloPM <> prefatura.CicloPM and financeiro.ServiceCenter <> XPT then
        'Ciclo PM para XPT'
    when isnull(prefatura.IntervaloFaixa,0) <> isnull(financeiro.FaixaKm,-1) and prefatura.InicioIntervalo is not null then 'Faixa de KM diferente' 
  else case when prefatura.IdRota is null then 
    'Diferença de tarifa Negociado x Cadastrado' 
  else 'Diferença de tarifa Negociado x Cadastrado' end end MotivoContestado,

    case when (financeiro.TipoVeiculo <> prefatura.Veiculo + case when prefatura.ContinuacaoVeiculo is not null then ' - ' + prefatura.ContinuacaoVeiculo else '' end) then
    financeiro.ServiceCenter + ' - PAGAMENTO DIVERGENTE DA TABELA NEGOCIADA, VALOR CORRETO R$ ' + cast(financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) as varchar(20))
        when financeiro.CicloPM <> prefatura.CicloPM and financeiro.ServiceCenter = XPT then
        financeiro.ServiceCenter + ' - PAGAMENTO DIVERGENTE DA TABELA NEGOCIADA, VALOR CORRETO R$ ' + cast(financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) as varchar(20))
        when financeiro.CicloPM <> prefatura.CicloPM and financeiro.ServiceCenter <> XPT then
    financeiro.ServiceCenter + ' - PAGAMENTO DIVERGENTE DA TABELA NEGOCIADA, VALOR CORRETO R$ ' + cast(financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) as varchar(20))
    when isnull(prefatura.IntervaloFaixa,0) <> isnull(financeiro.FaixaKm,-1) and prefatura.InicioIntervalo is not null then
    financeiro.ServiceCenter + ' FAIXA DE KM DIVERGENTE DO PERCURSO REALIZADO. FAIXA CORRETA: ' + cast(financeiro.FaixaKm as varchar(20)) + ' VALOR CORRETO R$ ' + cast(financeiro.RecebMeli as varchar(20))
  else case when prefatura.IdRota is null then 
    financeiro.ServiceCenter + ' - PAGAMENTO DIVERGENTE DA TABELA NEGOCIADA, VALOR CORRETO R$ ' + cast(financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) as varchar(20)) 
  else financeiro.ServiceCenter + ' - PAGAMENTO DIVERGENTE DA TABELA NEGOCIADA, VALOR CORRETO R$ ' + cast(financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) as varchar(20))
      end end ObsGeral,
    financeiro.TipoVeiculo,
    financeiro.CicloPM,
    prefatura.Total as ValorPrefatura,
    financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) as ValorCorreto,
    financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) - prefatura.Total as Diferenca,
  --'https://' + cli_ds_sub_dominio + '/public/mapa?idRota=' + CAST(idRotaGuid AS varchar(50)) AS Link,
  --LinkMapaApp as Link,
  case 
    when isnull(prefatura.IntervaloFaixa,0) <> isnull(financeiro.FaixaKm,-1) and prefatura.InicioIntervalo is not null then LinkMapaApp
    else null end as Link,
    null TipoErro,
    cast(case when financeiro.DataReferencia >= dateadd(day,-30,cast(getdate() as date)) then cast(getdate() as date) else financeiro.DataReferencia end as datetime) DataAtualizacaoControlePowerBI

from
  tb_fin_resultado_financeiro financeiro
  left join (
  select 
  cli_cd_codigo_cliente as IdTransportadora
  ,Ano
  ,Mes
  ,Quinzena
  ,Veiculo
  ,ContinuacaoVeiculo
  ,ServiceCenter
  ,KmCiclo
  ,CicloPM
  ,IntervaloFaixa
  ,InicioIntervalo
  ,FimIntervalo
  ,Dia
  ,IdRota
  ,DataInicio
  ,DataTermino
  ,Placa
  ,Motorista
  ,Quantidade
  ,PrecoUnitario
  ,Total
  from tb_fin_prefatura as a
  inner join tb_clientes as b
  on a.IdTransportadora = b.cli_id_logistics
  -- and cli_cd_codigo_cliente = 1
  --and Ano = 2024
  --and Mes = 6
  --and Quinzena = 1


  )prefatura 
    on prefatura.IdTransportadora = financeiro.IdTransportadora
    and prefatura.Ano = financeiro.Ano
    and prefatura.Mes = financeiro.Mes
    and prefatura.Quinzena = financeiro.Quinzena
    and prefatura.IdRota = financeiro.IdRota

  join tb_clientes on financeiro.IdTransportadora = cli_cd_codigo_cliente

left join tb_ml_rotas mapa
on mapa.idrota = financeiro.idrota

left join tb_ml_processamento_km_rotas p
on p.idrota = financeiro.idrota

where 1=1
and financeiro.DataReferencia >= '2025-10-01'   -- ESCOLHER A DATA AQUI
--and cli_cd_codigo_cliente = 68
--and (financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0) ) > prefatura.Total 
and (
        (financeiro.RecebMeli - isnull(financeiro.DescontoCicloPM,0)) > prefatura.Total
        or (
            isnull(prefatura.IntervaloFaixa,0) <> isnull(financeiro.FaixaKm,-1)
            and prefatura.InicioIntervalo is not null 
      and financeiro.FaixaKm is not null
          --and mapa.excluido = 0
        )
      )
and p.pontosAppRotasTotalKm > 0
--and financeiro.IdRota = '334712085'

GO
