-- ============================================================
-- BASELINE: dbo.vw_pgto_periodo_rota_alc
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_periodo_rota_alc]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_pgto_periodo_rota_alc] as

select 
	 ppr_data_referencia as data
	,ppr_ds_placa
	,ppr_nome_motorista as Motorista
	,ppr_cd_rota as Idrota
	,ppr_base_principal as svc
	,replace(ppr_cd_faixa_km,'/',' A ') FaixaKM
	,ppr_usou_app as UsouApp
	,ppr_ds_tipo_veiculo as Veiculo
	,ppr_ds_ciclo					ciclo	 
	,ppr_qt_pacotes					pacotes	
	,ppr_qt_pontos					pontos	
	,ppr_qt_paradas					paradas	
	,ppr_vl_base					valorbase	
	,ppr_vl_paradas					Valorparadas
	,ppr_vl_total_km_minimo			ValorMinimo	
	,ppr_vl_total_km_prefatura		ValorPrefatura
	,ppr_vl_bonus					bonus
	,ppr_vl_total					total

from tb_pgto_periodo_rota
where ppr_cd_periodo = 47
and  ppr_cd_rota = 155959014
--and ppr_base_principal = 'SSP4'
--and ppr_vl_paradas > 0
--order by 2,1

--select * from tb_fin_base_frete_adicional_motorista
--where bfa_cd_service_center = 'SSP4'
--and bfa_cd_transportadora = 1 

--select * from tb_dra_tipo_veiculo

--select * from tb_ml_rotas where idrota = 155959014

--select * from [dbo].[tb_fin_base_frete_motorista]
--where bfm_cd_transportadora = 1 
--and bfm_cd_service_center = 'SSP4'
--and bfm_cd_tipo_veiculo in (29)

--update tb_fin_base_frete_adicional_motorista
--set 
--bfa_vl_adicional_ciclo_pm = 0
--,bfa_cd_transportadora = 1
--where  bfa_cd_service_center = 'SSP4'
--and bfa_cd_tipo_veiculo in (29,4,28,19)
--and bfa_cd_transportadora = 1

--select 
--QuantidadePontos	
--,QuantidadeParadas
--,TotalPacotes	
--,PacotesEntregues	
--,PacotesPendentes	
--,PacotesNaoEntregue	
--,PacotesEntreguesForaAreaEntrega
--,PacotesTransferidos
--,Ambulancia
--,[QuantidadeParadas]-[QuantidadeAmbulancia]-[PacotesTransferidos]
--from vw_rotas where idrota = 155756028


--select *  from tb_clientes
GO
