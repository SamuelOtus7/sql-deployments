-- ============================================================
-- BASELINE: dbo.vw_financeiro_complementar_km_ultimaquinzena
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_complementar_km_ultimaquinzena]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_financeiro_complementar_km_ultimaquinzena]
as

select
	cli_id_logistics as IdTransportadora
	,Ano
	,Mes
	,Quinzena
	,Transportadora
	,Data
	,IdRota
	,IdPacote
	,Reason
	,SubStatus
	,ObsSubStatus
	,Veiculo
	,Ciclo
	,FaixaKmMeli
	,FaixaKmML
	,KMTotalPercorrido
	,PagoNaPrefatura
	,ValorCorretoMLP
	,DiferencaPagoMelixValorMLP
	,NomeQuinzena
	,ServiceCenter
	,XPT
	,LinkEvidencia
from 
	vw_financeiro_complementar_km as a
	inner join tb_clientes as b on a.IdTransportadora = b.cli_cd_codigo_cliente
where
	a.Data >= case when DAY(getdate()) > 15 then dateadd(day,15,DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()) - 1, 0)) else DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()), 0) end
GO
