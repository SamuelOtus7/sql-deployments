-- ============================================================
-- BASELINE: dbo.fn_get_espelhos_integracao_nfse
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_espelhos_integracao_nfse]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE           function [dbo].[fn_get_espelhos_integracao_nfse]  
(  
 @topn int  
)  
  
returns table  
as return  

select espelhos.mtn_cd_status, mtn_cod_cliente as Tenant, nfse.enf_dh_processamento, espelhos.mtn_dh_envio_nfs,espelhos.mtn_cd_motorista_nfs as CodigoEspelho, espelhos.mtn_ds_link_nfs as UrlBlob, emp.emp_ds_cnpj as CNPJ, isnull(nfse.enf_qt_tentativas,0) Tentativas, espelhos.mtn_vl_nfs as ValorEspelho  
    --select count(*) as qtde  
from tb_pag_espelhos as espelhos  
 join tb_parametros as parametros   
 on espelhos.mtn_cod_cliente = parametros.prm_cod_cliente and parametros.prm_ds_chave = 'Integração NFSe Habilitada' and parametros.prm_ds_valor = 'true'  
 
left join tb_empresas emp on espelhos.mtn_cod_cliente = emp.emp_cd_codigo_cliente

 left join tb_pag_espelhos_nfse as nfse on espelhos.mtn_cd_motorista_nfs = nfse.enf_cd_espelho  
 --left join tb_pag_nfse_erros as erros on nfse.enf_ds_resultado = erros.pne_ds_erro  
where len(espelhos.mtn_ds_link_nfs) > 0   
   --and espelhos.mtn_dh_criacao >= '2026-05-20'  
   and cast(mtn_dh_envio_nfs as date)  >= '2026-08-17'
   and espelhos.mtn_vl_nfs <> 0  
   and mtn_cod_cliente <> 7
   --and nfse.enf_ds_link_xml is null
   --and espelhos.mtn_cd_status in(36,35)
   --and espelhos.mtn_cd_motorista_nfs in (1372203)
   

   
   AND (
   espelhos.mtn_ds_link_nfs_secundario IS NULL  
   or espelhos.mtn_ds_link_nfs_terceiro   IS NULL  
   or espelhos.mtn_ds_link_nfs_quarto     IS NULL
    )
    /*
    and (nfse.enf_dh_processamento is null or nfse.enf_dh_processamento <= espelhos.mtn_dh_envio_nfs) 
    and isnull(nfse.enf_qt_tentativas,0) < 5
    */
    and (
       nfse.enf_cd_espelho is null
       or espelhos.mtn_dh_envio_nfs > nfse.enf_dh_processamento
       or (nfse.enf_ds_resultado is not null and nfse.enf_ds_resultado like '%erro%')
    )

and isnull(nfse.enf_qt_tentativas,0) < 3
    --and mtn_cd_motorista_nfs = 1520384
 

 --1363237
GO
