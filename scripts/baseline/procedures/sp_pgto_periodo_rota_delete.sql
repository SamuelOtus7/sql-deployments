-- ============================================================
-- BASELINE: dbo.sp_pgto_periodo_rota_delete
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[sp_pgto_periodo_rota_delete]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    procedure [dbo].[sp_pgto_periodo_rota_delete]
(
@codespelho int,
@ppr_cd_pagamento_rota int
)
as
-- Deleta os registros de pagamento por periodo de rota de acordo com o codigo do espelho e o codigo do pagamento de rota passados como parâmetro
update tb_pgto_periodo_rota
set ppr_in_excluido = 1 
,ppr_lcto_dh_modificacao = GETDATE()
where  ppr_cd_pgto_espelho = @codespelho
and ppr_cd_pagamento_rota = @ppr_cd_pagamento_rota


IF EXISTS (
    SELECT 1
    FROM tb_pgto_periodo_rota
    WHERE ppr_cd_pgto_espelho = @codespelho
      AND ppr_in_excluido = 0
)
	BEGIN
		update a
		set mtn_vl_nfs = total
		from tb_pag_espelhos a 
		inner join (
		select sum(ppr_vl_total) as total
		,ppr_cd_pgto_espelho
		from tb_pgto_periodo_rota as a
		where  ppr_cd_pgto_espelho = @codespelho 
		and ppr_in_excluido = 0
		group by ppr_cd_pgto_espelho
		) as b
		on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 
	END
ELSE
	BEGIN
		update tb_pag_espelhos
		set mtn_vl_nfs = 0
		where mtn_cd_motorista_nfs = @codespelho
	END

GO
