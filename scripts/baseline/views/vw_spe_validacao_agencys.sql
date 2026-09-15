-- ============================================================
-- BASELINE: dbo.vw_spe_validacao_agencys
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_validacao_agencys]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_spe_validacao_agencys]

as
select json.agency,
	   isnull(clientes.cli_ds_nome,'Não cadastrado') as Cliente,
	   count(*) as Qtde, 
	   min(createdAt) as Primeiro, 
	   max(createdAt) as Ultimo
from db_Irisys_Json.dbo.tb_spe_webhook as webhook
	cross apply (
		select *
		from openjson (jsondata)
		with(
			agency varchar(150) '$.data.agency_id' 
		)
	) as json
	left join tb_clientes as clientes 
	on json.agency = clientes.cli_agency_shpee
where createdAt >= dateadd(day,-15,cast(getdate() as date))
	  and json.agency is not null
group by isnull(clientes.cli_ds_nome,'Não cadastrado'),
	     json.agency
GO
