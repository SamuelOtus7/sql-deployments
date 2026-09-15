-- ============================================================
-- BASELINE: dbo.vw_tb_apontamento_geo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_tb_apontamento_geo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_tb_apontamento_geo]
as
select
	*,
	--case when dateadd(hour,-3,apg_dh_apontamento) > apg_dh_Escrita then 
	--	case when datediff(minute, apg_dh_Escrita, dateadd(hour,-3,apg_dh_apontamento)) > 70 then
	--		cast(apg_dh_Escrita as date)
	--	else null end
	--else
	--	dateadd(hour,-3,apg_dh_apontamento) 
	--end DataHoraReferencia
	dateadd(hour,-3,apg_dh_apontamento) as DataHoraReferencia
from
	tb_apontamento_geo with(nolock)
where datediff(minute, apg_dh_Escrita, dateadd(hour,-3,apg_dh_apontamento)) >= -60
/*where 
	case when dateadd(hour,-3,apg_dh_apontamento) > apg_dh_Escrita then 
		case when datediff(minute, apg_dh_Escrita, dateadd(hour,-3,apg_dh_apontamento)) > 70 then
			cast(apg_dh_Escrita as date)
		else null end
	else
		dateadd(hour,-3,apg_dh_apontamento) 
	end is not null
*/
GO
