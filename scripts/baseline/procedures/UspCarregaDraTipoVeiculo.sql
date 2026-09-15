-- ============================================================
-- BASELINE: dbo.UspCarregaDraTipoVeiculo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspCarregaDraTipoVeiculo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspCarregaDraTipoVeiculo] as 

insert into tb_dra_tipo_veiculo (tvl_nm_tipo_veiculo)
select tipoveiculo
from tb_ml_rotas			  as a with(nolock) 
left join tb_dra_tipo_veiculo as b with(nolock)
on a.tipoveiculo  = b.tvl_nm_tipo_veiculo

where tvl_nm_tipo_veiculo is null
and excluido = 0 
 and StatusRota <> 'planned'  
 and tipoveiculo <>  ''
 and tipoveiculo not in ('not found')

group by tipoveiculo

GO
