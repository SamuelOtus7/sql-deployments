-- ============================================================
-- BASELINE: dbo.vw_ml_rotas_fora_area_entrega
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ml_rotas_fora_area_entrega]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ml_rotas_fora_area_entrega] as

select 
     idAreaEntrega	
    ,a.idtransportadora	
    ,a.datareferencia	
    ,b.Motorista
    ,b.ServiceCenter
    --,b.OrigemSaida as XPT
    ,Rota	
    ,CidadeApp	
    ,AreaDeEntrega	
    ,pontosAppRotasTotalKm
    ,pontosRotasPacotesKm	
    ,delta
    ,b.LinkAppInterno

from tb_ml_rotas_fora_area_entrega as a with(nolock)

inner join [dbo].[vw_rotas_motoristas] as b
on a.rota = b.IdRota
GO
