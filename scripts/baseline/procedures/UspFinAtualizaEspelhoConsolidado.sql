-- ============================================================
-- BASELINE: dbo.UspFinAtualizaEspelhoConsolidado
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaEspelhoConsolidado]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspFinAtualizaEspelhoConsolidado]  
(  
 @periodo int  
) as  
  
-- select  
-- ppr_cd_rota, count(*)   
-- from tb_pgto_periodo_rota   
-- where ppr_cd_periodo = 303   
-- and isnumeric(ppr_cd_rota) = 0  
-- group by ppr_cd_rota  
-- having count(*) > 1  
  
-- declare @periodo int = 303  
declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @periodo)  
declare @Operacao int = (select   
         lst_cd_lista   
        from   
         tb_lista with(nolock)  
        where   
         lst_nm_lista = 'Operações Marketplace'   
         and lst_ds_valor = 'LM'   
         and lst_cd_cliente = @CodigoCliente  
        )  
  
--pega apenas rotas dos espelhos em aberto de LM  
drop table if exists #pgto_periodo_rota  
select  
 r.ppr_cd_motorista  
 ,r.ppr_nome_motorista  
 ,r.ppr_base_principal  
 ,r.ppr_cd_periodo  
 ,r.ppr_fl_desconto  
 ,r.ppr_cd_motorista_nfs  
 ,r.ppr_vl_total  
 into #pgto_periodo_rota  
from  
 tb_pgto_periodo_rota r with(nolock)  
 join tb_pag_espelhos e with(nolock) on r.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs  
 join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista   
          and l.lst_nm_lista = 'Status motorista nfs'   
          and lst_cd_fechado=0  
where  
 e.mtn_cd_pgto_periodo = @periodo  
 and e.mtn_cd_operacao = @Operacao  
 and r.ppr_in_excluido = 0  
  
  
if @CodigoCliente = 1  
BEGIN  
    UPDATE  
  r  
    SET   
  r.ppr_base_principal = e.mtn_base_principal  
  -- SELECT r.ppr_base_principal , e.mtn_base_principal, *   
 FROM   
  tb_pgto_periodo_rota r  
  INNER JOIN tb_pag_espelhos e ON e.mtn_cd_pgto_periodo = r.ppr_cd_periodo   
        AND e.mtn_cd_motorista_nfs = r.ppr_cd_motorista_nfs  
    WHERE   
        r.ppr_cd_periodo = @periodo  
  -- AND r.ppr_cd_motorista_nfs = 543355   
        AND r.ppr_cd_rota IS NULL   
        AND r.ppr_in_excluido = 0   
        AND r.ppr_base_principal IS NULL  
  AND e.mtn_base_principal IS NOT NULL  
        AND r.ppr_tipo_rota IS NULL   
        AND r.ppr_nm_cidade IS NULL  
  and r.ppr_fl_desconto = 0  
  and e.mtn_cd_operacao = @Operacao  
END  
  
  
--Para 50+ precisa considerar a chave motorista e svc  
if @CodigoCliente in (11,1,56)  
begin  
 drop table if exists #tb_pgto_periodo_rota_50mais  
 select   
  ppr_base.ppr_base_principal as base_principal_espelho  
  ,ppr_rota.*  
  into #tb_pgto_periodo_rota_50mais  
 from   
  #pgto_periodo_rota as ppr_rota  
  join (  
    select   
     *  
     ,row_number() over(partition by ppr_cd_motorista, ppr_base_principal order by qtd desc) ordem  
    from  
     (  
     select  
      ppr_cd_motorista  
      ,ppr_base_principal  
      ,ppr_cd_periodo  
      ,count(*) qtd  
     from   
      #pgto_periodo_rota  
     where   
      ppr_cd_periodo = @periodo  
      and ppr_fl_desconto = 0  
     group by   
      ppr_cd_motorista,   
      ppr_base_principal,  
      ppr_cd_periodo  
     ) as a  
   ) as ppr_base on ppr_rota.ppr_cd_motorista = ppr_base.ppr_cd_motorista  
      and ppr_rota.ppr_base_principal = ppr_base.ppr_base_principal  
      and ppr_rota.ppr_cd_periodo = ppr_base.ppr_cd_periodo  
 where   
  ordem = 1  
  and ppr_fl_desconto = 0  
  
 drop table if exists #pag_espelhos_50mais  
 select  
  ppr_cd_motorista as mtn_cd_motorista  
  ,ppr_nome_motorista as mtn_nome_motorista  
  ,ppr_cd_periodo as mtn_cd_pgto_periodo  
  ,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs  
  ,count(*) as mtn_qt_rotas  
  ,bss_cd_base as mtn_cd_base  
  ,base_principal_espelho mtn_base_principal  
  into #pag_espelhos_50mais  
 from   
  #tb_pgto_periodo_rota_50mais as a  
  left join [tb_pgto_periodo] as periodo on a.ppr_cd_periodo = periodo.pgp_cd_periodo  
  left join tb_bases as c on a.base_principal_espelho = case   
         when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla  
         when bss_ds_marketplace = 'shopee' then bss_ds_nome  
         else bss_ds_sigla end  
        and periodo.pgp_cd_cliente = c.bss_cod_cliente  
  
 WHERE   
  ppr_cd_periodo = @periodo  
 group by    
  ppr_cd_motorista,  
  ppr_cd_periodo,  
  periodo.pgp_cd_cliente,  
  bss_cd_base,ppr_nome_motorista,  
  base_principal_espelho  
  
 update   
  a  
 set  
  a.mtn_vl_nfs = b.mtn_vl_nfs  
  ,a.mtn_qt_rotas = b.mtn_qt_rotas  
 from   
  tb_pag_espelhos as a  
  join #pag_espelhos_50mais as b on a.mtn_cd_motorista = b.mtn_cd_motorista  
        and a.mtn_base_principal = b.mtn_base_principal  
        and a.mtn_cd_pgto_periodo = b.mtn_cd_pgto_periodo  
 where   
  a.mtn_cd_pgto_periodo = @periodo  
  
end  
else  
begin  

  
 drop table if exists #tb_pgto_periodo_rota  
 select   
  ppr_base.ppr_base_principal as base_principal_espelho  
  --,ppr_rota.*  
    ,ppr_rota.ppr_cd_motorista	
  ,isnull(usu.usr_nm_usuario,ppr_rota.ppr_nome_motorista) ppr_nome_motorista
  ,ppr_rota.ppr_base_principal	
  ,ppr_rota.ppr_cd_periodo	
  ,ppr_rota.ppr_fl_desconto	
  ,ppr_rota.ppr_cd_motorista_nfs	
  ,ppr_rota.ppr_vl_total


  into #tb_pgto_periodo_rota  
 from #pgto_periodo_rota as ppr_rota  
 inner join   
   (  
    select *  
    ,row_number() over(partition by ppr_cd_motorista order by qtd desc) ordem  
    from(  
     select  
      ppr_cd_motorista  
      ,ppr_base_principal  
      ,ppr_cd_periodo  
      ,count(*) qtd  
     from #pgto_periodo_rota  
     where   
      ppr_cd_periodo = @periodo  
      and ppr_fl_desconto = 0  
     group by ppr_cd_motorista, ppr_base_principal,ppr_cd_periodo  
    ) as a  
   ) as ppr_base  
 on ppr_rota.ppr_cd_motorista = ppr_base.ppr_cd_motorista  
 and ppr_rota.ppr_cd_periodo = ppr_base.ppr_cd_periodo  

 left  join tb_usuario as usu 
    on ppr_rota.ppr_cd_motorista = usu.usr_cd_usuario 
    and usu.usr_in_ativo = 1
    and ppr_rota.ppr_nome_motorista <> usu.usr_nm_usuario

 where  
  ordem = 1  
  and ppr_fl_desconto = 0  
  
  
 -- SELECT base_principal_espelho, * FROM #tb_pgto_periodo_rota  
 -- WHERE ppr_nome_motorista = 'AGNALDO GOMES BARREIROS'  
  
  
 -- SELECT TOP 10 * FROM tb_bases  
 -- WHERE bss_cod_cliente = 27  
 -- AND bss_ds_nome = 'XPT_SP_Itapetininga'  
  
  
 drop table if exists #pag_espelhos  
 select  
   ppr_cd_motorista as mtn_cd_motorista  
  ,ppr_nome_motorista as mtn_nome_motorista  
  ,ppr_cd_periodo as mtn_cd_pgto_periodo  
  
  ,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs  
  ,count(*) as mtn_qt_rotas  
  ,bss_cd_base as mtn_cd_base  
  ,base_principal_espelho mtn_base_principal  
   
  into #pag_espelhos  
  
 from #tb_pgto_periodo_rota as a  
  
 left join [tb_pgto_periodo] as periodo  
 on a.ppr_cd_periodo = periodo.pgp_cd_periodo  
  
 left join tb_bases as c  
 on a.base_principal_espelho = case   
         when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla  
         when bss_ds_marketplace = 'shopee' then bss_ds_nome  
         else bss_ds_sigla end  
 and periodo.pgp_cd_cliente = c.bss_cod_cliente  
  
 WHERE ppr_cd_periodo = @periodo  
 --where ppr_cd_rota = 146941866  
  
 group by  ppr_cd_motorista ,ppr_cd_periodo,periodo.pgp_cd_cliente,bss_cd_base,ppr_nome_motorista,  
 base_principal_espelho;  
  
  
  
 update a  
 set  
  a.mtn_vl_nfs = b.mtn_vl_nfs  
  --Tratamento de espelhos estourando o tipo da coluna tinyint
  ,a.mtn_qt_rotas = case when b.mtn_qt_rotas > 255 then 255 else b.mtn_qt_rotas end
  ,a.mtn_cd_base = b.mtn_cd_base  
  ,a.mtn_base_principal = b.mtn_base_principal  
  
 from tb_pag_espelhos as a  
 inner join #pag_espelhos as b  
 on a.mtn_cd_motorista = b.mtn_cd_motorista  
 and a.mtn_cd_pgto_periodo = b.mtn_cd_pgto_periodo  
  and a.mtn_base_principal = b.mtn_base_principal

 where a.mtn_cd_pgto_periodo = @periodo  
 and mtn_in_excluido  = 0 
end  
  
  
-- Atualiza Descontos  
update   
 e  
set  
 e.mtn_vl_desconto = isnull(ppr_vl_total,0)  
from   
 tb_pag_espelhos e  
 join tb_lista l with(nolock) on e.mtn_cd_status = l.lst_cd_lista   
          and l.lst_nm_lista = 'Status motorista nfs'   
          and lst_cd_fechado=0  
 join (  
  select  
   ppr_cd_motorista_nfs,  
   sum(isnull(ppr_vl_total,0)) ppr_vl_total  
  from  
   #pgto_periodo_rota with(nolock)  
  where  
   ppr_cd_periodo = @periodo  
   and ppr_fl_desconto = 1  
  group by  
   ppr_cd_motorista_nfs  
 ) r on e.mtn_cd_motorista_nfs = r.ppr_cd_motorista_nfs  
where   
 e.mtn_cd_pgto_periodo = @periodo
 and mtn_in_excluido  = 0 


 if @CodigoCliente in (66,68,56,63,69)
 BEGIN
         update  tb_pgto_periodo_rota  
         set ppr_vl_total = (isnull(ppr_vl_base,0)  
         +isnull(ppr_vl_paradas,0)  
         +isnull(ppr_vl_pontos,0)  
         +isnull(ppr_vl_risco,0)  
         +isnull(ppr_vl_ajudante,0)  
         +isnull(ppr_vl_dom_fer,0)  
         +isnull(ppr_vl_lancamentos,0)  
         +isnull(ppr_vl_pedagio,0)  
         +isnull(ppr_vl_aluguel,0)  
         +isnull(ppr_vl_desconto,0)  
         +isnull(ppr_vl_recarga,0)  
         +isnull(ppr_vl_pacotes,0)  
         +isnull(ppr_vl_bonus,0) 
		 + ISNULL(ppr_vl_adicional_KM, 0)
		 + ISNULL(ppr_vl_bonus_ds, 0)
         --+isnull(ppr_vl_insucessos,0)  
         --+case   
         -- when ppr_cd_rota is null or ppr_vl_base is null then ppr_vl_total else 0 end   
         )  
  
   
         from tb_pgto_periodo_rota  
         where ppr_cd_periodo = @periodo  
         and ppr_in_excluido = 0


         
    update 
        a
    set 
        mtn_vl_nfs = isnull(total,0)
    from 
        tb_pag_espelhos a 
        left join (
                select sum(ppr_vl_total) as total
                ,ppr_cd_pgto_espelho
                from tb_pgto_periodo_rota as a
                where  ppr_cd_periodo = @periodo 
                and ppr_in_excluido = 0
                group by ppr_cd_pgto_espelho
        ) as b
        on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 

    where 
        mtn_cd_status in (34,228,38,1298)
        and mtn_cd_pgto_periodo = @periodo
        and mtn_in_excluido  = 0 

	--Criado por Saulo Barros em 28/01/2026
	--Regra: caso tenha sido gerado um espelho para um motorista em um período vinculado apenas a um tipo de contrato
	--	     e este motorista tiver alterado o tipo de contrato, esse espelho que foi gerado deverá ser excluido.
	--		 Realiza este procedimento apenas se o status do espelho estiver em aberto
	--Observação: acrescentando a principio apenas para Rodoprime para validação
	if @CodigoCliente = 61
	begin
		

		--Retorna espelhos que deverão ser excluidos
		drop table if exists #espelhos_exclusao
		select
			mtn_cd_motorista_nfs
			into #espelhos_exclusao
		from
			tb_pgto_periodo pg with(nolock)
			join tb_pag_espelhos p with(nolock) on pg.pgp_cd_periodo = p.mtn_cd_pgto_periodo
			join tb_usuario u with(nolock) on p.mtn_cd_motorista = u.usr_cd_usuario
			join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
		where
			pg.pgp_cd_periodo = @periodo
			and p.mtn_cd_status in (34,228,38,1298)
			and pgp_cd_tipo_contratos is not null
			and mot_ctn_cd_tipo_contrato is not null
			and pgp_cd_tipo_contratos <> -1
			and pgp_cd_tipo_contratos <> m.mot_ctn_cd_tipo_contrato
			and p.mtn_in_excluido = 0

		
		update
			tb_pag_espelhos
		set
			mtn_in_excluido = 1
		where
			mtn_cd_motorista_nfs in (select mtn_cd_motorista_nfs from #espelhos_exclusao)
			and mtn_cd_pgto_periodo = @periodo
			and mtn_cd_status in (34,228,38,1298)
            and mtn_in_excluido  = 0 

		update
			tb_pgto_periodo_rota
		set
			ppr_in_excluido = 1
		where
			ppr_cd_motorista_nfs in (select mtn_cd_motorista_nfs from #espelhos_exclusao)
			and ppr_cd_periodo = @periodo


	end


	--Incluído por saulo barros em 27/02/2026. Precisa ta em todos os clientes (precisa de tempo para testar para outros clientes para não ter impacto)
	if @CodigoCliente = 56
	begin
		--remove espelhos (que não são avulsos) que não possui nenhum lançamento na tb_pgto_periodo_rota
		update
			e
		set
			mtn_in_excluido = 1
		from
			tb_pag_espelhos e
			left join tb_pgto_periodo_rota p on e.mtn_cd_motorista_nfs = p.ppr_cd_motorista_nfs 
													and p.ppr_in_excluido = 0
		where
			e.mtn_cd_pgto_periodo = @periodo
			and e.mtn_cd_status in (34,228,38,1298)
			and e.mtn_in_excluido = 0
			and e.mtn_cd_tipo_espelho <> 95 --Não considera espelho avulso
			and p.ppr_cd_pagamento_rota is null
	end

 END
GO
