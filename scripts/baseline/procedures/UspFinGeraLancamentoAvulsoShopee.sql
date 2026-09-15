-- ============================================================
-- BASELINE: dbo.UspFinGeraLancamentoAvulsoShopee
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraLancamentoAvulsoShopee]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 19/06/2026
-- Description:	Gera lançamento avulso conforme regras criadas
-- =============================================
create PROCEDURE [dbo].[UspFinGeraLancamentoAvulsoShopee]  (
	@CodPeriodoPagamento int
)
AS
BEGIN
	
	SET NOCOUNT ON;


	--declare @CodPeriodoPagamento int = 2616
	

	------------------------------------------------------------
	-- INFORMAÇÕES SOBRE O PERÍODO QUE ESTÁ SENDO PROCESSADO
	------------------------------------------------------------
	declare @CodigoCliente int
	declare @DataInicial date
		
	select
		@CodigoCliente = pgp_cd_cliente
		,@DataInicial = pgp_dt_inicio
	from
		tb_pgto_periodo with(nolock)
	where
		pgp_cd_periodo = @CodPeriodoPagamento

	declare @Operacao int = (select 
								lst_cd_lista 
							from    
								tb_lista as a with(nolock)
								join [tb_pgto_periodo] as b with(nolock) on a.lst_cd_cliente = b.pgp_cd_cliente
																		and a.lst_cd_lista = b.pgp_tipo_operacao
							where   
								lst_nm_lista = 'Operações Marketplace'
								and pgp_cd_periodo = @CodPeriodoPagamento  
							)


	declare @IdCliTransportadora int = (select 
											lst_cd_lista 
										from 
											tb_lista (NOLOCK)
										where 
											lst_nm_lista = 'Clientes transportadoras'
											and lst_ds_label = 'Shopee'
											and lst_cd_cliente = @CodigoCliente
										)

		
	declare @CodigoRegra int 
	declare @TipoContrato int
	declare @ServiceCenter varchar(50)
	declare @TipoVeiculo int
	declare @NomeCriterio1 varchar(30)
	declare @ValorCriterio1 varchar(60)
	declare @NomeCriterio2 varchar(30)
	declare @ValorCriterio2 varchar(60)
	declare @NomeCriterio3 varchar(30)
	declare @ValorCriterio3 varchar(60)
	declare @DescricaoLancamento varchar(150)
	declare @ValorLancamento decimal(7,2)

	drop table if exists #espelhos_lancamentos
	create table #espelhos_lancamentos
	(
		mtn_cd_motorista_nfs int not null
	)

	drop table if exists #pgto_avulsos_regras
	create table #pgto_avulsos_regras
	(
		ppr_cd_periodo int
		,ppr_cd_motorista_nfs int
		,ppr_cd_pgto_espelho int
		,ppr_cd_motorista int
		,ppr_nome_motorista varchar(100)
		,ppr_data_referencia date
		,ppr_base_principal varchar(100)
		,ppr_vl_base decimal(7,2)
		,ppr_vl_total decimal(7,2)
		,ppr_lcto_observacao varchar(100)
		,ppr_dh_criacao datetime
		,ppr_cd_usr_criacao int
		,ppr_dh_modificacao datetime
		,ppr_cd_usr_modificacao int
		,ppr_in_ativo bit
		,ppr_in_excluido bit
		,ppr_cd_tipo_pgto int
	)


	------------------------------------------------------------
	-- REGRA LANÇAMENTO AVULSO: Desconto quinzenal
	------------------------------------------------------------
	drop table if exists #regras_desconto_quinzenal
	select
		*
		into #regras_desconto_quinzenal
	from 
		tb_fin_regras_lancamentos_avulso 
	where 
		rla_cd_transportadora = @CodigoCliente 
		and rla_cd_codigo_cliente = @IdCliTransportadora 
		and rla_cd_operacao = @Operacao 
		and rla_nm_regra = 'Desconto quinzenal' 
		and rla_int_ativo = 1
		and @DataInicial between rla_data_inicio_vigencia and isnull(rla_data_fim_vigencia,cast(getdate() as date))


	while exists (select 1 from #regras_desconto_quinzenal)
	begin
			
		select
			top 1
			@CodigoRegra = rla_cd_regras_lancamentos_avulso 
			,@TipoContrato = rla_cd_tipo_contrato
			,@ServiceCenter = rla_cd_service_center
			,@TipoVeiculo = rla_cd_tipo_veiculo
			,@NomeCriterio1 = rla_nm_criterio01
			,@ValorCriterio1 = rla_vl_criterio01
			,@NomeCriterio2 = rla_nm_criterio02
			,@ValorCriterio2 = rla_vl_criterio02
			,@NomeCriterio3 = rla_nm_criterio03
			,@ValorCriterio3 = rla_vl_criterio03
			,@DescricaoLancamento = rla_ds_lancamento
			,@ValorLancamento = rla_vl_lancamento
		from
			#regras_desconto_quinzenal

			
		if @NomeCriterio1 = 'Minimo Total Espelho' and @NomeCriterio2 = 'Mínimo Quantidade Rotas' and @NomeCriterio3 is null
		begin
			insert into #espelhos_lancamentos
			select
				e.mtn_cd_motorista_nfs
			from
				tb_pgto_periodo_rota r with(nolock)
				join tb_pag_espelhos e on r.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
													and e.mtn_in_excluido = 0
													and e.mtn_cd_status IN (34, 228, 38, 1298) --só considera espelhos abertos
				join tb_dra_tipo_veiculo v with(nolock) on r.ppr_ds_tipo_veiculo = v.tvl_nm_tipo_veiculo
			where
				ppr_cd_periodo = @CodPeriodoPagamento
				and ppr_in_excluido = 0
				and ppr_cd_tipo_pgto = 1362
				and (e.mtn_cd_tipo_contrato = @TipoContrato or @TipoContrato is null)
				and (r.ppr_base_principal = @ServiceCenter or @ServiceCenter is null)
				and (v.tvl_cd_tipo_veiculo = @TipoVeiculo or @TipoVeiculo is null)
			group by
				e.mtn_cd_motorista_nfs
			having
				sum(ppr_vl_total - isnull(ppr_vl_lancamentos,0)) > @ValorCriterio1
				and count(1) >= @ValorCriterio2
		end


		insert into #pgto_avulsos_regras
		select
			e.mtn_cd_pgto_periodo ppr_cd_periodo
			,e.mtn_cd_motorista_nfs ppr_cd_motorista_nfs
			,e.mtn_cd_motorista_nfs ppr_cd_pgto_espelho
			,e.mtn_cd_motorista ppr_cd_motorista
			,e.mtn_nome_motorista ppr_nome_motorista
			,@DataInicial ppr_data_referencia
			,e.mtn_base_principal ppr_base_principal
			,@ValorLancamento ppr_vl_base
			,@ValorLancamento ppr_vl_total
			,@DescricaoLancamento ppr_lcto_observacao
			,getdate() ppr_dh_criacao
			,7 ppr_cd_usr_criacao
			,getdate() ppr_dh_modificacao
			,7 ppr_cd_usr_modificacao
			,1 ppr_in_ativo
			,0 ppr_in_excluido
			,1364 ppr_cd_tipo_pgto 
		from
			tb_pag_espelhos e
			join #espelhos_lancamentos e2 on e.mtn_cd_motorista_nfs = e2.mtn_cd_motorista_nfs

			
		insert into tb_pgto_periodo_rota (ppr_cd_periodo, ppr_cd_motorista_nfs, ppr_cd_pgto_espelho, ppr_cd_motorista, ppr_nome_motorista, ppr_data_referencia, ppr_base_principal, ppr_vl_base, ppr_vl_total, ppr_lcto_observacao, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido, ppr_cd_tipo_pgto)
		select 
			a.ppr_cd_periodo
			,a.ppr_cd_motorista_nfs
			,a.ppr_cd_pgto_espelho
			,a.ppr_cd_motorista
			,a.ppr_nome_motorista
			,a.ppr_data_referencia
			,a.ppr_base_principal
			,a.ppr_vl_base
			,a.ppr_vl_total
			,a.ppr_lcto_observacao
			,a.ppr_dh_criacao
			,a.ppr_cd_usr_criacao
			,a.ppr_dh_modificacao
			,a.ppr_cd_usr_modificacao
			,a.ppr_in_ativo
			,a.ppr_in_excluido 
			,a.ppr_cd_tipo_pgto
		from 
			#pgto_avulsos_regras a
			left join tb_pgto_periodo_rota p with(nolock) on a.ppr_cd_motorista_nfs = p.ppr_cd_motorista_nfs
															and a.ppr_lcto_observacao = p.ppr_lcto_observacao
															and a.ppr_cd_tipo_pgto = p.ppr_cd_tipo_pgto
															and p.ppr_cd_periodo = @CodPeriodoPagamento
		where
			p.ppr_cd_pagamento_rota is null


		delete #regras_desconto_quinzenal where rla_cd_regras_lancamentos_avulso = @CodigoRegra

	end --fim regra lançamento avulso: desconto quinzenal

	
end
GO
