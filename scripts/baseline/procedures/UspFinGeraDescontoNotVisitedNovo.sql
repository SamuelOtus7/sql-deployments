-- ============================================================
-- BASELINE: dbo.UspFinGeraDescontoNotVisitedNovo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraDescontoNotVisitedNovo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Gustavo Tavares
-- Create date: 02/02/2026
-- Description:	Gera desconto de not visited no espelho do motorista para o novo processo de pagamento sem impactar nos clientes antigos
-- =============================================
CREATE procedure [dbo].[UspFinGeraDescontoNotVisitedNovo] 
(
	@CodPeriodoPagamento int
) 
as 
begin


	--declare @CodPeriodoPagamento int = 2408

	declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
	declare @data_inicial date = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	declare @data_final date = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)


	--Habilitado somente para HAWK
	--Regra: quando tiver um not visited é descontado o valor total da rota do motorista

	--- Parametrizar filtro de cliente
	if @CodigoCliente in (68,66)
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

			,isnull(p.ppr_vl_lancamentos,0) - isnull(d.Total,0) vl_lancamentos_novo

			--Acrescentado todo tipo de adicional mapeado
			,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_dom_fer,0) + isnull(p.ppr_vl_paradas,0) + ISNULL(ppr_vl_bonus_ds, 0) 
				+ ISNULL(ppr_vl_adicional_KM, 0) + isnull(ppr_vl_bonus,0) + isnull(ppr_vl_ajudante,0) + isnull(ppr_vl_risco,0)
				+ isnull(ppr_vl_pedagio,0) + isnull(ppr_vl_aluguel,0) + isnull(ppr_vl_recarga,0) + isnull(ppr_vl_pacotes,0)) * -1 ppr_vl_total

			,(isnull(p.ppr_vl_base,0) + isnull(p.ppr_vl_dom_fer,0) + isnull(p.ppr_vl_paradas,0) + ISNULL(ppr_vl_bonus_ds, 0) 
				+ ISNULL(ppr_vl_adicional_KM, 0) + isnull(ppr_vl_bonus,0) + isnull(ppr_vl_ajudante,0) + isnull(ppr_vl_risco,0)
				+ isnull(ppr_vl_pedagio,0) + isnull(ppr_vl_aluguel,0)+ isnull(ppr_vl_recarga,0) + isnull(ppr_vl_pacotes,0)) * -1 ppr_vl_desconto
			into #desconto_notvisit
		from 
			tb_fin_prefatura_descontos d
			join tb_pgto_periodo_rota p on cast(d.IdRota as varchar) = p.ppr_cd_rota and ppr_cd_periodo = @CodPeriodoPagamento
			join vw_lancamentos_manuais_aprovados as b on cast(d.IdRota as varchar) = cast(b.tlm_cd_rota as varchar) and b.plm_nm_tipo = 'PF - Endereço não visitado'
		where
			d.descricao like '%Vehicle Daily Not Visited%'
			and cast(cast(d.Ano as varchar(4)) + '-' + cast(d.Mes as varchar(2)) + '-' + case when d.Quinzena = 1 then '01' else '16' end as date) between @data_inicial and @data_final  



		update
			p
		set
			ppr_vl_desconto = isnull(d.ppr_vl_desconto,p.ppr_vl_desconto)
			,ppr_vl_total = isnull(p.ppr_vl_total,0) + isnull(d.ppr_vl_desconto,0)
			,ppr_lcto_observacao = isnull(d.ppr_lcto_observacao,p.ppr_lcto_observacao)
			,ppr_vl_lancamentos = isnull(vl_lancamentos_novo,ppr_vl_lancamentos)
		from
			tb_pgto_periodo_rota p
			inner join tb_pag_espelhos as e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			left join #desconto_notvisit d on p.ppr_cd_rota = d.ppr_cd_rota
		where
			p.ppr_cd_periodo = @CodPeriodoPagamento
			and e.mtn_cd_status IN (34,228,38)    

	end

end
		



		
GO
