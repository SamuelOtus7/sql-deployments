-- ============================================================
-- BASELINE: dbo.vw_dados_rotas_lancamentos_manuais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dados_rotas_lancamentos_manuais]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- dbo.vw_dados_rotas_lancamentos_manuais fonte

-- dbo.vw_dados_rotas_lancamentos_manuais fonte

-- dbo.vw_dados_rotas_lancamentos_manuais fonte

-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
-- -- dbo.vw_dados_rotas_lancamentos_manuais source

CREATE     view [dbo].[vw_dados_rotas_lancamentos_manuais]
as
select Id,
       CAST(IdRota as varchar(30)) as IdRota,	
	   ServiceCenter,
	   OrigemSaida,
	   NomeMotorista,
	   'AM' as Periodo,
	   PacotesEntregues + PacotesNaoEntregue + PacotesPendentes as Pacotes,
	   QuantidadePontos,
	   DataReferencia,
       IdTrevo,
       'Mercado Livre' as Marketplace,
       Tipo,
	   UsuarioDA
--from vw_rotas with(nolock) 
from
	tb_ml_rotas r with(nolock) 
 where
	r.excluido = 0  
	and StatusRota <> 'planned'  
	and isnull(SubStatusRota,'') <> 'cancelled' 

union all 

select Id Idinterno,
       codigorota,	
	   NomeHub,
	   '',
	   Motorista,
	   'AM' as Periodo,
	   TotalPacotes Pacotes,
	   0 QuantidadePontos,
	   DataReferencia,
       '' as IdTrevo,
       'Shopee' as Marketplace,
        TipoOperacao as Tipo,
		UsuarioIrisys UsuarioDA

--from vw_rotas_spe_v4 with(nolock) 
from tb_spe_rotas_v5 with(nolock)
where Excluido = 0  

union all 

select  '' Id,
       CAST(IdRota as varchar(30)) as IdRota,	
	   ServiceCenterOrigem ServiceCenter,
	   ServiceCenterDestino,
	   NomeMotorista,
	   'AM' as Periodo,
	   '' Pacotes,
	   '' QuantidadePontos,
	   DataReferencia,
       '' IdTrevo,
       'Mercado Livre' as Marketplace,
       '' as Tipo,
	   UsuarioDA
--from vw_rotas with(nolock) 
from
	tb_ml_lh_rotas r with(nolock) 
 where
	r.excluido = 0  
	and Status <> 'planned'  
	and isnull(SubStatus,'') <> 'cancelled';
GO
