-- ============================================================
-- BASELINE: dbo.vw_DiferencasPacotes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_DiferencasPacotes]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[vw_DiferencasPacotes]

as

select 
	rotas.IdTransportadora,
	rotas.idrota, 
	rotas.Pacotes as QtdeRota, 
	pacotes.qtde as QtdePacotes,
	rotas.Pacotes - pacotes.qtde as Delta
from 
	(
	select 
		IdTransportadora,
		IdRota,
		DataReferencia,
		TotalPacotes as Pacotes
	from 
		tb_ml_rotas with(nolock)
	where 
		Excluido = 0
		and TotalPacotes > 0
		and DataReferencia >= dateadd(day,-5,cast(getdate() as date)) and DataReferencia < cast(getdate() as date)
	) as rotas
	join 
	(
	select 
		IdTransportadora,
		IdRota,
		DataReferencia,
		count(*) as qtde
	from 
		tb_ml_pacotes  with(nolock)
	where 
		DataReferencia >= dateadd(day,-5,cast(getdate() as date)) and DataReferencia < cast(getdate() as date)
		and isnull(SubStatus,'') not in ('transferred','transferido')
		and Excluido = 0
	group by 
		IdTransportadora,
		IdRota,
		DataReferencia
	) as pacotes on rotas.IdRota = pacotes.IdRota and rotas.DataReferencia = pacotes.DataReferencia and rotas.IdTransportadora = pacotes.IdTransportadora
	left join tb_rotas_para_reprocessar reprocessar on rotas.IdRota = reprocessar.IdRota and rotas.DataReferencia = reprocessar.DataReferencia and rotas.IdTransportadora = reprocessar.IdTransportadora
where 
	rotas.Pacotes - pacotes.qtde <> 0
	and reprocessar.IdRota is null

GO
