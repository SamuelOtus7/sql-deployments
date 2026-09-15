-- ============================================================
-- BASELINE: dbo.fn_get_espelhos_integracao_nfse_hm
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_get_espelhos_integracao_nfse_hm]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   function [dbo].[fn_get_espelhos_integracao_nfse_hm]
(
	@topn int
)

returns table
as return

select top (@topn) espelhos.mtn_cd_motorista_nfs as CodigoEspelho, espelhos.mtn_ds_link_nfs as UrlBlob, empresas.emp_ds_cnpj as CNPJ
	   --select count(*) as qtde
from tb_pag_espelhos as espelhos
	join tb_parametros as parametros 
	on espelhos.mtn_cod_cliente = parametros.prm_cod_cliente and parametros.prm_ds_chave = 'Integração NFSe Habilitada' and parametros.prm_ds_valor = 'true'
	join tb_empresas as empresas on espelhos.mtn_cod_cliente = empresas.emp_cd_codigo_cliente --and empresas.emp_integracao_nfse = 1
	--left join tb_pag_espelhos_nfse as nfse on espelhos.mtn_cd_motorista_nfs = nfse.enf_cd_espelho
	--left join tb_pag_nfse_erros as erros on nfse.enf_ds_resultado = erros.pne_ds_erro
where len(espelhos.mtn_ds_link_nfs) > 0 
	  and espelhos.mtn_dh_criacao >= '2025-11-01'
	  and espelhos.mtn_cd_motorista_nfs = 769738 


GO
