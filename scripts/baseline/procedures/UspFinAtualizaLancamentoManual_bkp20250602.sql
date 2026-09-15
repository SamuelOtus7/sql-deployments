-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManual_bkp20250602
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManual_bkp20250602]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[UspFinAtualizaLancamentoManual_bkp20250602]  (
    @CodPeriodoPagamento VARCHAR(50),
    @idrota VARCHAR(50) = NULL
    )
AS

	declare
      @IdTransportadora int
    --, @CodPeriodoPagamento int = 563
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
			set @Motorista = (select distinct NomeMotorista from tb_ml_rotas (NOLOCK) where idrota = @idrota and excluido = 0)
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

						select lst_cd_lista from tb_lista (NOLOCK)
						where lst_nm_lista = 'Clientes transportadoras'
						and lst_ds_label = 'Mercado Livre'
						and lst_cd_cliente in (
												select pgp_cd_cliente
												from [tb_pgto_periodo] as a (NOLOCK)
												left join tb_clientes as b (NOLOCK)
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
												)
												)



	set @clienteid = (
						select pgp_cd_cliente
						from [tb_pgto_periodo] as a (NOLOCK)
						left join tb_clientes as b (NOLOCK)
						on a.pgp_cd_cliente = cli_cd_codigo_cliente
						where pgp_cd_periodo  = @CodPeriodoPagamento
						)

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
                    ,trim(cast(tlm_cd_rota as varchar(50))) as IdRota
                    ,tlm_dh_referencia as Data
                    ,case when TIP.plm_nm_tipo = 'Apoio' then tlm_ds_motorista_apoio else tlm_cd_motorista end ppr_nome_motorista
                    ,usr_cd_usuario
                    ,cast(tlm_dh_referencia as date) ppr_data_referencia
                    
                    ,case 
						when alm_ds_status = 'Aprovado' then isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
																+ case when TIP.plm_nm_tipo = 'Apoio' then tlm_vl_valor_apoio else (-1 * isnull(tlm_vl_valor_descontos,0)) end
						else 0 end
                    AS ppr_vl_lancamentos
                    
                    ,case 
						when alm_ds_status = 'Aprovado' then isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
																+ case when TIP.plm_nm_tipo = 'Apoio' then tlm_vl_valor_apoio else (-1 * isnull(tlm_vl_valor_descontos,0)) end
						else 0 end ppr_vl_total
                    ,alm_ds_status 
                    ,TIP.plm_nm_tipo
					,a.tlm_cd_service_center ppr_base_principal
                from [dbo].[tb_lancamentos_manuais] as a (NOLOCK)
                inner join [tb_aprovacao_lancamento_manual] as APV (NOLOCK)
                on alm_cd_lancamento_manual = tlm_cd_lancamento_manual

                LEFT JOIN [dbo].[tb_tipos_lancamentos_manuais] AS TIP (NOLOCK) ON TIP.plm_cd_tipo_lancamento_manual = a.tlm_cd_tipo
                
                left join tb_usuario as b (NOLOCK)
                on case when TIP.plm_nm_tipo = 'Apoio' then tlm_ds_motorista_apoio else tlm_cd_motorista end = b.usr_nm_usuario
                and cli_cd_codigo_cliente = tlm_cd_cliente                
                where tlm_in_ativo = 1
        
                and (@idrota is null or tlm_cd_rota = @idrota)
                and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final
                and tlm_cd_cliente = @clienteid
 
                union

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
                    
                    ,case 
						when alm_ds_status = 'Aprovado' then isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
																+ case when TIP.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0))  else (-1 * isnull(tlm_vl_valor_descontos,0)) end
						else 0 end
                    AS ppr_vl_lancamentos
                    
                    ,case 
						when alm_ds_status = 'Aprovado' then isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
																+ case when TIP.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end
						else 0 end ppr_vl_total
                    ,alm_ds_status 
                    ,TIP.plm_nm_tipo
					,a.tlm_cd_service_center ppr_base_principal
                from [dbo].[tb_lancamentos_manuais] as a (NOLOCK)
                inner join [tb_aprovacao_lancamento_manual] as APV (NOLOCK)
                on alm_cd_lancamento_manual = tlm_cd_lancamento_manual

                LEFT JOIN [dbo].[tb_tipos_lancamentos_manuais] AS TIP (NOLOCK) ON TIP.plm_cd_tipo_lancamento_manual = a.tlm_cd_tipo

                left join tb_usuario as b (NOLOCK)
                on a.tlm_cd_motorista = b.usr_nm_usuario
                and cli_cd_codigo_cliente = tlm_cd_cliente

                where tlm_in_ativo = 1
        
                and (@idrota is null or tlm_cd_rota = @idrota)
                and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final
                and tlm_cd_cliente = @clienteid
                and TIP.plm_nm_tipo = 'Apoio'
                
                ) LNC
            left join tb_pag_espelhos as esp
            on esp.mtn_cd_motorista = LNC.usr_cd_usuario
            and esp.mtn_cd_pgto_periodo =  @CodPeriodoPagamento
            
			--Regra criada por Saulo Barros em 09/05/2025 para considerar para 50+ a chave Periodo, Motorista e SVC
			and (
				(@clienteid in (11,1,56) and LNC.ppr_base_principal = esp.mtn_base_principal)
				or
				@clienteid not in (11,1,56)
			)

            where esp.mtn_cd_status in (34,228,38);
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

where 1=1 
and a.ppr_cd_periodo = @CodPeriodoPagamento
and esp.mtn_cd_status in (34,228,38)
and ts.idrota is null
--and b.ppr_cd_rota is null
and plm_nm_tipo <> 'Apoio';


--delete from tb_pgto_periodo_rota where ppr_cd_periodo = 534
--delete from tb_pag_espelhos where mtn_cd_pgto_periodo = 534

merge into tb_pgto_periodo_rota as a
using #lancamento_sem_rota_pf as b
on a.ppr_cd_rota = b.ppr_cd_rota
and a.ppr_cd_periodo = b.ppr_cd_periodo
and a.ppr_cd_motorista_nfs = b.ppr_cd_motorista_nfs
and a.ppr_lcto_cd_lancamento = b.ppr_lcto_cd_lancamento

when matched then
update set
         ppr_vl_lancamentos = b.ppr_vl_lancamentos
        ,ppr_vl_total = b.ppr_vl_total
when not matched then
insert ( ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho
        , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido
        ,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal)

values (b.ppr_cd_rota, b.ppr_nome_motorista, b.ppr_data_referencia, b.ppr_lcto_observacao, b.ppr_vl_lancamentos, b.ppr_vl_total, b.ppr_cd_periodo, b.ppr_cd_motorista_nfs
        ,b.ppr_dh_criacao, b.ppr_cd_usr_criacao, b.ppr_dh_modificacao, b.ppr_cd_usr_modificacao, b.ppr_in_ativo, b.ppr_in_excluido
        ,b.ppr_cd_motorista,b.ppr_cd_motorista_nfs, b.ppr_lcto_cd_lancamento, b.ppr_cd_service_center);


-----------------------------lancamentos manuais com rotas desta quinzena e valor de apoio

update a
set ppr_vl_lancamentos = b.ppr_vl_lancamentos

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
    
    left join #lancamento_sem_rota_pf as C
    on a.mtn_cd_motorista_nfs = c.ppr_cd_motorista_nfs
    and a.tlm_cd_rota = ppr_Cd_rota
	and ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual

    where 1=1
    -- and tlm_cd_lancamento_manual not in (select * from #lancamento_sem_rota_pf )
     --and tlm_cd_rota = 222288942
    group by a.tlm_cd_rota, a.ppr_cd_periodo,a.mtn_cd_motorista_nfs,c.ppr_cd_rota,a.tlm_cd_lancamento_manual

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

from tb_pgto_periodo_rota as a

inner join (

    select 
         a.tlm_cd_rota as IdRota
        ,a.ppr_cd_periodo
        ,a.mtn_cd_motorista_nfs
        ,sum(a.ppr_vl_lancamentos) as ppr_vl_lancamentos	
        ,sum(a.ppr_vl_total) as ppr_vl_total

    from  #TempLancamentoManual as a
    
    left join #lancamento_sem_rota_pf as C
    on a.mtn_cd_motorista_nfs = c.ppr_cd_motorista_nfs
    and a.tlm_cd_rota = ppr_Cd_rota
	and ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual

    where 1=1
    -- and tlm_cd_lancamento_manual not in (select * from #lancamento_sem_rota_pf )
    --  and tlm_cd_rota = 218489748
    group by a.tlm_cd_rota, a.ppr_cd_periodo,a.mtn_cd_motorista_nfs,c.ppr_cd_rota

 ) as b
on  a.ppr_cd_rota = b.IdRota
and a.ppr_cd_periodo = b.ppr_cd_periodo
and a.ppr_cd_motorista_nfs = b.mtn_cd_motorista_nfs
and a.ppr_lcto_cd_lancamento is null

where 1=1
and a.ppr_cd_periodo = @CodPeriodoPagamento



update tb_pgto_periodo_rota
set 
    ppr_vl_total = (isnull(ppr_vl_base		,0)
                    +isnull(ppr_vl_paradas		,0)
                    +isnull(ppr_vl_dom_fer		,0)
                    +isnull(ppr_vl_risco		,0)
                    +isnull(ppr_vl_ajudante	,0)
                    +isnull(ppr_vl_lancamentos	,0)
                    +isnull(ppr_vl_bonus		,0)
                    +isnull(ppr_vl_recarga		,0)
                    +isnull(ppr_vl_aluguel		,0)
                    +isnull(ppr_vl_pedagio		,0)	
					 +isnull(ppr_vl_desconto		,0)	
                    )

where ppr_cd_periodo = @CodPeriodoPagamento
-- and ppr_cd_pgto_espelho = 499870



update a
set mtn_vl_nfs = total
from tb_pag_espelhos a 
inner join (
    select sum(ppr_vl_total) as total
    ,ppr_cd_pgto_espelho
    from tb_pgto_periodo_rota as a
    where  ppr_cd_periodo = @CodPeriodoPagamento 
    and ppr_in_excluido = 0
    group by ppr_cd_pgto_espelho
) as b
on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 




;



-- insere valor de apoio

--insert into tb_pgto_periodo_rota (ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho
--        , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido
--        ,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal)

--select 
--	cast(a.IdRota as varchar(50)) as ppr_cd_rota
--    ,a.ppr_nome_motorista
--    ,a.data as ppr_data_referencia
--    ,a.tlm_ds_observacao as ppr_lcto_observacao
--    ,a.ppr_vl_lancamentos
--    ,a.ppr_vl_total
--    ,a.ppr_cd_periodo
--    ,esp.mtn_cd_motorista_nfs ppr_cd_pgto_espelho
--    ,getdate() ppr_dh_criacao
--    ,7 ppr_cd_usr_criacao
--    ,getdate() ppr_dh_modificacao
--    ,7 ppr_cd_usr_modificacao
--    ,1 ppr_in_ativo
--    ,0 ppr_in_excluido
--    ,a.usr_cd_usuario as ppr_cd_motorista
--    ,a.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs
--    ,tlm_cd_lancamento_manual as ppr_lcto_cd_lancamento
--    ,r.ServiceCenter as ppr_cd_service_center
    
--from #TempLancamentoManual as a

--left join tb_pgto_periodo_rota as b (NOLOCK)
--on cast(a.IdRota as varchar(50)) = b.ppr_cd_rota
--and a.ppr_cd_periodo = b.ppr_cd_periodo
--and mtn_cd_motorista_nfs = b.ppr_cd_motorista_nfs

--inner join tb_ml_rotas as r (NOLOCK)
--on r.idrota = a.idrota
--and r.Excluido = 0 

--left join tb_pag_espelhos as esp (NOLOCK)
--on esp.mtn_cd_motorista = r.usuarioda
--and mtn_cd_pgto_periodo = a.ppr_cd_periodo

--where 1=1 
--and a.ppr_cd_periodo = @CodPeriodoPagamento
--and esp.mtn_cd_status in (34,228,38)
--and ppr_cd_rota is null
--and plm_nm_tipo = 'Apoio';

--end


--select 
--	 ppr_cd_rota
--	,ppr_nome_motorista
--	,ppr_vl_base
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

--	,(isnull(ppr_vl_base		,0)
--	 +isnull(ppr_vl_paradas		,0)
--	 +isnull(ppr_vl_dom_fer		,0)
--	 +isnull(ppr_vl_risco		,0)
--	 +isnull(ppr_vl_ajudante	,0)
--	 +isnull(ppr_vl_lancamentos	,0)
--	 +isnull(ppr_vl_bonus		,0)
--	 +isnull(ppr_vl_recarga		,0)
--	 +isnull(ppr_vl_aluguel		,0)
--	 +isnull(ppr_vl_pedagio		,0)	
--	 )
--	,ppr_vl_total

--from tb_pgto_periodo_rota
--where ppr_cd_periodo = 534
--and ppr_nome_motorista = 'Adriano Rodrigues da Silva'
--and (isnull(ppr_vl_base		,0)
--	 +isnull(ppr_vl_paradas		,0)
--	 +isnull(ppr_vl_dom_fer		,0)
--	 +isnull(ppr_vl_risco		,0)
--	 +isnull(ppr_vl_ajudante	,0)
--	 +isnull(ppr_vl_lancamentos	,0)
--	 +isnull(ppr_vl_bonus		,0)
--	 +isnull(ppr_vl_recarga		,0)
--	 +isnull(ppr_vl_aluguel		,0)
--	 +isnull(ppr_vl_pedagio		,0)	
--	 )
--	<>
--	ppr_vl_total
	
--	delete from tb_pgto_periodo_rota where ppr_cd_rota  = '222906027' and ppr_cd_periodo = 534
	--delete from tb_pgto_periodo_rota where ppr_cd_pagamento_rota =3340739

-----------------------------lancamentos de apoio. lanca o desconto do motorista e credita para o apiador


-- select ppr_lcto_cd_lancamento from #lancamento_sem_rota_pf 
-- where ppr_cd_rota = '225712621'

-- select * from #lancamento_sem_rota_pf

-- select * from #TempLancamentoManual   where  tlm_cd_rota = '222906027'

-- select ppr_cd_motorista_nfs,ppr_lcto_cd_lancamento,ppr_vl_lancamentos,* from tb_pgto_periodo_rota where ppr_cd_periodo = 534 and ppr_Cd_rota = '225712621'  
GO
