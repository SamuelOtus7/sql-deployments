-- ============================================================
-- BASELINE: dbo.vw_sdr_irs_espelhos_pagamentos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_sdr_irs_espelhos_pagamentos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_sdr_irs_espelhos_pagamentos] as   
  
select    
mtn_cod_cliente  TenantId
,lst_ds_valor  
,cast(mtn_dh_criacao as date) DataCriacaoEspelho  
,sum(case when mtn_ds_link_nfs is not null then 1 else 0 end ) NFEmitida  
,sum(case when mtn_ds_link_nfs is null then 1 else 0 end ) NFNaoEmitida  
,count(*) QtdEspelhos  
from tb_pag_espelhos as a  
inner join tb_lista as b  
on lst_cd_lista = mtn_cd_status  
  
group by mtn_cod_cliente  
,lst_ds_valor  
,cast(mtn_dh_criacao as date)
GO
