-- ============================================================
-- BASELINE: dbo.vw_fin_base_frete_motorista_distritos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_base_frete_motorista_distritos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[vw_fin_base_frete_motorista_distritos] as 

select  
    
    base.bfm_cd_base_frete_motorista
   ,base.bfm_cd_transportadora
   ,base.bfm_cd_service_center
   ,CidadeBase as bfm_nm_cidade
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
   ,base.ValidFrom
   ,base.ValidTo
   ,base.bfm_cd_pagar_por_pacotes
   ,base.bfm_vl_frete_sd
   ,base.bfm_pag_pacote_entregues
   ,base.bfm_cd_criterio_pagamento
   ,base.bfm_perc_minimo_endereco_nao_visitado
   ,base.bfm_zerar_ambulancia_nao_aprovada
   ,base.bfm_ds_placa
   ,l2.lst_ds_label CriterioFaixa
   ,base.bfm_vl_inicio_faixa2
   ,base.bfm_vl_fim_faixa2
   ,l3.lst_ds_label CriterioFaixa2
   ,base.bfm_vl_frete_ambulancia_am
   ,base.bfm_vl_frete_ambulancia_pm
   ,base.bfm_vl_frete_saca
 from  
  tb_fin_base_frete_motorista base with(nolock)  
  join tb_lista lista with(nolock) on base.bfm_cd_operacao = lista.lst_cd_lista  
  join (  

    SELECT 
       idcliente bss_cod_cliente  
      ,cid_cd_tipo_contrato bmf_cd_tipo_contrato
      ,base bss_ds_sigla  
      ,CidadeCalculo 
      ,CidadeBase 
  
    FROM vw_fin_cidade_DePara 
        
  ) as b  
  on bfm_cd_transportadora = bss_cod_cliente  
  and bfm_cd_service_center  = bss_ds_sigla  
  and bfm_nm_cidade = CidadeCalculo
  
  left join tb_lista l2 with(nolock) on base.bfm_cd_criterio_faixa = l2.lst_cd_lista  
  left join tb_lista l3 with(nolock) on base.bfm_cd_criterio_faixa2 = l3.lst_cd_lista  
  
 where 1=1 
 and CidadeBase <> base.bfm_nm_cidade
 and b.CidadeBase IS NOT NULL  
 --and base.bfm_cd_transportadora = 61  
 --and bfm_cd_service_center = 'eba19'
GO
