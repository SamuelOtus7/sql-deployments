-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManualOutrosClientes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManualOutrosClientes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspFinAtualizaLancamentoManualOutrosClientes]  (  
    @CodPeriodoPagamento VARCHAR(50)
)  
AS  
begin

	declare @data_inicial date = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with (nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)  
	declare @data_final date = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with (nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)  
  
	declare @clienteid int = (  
								select 
									pgp_cd_cliente  
								from 
									[tb_pgto_periodo] as a (NOLOCK)  
								where 
									pgp_cd_periodo  = @CodPeriodoPagamento  
								)  

	declare @Operacao int = (
								select 
									pgp_tipo_operacao  
								from 
									[tb_pgto_periodo] as a (NOLOCK)  
								where 
									pgp_cd_periodo  = @CodPeriodoPagamento  
								) 
								
	declare @IdCliTransportadora int = (
										select 
											pgp_cd_cliente_transportadora  
										from 
											[tb_pgto_periodo] as a (NOLOCK)  
										where 
											pgp_cd_periodo  = @CodPeriodoPagamento
										)

	declare @MarketPlace varchar(100) = (
										select
											lst_ds_valor 
										from 
											tb_lista 
										where 
											lst_cd_lista = @IdCliTransportadora
										)
	declare @DataPrevistaPagamento date = (  
      
										select pgp_dt_prevista_pagamento  
										from [tb_pgto_periodo] as a (NOLOCK)  
										where pgp_cd_periodo  = @CodPeriodoPagamento
     
										)


 	drop table if exists #lancamentos_aprovados
	select  
		tlm_cd_cliente  
		,tlm_cd_rota  
		,tlm_ds_observacao  
		,tlm_cd_lancamento_manual  
		,trim(cast(tlm_cd_rota as varchar(50))) as IdRota  
		,tlm_dh_referencia as Data  
		,tlm_cd_motorista as ppr_nome_motorista  
		,usr_cd_usuario  
		,cast(tlm_dh_referencia as date) ppr_data_referencia  
		,case when alm_ds_status = 'Aprovado' then 
			isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when a.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end  
		else 
			0 
		end  AS ppr_vl_lancamentos          
		,case when alm_ds_status = 'Aprovado' then isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when a.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end  else 0 end ppr_vl_total  
		,alm_ds_status   
		,a.plm_nm_tipo  
		,a.tlm_cd_service_center ppr_base_principal  
		,tlm_cd_tipo
		into #lancamentos_aprovados
	from
		vw_lancamentos_manuais_aprovados a  
		left join tb_usuario as b (NOLOCK)  on a.tlm_cd_motorista = b.usr_nm_usuario  
									and cli_cd_codigo_cliente = tlm_cd_cliente                
	where   
		tlm_in_ativo = 1  
		and plm_in_calculo_desconto = 0  
		and (tlm_cd_rota is null or tlm_cd_rota = 'null' or tlm_cd_rota = '') 
		and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
		and tlm_cd_cliente = @clienteid  
		and a.tlm_cd_operacao = @Operacao  
		and a.tlm_cd_cliente_transportadora = @IdCliTransportadora

	
	--atualiza base principal com base no que tiver mais lançamentos
	update 
		a
	set	
		ppr_base_principal = case when @clienteid in (11,1,56) then a.ppr_base_principal else b.ppr_base_principal end
	from	
		#lancamentos_aprovados as a
		join (
			select 
				*
				,row_number() over(partition by ppr_nome_motorista order by qtd desc, ppr_base_principal desc) ordem
			from
				(
					select
						ppr_nome_motorista
						,ppr_base_principal
						,count(*) qtd
					from 
						#lancamentos_aprovados
					group by 
						ppr_nome_motorista
						,ppr_base_principal
				) as a
			) as b on a.ppr_nome_motorista = b.ppr_nome_motorista
	where 
		b.ordem = 1


	insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_cd_operacao, mtn_dt_prevista_pagamento)
	select
		usr_cd_usuario mtn_cd_motorista
		,ppr_nome_motorista as mtn_nome_motorista
		,@CodPeriodoPagamento as mtn_cd_pgto_periodo
		,228 mtn_cd_status
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,null mtn_ds_link_nfs
		,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
		,getdate() mtn_dh_criacao
		,8851 as mtn_cd_usr_criacao
		,getdate() mtn_dh_modificacao
		,8851 as mtn_cd_usr_modificacao
		,0 as mtn_in_excluido
		,@clienteid as mtn_cod_cliente
		,count(*) as mtn_qt_rotas
		,94  as mtn_cd_tipo_espelho
		,@IdCliTransportadora as mtn_cd_cliente_transportadora
		,bss_cd_base as mtn_cd_base
		,ppr_base_principal mtn_base_principal
		,@operacao mtn_cd_operacao
		,@DataPrevistaPagamento mtn_dt_prevista_pagamento
	from
		#lancamentos_aprovados l
		left join tb_bases as c on l.ppr_base_principal = c.bss_ds_sigla and c.bss_cod_cliente = @clienteid
		left join tb_pag_espelhos as e on e.mtn_cd_motorista = l.usr_cd_usuario  
										and e.mtn_cd_pgto_periodo =  @CodPeriodoPagamento  
										and e.mtn_cd_operacao = @Operacao 
										and e.mtn_in_excluido = 0
										and (  
												(@clienteid in (11,1,56) and l.ppr_base_principal = e.mtn_base_principal)  
												or  
												@clienteid not in (11,1,56)  
										) 
	where
		e.mtn_cd_motorista_nfs is null
	group by
		usr_cd_usuario
		,ppr_nome_motorista
		,bss_cd_base
		,ppr_base_principal
										


 	drop table if exists #TempLancamentoManual  
	SELECT   
		LNC.*  
		,@CodPeriodoPagamento as ppr_cd_periodo  
		,esp.mtn_cd_motorista_nfs  
		into #TempLancamentoManual  
	FROM 
		#lancamentos_aprovados LNC
		join tb_pag_espelhos as esp on esp.mtn_cd_motorista = LNC.usr_cd_usuario  
										and esp.mtn_cd_pgto_periodo =  @CodPeriodoPagamento  
										and esp.mtn_cd_operacao = @Operacao  
										and (  
												(@clienteid in (11,1,56) and LNC.ppr_base_principal = esp.mtn_base_principal)  
												or  
												@clienteid not in (11,1,56)  
										)  
	where 
		esp.mtn_cd_status in (34,228,38,1298)
		and esp.mtn_in_excluido = 0;   


	drop table if exists #lancamento_sem_rota_pf
	select 
		distinct  
		null ppr_cd_rota  
		,a.ppr_nome_motorista  
		,a.data as ppr_data_referencia  
		,a.tlm_ds_observacao as ppr_lcto_observacao  
		,a.ppr_vl_lancamentos  
		,a.ppr_vl_total  
		,a.ppr_cd_periodo  
		,esp.mtn_cd_motorista_nfs ppr_cd_pgto_espelho  
		,getdate() ppr_dh_criacao  
		,7 ppr_cd_usr_criacao  
		,getdate() ppr_dh_modificacao  
		,7 ppr_cd_usr_modificacao  
		,1 ppr_in_ativo  
		,0 ppr_in_excluido  
		,a.usr_cd_usuario as ppr_cd_motorista  
		,a.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs  
		,tlm_cd_lancamento_manual as ppr_lcto_cd_lancamento  
		,mtn_base_principal as ppr_cd_service_center  
		into #lancamento_sem_rota_pf
	from 
		#TempLancamentoManual as a  
		join tb_pag_espelhos as esp (NOLOCK) on esp.mtn_cd_motorista_nfs = a.mtn_cd_motorista_nfs
	where 
		a.ppr_cd_periodo = @CodPeriodoPagamento  
		and esp.mtn_cd_status in (34,228,38,1298) 


	merge into tb_pgto_periodo_rota as a  
	using #lancamento_sem_rota_pf as b on a.ppr_cd_periodo = b.ppr_cd_periodo  
										and a.ppr_cd_motorista_nfs = b.ppr_cd_motorista_nfs  
										and a.ppr_lcto_cd_lancamento = b.ppr_lcto_cd_lancamento  
  
	when matched then  
	update set  
         ppr_vl_lancamentos = b.ppr_vl_lancamentos  
        ,ppr_vl_total = b.ppr_vl_total
		,ppr_lcto_observacao = b.ppr_lcto_observacao
		,ppr_in_excluido = 0
	when not matched then  
	insert ( ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
        , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido  
        ,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal, ppr_cd_tipo_pgto)  
  
	values (b.ppr_cd_rota, b.ppr_nome_motorista, b.ppr_data_referencia, b.ppr_lcto_observacao, b.ppr_vl_lancamentos, b.ppr_vl_total, b.ppr_cd_periodo, b.ppr_cd_motorista_nfs  
        ,b.ppr_dh_criacao, b.ppr_cd_usr_criacao, b.ppr_dh_modificacao, b.ppr_cd_usr_modificacao, b.ppr_in_ativo, b.ppr_in_excluido  
        ,b.ppr_cd_motorista,b.ppr_cd_motorista_nfs, b.ppr_lcto_cd_lancamento, b.ppr_cd_service_center, 1363);  


		
	-- Deleta lançamentos que foram cancelados com espelhos ainda em aberto
	update
		p
	set
		p.ppr_in_excluido = 1
	from
		tb_pgto_periodo_rota p
		join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
	where
		p.ppr_cd_periodo = @CodPeriodoPagamento
		and e.mtn_cd_status in (34,228,38,1298)  
		and mtn_cd_operacao = @Operacao
		and p.ppr_lcto_cd_lancamento is not null
		and not exists (select 
							1 
						from 
							vw_lancamentos_manuais_aprovados l 
						where 
							l.tlm_cd_cliente = @clienteid
							and p.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
							and l.tlm_cd_operacao = @Operacao
							and l.tlm_cd_cliente_transportadora = @IdCliTransportadora
						);
  

end
GO
