-- ============================================================
-- BASELINE: dbo.vw_resumo_rotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_resumo_rotas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE view [dbo].[vw_resumo_rotas]  
as  
select  
 base.Data,  
 tr.tpr_nome_transportadora Transportadora,  
 isnull(rotas.Qtde,0) Rotas,  
 isnull(reprocessar.Qtde,0) Reprocessar,  
 isnull(app.Qtde,0) ApontamentoAPP,  
 isnull(coletaKm.Qtde,0) KmEntregaCalculado  
from  
 (  
 select  
  dt.Data,  
  tr.tpr_cd_transportadora IdTransportadora  
 from  
  DimData dt  
  cross join tb_dra_transportadora tr  
 where  
  dt.Data between '2026-04-01' and cast(getdate() as date)  
  and tr.tpr_cd_marketplace = 1  
 ) base  
 join tb_dra_transportadora tr on base.IdTransportadora = tr.tpr_cd_transportadora  
 left join (  
  select  
   IdTransportadora,  
   DataReferencia,  
   count(1) Qtde  
  from  
   tb_ml_rotas  
  where  
   Excluido = 0  
   and DataReferencia between '2026-01-01' and cast(getdate() as date)  
  group by  
   IdTransportadora,  
   DataReferencia  
 ) rotas on base.IdTransportadora = rotas.IdTransportadora and base.Data = rotas.DataReferencia  
 left join (  
  select  
   IdTransportadora,  
   DataReferencia,  
   count(1) Qtde  
  from  
   tb_rotas_para_reprocessar  
  where  
   DataReferencia between '2026-01-01' and cast(getdate() as date)  
  group by  
   IdTransportadora,  
   DataReferencia  
 ) reprocessar on base.IdTransportadora = reprocessar.IdTransportadora and base.Data = reprocessar.DataReferencia  
 left join (  
  select   
   r.IdTransportadora,  
   r.DataReferencia,  
   count(1) Qtde  
  from  
   tb_ml_rotas r with(nolock)  
   join tb_clientes as c on r.IdTransportadora = c.cli_id_logistics  
   join (  
  
    select   
     distinct   
     users.cli_cd_codigo_cliente as Transportadora,  
     --users.usr_nm_usuario as Motorista,  
     users.usr_cd_usuario as UsuarioDA,  
     cast(gps.rgp_dh_data_hora as date) as Data  
    from   
     tb_registro_gps as gps with(nolock)  
     join tb_usuario as users  with(nolock)  
     on gps.rgp_cd_usuario = users.usr_cd_usuario   
     
   ) gps on c.cli_cd_codigo_cliente = gps.Transportadora   
     --and r.NomeMotorista = gps.Motorista  
     and r.UsuarioDA = gps.UsuarioDA  
     and r.DataReferencia = gps.Data   
  where  
   DataReferencia between '2026-01-01' and cast(getdate() as date)  
  group by  
   r.IdTransportadora,  
   r.DataReferencia  
 ) app on base.IdTransportadora = app.IdTransportadora and base.Data = app.DataReferencia  
 left join (  
  select  
   dam_cd_transportadora IdTransportadora,  
   dam_dh_referencia DataReferencia,  
   count(1) Qtde  
  from  
   tb_dra_coleta_maps  
  where  
   dam_dh_referencia between '2026-04-01' and cast(getdate() as date)  
  group by  
   dam_cd_transportadora,  
   dam_dh_referencia  
 ) coletaKm   
 on base.IdTransportadora = coletaKm.IdTransportadora   
 and base.Data = coletaKm.DataReferencia  
  
GO
