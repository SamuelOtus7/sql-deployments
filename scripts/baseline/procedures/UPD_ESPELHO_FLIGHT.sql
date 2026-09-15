-- ============================================================
-- BASELINE: dbo.UPD_ESPELHO_FLIGHT
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UPD_ESPELHO_FLIGHT]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE PROCEDURE [dbo].[UPD_ESPELHO_FLIGHT]
(
    @CodPeriodoPagamento INT,
    @avulso INT
)
AS
BEGIN
    SET NOCOUNT ON;

	if @avulso is not null
	begin
		UPDATE a
		SET 
			mtn_vl_nfs = b.ppr_vl_total,
			mtn_nome_motorista = b.ppr_nome_motorista,
			mtn_cd_motorista = b.ppr_cd_motorista
		FROM tb_pag_espelhos AS a WITH (NOLOCK)
		INNER JOIN (
			SELECT
				ppr_cd_pgto_espelho,
				ppr_nome_motorista,
				ppr_cd_motorista,
				SUM(ppr_vl_total) AS ppr_vl_total
			FROM tb_pgto_periodo_rota WITH (NOLOCK)
			WHERE ppr_cd_pgto_espelho = @avulso
			  AND ppr_cd_periodo = @CodPeriodoPagamento
			  and ppr_in_excluido = 0
			GROUP BY ppr_cd_pgto_espelho, ppr_nome_motorista, ppr_cd_motorista
		) AS b
		ON a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho;
	end
	else
	begin
		UPDATE 
			a
		SET 
			mtn_vl_nfs = b.ppr_vl_total
		FROM 
			tb_pag_espelhos AS a WITH (NOLOCK)
			JOIN (
				SELECT
					ppr_cd_motorista_nfs,
					SUM(ppr_vl_total) AS ppr_vl_total
				FROM	
					tb_pgto_periodo_rota WITH (NOLOCK)
				WHERE 
					ppr_cd_periodo = @CodPeriodoPagamento
					and ppr_in_excluido = 0
				GROUP BY 
					ppr_cd_motorista_nfs
			) AS b ON a.mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs
		where
			a.mtn_cd_pgto_periodo = @CodPeriodoPagamento
	end

END
GO
