-- ============================================================
-- BASELINE: dbo.UspFinConsolidaEspelhoMeliLM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinConsolidaEspelhoMeliLM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 23/03/2026
-- Description:	Consolida valores na tb_pag_espelhos
-- =============================================
CREATE PROCEDURE [dbo].[UspFinConsolidaEspelhoMeliLM] (
	@CodPeriodoPagamento int
	,@IdRota int = null
	,@CodEspelho int = null
	,@CodUsuario int = null
)
AS
BEGIN
	
	SET NOCOUNT ON;


	--declare @CodPeriodoPagamento int = 2616
	--declare @IdRota int = null
	--declare @CodEspelho int = null -- codigo espelho,
	--declare @CodUsuario int = null

	
	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @DataLimiteReanalise date = (select pgp_dt_limite_reanalise from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1 and cast(getdate() as date) <= isnull(@DataLimiteReanalise,cast(getdate() as date))
	begin


		------------------------------------------------------------
		-- INFORMAÇÕES SOBRE O PERÍODO QUE ESTÁ SENDO PROCESSADO
		------------------------------------------------------------
		declare @Operacao int
		declare @IdCliTransportadora int
		
		select
			@Operacao = pgp_tipo_operacao
			,@IdCliTransportadora = pgp_cd_cliente_transportadora
		from
			tb_pgto_periodo with(nolock)
		where
			pgp_cd_periodo = @CodPeriodoPagamento
		

		------------------------------------------------------------
		-- ATUALIZA VALOR TOTAL
		------------------------------------------------------------
		 update  
			p
         set 
			ppr_vl_total = isnull(ppr_vl_base,0)  
							+ isnull(ppr_vl_paradas,0)  
							+ isnull(ppr_vl_pontos,0)  
							+ isnull(ppr_vl_risco,0)  
							+ isnull(ppr_vl_ajudante,0)  
							+ isnull(ppr_vl_dom_fer,0)  
							+ isnull(ppr_vl_lancamentos,0)  
							+ isnull(ppr_vl_pedagio,0)  
							+ isnull(ppr_vl_aluguel,0)  
							+ isnull(ppr_vl_desconto,0)  
							+ isnull(ppr_vl_recarga,0)  
							+ isnull(ppr_vl_pacotes,0)  
							+ isnull(ppr_vl_bonus,0) 
							+ isnull(ppr_vl_adicional_KM, 0)
							+ isnull(ppr_vl_bonus_ds, 0)
        from
			tb_pgto_periodo_rota p
			join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
										and e.mtn_cd_operacao = @Operacao
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and p.ppr_in_excluido = 0
			and e.mtn_cd_status in (34,228,38,1298)
			and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


		------------------------------------------------------------
		-- ATUALIZA VALOR TOTAL DO ESPELHO
		------------------------------------------------------------
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
						and (ppr_cd_pgto_espelho = @CodEspelho or @CodEspelho is null)
						and ppr_in_excluido = 0
					group by 
						ppr_cd_pgto_espelho
			) as p on e.mtn_cd_motorista_nfs = p.ppr_cd_pgto_espelho 
		where
			e.mtn_in_excluido = 0
			and e.mtn_cd_status in (34,228,38,1298)
			and e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
			and (e.mtn_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


		------------------------------------------------------------
		-- EXCLUI ESPELHOS QUE NÃO CONTÉM REGISTRO ATIVO NA TB_PGTO_PERIODO_ROTA
		------------------------------------------------------------
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
			and (e.mtn_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


	end --fim do if que verifica se o período pode sofrer alterações

end --fim procedure
GO
