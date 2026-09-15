-- ============================================================
-- BASELINE: dbo.UspMLExcluiPacoteComRotaExcluida
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLExcluiPacoteComRotaExcluida]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspMLExcluiPacoteComRotaExcluida]
as 
begin

	SET NOCOUNT ON;

	--altera para excluido todos os pacotes das rotas excluidas
	update
		p
	set
		Excluido = 1,
		DataAtualizacao = getdate()
	from
		tb_ml_rotas r
		join tb_ml_pacotes p on r.IdRota = p.IdRota and r.IdTransportadora = p.IdTransportadora and r.DataReferencia = p.DataReferencia
	where
		r.Excluido = 1
		and p.Excluido = 0
		and r.DataReferencia = dateadd(day,-1,cast(getdate() as date))

end
GO
