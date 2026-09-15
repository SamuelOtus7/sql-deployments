-- ============================================================
-- BASELINE: dbo.vw_fila_validacao_gr
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fila_validacao_gr]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_fila_validacao_gr] 
as
select grv_cd_cliente as CodigoCliente,
	   1 as Servico, --Tecnorisk    
	   grv_nr_ficha as IdFicha
from tb_gr_fichas
where grv_dh_processamento <= cast(getdate() as date)
	  or (
			grv_ds_resultado = 'Em análise'
			and grv_dh_processamento <= dateadd(hour,-1,getdate())
		 )
GO
