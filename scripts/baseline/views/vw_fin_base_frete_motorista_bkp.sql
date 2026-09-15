-- ============================================================
-- BASELINE: dbo.vw_fin_base_frete_motorista_bkp
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_base_frete_motorista_bkp]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  view [dbo].[vw_fin_base_frete_motorista_bkp]  
as  
  
 select  a.*  
  
 from (  
 select   
   base.bfm_cd_base_frete_motorista  
  ,base.bfm_cd_transportadora  
  ,base.bfm_cd_service_center  
  ,bfm_nm_cidade 
  ,base.bfm_cd_tipo_veiculo  
  ,base.bfm_vl_inicio_faixa  
  ,base.bfm_vl_fim_faixa  
  ,base.bfm_vl_frete  
  ,base.bfm_vl_frete_pm  
  ,base.bfm_vl_frete_fixo  
  ,base.bmf_cd_tipo_contrato  
  ,base.bfm_cd_codigo_cliente  
  ,base.bfm_vl_domfer_am  
  ,base.bfm_vl_domfer_pm  
  ,base.bfm_data_inicio_vigencia  
  ,base.bfm_data_fim_vigencia  
  ,base.bfm_nm_regiao  
  ,base.bfm_cd_operacao  
  ,lista.lst_ds_valor Operacao  
  
 from tb_fin_base_frete_motorista  as base  
  join tb_lista lista with(nolock) on base.bfm_cd_operacao = lista.lst_cd_lista  
    

 where base.bfm_cd_transportadora = 61  
  
 ) as a  
  
 left join  
  
 (  
  
  
 select  
   base.bfm_cd_base_frete_motorista  
   
  
 from  
  tb_fin_base_frete_motorista base with(nolock)  
  join tb_lista lista with(nolock) on base.bfm_cd_operacao = lista.lst_cd_lista  
  left join (  
    SELECT sigla  
      ,bss_cod_cliente  
      ,bss_ds_sigla  
      ,cid_cd_municipio  
      ,cid_ds_cidade  
      ,NomeMunicipio  
      ,NomeDistrito  
  
    FROM [dbo].[tb_codigos_cidades] as a  
    inner join tb_ibge_distritos as b  
    on  a.cid_cd_municipio = b.Municipio  
    inner join [tb_estados_ibge] as c  
    on a.cid_cd_estado = c.ibge  
    inner join tb_bases as d  
    on c.sigla = bss_ds_estado  
    where bss_cod_cliente = 61  
        
  ) as b  
  on bfm_cd_transportadora = bss_cod_cliente  
  and bfm_cd_service_center  = bss_ds_sigla  
  and bfm_nm_cidade = NomeMunicipio  
  
 where base.bfm_cd_transportadora = 61  
 and b.NomeDistrito IS NOT NULL  
  
 ) as b  
 on a.bfm_cd_base_frete_motorista = b.bfm_cd_base_frete_motorista  
  
 where b.bfm_cd_base_frete_motorista is null  
 -- and a.bfm_cd_service_center = 'EBA14'  
  
 union all  
  
  
  
 select  
   base.bfm_cd_base_frete_motorista  
  ,base.bfm_cd_transportadora  
  ,base.bfm_cd_service_center  
  --,b.NomeDistrito as bfm_nm_cidade   
  ,coalesce(CidadeFilho,b.NomeDistrito) as bfm_nm_cidade
  --,b.NomeDistrito  
  --,base.bfm_nm_cidade  
  ,base.bfm_cd_tipo_veiculo  
  ,base.bfm_vl_inicio_faixa  
  ,base.bfm_vl_fim_faixa  
  ,base.bfm_vl_frete  
  ,base.bfm_vl_frete_pm  
  ,base.bfm_vl_frete_fixo  
  ,base.bmf_cd_tipo_contrato  
  ,base.bfm_cd_codigo_cliente  
  ,base.bfm_vl_domfer_am  
  ,base.bfm_vl_domfer_pm  
  ,base.bfm_data_inicio_vigencia  
  ,base.bfm_data_fim_vigencia  
  ,base.bfm_nm_regiao  
  ,base.bfm_cd_operacao  
  ,lista.lst_ds_valor Operacao  
  
 from  
  tb_fin_base_frete_motorista base with(nolock)  
  join tb_lista lista with(nolock) on base.bfm_cd_operacao = lista.lst_cd_lista  
  
  left join tb_fin_Cidades_DePara as cid
    on bfm_cd_service_center = base
    and bfm_nm_cidade = CidadePai
    and cid.idcliente = bfm_cd_transportadora

  left join (  
    SELECT sigla  
      ,bss_cod_cliente  
      ,bss_ds_sigla  
      ,cid_cd_municipio  
      ,cid_ds_cidade  
      ,NomeMunicipio  
      ,NomeDistrito  
  
    FROM [dbo].[tb_codigos_cidades] as a  
    inner join tb_ibge_distritos as b  
    on  a.cid_cd_municipio = b.Municipio  
    inner join [tb_estados_ibge] as c  
    on a.cid_cd_estado = c.ibge  
    inner join tb_bases as d  
    on c.sigla = bss_ds_estado  
    where bss_cod_cliente = 61  
        
  ) as b  
  on bfm_cd_transportadora = bss_cod_cliente  
  and bfm_cd_service_center  = bss_ds_sigla  
  and bfm_nm_cidade = NomeMunicipio  
  
 where base.bfm_cd_transportadora = 61  
 and b.NomeDistrito IS NOT NULL  
 -- and base.bfm_cd_service_center = 'EBA14'  
  
  
union   
  
  
select  
  base.bfm_cd_base_frete_motorista  
 ,base.bfm_cd_transportadora  
 ,base.bfm_cd_service_center  
 ,base.bfm_nm_cidade  
 ,base.bfm_cd_tipo_veiculo  
 ,base.bfm_vl_inicio_faixa  
 ,base.bfm_vl_fim_faixa  
 ,base.bfm_vl_frete  
 ,base.bfm_vl_frete_pm  
 ,base.bfm_vl_frete_fixo  
 ,base.bmf_cd_tipo_contrato  
 ,base.bfm_cd_codigo_cliente  
 ,base.bfm_vl_domfer_am  
 ,base.bfm_vl_domfer_pm  
 ,base.bfm_data_inicio_vigencia  
 ,base.bfm_data_fim_vigencia  
 ,base.bfm_nm_regiao  
 ,base.bfm_cd_operacao  
 ,lista.lst_ds_valor Operacao  
  
from  
 tb_fin_base_frete_motorista base with(nolock)  
 join tb_lista lista with(nolock) on base.bfm_cd_operacao = lista.lst_cd_lista  
   
where base.bfm_cd_transportadora <> 61  
  
  
  
  
GO
