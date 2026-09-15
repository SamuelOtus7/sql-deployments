-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManualDesconto
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManualDesconto]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--================================================
-- Autor: Saulo Barros
-- Data de Criação: 02/06/2025
-- Descrição: Atualiza Lançamentos de Descontos
-- Negócio: Os descontos são lançamentos que não devem refletir no total bruto do motorista, ou seja, no valor que ele visualiza para gerar a nota fiscal.
--			Deve ser abatido do valor que a transportadora deverá pagar, sendo refletido no pagamento líqudio.
--			Exemplo: Adiantamentos
--==================================================
CREATE procedure [dbo].[UspFinAtualizaLancamentoManualDesconto]  (
	@CodPeriodoPagamento int
)
as
begin



	--declare @CodPeriodoPagamento int = 581
	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento and pgp_cd_cliente <> 63)

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1
	begin

		declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
		declare @IdTransportadora int = (select cli_id_logistics from tb_clientes where cli_cd_codigo_cliente=@CodigoCliente)
		declare @DataInicial date = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
		declare @DataFinal date = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)
		declare @IdCliTransportadora int = (  select lst_cd_lista
											  from tb_lista as a (NOLOCK)  
											  inner join [tb_pgto_periodo] as b 
													on a.lst_cd_cliente = b.pgp_cd_cliente
													--Ajuste para diferenciar o MArketPlace
													and a.lst_cd_lista = b.pgp_cd_cliente_transportadora
											  where a.lst_nm_lista = 'Clientes transportadoras' 
													and b.pgp_cd_periodo  = @CodPeriodoPagamento 
											)

		declare @Operacao int = (select 
								lst_cd_lista 
							from 
								tb_lista with(nolock)
							where 
								lst_nm_lista = 'Operações Marketplace' 
								and lst_ds_valor = 'LM' 
								and lst_cd_cliente = @CodigoCliente
							)
		
		 declare @DataPrevistaPagamento date = (  
      
			  select pgp_dt_prevista_pagamento  
			  from [tb_pgto_periodo] as a (NOLOCK)  
			  where pgp_cd_periodo  = @CodPeriodoPagamento
     
			 )  

		drop table if exists #descontos
		select
			@CodPeriodoPagamento ppr_cd_periodo
			,tlm_cd_lancamento_manual ppr_lcto_cd_lancamento
			,tlm_cd_cliente
			--,case when tlm_cd_rota = 'null' or tlm_cd_rota = '' then null else tlm_cd_rota end ppr_cd_rota
			,cast(tlm_dh_referencia as date) ppr_data_referencia
			,tlm_cd_service_center ppr_base_principal
			,tlm_cd_motorista ppr_nome_motorista
			,plm_nm_tipo + case when tlm_ds_observacao <> '' then ': ' + tlm_ds_observacao else '' end  ppr_lcto_observacao
			,usr_cd_usuario ppr_cd_motorista
			,isnull(tlm_vl_valor_descontos,0) ppr_vl_lancamentos
			,isnull(tlm_vl_valor_descontos,0) ppr_vl_total
			into #descontos
		from
			vw_lancamentos_manuais_aprovados a
			left join tb_usuario b (nolock) on a.tlm_cd_motorista = b.usr_nm_usuario
													and a.tlm_cd_cliente = b.cli_cd_codigo_cliente
		where 1=1
			and plm_in_calculo_desconto = 1
			and tlm_cd_cliente = @CodigoCliente
			and cast(tlm_dh_referencia as date) between @DataInicial and @DataFinal
			and a.Operacao = 'LM'
			--Ajuste para diferenciar o MArketPlace
			--and a.tlm_cd_cliente_transportadora = @IdCliTransportadora

		-- apaga quando não existe usuario criado (verificar se existe parametro para isso)
		if @CodigoCliente = 11
		begin
			delete #descontos where ppr_cd_motorista is null
		end


		-- cria espelho caso ainda não exista
		--INSERE PRIMEIRO O ESPELHO DAS ROTAS QUE NÃO GERARAM ESPELHO
		insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_vl_desconto, mtn_cd_operacao, mtn_dt_prevista_pagamento)
		select 
			ppr_cd_motorista mtn_cd_motorista
			,ppr_nome_motorista as mtn_nome_motorista
			,ppr_cd_periodo as mtn_cd_pgto_periodo
			,228 mtn_cd_status
			,0 as mtn_vl_nfs
			,null mtn_ds_link_nfs
			,dateadd(day,30,@DataFinal) as mtn_dt_prazo_contestacao
			,getdate() mtn_dh_criacao
			,8851 as mtn_cd_usr_criacao
			,getdate() mtn_dh_modificacao
			,8851 as mtn_cd_usr_modificacao
			,0 as mtn_in_excluido
			,@CodigoCliente as mtn_cod_cliente
			,count(*) as mtn_qt_rotas
			,94  as mtn_cd_tipo_espelho
			,@IdCliTransportadora as mtn_cd_cliente_transportadora
			,bss_cd_base as mtn_cd_base
			,ppr_base_principal mtn_base_principal
			,SUM(isnull(ppr_vl_total,0)) mtn_vl_desconto
			,@Operacao mtn_cd_operacao
			,@DataPrevistaPagamento mtn_dt_prevista_pagamento
		from 
			#descontos as a 
			left join tb_pag_espelhos as e on a.ppr_nome_motorista = e.mtn_nome_motorista
											and a.ppr_cd_periodo = e.mtn_cd_pgto_periodo
											--Criar parametro para dizer se o espelho do motorista varia para cada svc
											and (
												(@CodigoCliente = 11 and a.ppr_base_principal = e.mtn_base_principal)
												or
												@CodigoCliente <> 11
											)
											and e.mtn_cd_operacao = @Operacao
			left join tb_bases as c on a.ppr_base_principal = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
		where
			e.mtn_cd_motorista_nfs is null
		group by
			ppr_cd_motorista
			,ppr_nome_motorista
			,ppr_cd_periodo
			,bss_cd_base
			,ppr_base_principal


		drop table if exists #pgto_descontos
		select
			d.ppr_nome_motorista
			,d.ppr_data_referencia
			,d.ppr_lcto_observacao
			,d.ppr_vl_lancamentos
			,d.ppr_vl_total
			,d.ppr_cd_periodo
			,e.mtn_cd_motorista_nfs ppr_cd_pgto_espelho
			,getdate() ppr_dh_criacao
			,7 ppr_cd_usr_criacao
			,getdate() ppr_dh_modificacao
			,7 ppr_cd_usr_modificacao
			,1 ppr_in_ativo
			,0 ppr_in_excluido
			,d.ppr_cd_motorista
			,e.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs
			,d.ppr_lcto_cd_lancamento
			,d.ppr_base_principal as ppr_cd_service_center
			,1 ppr_fl_desconto
			into #pgto_descontos
		from
			#descontos d
			join tb_pag_espelhos e on d.ppr_nome_motorista = e. mtn_nome_motorista
										and d.ppr_cd_periodo = e.mtn_cd_pgto_periodo
										--Criar parametro para dizer se o espelho do motorista varia para cada svc
											and (
												(@CodigoCliente = 11 and d.ppr_base_principal = e.mtn_base_principal)
												or
												@CodigoCliente <> 11
											)
											and e.mtn_cd_operacao = @Operacao

			join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista 
										and l.lst_nm_lista = 'Status motorista nfs' 
										and lst_cd_fechado=0

		where
			e.mtn_in_excluido = 0


		-- Insere novos lançamentos ou altera o que já foi incluido
		merge into tb_pgto_periodo_rota as a
		using #pgto_descontos as p on a.ppr_cd_periodo = p.ppr_cd_periodo
										and a.ppr_cd_motorista_nfs = p.ppr_cd_motorista_nfs
										and a.ppr_lcto_cd_lancamento = p.ppr_lcto_cd_lancamento
		when matched then
			update set
				 ppr_vl_lancamentos = p.ppr_vl_lancamentos
				,ppr_vl_total = p.ppr_vl_total
				,ppr_dh_modificacao = getdate()
		when not matched then
			insert ( 
					ppr_nome_motorista
					,ppr_data_referencia
					,ppr_lcto_observacao
					,ppr_vl_lancamentos
					,ppr_vl_total
					,ppr_cd_periodo
					,ppr_cd_pgto_espelho
					,ppr_dh_criacao
					,ppr_cd_usr_criacao
					,ppr_dh_modificacao
					,ppr_cd_usr_modificacao
					,ppr_in_ativo
					,ppr_in_excluido
					,ppr_cd_motorista
					,ppr_cd_motorista_nfs
					,ppr_lcto_cd_lancamento
					,ppr_base_principal
					,ppr_fl_desconto
					,ppr_cd_tipo_pgto
					)
			values (
					p.ppr_nome_motorista
					,p.ppr_data_referencia
					,p.ppr_lcto_observacao
					,p.ppr_vl_lancamentos
					,p.ppr_vl_total
					,p.ppr_cd_periodo
					,p.ppr_cd_pgto_espelho
					,p.ppr_dh_criacao
					,p.ppr_cd_usr_criacao
					,p.ppr_dh_modificacao
					,p.ppr_cd_usr_modificacao
					,p.ppr_in_ativo
					,p.ppr_in_excluido
					,p.ppr_cd_motorista
					,p.ppr_cd_motorista_nfs
					,p.ppr_lcto_cd_lancamento
					,p.ppr_cd_service_center
					,p.ppr_fl_desconto
					,1363
			);

			-- Deleta lançamentos que foram cancelados com espelhos ainda em aberto
			update
				p
			set
				p.ppr_in_excluido = 1
			from
				tb_pgto_periodo_rota p
				join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista 
											and l.lst_nm_lista = 'Status motorista nfs' 
											and lst_cd_fechado=0
			where
				p.ppr_cd_periodo = @CodPeriodoPagamento
				and p.ppr_fl_desconto = 1
				and e.mtn_cd_operacao = @Operacao
				and not exists (select 
									1 
								from 
									vw_lancamentos_manuais_aprovados l 
								where 
									l.tlm_cd_cliente = @CodigoCliente
									and p.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
									and l.Operacao = 'LM'
								)
			

	end

end
GO
