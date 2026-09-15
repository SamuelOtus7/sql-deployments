-- ============================================================
-- BASELINE: dbo.vw_pnr
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pnr]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_pnr]  
as  
select  
	 pnr.IdTransportadora
	 ,pacote.IdRota
	 ,r.NomeMotorista
	 ,pnr.IdReclamacao  
	 ,pnr.Quinzena  
	 ,pnr.DataReclamacao  
	 ,pnr.Motorista  
	 ,pnr.ServiceCenter  
	 ,pnr.IdPacote  
	 ,pnr.Valor  
	 ,isnull(tra.tds_ds_traducao,pnr.Status) Status  
	 ,dateadd(hour, -3, pnr.DataColeta) as DataColeta  
from tb_ml_pnr pnr with(nolock)  
left join tb_ml_traducoes tra with(nolock) 
on pnr.Status = tra.tds_vl_json 
and tra.tds_nm_tabela = 'tb_ml_pnr' 
and tra.tds_nm_campo = 'Status' 
join (
	select IdPacote,max(IdRota) as IdRota
	from tb_ml_pacotes 
	where Excluido = 0
	group by IdPacote

	)as pacote
on pnr.IdPacote  = pacote.IdPacote
join tb_ml_rotas as r
on pacote.IdRota = r.IdRota
and r.StatusRota <> 'planned'
and r.Excluido = 0
GO
