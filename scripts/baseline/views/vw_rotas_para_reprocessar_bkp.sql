-- ============================================================
-- BASELINE: dbo.vw_rotas_para_reprocessar_bkp
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_para_reprocessar_bkp]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create view [dbo].[vw_rotas_para_reprocessar_bkp]
as
select top 100
	r.IdRota,
	max(r.DataReferencia) as DataReferencia,
	max(r.IdTransportadora) as IdTransportadora
from
	tb_ml_rotas r with(nolock)
	left join (
		select
			IdRota,
			DataReferencia,
			IdTransportadora,
			count(1) Pacotes,
			sum(case when StatusEntrega = 'delivered' then 1 else 0 end) PacotesEntregues,
			sum(case when StatusEntrega = 'pending' then 1 else 0 end) PacotesPendentes,
			sum(case when StatusEntrega = 'not_delivered' and isnull(SubStatus,'') <> 'transferred' then 1 else 0 end) PacotesNaoEntregues
		from
			tb_ml_pacotes with(nolock)
		where
			DataReferencia < cast(getdate() as date)
		group by
			IdRota,
			DataReferencia,
			IdTransportadora
	) p on r.IdRota = p.IdRota and r.DataReferencia = p.DataReferencia and r.IdTransportadora = p.IdTransportadora
where
	r.DataReferencia < cast(getdate() as date)
	and 
		(
			r.TotalPacotes <> isnull(p.Pacotes,0)
			or 
			r.PacotesEntregues <> isnull(p.PacotesEntregues,0)
			or 
			r.PacotesPendentes <> isnull(p.PacotesPendentes,0)
			or 
			r.PacotesNaoEntregue <> isnull(p.PacotesNaoEntregues,0)
			or
			r.TotalPacotes <> r.PacotesEntregues + r.PacotesNaoEntregue
		)
group by r.IdRota
GO
