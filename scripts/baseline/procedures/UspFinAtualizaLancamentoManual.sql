-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManual
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManual]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspFinAtualizaLancamentoManual]  (  
    @CodPeriodoPagamento VARCHAR(50),  
    @idrota VARCHAR(50) = NULL  
    )  
AS  
  
 declare  
      @IdTransportadora int  
  --  , @CodPeriodoPagamento int = 2387
    , @data_inicial date  
    , @data_final date  
 , @clienteid int  
 , @usuarioIrisys int  
 , @Motorista varchar(250)  
 , @IdCliTransportadora int  
 --, @idrota varchar(50) = null  
 --, @avulso int = null  
    ,@tipocontrato int = null  
  
  
  
 set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with (nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)  
 set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with (nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)  
  
  
  
 if @idrota is not null  
  begin  
   set @Motorista = (select distinct NomeMotorista from tb_ml_rotas (NOLOCK) where cast(idrota as varchar(50)) = @idrota and excluido = 0)  
  end  
  
 set @IdTransportadora = (  
       select cli_id_logistics  
       from [tb_pgto_periodo] as a (NOLOCK)  
       left join tb_clientes as b (NOLOCK)  
       on a.pgp_cd_cliente = cli_cd_codigo_cliente  
       where pgp_cd_periodo  = @CodPeriodoPagamento  
      )  
  
  
 set @tipocontrato = (  
       select pgp_cd_tipo_contratos  
       from [tb_pgto_periodo] as a (NOLOCK)  
       left join tb_clientes as b (NOLOCK)  
       on a.pgp_cd_cliente = cli_cd_codigo_cliente  
       where pgp_cd_periodo  = @CodPeriodoPagamento  
      )  
  
 set @IdCliTransportadora = (  

      select lst_cd_lista
      from tb_lista as a (NOLOCK)  
      inner join [tb_pgto_periodo] as b 
            on a.lst_cd_cliente = b.pgp_cd_cliente
            --Ajuste para diferenciar o MArketPlace
            and a.lst_cd_lista = b.pgp_cd_cliente_transportadora
      where a.lst_nm_lista = 'Clientes transportadoras' 
            and b.pgp_cd_periodo  = @CodPeriodoPagamento 

      )  
  
  
  
 set @clienteid = (  
      select pgp_cd_cliente  
      from [tb_pgto_periodo] as a (NOLOCK)  
      left join tb_clientes as b (NOLOCK)  
      on a.pgp_cd_cliente = cli_cd_codigo_cliente  
      where pgp_cd_periodo  = @CodPeriodoPagamento  
	  and a.pgp_cd_cliente <> 63
      )  
  

 declare @Operacao int = (select   
        lst_cd_lista   
       from   
        tb_lista with(nolock)  
       where   
        lst_nm_lista = 'Operações Marketplace'   
        and lst_ds_valor = 'LM'   
        and lst_cd_cliente = @clienteid    
       )  

 declare @DataPrevistaPagamento date = (  
      
	  select pgp_dt_prevista_pagamento  
      from [tb_pgto_periodo] as a (NOLOCK)  
      where pgp_cd_periodo  = @CodPeriodoPagamento
     
	 )  
  

		--Adicionado por Saulo Barros em 10/04/2026 para poder gerar espelhos para motoristas que tiveram lançamento manual 
		--mas não tem espelho gerado. Este processo só é feito para clientes que estão parametrizados para que seja realizado
		declare @CriarEspelho int = (select prm_ds_valor from tb_parametros where prm_nm_parametro = 'Geração automática de espelho' and prm_cod_cliente = @clienteid)
		if @CriarEspelho = 1
		begin
			
			--Retorna todos os lançamentos do período
			drop table if exists #lancamentos
			select
				*
				into #lancamentos
			from
				(
					select  
						tlm_cd_cliente  
						,tlm_cd_rota  
						,case when isnull(rtrim(ltrim(tlm_ds_observacao)),'') = '' then plm_nm_tipo else tlm_ds_observacao end tlm_ds_observacao    
						,tlm_cd_lancamento_manual  
						,trim(cast(tlm_cd_rota as varchar(50))) as IdRota  
						,tlm_dh_referencia as Data  
						,tlm_cd_motorista as ppr_nome_motorista  
						,usr_cd_usuario  
						,cast(tlm_dh_referencia as date) ppr_data_referencia  
						,isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when a.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end ppr_vl_lancamentos  
						,isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when a.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end ppr_vl_total  
						,alm_ds_status   
						,a.plm_nm_tipo  
						,a.tlm_cd_service_center ppr_base_principal  
						,tlm_cd_tipo
					from
						--Alterado por Saulo Barros em 21/07 para buscar da view de aprovados
						--vw_lancamentos_manuais a  
						vw_lancamentos_manuais_aprovados a  
						join tb_usuario as b (NOLOCK)  on a.tlm_cd_motorista = b.usr_nm_usuario  
														and cli_cd_codigo_cliente = tlm_cd_cliente 
														and b.usr_in_ativo = 1
					where   
						tlm_in_ativo = 1  
						and plm_in_calculo_desconto = 0  
						and (@idrota is null or tlm_cd_rota = @idrota)  
						and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
						and tlm_cd_cliente = @clienteid  
						and a.Operacao = 'LM'  
						and a.tlm_cd_cliente_transportadora = @IdCliTransportadora
						and 
						(
							(tlm_cd_rota is null or tlm_cd_rota = 'null' or tlm_cd_rota = '')
							or
							(
								tlm_cd_rota is not null 
								and tlm_cd_rota <> 'null' 
								and tlm_cd_rota <> '' 
								and not exists (select 1 from tb_pgto_periodo_rota p where p.ppr_cd_periodo = @CodPeriodoPagamento and p.ppr_cd_rota is not null and p.ppr_lcto_cd_lancamento is null and tlm_cd_rota = ppr_cd_rota)
							)
						)
						
   
					union  
  
					select  
						tlm_cd_cliente  
						,tlm_cd_rota  
						,case when isnull(rtrim(ltrim(tlm_ds_observacao)),'') = '' then plm_nm_tipo else tlm_ds_observacao end tlm_ds_observacao  
						,tlm_cd_lancamento_manual  
						,trim(cast(tlm_cd_rota as varchar(50))) as IdRota  
						,tlm_dh_referencia as Data  
						,tlm_ds_motorista_apoio ppr_nome_motorista  
						,usr_cd_usuario  
						,cast(tlm_dh_referencia as date) ppr_data_referencia  
						,case when alm_ds_status = 'Aprovado' then tlm_vl_valor_apoio else 0 end AS ppr_vl_lancamentos  
						,case when alm_ds_status = 'Aprovado' then tlm_vl_valor_apoio else 0 end ppr_vl_total  
						,alm_ds_status   
						,a.plm_nm_tipo  
						,a.tlm_cd_service_center ppr_base_principal
						,tlm_cd_tipo
					from
						--Alterado por Saulo Barros em 21/07 para buscar da view de aprovados
						--vw_lancamentos_manuais a  
						vw_lancamentos_manuais_aprovados a
						join tb_usuario as b (NOLOCK) on tlm_ds_motorista_apoio = b.usr_nm_usuario  
															and cli_cd_codigo_cliente = tlm_cd_cliente  
															and b.usr_in_ativo = 1
					
  
					where   
							tlm_in_ativo = 1  
							and plm_in_calculo_desconto = 0  
							and (@idrota is null or tlm_cd_rota = @idrota)  
							and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
							and tlm_cd_cliente = @clienteid  
							and a.plm_nm_tipo = 'Apoio'  
							and a.Operacao = 'LM'  
							and a.tlm_cd_cliente_transportadora = @IdCliTransportadora
				) t


				if @clienteid not in (11,1,56)
				begin
					update
						r
					set
						r.ppr_base_principal = r2.ppr_base_principal
					from
						#lancamentos r
						join (
							select
								ppr_nome_motorista
								,ppr_base_principal
								,row_number() over(partition by ppr_nome_motorista order by count(*) desc, ppr_base_principal desc) as ordem
							from
								#lancamentos
							group by
								ppr_nome_motorista
								,ppr_base_principal
						) r2 on isnull(r.ppr_nome_motorista, N'') = isnull(r2.ppr_nome_motorista, N'')
							and r2.ordem = 1
				end

				-- cria espelho caso ainda não exista
				insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_vl_desconto, mtn_cd_operacao, mtn_dt_prevista_pagamento)
				select 
					usr_cd_usuario mtn_cd_motorista
					,ppr_nome_motorista as mtn_nome_motorista
					,@CodPeriodoPagamento as mtn_cd_pgto_periodo
					,228 mtn_cd_status
					,0 as mtn_vl_nfs
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
					,SUM(isnull(ppr_vl_total,0)) mtn_vl_desconto
					,@Operacao mtn_cd_operacao
					,@DataPrevistaPagamento mtn_dt_prevista_pagamento
				from 
					#lancamentos as a 
					left join tb_pag_espelhos as e on a.ppr_nome_motorista = e.mtn_nome_motorista
													and e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
													and e.mtn_cd_operacao = @Operacao
													and e.mtn_in_excluido = 0
													and mtn_cd_cliente_transportadora = @IdCliTransportadora
													--Criar parametro para dizer se o espelho do motorista varia para cada svc
													and (
														(@clienteid in (11,1,56) and a.ppr_base_principal = e.mtn_base_principal)
														or
														@clienteid not in (11,1,56)
													)
					left join tb_bases as c on a.ppr_base_principal = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
				where
					e.mtn_cd_motorista_nfs is null
				group by
					usr_cd_usuario
					,ppr_nome_motorista
					,bss_cd_base
					,ppr_base_principal

		end
		--Fim condição para criar espelho



        drop table if exists #TempLancamentoManual  
        SELECT   
			LNC.*  
			,@CodPeriodoPagamento as ppr_cd_periodo  
			,esp.mtn_cd_motorista_nfs  
			into #TempLancamentoManual  
        FROM (  
                select  
                     tlm_cd_cliente  
                    ,tlm_cd_rota  
                    ,tlm_ds_observacao  
					,tlm_cd_lancamento_manual  
                    ,trim(cast(replace(replace(replace(replace(tlm_cd_rota, char(9), ''), char(10), ''), char(13), ''), ' ', '') as varchar(50))) as IdRota  
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
                from
					--Alterado por Saulo Barros em 21/07 para buscar da view de aprovados
					--vw_lancamentos_manuais a  
					vw_lancamentos_manuais_aprovados a  
					left join tb_usuario as b (NOLOCK)  on a.tlm_cd_motorista = b.usr_nm_usuario  
													and cli_cd_codigo_cliente = tlm_cd_cliente                
                where   
					 tlm_in_ativo = 1  
					 and plm_in_calculo_desconto = 0  
					 and (@idrota is null or tlm_cd_rota = @idrota)  
					 and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
					 and tlm_cd_cliente = @clienteid  
					 and a.Operacao = 'LM'  
					 --Adicionado por Saulo Barros em 23/07 pois todos os lançametnos que tem rota são calculados na gera pagamento a partir da rota que foi coletada
					 and 
						(
							(tlm_cd_rota is null or tlm_cd_rota = 'null' or tlm_cd_rota = '')
							or
							(
								tlm_cd_rota is not null 
								and tlm_cd_rota <> 'null' 
								and not exists (select 1 from tb_pgto_periodo_rota p where p.ppr_cd_periodo = @CodPeriodoPagamento and p.ppr_cd_rota is not null and p.ppr_lcto_cd_lancamento is null and tlm_cd_rota = ppr_cd_rota)
							)
						)
                    --Ajuste para diferenciar o MArketPlace
                    and a.tlm_cd_cliente_transportadora = @IdCliTransportadora
   
                union  
  
                select  
                     tlm_cd_cliente  
                    ,tlm_cd_rota  
                    ,tlm_ds_observacao  
					,tlm_cd_lancamento_manual  
					,trim(cast(replace(replace(replace(replace(tlm_cd_rota, char(9), ''), char(10), ''), char(13), ''), ' ', '') as varchar(50))) as IdRota  
                    ,tlm_dh_referencia as Data  
                    ,tlm_ds_motorista_apoio ppr_nome_motorista  
                    ,usr_cd_usuario  
                    ,cast(tlm_dh_referencia as date) ppr_data_referencia  
                    ,case when alm_ds_status = 'Aprovado' then tlm_vl_valor_apoio else 0 end AS ppr_vl_lancamentos  
                    ,case when alm_ds_status = 'Aprovado' then tlm_vl_valor_apoio else 0 end ppr_vl_total  
                    ,alm_ds_status   
                    ,a.plm_nm_tipo  
					,a.tlm_cd_service_center ppr_base_principal
                    ,tlm_cd_tipo
                from
					--Alterado por Saulo Barros em 21/07 para buscar da view de aprovados
					--vw_lancamentos_manuais a  
					vw_lancamentos_manuais_aprovados a
					left join tb_usuario as b (NOLOCK) on tlm_ds_motorista_apoio = b.usr_nm_usuario  
														and cli_cd_codigo_cliente = tlm_cd_cliente    
					
  
                where   
					 tlm_in_ativo = 1  
					 and plm_in_calculo_desconto = 0  
					 and (@idrota is null or tlm_cd_rota = @idrota)  
					 and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
					 and tlm_cd_cliente = @clienteid  
					 and a.plm_nm_tipo = 'Apoio'  
					 and a.Operacao = 'LM'  
                     --Ajuste para diferenciar o MArketPlace
                     and a.tlm_cd_cliente_transportadora = @IdCliTransportadora
                  
                ) LNC  
            left join tb_pag_espelhos as esp on esp.mtn_cd_motorista = LNC.usr_cd_usuario  
												and esp.mtn_cd_pgto_periodo =  @CodPeriodoPagamento  
												and esp.mtn_cd_operacao = @Operacao  
												and esp.mtn_in_excluido = 0
											   --Regra criada por Saulo Barros em 09/05/2025 para considerar para 50+ a chave Periodo, Motorista e SVC  
											   and (  
												(@clienteid in (11,1,56) and LNC.ppr_base_principal = esp.mtn_base_principal)  
												or  
												@clienteid not in (11,1,56)  
											   )  
  
            where esp.mtn_cd_status in (34,228,38,1298);  
-----lancamento manuais sem rotas ou descontos de rotas de quinzenas anteriores  
  
  
  
--select *  from #lancamento_sem_rota_pf where ppr_cd_rota in (222288942)  
  
drop table if exists #lancamento_sem_rota_pf  
select distinct  
 cast(a.IdRota as varchar(50)) as ppr_cd_rota  
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
    ,r.ServiceCenter as ppr_cd_service_center  
      
into #lancamento_sem_rota_pf  
  
from #TempLancamentoManual as a  
  
left join tb_pgto_periodo_rota as b (NOLOCK)  
on cast(a.IdRota as varchar(50)) = b.ppr_cd_rota  
and a.ppr_cd_periodo = b.ppr_cd_periodo  
and a.mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs  
  
inner join tb_ml_rotas as r (NOLOCK)  
on cast(r.IdRota as varchar(50)) = a.idrota  
and r.Excluido = 0   
and  r.StatusRota <> 'planned'    
  
  
left join (  
    select*   
    from  tb_ml_rotas as r (NOLOCK)  
    where  r.Excluido = 0   
    and  r.StatusRota <> 'planned'  
    and datareferencia between @data_inicial and @data_final  
) as ts  
on cast(ts.IdRota as varchar(50)) = a.idrota  
  
  
left join tb_pag_espelhos as esp (NOLOCK)  
on esp.mtn_cd_motorista = r.usuarioda  
and mtn_cd_pgto_periodo = a.ppr_cd_periodo  
and esp.mtn_cd_motorista_nfs = a.mtn_cd_motorista_nfs  
and esp.mtn_cd_operacao = @Operacao  
  
where 1=1   
and a.ppr_cd_periodo = @CodPeriodoPagamento  
and esp.mtn_cd_status in (34,228,38,1298)  
and ts.idrota is null  
--and b.ppr_cd_rota is null  
and plm_nm_tipo <> 'Apoio';  
  
--sem rota  
insert into #lancamento_sem_rota_pf  
select distinct  
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
      
from #TempLancamentoManual as a  
  
left join tb_pgto_periodo_rota as b (NOLOCK)  
on cast(a.ppr_nome_motorista as varchar(50)) = b.ppr_nome_motorista  
and a.ppr_cd_periodo = b.ppr_cd_periodo  
and a.mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs  
  
  
inner join tb_pag_espelhos as esp (NOLOCK)  
on esp.mtn_cd_motorista = b.ppr_cd_motorista  
and mtn_cd_pgto_periodo = b.ppr_cd_periodo  
and esp.mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs  
and esp.mtn_cd_operacao = @Operacao  
  
where 1=1   
and a.ppr_cd_periodo = @CodPeriodoPagamento  
and (tlm_cd_rota is null or tlm_cd_rota = 'null' or tlm_cd_rota = '')  
and plm_nm_tipo <> 'Apoio'  
and mtn_base_principal is not null  
--and esp.mtn_cd_status in (34,228,38)  
--and ts.idrota is null  
--and b.ppr_cd_rota is null  
--and a.ppr_nome_motorista = 'CARLOS RENATO TOSTES DOS SANTOS'  
  

--Inserido por Saulo Barros em 16/02/2026 pois os comandos acima vai na tb_pgto_periodo_rota e quando tenho espelho criado avulso que terá só lançamento
--manual, ainda não tem registro na tb_pgto_periodo_rota
insert into #lancamento_sem_rota_pf  
select 
	distinct  
	null ppr_cd_rota  
    ,a.ppr_nome_motorista  
    ,a.data as ppr_data_referencia  
    ,a.tlm_ds_observacao as ppr_lcto_observacao  
    ,a.ppr_vl_lancamentos  
    ,a.ppr_vl_total  
    ,a.ppr_cd_periodo  
    ,a.mtn_cd_motorista_nfs ppr_cd_pgto_espelho  
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
from 
	#TempLancamentoManual as a  
	join tb_pag_espelhos as esp (NOLOCK) on esp.mtn_cd_motorista_nfs = a.mtn_cd_motorista_nfs 
where 
	(tlm_cd_rota is null or tlm_cd_rota = 'null' or tlm_cd_rota = '')  
	and plm_nm_tipo <> 'Apoio'  
	and tlm_cd_lancamento_manual not in (select ppr_lcto_cd_lancamento from #lancamento_sem_rota_pf)
  
  




--delete from tb_pgto_periodo_rota where ppr_cd_periodo = 534  
--delete from tb_pag_espelhos where mtn_cd_pgto_periodo = 534  
merge into tb_pgto_periodo_rota as a  
using #lancamento_sem_rota_pf as b  
on   
--a.ppr_cd_rota = b.ppr_cd_rota  
a.ppr_cd_periodo = b.ppr_cd_periodo  
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
  
  
-----------------------------lancamentos manuais com rotas desta quinzena e valor de apoio  
  
update a  
set ppr_vl_lancamentos = b.ppr_vl_lancamentos  
  ,ppr_in_excluido = 0
from tb_pgto_periodo_rota as a  
  
inner join (  
  
    select   
         a.tlm_cd_rota as IdRota  
        ,a.ppr_cd_periodo  
        ,a.mtn_cd_motorista_nfs  
        ,a.tlm_cd_lancamento_manual  
        ,sum(a.ppr_vl_lancamentos) as ppr_vl_lancamentos   
        ,sum(a.ppr_vl_total) as ppr_vl_total  
  
    from  #TempLancamentoManual as a  
      
 --   left join #lancamento_sem_rota_pf as C  
 --   on a.mtn_cd_motorista_nfs = c.ppr_cd_motorista_nfs  
 --   and a.tlm_cd_rota = ppr_Cd_rota  
 --and ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual  
  
    where 1=1  
 and (tlm_cd_rota is not null and tlm_cd_rota <> 'null')  
      
    group by a.tlm_cd_rota, a.ppr_cd_periodo,a.mtn_cd_motorista_nfs,a.tlm_cd_lancamento_manual  
  
 ) as b  
on  a.ppr_cd_rota = b.IdRota  
and a.ppr_cd_periodo = b.ppr_cd_periodo  
and a.ppr_cd_motorista_nfs = b.mtn_cd_motorista_nfs  
and a.ppr_lcto_cd_lancamento = b.tlm_cd_lancamento_manual  
  
where 1=1  
and a.ppr_cd_periodo = @CodPeriodoPagamento;  
  
  
--lancamentos com rota  
update a   
set a.ppr_vl_lancamentos = b.ppr_vl_lancamentos  
  ,ppr_in_excluido = 0
from tb_pgto_periodo_rota as a  
  
inner join (  
  
    select   
         a.tlm_cd_rota as IdRota  
        ,a.ppr_cd_periodo  
        ,a.mtn_cd_motorista_nfs  
        ,sum(a.ppr_vl_lancamentos) as ppr_vl_lancamentos   
        ,sum(a.ppr_vl_total) as ppr_vl_total  
  
    from  #TempLancamentoManual as a  
  
    where 1=1  
  and (tlm_cd_rota is not null and tlm_cd_rota <> 'null')  
    group by a.tlm_cd_rota, a.ppr_cd_periodo,a.mtn_cd_motorista_nfs--,c.ppr_cd_rota  
  
 ) as b  
on  a.ppr_cd_rota = b.IdRota  
and a.ppr_cd_periodo = b.ppr_cd_periodo  
and a.ppr_cd_motorista_nfs = b.mtn_cd_motorista_nfs  
and a.ppr_lcto_cd_lancamento is null  
  
where 1=1  
and a.ppr_cd_periodo = @CodPeriodoPagamento  
  
  

if @clienteid = 37 
--lancamentos com rota  
update a   
set 
    a.ppr_vl_lancamentos = (-1*a.ppr_vl_total)
  ,ppr_in_excluido = 0
from tb_pgto_periodo_rota as a  
  
inner join (  
  
    select   
         a.tlm_cd_rota as IdRota  
        ,a.ppr_cd_periodo  
        ,a.mtn_cd_motorista_nfs  
        ,sum(a.ppr_vl_lancamentos) as ppr_vl_lancamentos   
        ,sum(a.ppr_vl_total) as ppr_vl_total  
  
    from  #TempLancamentoManual as a  
  
    where 1=1  
    and tlm_cd_tipo = 308
    and (tlm_cd_rota is not null and tlm_cd_rota <> 'null')
    group by a.tlm_cd_rota, a.ppr_cd_periodo,a.mtn_cd_motorista_nfs--,c.ppr_cd_rota  
  
 ) as b  
on  a.ppr_cd_rota = b.IdRota  
and a.ppr_cd_periodo = b.ppr_cd_periodo  
and a.ppr_cd_motorista_nfs = b.mtn_cd_motorista_nfs  
and a.ppr_lcto_cd_lancamento is null  
  
where 1=1  
and a.ppr_cd_periodo = @CodPeriodoPagamento  




--lancamentos manuais de rotas de quinznas anteriores
insert into tb_pgto_periodo_rota (ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
       , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido  
       ,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal, ppr_cd_tipo_pgto)  
  
select   
    cast(a.IdRota as varchar(50)) as ppr_cd_rota  
   ,a.ppr_nome_motorista  
   ,a.data as ppr_data_referencia  
   ,a.tlm_ds_observacao as ppr_lcto_observacao  
   ,a.ppr_vl_lancamentos  
   ,a.ppr_vl_total  
   ,a.ppr_cd_periodo  
   ,a.mtn_cd_motorista_nfs ppr_cd_pgto_espelho  
   ,getdate() ppr_dh_criacao  
   ,7 ppr_cd_usr_criacao  
   ,getdate() ppr_dh_modificacao  
   ,7 ppr_cd_usr_modificacao  
   ,1 ppr_in_ativo  
   ,0 ppr_in_excluido  
   ,a.usr_cd_usuario as ppr_cd_motorista  
   ,a.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs  
   ,tlm_cd_lancamento_manual as ppr_lcto_cd_lancamento  
    ,a.ppr_base_principal ppr_cd_service_center
	,1363 ppr_cd_tipo_pgto

from  #TempLancamentoManual as a  

left join tb_pgto_periodo_rota as b (NOLOCK)  
on  b.ppr_lcto_cd_lancamento = a.tlm_cd_lancamento_manual  
and b.ppr_cd_pgto_espelho = a.mtn_cd_motorista_nfs 
and b.ppr_cd_periodo = @CodPeriodoPagamento

where 1=1  
and ppr_lcto_cd_lancamento is null
and (tlm_cd_rota is not null and tlm_cd_rota <> 'null') AND NOT EXISTS (  
      SELECT 1  
      FROM tb_pgto_periodo_rota b  
      WHERE b.ppr_cd_periodo = a.ppr_cd_periodo  
        AND b.ppr_cd_motorista_nfs = a.mtn_cd_motorista_nfs  
        AND b.ppr_lcto_cd_lancamento = a.tlm_cd_lancamento_manual  
  ) ;




  
update tb_pgto_periodo_rota  
set   
    ppr_vl_total = (isnull(ppr_vl_base  ,0)  
                    +isnull(ppr_vl_paradas  ,0)  
                    +isnull(ppr_vl_dom_fer  ,0)  
                    +isnull(ppr_vl_risco  ,0)  
                    +isnull(ppr_vl_ajudante ,0)  
                    +isnull(ppr_vl_lancamentos ,0)  
                    +isnull(ppr_vl_bonus  ,0)  
                    +isnull(ppr_vl_recarga  ,0)  
                    +isnull(ppr_vl_aluguel  ,0)  
                    +isnull(ppr_vl_pedagio  ,0)   
      +isnull(ppr_vl_desconto  ,0)   
       +isnull(ppr_vl_bonus_ds, 0)  
      +isnull(ppr_vl_adicional_km,0)  
                    )  
  
where ppr_cd_periodo = @CodPeriodoPagamento  
-- and ppr_cd_pgto_espelho = 499870  
  
  
  
update a  
set   
 mtn_vl_nfs = total  
from   
 tb_pag_espelhos a   
 inner join (  
  select   
   sum(ppr_vl_total) as total  
   ,ppr_cd_pgto_espelho  
  from   
   tb_pgto_periodo_rota as a  
  where   
   ppr_cd_periodo = @CodPeriodoPagamento  
            and ppr_in_excluido = 0  
   and ppr_fl_desconto = 0  
  group by ppr_cd_pgto_espelho  
 ) as b  
 on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho  
--where  
-- a.mtn_cd_operacao = @Operacao  
  
  
-- insere valor de apoio  
if @clienteid <> 11  
begin  
insert into tb_pgto_periodo_rota (ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
       , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido  
       ,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal, ppr_cd_tipo_pgto)  
  
select   
 cast(a.IdRota as varchar(50)) as ppr_cd_rota  
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
     
   --,r.ServiceCenter as ppr_cd_service_center  
   ,a.ppr_base_principal ppr_cd_service_center  
   ,1363 ppr_cd_tipo_pgto
      
from #TempLancamentoManual as a  
  
left join tb_pgto_periodo_rota as b (NOLOCK)  
on cast(a.IdRota as varchar(50)) = b.ppr_cd_rota  
and a.ppr_cd_periodo = b.ppr_cd_periodo  
and mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs  
  
  
--inner join tb_ml_rotas as r (NOLOCK)  
--on r.idrota = a.idrota  
--and r.Excluido = 0   
  
left join tb_pag_espelhos as esp (NOLOCK)  
--on esp.mtn_cd_motorista = r.usuarioda  
on esp.mtn_cd_motorista = a.usr_cd_usuario  
and mtn_cd_pgto_periodo = a.ppr_cd_periodo  
and esp.mtn_base_principal = a.ppr_base_principal  
and esp.mtn_cd_operacao = @Operacao  
  
where 1=1   
and a.ppr_cd_periodo = @CodPeriodoPagamento  
and esp.mtn_cd_status in (34,228,38,1298)  
and ppr_cd_rota is null  
and plm_nm_tipo = 'Apoio'  
AND NOT EXISTS (  
      SELECT 1  
      FROM tb_pgto_periodo_rota b  
      WHERE b.ppr_cd_periodo = a.ppr_cd_periodo  
        AND b.ppr_cd_motorista_nfs = a.mtn_cd_motorista_nfs  
        AND b.ppr_lcto_cd_lancamento = a.tlm_cd_lancamento_manual  
  ); 
  


--Adicionado por Gabriel Ramos em 23/07/2025 para excluir lançamentos que estão vindo duplicados nas rotas
--if @clienteid <> 11
--begin
--	UPDATE pr
--	SET pr.ppr_in_excluido = 1
--	 FROM tb_pgto_periodo_rota pr
--	WHERE pr.ppr_lcto_cd_lancamento IS NOT NULL
--	  AND pr.ppr_cd_periodo = @CodPeriodoPagamento
--	  AND ppr_in_excluido <> 1
--	  AND ppr_vl_base IS NULL
--	  AND EXISTS (
--		  SELECT 1
--		  FROM tb_pgto_periodo_rota pr2
--		  WHERE pr2.ppr_cd_rota = pr.ppr_cd_rota
--			AND pr2.ppr_cd_periodo = pr.ppr_cd_periodo
--			AND pr2.ppr_nome_motorista = pr.ppr_nome_motorista
--			AND pr2.ppr_lcto_cd_lancamento IS NULL
--			);
--end
    
  
end 


--Adicionado por Saulo Barros em 21/07/2025 para excluir lançamentos que foram cancelados
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
	and p.ppr_fl_desconto = 0
	and mtn_cd_operacao = @Operacao
	and p.ppr_lcto_cd_lancamento is not null
	and not exists (select 
						1 
					from 
						vw_lancamentos_manuais_aprovados l 
					where 
						l.tlm_cd_cliente = @clienteid
						and p.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
						and l.Operacao = 'LM'
                        and l.tlm_cd_cliente_transportadora = @IdCliTransportadora
					);



--etapa apra cancelar os lancamentos da flex do motoristas que foram removidos do desconto a partir da tela de gerenciar motorista. 
--update b
--set ppr_in_excluido = 
--                    case 
--                        when alm_ds_status <> 'Aprovado' 
--                            then 1
--                        when mot_desconto_flex_frota = 0 
--                            then 1
--                        else 0 end

--from tb_pag_espelhos as a

--inner join tb_pgto_periodo_rota as b
--on a.mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs

--inner join tb_motorista as mot
--on a.mtn_cd_motorista = mot.mot_cd_usuario

--inner join vw_lancamentos_manuais
--on ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual

--where mtn_cd_pgto_periodo = @CodPeriodoPagamento
--and tlm_cd_tipo = 440
  
  
--end  
  
  
--select   
--  ppr_cd_rota  
-- ,ppr_nome_motorista  
-- ,ppr_vl_base  
--,ppr_vl_paradas  
--,ppr_vl_risco  
--,ppr_vl_ajudante  
--,ppr_vl_dom_fer  
--,ppr_vl_lancamentos  
--,ppr_vl_total_km_real  
--,ppr_vl_total_km_minimo  
--,ppr_vl_total_km_prefatura  
--,ppr_vl_total  
--,ppr_bfm_vl_FaixaKM  
--,ppr_bfm_vl_adicional_domingo  
--,ppr_bfm_vl_adicional_ciclo_pm  
--,ppr_bfm_vl_paradas0_60  
--,ppr_bfm_vl_paradas61_75  
--,ppr_bfm_vl_paradas76_85  
--,ppr_bfm_vl_paradas86_90  
--,ppr_bfm_vl_paradas_acima_90  
--,ppr_bfm_vl_adicional_ajudante  
--,ppr_bfm_vl_adicional_risco  
--,ppr_bfm_vl_insucesso  
--,ppr_lcto_vl_risco_ajudante  
--,ppr_lcto_vl_apoio  
--,ppr_vl_bonus  
--,ppr_vl_pm  
--,ppr_vl_valor_frete  
--,ppr_vl_pedagio  
--,ppr_vl_aluguel  
--,ppr_vl_desconto  
--,ppr_vl_recarga  
--,ppr_vl_pontos  
--,ppr_vl_pacotes  
--,ppr_vl_desconto_flex_rota  
--,ppr_vl_desconto_cartao_flex_rota  
  
-- ,(isnull(ppr_vl_base  ,0)  
--  +isnull(ppr_vl_paradas  ,0)  
--  +isnull(ppr_vl_dom_fer  ,0)  
--  +isnull(ppr_vl_risco  ,0)  
--  +isnull(ppr_vl_ajudante ,0)  
--  +isnull(ppr_vl_lancamentos ,0)  
--  +isnull(ppr_vl_bonus  ,0)  
--  +isnull(ppr_vl_recarga  ,0)  
--  +isnull(ppr_vl_aluguel  ,0)  
--  +isnull(ppr_vl_pedagio  ,0)   
--  )  
-- ,ppr_vl_total  
  
--from tb_pgto_periodo_rota  
--where ppr_cd_periodo = 534  
--and ppr_nome_motorista = 'Adriano Rodrigues da Silva'  
--and (isnull(ppr_vl_base  ,0)  
--  +isnull(ppr_vl_paradas  ,0)  
--  +isnull(ppr_vl_dom_fer  ,0)  
--  +isnull(ppr_vl_risco  ,0)  
--  +isnull(ppr_vl_ajudante ,0)  
--  +isnull(ppr_vl_lancamentos ,0)  
--  +isnull(ppr_vl_bonus  ,0)  
--  +isnull(ppr_vl_recarga  ,0)  
--  +isnull(ppr_vl_aluguel  ,0)  
--  +isnull(ppr_vl_pedagio  ,0)   
--  )  
-- <>  
-- ppr_vl_total  
   
-- delete from tb_pgto_periodo_rota where ppr_cd_rota  = '222906027' and ppr_cd_periodo = 534  
 --delete from tb_pgto_periodo_rota where ppr_cd_pagamento_rota =3340739  
  
-----------------------------lancamentos de apoio. lanca o desconto do motorista e credita para o apiador  
  
  
-- select ppr_lcto_cd_lancamento from #lancamento_sem_rota_pf   
-- where ppr_cd_rota = '225712621'  
  
-- select * from #lancamento_sem_rota_pf  
  
-- select * from #TempLancamentoManual   where  tlm_cd_rota = '222906027'  
  
-- select ppr_cd_motorista_nfs,ppr_lcto_cd_lancamento,ppr_vl_lancamentos,* from tb_pgto_periodo_rota where ppr_cd_periodo = 534 and ppr_Cd_rota = '225712621'    
GO
