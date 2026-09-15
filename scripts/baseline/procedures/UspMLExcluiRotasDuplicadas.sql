-- ============================================================
-- BASELINE: dbo.UspMLExcluiRotasDuplicadas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLExcluiRotasDuplicadas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLExcluiRotasDuplicadas]

as

begin
	
	--Exclui rotas duplicadas mantendo apenas a data mais recente
	drop table if exists #rotas_exclusao
	select
		r.IdRota,
		r.IdTransportadora,
		r.DataReferencia
		into #rotas_exclusao
	from
		tb_ml_rotas r
		join (
			select
				IdRota,
				IdTransportadora
			from
				tb_ml_rotas
			where
				Excluido = 0
			group by
				IdRota,
				IdTransportadora
			having
				count(1) > 1
		) r2 on r.IdRota = r2.IdRota and r.IdTransportadora = r2.IdTransportadora
	where
		r.Excluido = 0
		and r.DataReferencia < (
			select
				max(DataReferencia)
			from
				tb_ml_rotas r3
			where
				r3.Excluido = 0
				and r.IdRota = r3.IdRota
				and r.IdTransportadora = r3.IdTransportadora
		)
		

	update
		r
	set
		Excluido = 1
	from
		tb_ml_rotas r
		join #rotas_exclusao e on r.IdRota = e.IdRota
								and r.DataReferencia = e.DataReferencia
								and r.IdTransportadora = e.IdTransportadora

	update
		p
	set
		Excluido = 1
	from
		tb_ml_pacotes p
		join #rotas_exclusao e on p.IdRota = e.IdRota
								and p.DataReferencia = e.DataReferencia
								and p.IdTransportadora = e.IdTransportadora
		
		


end
GO
