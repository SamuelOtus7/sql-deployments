-- ============================================================
-- BASELINE: dbo.vw_fin_cidade_DePara
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_cidade_DePara]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_fin_cidade_DePara] as   
  
select   
  a.Id  
 ,idcliente
 ,bss_ds_sigla as Base  
 ,ttc_nm_tipo as Contrato  
   
 ,uffilho.sigla as EstadoCalculo  
 ,cidpai.cid_ds_cidade as CidadeCalculo  
  
 ,ufpai.sigla   as EstadoBase  
 ,cidfilho.NomeDistrito as CidadeBase  
 ,cid_cd_usu_criacao  
 ,cid_dh_criacao  
 ,cid_cd_tipo_contrato
 
 
from tb_fin_Cidades_DePara AS a  
  
join [dbo].[tb_codigos_cidades] as cidpai  
on cid_cd_calculo_ibge = cidpai.cid_cd_cidade  
  
join tb_fin_distritos_cadastrados as cidfilho    
on  a.cid_cd_base_ibge = cidfilho.IdDistrito   
  
join [tb_estados_ibge] as ufpai    
on a.cid_cd_uf_calculo_ibge = ufpai.id  
  
join [tb_estados_ibge] as uffilho    
on a.cid_cd_uf_base_ibge = uffilho.id  
  
join tb_bases as base  
on bss_cd_base = cid_cd_base  
  
join tb_tipo_contrato  as ctt  
on a.cid_cd_tipo_contrato = ctt.ttc_cd_tipo_contrato  
  
GO
