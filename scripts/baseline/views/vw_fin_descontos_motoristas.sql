-- ============================================================
-- BASELINE: dbo.vw_fin_descontos_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_descontos_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_fin_descontos_motoristas]
as

select 
	motoristas.IdTransportadora
	,cli_cd_codigo_cliente as TenantID
	,motoristas.Ano
	,motoristas.Mes
	,motoristas.Quinzena
	,try_cast(motoristas.IdRota as int) as Idrota
	,motoristas.DataReferencia
	,motoristas.ServiceCenter
	,motoristas.Motorista
	,motoristas.TipoVeiculo
	,Ciclo
	,Desconto
	,Motivo
	,IdPacote
	,isnull(FIN.id,0) as IDFINANCEIRO
	,FIN.DataAtualizacao

from 
	tb_fin_descontos_motoristas motoristas with(nolock)

	inner JOIN tb_fin_resultado_financeiro FIN ON try_cast(FIN.IdRota as int) = motoristas.IdRota 
	--AND FIN.IdTransportadora = motoristas.idtransportadora

	inner join tb_clientes as cli
	on motoristas.IdTransportadora = cli_id_logistics

	where  	motoristas.DataReferencia >= '2024-10-01'
	--and FIN.Mes = motoristas.Mes
	--and FIN.Ano = motoristas.Ano
	--and FIN.Quinzena = motoristas.Quinzena
	








GO
