-- ============================================================
-- BASELINE: dbo.UspFinGeraDescontoNotVisited
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraDescontoNotVisited]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 21/03/2025
-- Description:	Gera desconto de not visited no espelho do motorista
-- =============================================
CREATE procedure [dbo].[UspFinGeraDescontoNotVisited] 
(
	@CodPeriodoPagamento int
) 
as 
begin


	declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @data_inicial date = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	declare @data_final date = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)


	--Habilitado somente para 50+. 
	--Regra: quando tiver um not visited é descontado o valor total da rota do motorista
	if @CodigoCliente = 11
	begin
		drop table if exists #desconto_notvisit
		select 
			@CodPeriodoPagamento as ppr_cd_periodo
			,d.DataReferencia as ppr_data_referencia
			,cast(d.IdRota as varchar(50)) as ppr_cd_rota
			,p.ppr_nome_motorista
			,p.ppr_cd_motorista
			,p.ppr_base_principal
			,'Rota: ' + cast(d.IdRota as varchar) + ' - ' + Descricao as ppr_lcto_observacao
			--,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_paradas,0) + isnull(p.ppr_vl_risco,0) + isnull(p.ppr_vl_dom_fer,0) + isnull(p.ppr_vl_bonus,0)) * -1 ppr_vl_total
			--,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_paradas,0) + isnull(p.ppr_vl_risco,0) + isnull(p.ppr_vl_dom_fer,0) + isnull(p.ppr_vl_bonus,0)) * -1 ppr_vl_desconto
			,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_dom_fer,0)) * -1 ppr_vl_total
			,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_dom_fer,0)) * -1 ppr_vl_desconto
			into #desconto_notvisit
		from 
			tb_fin_prefatura_descontos d
			join tb_pgto_periodo_rota p on cast(d.IdRota as varchar) = p.ppr_cd_rota and ppr_cd_periodo = @CodPeriodoPagamento
		where
			d.descricao like '%Vehicle Daily Not Visited%'
			and cast(cast(d.Ano as varchar(4)) + '-' + cast(d.Mes as varchar(2)) + '-' + case when d.Quinzena = 1 then '01' else '16' end as date) between @data_inicial and @data_final  

		--select 
		--	@CodPeriodoPagamento as ppr_cd_periodo
		--	,d.DataReferencia as ppr_data_referencia
		--	,cast(d.IdRota as varchar(50)) as ppr_cd_rota
		--	,p.ppr_nome_motorista
		--	,p.ppr_cd_motorista
		--	,p.ppr_base_principal
		--	,'Rota: ' + cast(d.IdRota as varchar) + ' - ' + Descricao as ppr_lcto_observacao
		--	--,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_paradas,0) + isnull(p.ppr_vl_risco,0) + isnull(p.ppr_vl_dom_fer,0) + isnull(p.ppr_vl_bonus,0)) * -1 ppr_vl_total
		--	--,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_paradas,0) + isnull(p.ppr_vl_risco,0) + isnull(p.ppr_vl_dom_fer,0) + isnull(p.ppr_vl_bonus,0)) * -1 ppr_vl_desconto
		--	,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_dom_fer,0)) * -1 ppr_vl_total
		--	,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_dom_fer,0)) * -1 ppr_vl_desconto
		--	into #desconto_notvisit
		--from 
		--	tb_fin_prefatura_descontos_not_visited d
		--	join tb_pgto_periodo_rota p on cast(d.IdRota as varchar) = p.ppr_cd_rota and ppr_cd_periodo = @CodPeriodoPagamento
		--where
		--	cast(cast(d.Ano as varchar(4)) + '-' + cast(d.Mes as varchar(2)) + '-' + case when d.Quinzena = 1 then '01' else '16' end as date) between @data_inicial and @data_final  

	
		--delete tb_pgto_periodo_rota where ppr_cd_periodo = @CodPeriodoPagamento and ppr_cd_rota = 'Not Visited'

		--insert into tb_pgto_periodo_rota (ppr_data_referencia, ppr_cd_periodo, ppr_cd_rota, ppr_nome_motorista, ppr_cd_motorista, ppr_base_principal, ppr_lcto_observacao, ppr_vl_total, ppr_vl_desconto, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido, ppr_cd_motorista_nfs, ppr_cd_pgto_espelho)
		--select 
		--	 ppr_data_referencia
		--	,@CodPeriodoPagamento ppr_cd_periodo
		--	,ppr_cd_rota
		--	,ppr_nome_motorista
		--	,ppr_cd_motorista
		--	,ppr_base_principal
		--	,ppr_lcto_observacao
		--	,ppr_vl_total
		--	,ppr_vl_desconto
		--	,getdate() as ppr_dh_criacao
		--	,8851 as ppr_cd_usr_criacao
		--	,getdate() ppr_dh_modificacao
		--	,8851 as ppr_cd_usr_modificacao
		--	,1 as ppr_in_ativo
		--	,0 as ppr_in_excluido
		--	,mtn_cd_motorista_nfs as ppr_cd_motorista_nfs 
		--	,mtn_cd_motorista_nfs as ppr_cd_pgto_espelho
		--from 
		--	#desconto_notvisit as a 
		--	left join tb_pag_espelhos as b on mtn_cd_motorista = ppr_cd_motorista and ppr_cd_periodo = mtn_cd_pgto_periodo

		update
			p
		set
			ppr_vl_desconto = isnull(d.ppr_vl_desconto,0)
			,ppr_vl_total = isnull(p.ppr_vl_total,0) + isnull(d.ppr_vl_desconto,0)
			,ppr_lcto_observacao = d.ppr_lcto_observacao
		from
			tb_pgto_periodo_rota p
			join #desconto_notvisit d on p.ppr_cd_rota = d.ppr_cd_rota
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento


	end

end
		
GO
