-- ============================================================
-- BASELINE: dbo.vw_svc_pagamento
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_svc_pagamento]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_svc_pagamento]
as
select
	distinct 
	pgp_cd_cliente as TenantId
	,ppr_base_principal SVC 
from 
	tb_pgto_periodo_rota a with(nolock)
	inner join tb_pgto_periodo as b with(nolock) on a.ppr_cd_periodo = b.pgp_cd_periodo
where
	pgp_cd_status = 1
	and pgp_cd_periodo >= 370 
	and pgp_in_excluido = 0
GO
