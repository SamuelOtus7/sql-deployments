-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaIndicadoresRota
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaIndicadoresRota]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEAtualizaIndicadoresRota] (
	@QtdeDiasRetroativo int = 1
)
as
begin

	SET NOCOUNT ON;

	update
		r
	set
		r.TotalPacotes = isnull(p.TotalPacotes,0),
		r.PacotesEntregues = isnull(p.PacotesEntregues,0),
		r.PacotesNaoEntregue = p.PacotesNaoEntregue,
		r.PacotesPendentes = p.PacotesPendentes,
		r.DataUltimaEntrega = p.DataUltimaEntrega
	from
		tb_spe_rotas r
		left join (
			select
				p.IdTransportadora,
				p.DataReferencia,
				p.IdMotorista,
				count(1) TotalPacotes,
				sum(case when p.StatusEntrega = 'Delivered' then 1 else 0 end) PacotesEntregues,
				sum(case when p.StatusEntrega = 'OnHold' then 1 else 0 end) PacotesNaoEntregue,
				sum(case when p.StatusEntrega = 'Delivering' then 1 else 0 end) PacotesPendentes,
				max(case when p.StatusEntrega = 'Delivered' then p.DataHoraEntrega end) DataUltimaEntrega
			from
				tb_spe_pacotes p with(nolock)
			where
				p.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
			group by
				p.IdTransportadora,
				p.DataReferencia,
				p.IdMotorista
		) p on r.IdTransportadora = p.IdTransportadora and r.DataReferencia = p.DataReferencia and r.IdMotorista = p.IdMotorista
	where
		r.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))


	update
		r
	set
		r.TotalPacotes = isnull(p.TotalPacotes,0),
		r.PacotesEntregues = isnull(p.PacotesEntregues,0),
		r.PacotesNaoEntregue = p.PacotesNaoEntregue,
		r.PacotesPendentes = p.PacotesPendentes,
		r.DataUltimaEntrega = p.DataUltimaEntrega
	from
		tb_spe_rotas_novo r
		left join (
			select
				p.IdTransportadora,
				p.DataReferencia,
				p.CodigoRota,
				count(1) TotalPacotes,
				sum(case when p.StatusEntrega = 'Delivered' then 1 else 0 end) PacotesEntregues,
				sum(case when p.StatusEntrega = 'On Hold' then 1 else 0 end) PacotesNaoEntregue,
				sum(case when p.StatusEntrega = 'Assigned' then 1 else 0 end) PacotesPendentes,
				max(case when p.StatusEntrega = 'Delivered' then p.DataHoraEntrega end) DataUltimaEntrega
			from
				tb_spe_pacotes_novo p with(nolock)
			where
				p.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
			group by
				p.IdTransportadora,
				p.DataReferencia,
				p.CodigoRota
		) p on r.IdTransportadora = p.IdTransportadora and r.DataReferencia = p.DataReferencia and r.CodigoRota = p.CodigoRota
	where
		r.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))


	


end
GO
