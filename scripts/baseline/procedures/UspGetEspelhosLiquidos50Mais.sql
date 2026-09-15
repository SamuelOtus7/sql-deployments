-- ============================================================
-- BASELINE: dbo.UspGetEspelhosLiquidos50Mais
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetEspelhosLiquidos50Mais]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetEspelhosLiquidos50Mais]
(
	@CodEspelho int 
)

as

drop table if exists #base
select
	*
	into #base
from
	(
		select
			per.pgp_nm_periodo Periodo
			,pgt.ppr_base_principal ServiceCenter
			,pgt.ppr_nome_motorista NomeMotorista
			,pgt.ppr_data_referencia Data
			,pgt.ppr_cd_rota Rota
			,pgt.ppr_tipo_rota Tipo
			,pgt.ppr_cd_faixa_km FaixaKm
			,pgt.ppr_nm_cidade Cidade
			,pgt.ppr_ds_ciclo Ciclo
			,pgt.ppr_qt_paradas Paradas
			,isnull(pgt.ppr_vl_base,0) ValorRota
			,isnull(pgt.ppr_vl_paradas,0) + isnull(pgt.ppr_vl_ajudante,0) + isnull(pgt.ppr_vl_risco,0) + isnull( pgt.ppr_vl_dom_fer,0) + isnull(pgt.ppr_vl_bonus,0) + isnull(pgt.ppr_vl_recarga,0) Adicional
			,isnull(pgt.ppr_vl_lancamentos,0) ValorManuais
			,isnull(pgt.ppr_vl_desconto,0) Descontos
			,isnull(pgt.ppr_vl_base,0) + isnull(pgt.ppr_vl_paradas,0) + isnull(pgt.ppr_vl_ajudante,0) + isnull(pgt.ppr_vl_risco,0) + isnull( pgt.ppr_vl_dom_fer,0) + isnull(pgt.ppr_vl_bonus,0) + isnull(pgt.ppr_vl_recarga,0) + isnull(pgt.ppr_vl_lancamentos,0) + isnull(pgt.ppr_vl_desconto,0) Total
		from
			tb_pgto_periodo_rota pgt with(nolock)
			join tb_pgto_periodo per with(nolock) on pgt.ppr_cd_periodo = per.pgp_cd_periodo
		where
			pgt.ppr_cd_periodo = @CodEspelho

		union all

		select
			'Janeiro 02Q2025' Periodo
			,lan.tlm_cd_service_center ServiceCenter
			,lan.tlm_cd_motorista Motorista
			,cast(lan.tlm_dh_referencia as date) Data
			,tlm_cd_rota Rota
			,'Adiantamento' Tipo
			,null FaixaKm
			,null Cidade
			,null Ciclo
			,null Paradas
			,null ValorRota
			,null Adicional
			,null ValorManuais
			,lan.tlm_vl_valor_descontos * -1 Desconto
			,lan.tlm_vl_valor_descontos * -1 Total
		from 
			tb_lancamentos_manuais lan with(nolock)
			join tb_aprovacao_lancamento_manual apr with(nolock) on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
		where 
			lan.tlm_cd_cliente = 11
			and lan.tlm_cd_tipo = 233
			and apr.alm_ds_status = 'Aprovado'
	) t
order by
	NomeMotorista, Data
	

drop table if exists #motoristas
select distinct NomeMotorista into #motoristas from #base order by 1

drop table if exists #relatorio
select *, 0 Ordem into #relatorio from #base where 1=0

while exists (select 1 from #motoristas)
begin
	declare @Motorista varchar(100) = (select top 1 NomeMotorista from #motoristas order by 1)
	declare @SVC varchar(100) = (select top 1 ServiceCenter from #base where NomeMotorista = @Motorista)

	insert into #relatorio
	select *, 1 Ordem from #base where isnull(Tipo,'') <> 'Adiantamento' and NomeMotorista = @Motorista order by Data

	declare @TotalBruto decimal(18,2) = (select sum(Total) from #base where isnull(Tipo,'') <> 'Adiantamento' and NomeMotorista = @Motorista)
	insert into #relatorio values ('Janeiro 02Q2025', @SVC, @Motorista, null, null, 'Total Bruto', null, null, null, null, null, null, null, null, @TotalBruto, 2)

	insert into #relatorio
	select *, 3 Ordem from #base where isnull(Tipo,'') = 'Adiantamento' and NomeMotorista = @Motorista order by Data

	declare @TotalAdiantamento decimal(18,2) = (select sum(Total) from #base where isnull(Tipo,'') = 'Adiantamento' and NomeMotorista = @Motorista)
	if isnull(@TotalAdiantamento,0) <> 0
		insert into #relatorio values ('Janeiro 02Q2025', @SVC, @Motorista, null, null, 'Total Adiantamento', null, null, null, null, null, null, null, null, @TotalAdiantamento, 4)

	insert into #relatorio values ('Janeiro 02Q2025', @SVC, @Motorista, null, null, 'Total Liquido', null, null, null, null, null, null, null, null, isnull(@TotalBruto,0)+isnull(@TotalAdiantamento,0), 5)

	delete #motoristas where NomeMotorista = @Motorista
end

select * from #relatorio order by NomeMotorista, Ordem, Data	

GO
