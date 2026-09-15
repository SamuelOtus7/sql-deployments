-- ============================================================
-- BASELINE: dbo.UspFinGeraTestesFinanceiroClientes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraTestesFinanceiroClientes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinGeraTestesFinanceiroClientes]  (
	@MarktplaceTeste varchar(100)
	,@Operacao varchar(100)
	,@DataInicioPeriodoTeste date
	,@FaseTeste varchar(100)
	,@ProcessoPagamento varchar(100)
)
as
begin


	drop table if exists #periodos
	select
		pgp_cd_cliente
		,pgp_cd_cliente_transportadora
		,min(pgp_cd_periodo) pgp_cd_periodo
		--,pgp_cd_periodo pgp_cd_periodo
		into #periodos
	from
		tb_pgto_periodo p
		join tb_lista l on p.pgp_cd_cliente_transportadora = l.lst_cd_lista
		join tb_lista l2 on p.pgp_tipo_operacao = l2.lst_cd_lista
	where
		pgp_dt_inicio >= @DataInicioPeriodoTeste
		and pgp_cd_cliente <> 7
		and pgp_in_excluido = 0
		and (
				l.lst_ds_valor = @MarktplaceTeste
				or
				(@MarktplaceTeste = 'outros' and l.lst_ds_valor not in ('mercado_livre', 'shopee', 'Administrativo'))
			)
		and l2.lst_ds_valor = @Operacao
		and (
				(
					@MarktplaceTeste = 'mercado_livre' and @Operacao = 'LM'
					and
					(
						(@ProcessoPagamento = 'V1' and pgp_cd_cliente not in (66,67,68,69,27, 73, 37, 88, 56))  
						or
						(@ProcessoPagamento = 'V2' and pgp_cd_cliente in (66,67,68)) 
						or
						(@ProcessoPagamento = 'V3' and pgp_cd_cliente in (27, 73, 37, 88, 56, 69)) 
					)
				)
				or
				NOT (@MarktplaceTeste = 'mercado_livre' AND @Operacao = 'LM')
			)
	group by
		pgp_cd_cliente
		,pgp_cd_cliente_transportadora

	while exists (select 1 from #periodos)
	begin
		declare @PeriodoPagamento int
		declare @CodigoCliente int

		select
			top 1
			@PeriodoPagamento = pgp_cd_periodo
			,@CodigoCliente = pgp_cd_cliente
		from
			#periodos
		
		print('Cliente ' + cast(@CodigoCliente as varchar) + ' - Período: ' + cast(@PeriodoPagamento as varchar))
		exec [UspFinGeraTestesFinanceiro] @PeriodoPagamento, @FaseTeste

		delete #periodos where pgp_cd_periodo = @PeriodoPagamento

	end

end
GO
