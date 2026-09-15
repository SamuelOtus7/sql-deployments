-- ============================================================
-- BASELINE: dbo.UspValidacoesEspelhoResultados
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspValidacoesEspelhoResultados]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[UspValidacoesEspelhoResultados]    (
    @CodigoPeriodoPagamento int,
	@CodigoValidacaoContexto int
)
as
begin

	set nocount on

	--Verifica o grupo da validação para retornar a informação
	declare @GrupoValidacao varchar(60)
	select
		@GrupoValidacao = l.lst_ds_valor
	from
		tb_validacoes_espelho_contexto c with(nolock)
		join tb_validacoes_espelho v with(nolock) on c.vec_cd_validacao = v.vle_cd_validacao
		join tb_lista l with(nolock) on v.vle_cd_grupo_validacao = l.lst_cd_lista 
	where
		c.vec_cd_validacao_contexto = @CodigoValidacaoContexto

	--Verifica qual url do cliente
	declare @UrlCliente varchar(100)
	select 
		@UrlCliente = c.cli_ds_sub_dominio
	from 
		tb_pgto_periodo p with(nolock)
		join tb_clientes c with(nolock) on p.pgp_cd_cliente = c.cli_cd_codigo_cliente
	where
		p.pgp_cd_periodo = @CodigoPeriodoPagamento

		
	if @GrupoValidacao = 'Pagamento'
	begin
		select 
			CodigoValidacaoResultado
			,replace(Acao,'{subdominio}',@UrlCliente) Acao
			,IdRota
			,Base
			,TipoVeiculo
			,Motorista
			,case when UsuarioInativacao is not null then 1 else 0 end Inativado
		from 
			vw_validacoes_espelho_resultados_pagamento 
		where 
			CodigoPeriodo = @CodigoPeriodoPagamento 
			and CodigoValidacaoContexto = @CodigoValidacaoContexto 
			and Sucesso = 0 
	end


	if @GrupoValidacao = 'Análise de rotas'
	begin
		select 
			CodigoValidacaoResultado
			,replace(Acao,'{subdominio}',@UrlCliente) Acao
			,IdRota
			,DataReferencia
			,StatusRota
			,Base
			,TipoVeiculo
			,Motorista
			,case when UsuarioInativacao is not null then 1 else 0 end Inativado
		from 
			vw_validacoes_espelho_resultados_rotas 
		where 
			CodigoPeriodo = @CodigoPeriodoPagamento 
			and CodigoValidacaoContexto = @CodigoValidacaoContexto 
			and Sucesso = 0 
	end


	if @GrupoValidacao = 'Lançamentos manuais'
	begin
		select 
			CodigoValidacaoResultado
			,replace(Acao,'{subdominio}',@UrlCliente) Acao
			,IdLancamentoManual
			,TipoLancamentoManual
			,Base
			,IdRota
			,Motorista
			,case when UsuarioInativacao is not null then 1 else 0 end Inativado
		from 
			vw_validacoes_espelho_resultados_lancamentos_manuais 
		where 
			CodigoPeriodo = @CodigoPeriodoPagamento 
			and CodigoValidacaoContexto = @CodigoValidacaoContexto 
			and Sucesso = 0 
	end



end
GO
