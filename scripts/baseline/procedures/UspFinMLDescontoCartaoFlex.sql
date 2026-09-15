-- ============================================================
-- BASELINE: dbo.UspFinMLDescontoCartaoFlex
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinMLDescontoCartaoFlex]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinMLDescontoCartaoFlex]   
 (  
 @codperiodopagamento int   
 ) as  
  
declare @UsuarioCriacao int = 7  
--declare @codperiodopagamento int = 718  
  
  
drop table if exists #pgto_descontos  
select distinct  
   mtn_cd_pgto_periodo as ppr_cd_periodo  
 , mtn_nome_motorista as ppr_nome_motorista  
 , pgp_dt_inicio as ppr_data_referencia  
 , 'Desconto de utilização do cartão Flex' as ppr_lcto_observacao  
 , a.mtn_cd_motorista_nfs ppr_cd_pgto_espelho  
 , getdate() ppr_dh_criacao  
 , @UsuarioCriacao ppr_cd_usr_criacao  
 , getdate() ppr_dh_modificacao  
 , @UsuarioCriacao ppr_cd_usr_modificacao  
 , 1 ppr_in_ativo  
 , 0 ppr_in_excluido  
 , a.mtn_cd_motorista ppr_cd_motorista  
 , a.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs  
 , -10 ppr_vl_desconto_cartao_flex_rota  
 , -10 ppr_vl_total  
 , a.mtn_base_principal as ppr_base_principal  
  
into #pgto_descontos  
  
from tb_pag_espelhos as a  
  
inner join tb_pgto_periodo as per  
on a.mtn_cd_pgto_periodo = per.pgp_cd_periodo  
  
-- inner join tb_fin_base_frete_adicional_motorista as b  
-- on a.mtn_base_principal = b.bfa_cd_service_center  
--     and per.pgp_cd_cliente = b.bfa_cd_transportadora  
  
where mtn_cd_pgto_periodo = @codperiodopagamento  
-- and mtn_base_principal in ('SSP10','ssp12','ssp28','ssp04')  
and pgp_cd_cliente  = 37  
and mtn_cd_motorista_nfs in (
                 select ppr_cd_motorista_nfs 
                 from tb_pgto_periodo_rota as a
                 inner join tb_lancamentos_manuais as b
                 on a.ppr_lcto_cd_lancamento = b.tlm_cd_lancamento_manual  
                 and tlm_cd_tipo = 440  
                 where ppr_cd_periodo = @codperiodopagamento
                 group by ppr_cd_motorista_nfs
 )



 --sp_rename 'tb_pgto_lancamento_desc_cartao_flex_frota.ppr_cd_motorista','pcf_cd_motorista'

 --create table tb_pgto_lancamento_desc_cartao_flex_frota  
 --(  
 --pcf_cd_lc_cartao int identity(1,1) primary key,
 --pcf_cd_periodo int not null,
 --pcf_cd_motorista_nfs int not null,
 --pcf_vl_desconto_cartao_flex_frota decimal(18,2) not null,
 --pcf_vl_total decimal(18,2) not null,
 --pcf_dh_criacao datetime not null default getdate(),
 --pcf_cd_usr_criacao int not null default 7,
 --pcf_dh_modificacao datetime not null default getdate(),
 --pcf_cd_usr_modificacao int not null default 7,
 --pcf_in_ativo bit not null default 1,
 --pcf_in_excluido bit not null default 0,
 --pcf_base_principal varchar(20) null,
 --pcf_lcto_observacao varchar(255) null,
 --pcf_nome_motorista varchar(100) null,
 --pcf_cd_motorista int null,
 --pcf_data_referencia date

 --);


insert into tb_pgto_lancamento_desc_cartao_flex_frota
(pcf_cd_periodo, pcf_cd_motorista_nfs, pcf_vl_desconto_cartao_flex_frota, pcf_vl_total, pcf_dh_criacao, pcf_cd_usr_criacao
, pcf_dh_modificacao, pcf_cd_usr_modificacao, pcf_in_ativo, pcf_in_excluido, pcf_base_principal
, pcf_lcto_observacao, pcf_nome_motorista, pcf_cd_motorista, pcf_data_referencia)
select
  p.ppr_cd_periodo,
  p.ppr_cd_motorista_nfs,
  p.ppr_vl_desconto_cartao_flex_rota,
  p.ppr_vl_total,
  p.ppr_dh_criacao,
  p.ppr_cd_usr_criacao,
  p.ppr_dh_modificacao,
  p.ppr_cd_usr_modificacao,
  p.ppr_in_ativo,
  p.ppr_in_excluido,
  p.ppr_base_principal,
  p.ppr_lcto_observacao,
  p.ppr_nome_motorista,
  p.ppr_cd_motorista,
  p.ppr_data_referencia

from #pgto_descontos as p
left join tb_pgto_lancamento_desc_cartao_flex_frota as a
on p.ppr_cd_periodo = a.pcf_cd_periodo
    and p.ppr_cd_motorista_nfs = a.pcf_cd_motorista_nfs
      
where a.pcf_cd_lc_cartao is null;
  
-- Insere novos lançamentos ou altera o que já foi incluido (sem rotas)  
merge into tb_pgto_periodo_rota as a  
using tb_pgto_lancamento_desc_cartao_flex_frota as p on a.ppr_cd_periodo = p.pcf_cd_periodo  
    and a.ppr_cd_motorista_nfs = p.pcf_cd_motorista_nfs
    and a.ppr_cd_lc_cartao_flex = p.pcf_cd_lc_cartao

when matched then  
update set  
  ppr_vl_desconto_cartao_flex_rota = p.pcf_vl_desconto_cartao_flex_frota  
  ,ppr_vl_total = p.pcf_vl_total  
  
when not matched then  
insert (   
  ppr_cd_lc_cartao_flex
  ,ppr_nome_motorista  
  ,ppr_data_referencia  
  ,ppr_lcto_observacao  
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
  ,ppr_base_principal  
  ,ppr_vl_desconto_cartao_flex_rota  
  )  
values (  
  pcf_cd_lc_cartao
  ,p.pcf_nome_motorista  
  ,p.pcf_data_referencia  
  ,p.pcf_lcto_observacao  
  ,p.pcf_vl_total  
  ,p.pcf_cd_periodo  
  ,p.pcf_cd_motorista_nfs   
  ,p.pcf_dh_criacao  
  ,p.pcf_cd_usr_criacao  
  ,p.pcf_dh_modificacao  
  ,p.pcf_cd_usr_modificacao  
  ,p.pcf_in_ativo  
  ,p.pcf_in_excluido  
  ,p.pcf_cd_motorista  
  ,p.pcf_cd_motorista_nfs  
  ,p.pcf_base_principal  
  ,p.pcf_vl_desconto_cartao_flex_frota  
);  
  
  
  
  
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
   ppr_cd_periodo = @codperiodopagamento  
            and ppr_in_excluido = 0  
   and ppr_fl_desconto = 0  
  group by ppr_cd_pgto_espelho  
 ) as b  
 on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho
GO
