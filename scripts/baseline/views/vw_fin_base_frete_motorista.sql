-- ============================================================
-- BASELINE: dbo.vw_fin_base_frete_motorista
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_base_frete_motorista]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  view [dbo].[vw_fin_base_frete_motorista]  
as  
  
select *

from (

	select 
		 bfm_cd_base_frete_motorista
		,bfm_cd_transportadora
		,bfm_cd_service_center
		,bfm_nm_cidade
		,bfm_cd_tipo_veiculo
		,bfm_vl_inicio_faixa
		,bfm_vl_fim_faixa
		,bfm_vl_frete
		,bfm_vl_frete_pm
		,bfm_vl_frete_fixo
		,bmf_cd_tipo_contrato
		,bfm_cd_codigo_cliente
		,bfm_vl_domfer_am
		,bfm_vl_domfer_pm
		,bfm_data_inicio_vigencia
		,bfm_data_fim_vigencia
		,bfm_nm_regiao
		,bfm_cd_operacao
		,ValidFrom
		,ValidTo
		,lista.lst_ds_valor Operacao  
		,bfm_cd_pagar_por_pacotes
		,bfm_vl_frete_sd
		,bfm_cd_criterio_pagamento
		,bfm_pag_pacote_entregues
		,lst_criterio.lst_ds_label CriterioPagamento
		,bfm_perc_minimo_endereco_nao_visitado
		,bfm_zerar_ambulancia_nao_aprovada
		,bfm_ds_placa
		,l2.lst_ds_label CriterioFaixa
		,a.bfm_vl_inicio_faixa2
		,a.bfm_vl_fim_faixa2
		,l3.lst_ds_label CriterioFaixa2
		,bfm_vl_frete_ambulancia_am
		,bfm_vl_frete_ambulancia_pm
		,bfm_vl_frete_saca
	from 
		TB_fin_base_frete_motorista as a
		join tb_lista lista with(nolock) on a.bfm_cd_operacao = lista.lst_cd_lista  
		left join tb_lista lst_criterio with(nolock) on a.bfm_cd_criterio_pagamento = lst_criterio.lst_cd_lista

		left join tb_lista l2 with(nolock) on a.bfm_cd_criterio_faixa = l2.lst_cd_lista  
		left join tb_lista l3 with(nolock) on a.bfm_cd_criterio_faixa2 = l3.lst_cd_lista

	where 1=1  
	--and bfm_cd_transportadora = 45
	--and bfm_cd_service_center = 'EAL2'
	--and bfm_data_fim_vigencia is null
	

) as a

where 1=1  
--	and bfm_cd_transportadora = 61
	-- and bfm_cd_service_center = 'EBA19'
	--and	 bfm_nm_cidade = 'Novo Acre'

union

select 
		 a.bfm_cd_base_frete_motorista
		,a.bfm_cd_transportadora
		,a.bfm_cd_service_center
		,a.bfm_nm_cidade
		,a.bfm_cd_tipo_veiculo
		,a.bfm_vl_inicio_faixa
		,a.bfm_vl_fim_faixa
		,a.bfm_vl_frete
		,a.bfm_vl_frete_pm
		,a.bfm_vl_frete_fixo
		,a.bmf_cd_tipo_contrato
		,a.bfm_cd_codigo_cliente
		,a.bfm_vl_domfer_am
		,a.bfm_vl_domfer_pm
		,a.bfm_data_inicio_vigencia
		,a.bfm_data_fim_vigencia
		,a.bfm_nm_regiao
		,a.bfm_cd_operacao
		,a.ValidFrom
		,a.ValidTo
		,lista.lst_ds_valor Operacao  
		,a.bfm_cd_pagar_por_pacotes
		,a.bfm_vl_frete_sd
		,a.bfm_cd_criterio_pagamento
		,a.bfm_pag_pacote_entregues
		,lst_criterio.lst_ds_label CriterioPagamento
		,a.bfm_perc_minimo_endereco_nao_visitado
		,a.bfm_zerar_ambulancia_nao_aprovada
		,a.bfm_ds_placa
		,a.CriterioFaixa
		,a.bfm_vl_inicio_faixa2
		,a.bfm_vl_fim_faixa2
		,a.CriterioFaixa2
		,a.bfm_vl_frete_ambulancia_am
		,a.bfm_vl_frete_ambulancia_pm
		,a.bfm_vl_frete_saca
from vw_fin_base_frete_motorista_distritos as a
left join tb_fin_base_frete_motorista as b
on  a.bfm_cd_transportadora =   b.bfm_cd_transportadora
and a.bfm_nm_cidade	 =			b.bfm_nm_cidade	
and a.bfm_cd_tipo_veiculo	 =  b.bfm_cd_tipo_veiculo	
and a.bfm_vl_inicio_faixa	 =  b.bfm_vl_inicio_faixa	
and a.bfm_vl_fim_faixa =		b.bfm_vl_fim_faixa

join tb_lista lista with(nolock) on a.bfm_cd_operacao = lista.lst_cd_lista  
left join tb_lista lst_criterio with(nolock) on a.bfm_cd_criterio_pagamento = lst_criterio.lst_cd_lista

where 1=1  
--and a.bfm_cd_transportadora = 61
--and a.bfm_cd_service_center = 'EBA19'
--and	 a.bfm_nm_cidade = 'Novo Acre'
and b.bfm_cd_service_center is null


--select * from tb_fin_base_frete_motorista where bfm_cd_base_frete_motorista in (94995,94992)
--select * from tb_fin_base_frete_motorista where bfm_cd_service_center = 'EBA19' and	 bfm_nm_cidade = 'Novo Acre'

--update tb_fin_base_frete_motorista 
--set bfm_data_inicio_vigencia = '2025-08-01'
--where bfm_cd_base_frete_motorista in (94993)

GO
