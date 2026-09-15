-- ============================================================
-- BASELINE: dbo.vw_periodos_pagamento
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_periodos_pagamento]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_periodos_pagamento]  
as  
select  
	pgp_cd_periodo  
	,pgp_cd_cliente  
	,pgp_nm_periodo  
	,pgp_dt_inicio  
from  
	tb_pgto_periodo with(nolock)  
where  
	pgp_cd_periodo >= 370   
	and pgp_in_excluido = 0
GO
