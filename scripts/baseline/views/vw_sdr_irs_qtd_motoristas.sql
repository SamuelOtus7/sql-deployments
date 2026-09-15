-- ============================================================
-- BASELINE: dbo.vw_sdr_irs_qtd_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_sdr_irs_qtd_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_sdr_irs_qtd_motoristas] as

select
	
	 a.cli_cd_codigo_cliente TenantId
	,case when usr_in_ativo = 1 then 'Ativo' else 'inativo' end as usr_in_ativo
	,Isnull(usr_in_motorista,0) as usr_in_motorista
	,count(*) Qtd

from tb_usuario as a
inner join tb_clientes as b
on a.cli_cd_codigo_cliente = b.cli_cd_codigo_cliente
where a.cli_cd_codigo_cliente <> 7
and cli_in_ativo = 1
group by 
 a.cli_cd_codigo_cliente
	,case when usr_in_ativo = 1 then 'Ativo' else 'inativo' end
	,Isnull(usr_in_motorista,0) 
	
GO
