-- ============================================================
-- BASELINE: dbo.UspFinExcluiEspelhoSemLancamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinExcluiEspelhoSemLancamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[UspFinExcluiEspelhoSemLancamento]   (
	@CodPeriodoPagamento int
)
as
begin

	update a
	set 
		mtn_in_excluido = 1
		,mtn_vl_nfs = 0

	from tb_pag_espelhos as a

	left join tb_pgto_periodo_rota as b
	on a.mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs

	where 1=1 
	and  ppr_cd_periodo is null
	and mtn_cd_pgto_periodo in (@CodPeriodoPagamento)

end 
GO
