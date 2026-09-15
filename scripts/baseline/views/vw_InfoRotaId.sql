-- ============================================================
-- BASELINE: dbo.vw_InfoRotaId
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_InfoRotaId]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_InfoRotaId] as   
    
select   
    rotas.DataReferencia,   
    rotas.DataHoraInicio,   
    rotas.DataUltimaEntrega,  
    rotas.ServiceCenter,   
    rotas.OrigemSaida,   
    rotas.NomeMotorista,   
    rotas.TipoVeiculo,  
    rotas.TotalPacotes,  
    rotas.QuantidadeParadas,  
    fin.IntervaloFaixa  as FaixaPreFatura,  
    kmRota.opcaoKmPreFatura,  
    kmRota.IdRotaGuid,  
    cast(rotas.IdRota as varchar(50)) as IdRota  
from tb_ml_rotas as rotas with(nolock)  
 left join tb_fin_prefatura as fin  
 on cast(rotas.IdRota as varchar(50)) = fin.IdRota  
 and rotas.IdTransportadora = fin.IdTransportadora  
left join tb_ml_processamento_km_rotas as kmRota  
 on rotas.IdRota = kmRota.idRota  
where rotas.DataReferencia >= cast(getdate()-120 as date)  
   and Excluido = 0  
  
union all

select 
    rotas.DataReferencia,   
    rotas.DataInicio,   
    null DataUltimaEntrega,  
    OrigemSaida ServiceCenter,   
    rotas.OrigemSaida,   
    rotas.NomeMotorista,   
    rotas.TipoVeiculo,  
    0 TotalPacotes,  
    rotas.QuantidadeParadas,  
    null  as FaixaPreFatura,  
    kmRota.opcaoKmPreFatura,  
    kmRota.IdRotaGuid,  
    cast(rotas.IdRota as varchar(50)) as IdRota  
from
  tb_ml_fm_rotas as rotas with (nolock)
  join tb_clientes cli with (nolock) 
    on rotas.IdTransportadora = cli.cli_id_logistics 
    and cli.cli_in_ativo = 1
    
    left join tb_ml_processamento_km_rotas as kmRota  
    on rotas.IdRota = kmRota.idRota
    
where
  Excluido = 0

  
union all  
  
select 
 rotas.DataReferencia,   
 rotas.DataHoraInicio,   
    rotas.DataUltimaEntrega,  
 rotas.nomehub,   
 rotas.nomehub,   
 rotas.motorista,   
 rotas.TipoVeiculo,  
 rotas.TotalPacotes,  
    rotas.Paradas as QuantidadeParadas,  
 '-'  as FaixaPreFatura,  
 kmRota.opcaoKmPreFatura,  
 kmRota.IdRotaGuid,  
 codigorota as IdRota  
from tb_spe_rotas_v5 as rotas  with(nolock)  
 left join tb_spe_processamento_km_rotas as kmRota  with(nolock)  
 on codigorota = idRota  
where rotas.DataReferencia >= cast(getdate()-120 as date)  
   and Excluido = 0  
  
GO
