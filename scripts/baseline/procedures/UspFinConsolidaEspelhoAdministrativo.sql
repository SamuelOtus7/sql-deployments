-- ============================================================
-- BASELINE: dbo.UspFinConsolidaEspelhoAdministrativo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinConsolidaEspelhoAdministrativo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinConsolidaEspelhoAdministrativo]    (
    @CodPeriodoPagamento int,
	@avulso int = null -- codigo espelho,
)
as
begin

	set nocount on

	set @avulso = case when @avulso = 0 then null else @avulso end
	
	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1
	begin
		

		--atualiza valores
		update 
			e
		set 
			mtn_vl_nfs = isnull(total,0)
		from 
			tb_pag_espelhos e 
			left join (
					select 
						sum(ppr_vl_total) as total
						,ppr_cd_pgto_espelho
					from 
						tb_pgto_periodo_rota as a
					where  
						ppr_cd_periodo = @CodPeriodoPagamento 
						and (ppr_cd_pgto_espelho = @avulso or @avulso is null)
						and ppr_in_excluido = 0
					group by 
						ppr_cd_pgto_espelho
			) as p on e.mtn_cd_motorista_nfs = p.ppr_cd_pgto_espelho 
		where
			e.mtn_in_excluido = 0
			and e.mtn_cd_status in (34,228,38)
			and e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
			and (e.mtn_cd_motorista_nfs = @avulso or @avulso is null)


		--remove espelhos (que não são avulsos) que não possui nenhum lançamento na tb_pgto_periodo_rota
		update
			e
		set
			mtn_in_excluido = 1
		from
			tb_pag_espelhos e
			left join tb_pgto_periodo_rota p on e.mtn_cd_motorista_nfs = p.ppr_cd_motorista_nfs 
													and p.ppr_in_excluido = 0
		where
			e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
			and e.mtn_cd_status in (34,228,38,1298)
			and e.mtn_in_excluido = 0
			and e.mtn_cd_tipo_espelho <> 95 --Não considera espelho avulso
			and p.ppr_cd_pagamento_rota is null
			and (e.mtn_cd_motorista_nfs = @avulso or @avulso is null)

	end


END
GO
